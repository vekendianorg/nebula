"""
bundle.py — Nebula packing tool
Embeds all src/ modules into a single VFS-based nebula_packed.lua.

Usage:
  python bundle.py              # normal pack
  python bundle.py -o out.lua   # custom output path
  python bundle.py -v 1.0.0     # inject version string
"""

import os
import re
import sys
import argparse
from datetime import datetime

SRC_DIR   = "src"
MAIN_FILE = os.path.join(SRC_DIR, "main.lua")
DEFAULT_OUTPUT = "nebula_packed.lua"


# ── Module collection ──────────────────────────────────────────────────────────

def collect_modules():
    """Walk src/ and return an OrderedDict-like list of (virtual_name, real_path)
    for every .lua file except main.lua."""
    modules = {}
    for root, dirs, files in os.walk(SRC_DIR):
        dirs[:] = sorted(d for d in dirs if not d.startswith("{"))
        for filename in sorted(files):
            if not filename.endswith(".lua"):
                continue
            real_path    = os.path.join(root, filename)
            virtual_name = os.path.relpath(real_path, SRC_DIR).replace(os.sep, "/")
            if virtual_name == "main.lua":
                continue
            modules[virtual_name] = real_path
    return modules


# ── main.lua loader block stripping ───────────────────────────────────────────

def strip_loader_block(lines):
    """Remove the encapsulated loader block from main.lua: from the
    'Encapsulated module loader' banner down to `local loadModule =
    ENV.loadModule`. The bundler replaces it with a VFS-backed prologue
    that provides the same ENV / loadModule locals to the inlined main
    body, so the main wiring runs unchanged and its own
    `Nebula = Nebula or {}` stays the single deliberate global write.

    Returns (cleaned_lines, diagnostic_string).
    """
    start_idx = None
    end_idx = None
    for i, line in enumerate(lines):
        s = line.strip()
        if s.startswith("-- Encapsulated module loader"):
            start_idx = i
        if start_idx is not None and s == "local loadModule = ENV.loadModule":
            end_idx = i
            break

    if start_idx is None or end_idx is None:
        return lines, "Warning: encapsulated loader block not found — skipping strip."

    # Swallow the --==== banner line above the block title too
    scan = start_idx - 1
    while scan >= 0 and lines[scan].strip() == "--==":
        scan -= 1
    strip_from = scan + 1

    diag = f"Stripped encapsulated loader block (lines {strip_from + 1}–{end_idx + 1})"
    del lines[strip_from : end_idx + 1]
    return lines, diag


# ── VFS loader (replaces the stripped native loader) ──────────────────────────

def lua_long_bracket(content):
    """Return content wrapped in a long-bracket literal whose level
    does not collide with any [=*=[ / ]=*=] sequence inside it."""
    level = 0
    while ("]" + "=" * level + "]") in content or ("[" + "=" * level + "[") in content:
        level += 1
    return "[" + "=" * level + "[" + content + "]" + "=" * level + "]"


def build_vfs_loader():
    """Encapsulated packed prologue. Same contract as main.lua's dev
    loader: private ENV, VFS-backed loadModule, embed-aware failure
    semantics, and exactly one global write (the `Nebula = Nebula or {}`
    inside the inlined main body)."""
    return """\
-- ── ENCAPSULATED VFS LOADER ─────────────────────────────────────────────
-- Same host-script contract as src/main.lua: everything private, the
-- only global write is the exported `Nebula` table (main body below).
local __vfs = {}          -- virtual path -> module SOURCE (compiled lazily)
local _moduleCache = {}

local ENV = setmetatable({
    scriptDir = gg.getFile():match("(.*/)") or "",
}, { __index = _G })

function ENV.loadModule(name, soft)
    local key = name:gsub("^%./", "")
    if not key:match("%.lua$") then key = key .. ".lua" end
    if _moduleCache[key] ~= nil then
        return _moduleCache[key]
    end
    local function fail(what, err)
        local n = ENV.Nebula
        if n and n.embed then
            error(what .. ": " .. tostring(err), 0)
        end
        gg.alert(what .. "\\n" .. tostring(err))
        os.exit()
        return nil -- unreachable in GG; keeps mock runners deterministic
    end
    local src = __vfs[key]
    if src then
        local chunk, err = load(src, key, "t", ENV)
        if chunk then
            -- Soft mode: run the module body guarded so a feature crash
            -- returns nil, err instead of propagating.
            if soft then
                local results = table.pack(pcall(chunk))
                if not results[1] then return nil, results[2] end
                _moduleCache[key] = table.unpack(results, 2, results.n)
                return _moduleCache[key]
            end
            _moduleCache[key] = chunk()
            return _moduleCache[key]
        end
        if soft then return nil, err end
        fail("Module load failed: " .. key, err)
    end
    -- VFS miss: fall back to disk relative to the script (dev overlay)
    local path = ENV.scriptDir .. name
    local chunk, err = loadfile(path, "t", ENV)
    if not chunk then
        if soft then return nil, err end
        fail("Module load failed: " .. name, err)
    end
    if soft then
        local results = table.pack(pcall(chunk))
        if not results[1] then return nil, results[2] end
        _moduleCache[key] = table.unpack(results, 2, results.n)
        return _moduleCache[key]
    end
    _moduleCache[key] = chunk()
    return _moduleCache[key]
end

local loadModule = ENV.loadModule

"""


# ── Main bundler ───────────────────────────────────────────────────────────────

def bundle(output_file, version=None):
    if not os.path.exists(MAIN_FILE):
        print(f"[-] Entry point not found: {MAIN_FILE}")
        print("    Run this script from the project root (folder containing 'src/').")
        sys.exit(1)

    modules = collect_modules()
    parts   = [
        f"-- Packed by bundle.py  •  {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n",
        "-- Do not edit — regenerate with:  python bundle.py\n\n",
        build_vfs_loader(),
    ]

    total_src_bytes = 0

    for virtual_name, real_path in modules.items():
        if not os.path.exists(real_path):
            print(f"[-] Skipped (missing): {real_path}")
            continue
        with open(real_path, encoding="utf-8") as f:
            content = f.read()
        total_src_bytes += len(content.encode("utf-8"))
        sz = len(content.encode("utf-8"))
        print(f"[+] {virtual_name:<45}  {sz:>7,} B")
        parts.append(f"__vfs['{virtual_name}'] = " + lua_long_bracket(content) + "\n")

    # Process main.lua
    with open(MAIN_FILE, encoding="utf-8") as f:
        lines = f.readlines()

    lines, diag = strip_loader_block(lines)
    print(f"[~] {diag}")

    main_src = "".join(lines)

    # ── Version Injection ─────────────────────────────────────────────────────
    if version:
        main_src, n = re.subn(
            r'Nebula\.VERSION\s*=\s*"[^"]*"',
            f'Nebula.VERSION = "{version}"',
            main_src
        )
        if n == 0:
            print("[-] Warning: Nebula.VERSION not found — version not injected")
        else:
            print(f"[~] Version injected: v{version}")

    total_src_bytes += len(main_src.encode("utf-8"))

    parts.append("\n-- ── MAIN ENTRYPOINT ──────────────────────────────────────────────────────\n\n")
    parts.append(main_src)

    output = "\n".join(parts)
    out_bytes = output.encode("utf-8")

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(output)

    # ── Stats ─────────────────────────────────────────────────────────────────
    line_count = output.count("\n")
    tag        = ""

    print()
    print(f"[OK] Output  ->  '{output_file}'{tag}")
    print(f"    Modules :  {len(modules)}")
    print(f"    Lines   :  {line_count:,}")
    print(f"    Size    :  {len(out_bytes):,} B  ({len(out_bytes)/1024:.1f} KB)")


# ── Entry point ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Pack Nebula src/ modules into a single Lua file.")
    parser.add_argument(
        "-o", "--output",
        default=DEFAULT_OUTPUT,
        metavar="FILE",
        help=f"Output file path (default: {DEFAULT_OUTPUT})")
    parser.add_argument(
        "-v", "--version",
        default=None,
        metavar="VERSION",
        help="Inject the version into Nebula.VERSION in the packed output")
        
    args = parser.parse_args()

    bundle(output_file=args.output, version=args.version)
