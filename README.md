# Nebula

A metadata-driven memory SDK for HCR2 (Hill Climb Racing 2), built for
GameGuardian's Lua environment.

Instead of writing raw `gg.getValues`/`gg.setValues` calls scattered
across scripts, Nebula gives you a typed, declarative API:

```lua
Nebula.GameStatus.get("coins")
Nebula.GameStatus.set("coins", 999)
```

The low-level memory work — pointer chasing, string encoding,
anti-cheat checksum handling — is hidden behind a small set of
reusable type modules, driven entirely by metadata tables.

## Philosophy

- ✅ Open source
- ✅ Compatibility first
- ✅ Pure Lua + GG API (no LuaJava)
- ✅ Headless (no UI)
- ✅ Metadata-driven
- ✅ SDK, not a cheat script

## Status

Early / actively in development. Base address resolution, four
scalar types, and one message (`GameStatus`) are working and tested
against a live game. Nested message (`Object`) and array
(`repeated`) support are planned but not yet implemented.

## Project structure

```
Nebula
├── main.lua                    -- entry point / dev-mode module loader
├── bundle.py                   -- packs src/ into a single distributable .lua
│
├── api/
│   └── GameStatus.lua          -- public get() / set() / meta() surface
│
├── core/
│   ├── Memory.lua               -- gg.getValues/setValues wrapper + base resolution
│   ├── Type.lua                 -- type registry (name -> get/set implementation)
│   └── types/
│       ├── Int32.lua
│       ├── Bool.lua
│       ├── Float.lua
│       ├── String.lua
│       └── SafeInt32.lua
│
└── metadata/
    └── GameStatus.lua           -- field table: offsets, types, per field
```

## How it fits together

1. **`metadata/GameStatus.lua`** declares every known field on the
   `GameStatus` struct: its byte offset, whether it's a repeated
   field, and which type module reads/writes it.
2. **`core/Type.lua`** is a registry mapping a type name (`"Int32"`,
   `"String"`, ...) to the module implementing `get(base, field)` /
   `set(base, field, value)` for it.
3. **`core/Memory.lua`** is the only file that talks to `gg.*`
   directly — every read/write in Nebula goes through it. It also
   owns the (expensive) signature scan that locates the live
   `GameStatus` struct in memory.
4. **`api/GameStatus.lua`** ties it together: looks up a field in
   metadata, resolves (and caches) the struct base address, and
   dispatches to the right type module.

Adding a new field is a metadata edit. Adding a new type is a new
file in `core/types/`. Neither requires touching the public API.

## Usage

```lua
local Nebula = loadModule("nebula.lua") -- or however your loader wires it in

-- Read
local coins = Nebula.GameStatus.get("coins")

-- Write
Nebula.GameStatus.set("coins", 999)

-- Dangerous fields require an explicit :force()
Nebula.GameStatus.set("cheater", true):force()

-- Validate without touching memory
Nebula.GameStatus.set("coins", 999):dry()

-- Introspect a field without reading its value
local meta = Nebula.GameStatus.meta("coins")
print(meta.name, meta.type, meta.offset, meta.risk, meta.known)
```

`set()` executes immediately by default — the returned object is
only needed if you want to call `:force()` (bypass the dangerous-field
guard) or `:dry()` (validate everything except the actual memory
write) explicitly.

## Memory flags

GG value-type flags used throughout Nebula (`core/Memory.lua`
`M.FLAGS`):

| Flag | Value | Meaning |
|------|-------|---------|
| `BYTE`   | 1  | single byte |
| `WORD`   | 2  | 2 bytes |
| `INT32`  | 4  | 4-byte signed int |
| `XOR`    | 8  | reserved, unused |
| `FLOAT`  | 16 | 4-byte IEEE-754 float |
| `INT64`  | 32 | 8-byte int / pointer |
| `DOUBLE` | 64 | 8-byte IEEE-754 double |

## Type modules

| Type | Layout |
|------|--------|
| `Int32` | direct 4-byte signed int at `base + offset` |
| `Bool` | single byte at `base + offset`, `0x00`/`0x01` |
| `Float` | direct 4-byte float at `base + offset` |
| `String` | pointer at `base + offset`; two on-disk encodings (see below) |
| `SafeInt32` | pointer at `base + offset` to an anti-cheat-protected int struct |

### String encoding

Strings use one of two layouts depending on length, auto-detected
on read and auto-selected on write:

**Inline** (fits in 6 dwords / 24 bytes, length byte included):
```
ptr + 0x0   length byte (byteCount * 2)
ptr + 0x1.. raw chars
```

**Long / indirected** (used once inline would overflow):
```
ptr + 0x0   header, expected in range [9, 99]
ptr + 0x4   must be 0
ptr + 0x8   length (raw char count, not multiplied)
ptr + 0xC   must be 0
ptr + 0x10  pointer to the actual char data
```

### SafeInt32

Fields of this type store a **pointer** at `base + offset`, not an
inline struct. The struct itself lives at that pointer:

```
structPtr + 0x18  safeValue
structPtr + 0x1C  key
structPtr + 0x20  checksum
structPtr + 0x24  keyChecksum
```

Values are XOR-encoded against a single account-wide static key
(`GameStatus.safeIntStaticKey`, offset `0x6AC`), resolved internally
— individual fields don't declare it.

## Base address resolution

`Memory.resolveGameStatusBase()` locates the live `GameStatus`
struct by:

1. Searching each memory region (`gg.REGION_C_ALLOC`, then
   `gg.REGION_OTHER`) for the `"startup_count"` string constant.
2. For each hit, reading a pointer at `hit + 0x1F` and sanity-checking
   it's in a plausible address range (rules out AOB false-positives
   landing inside unrelated string literals).
3. Validating a vtable/version marker at `ptr + 0x10` against a
   known set of values.
4. Reading a second pointer at `ptr + 0x80` — this is the resolved
   struct base.

`api/GameStatus.lua` caches the result for the lifetime of the
script session; the scan only runs once unless explicitly forced.

## Dangerous fields

Some fields are gated behind `:force()` to prevent accidental writes
(currently just `cheater`). Calling `set()` on a dangerous field
without `:force()` fails with `dangerous_field_requires_force`.

## Packing for release

```
python bundle.py                 # pack src/ -> void_packed.lua equivalent
python bundle.py -m              # + strip comments / minify
python bundle.py -o out.lua      # custom output path
python bundle.py -v 1.0.0        # inject version string
```

The bundler walks `src/`, embeds every module into a `__vfs` table,
strips `main.lua`'s native loader block, and replaces it with a
VFS-aware `loadModule()` — so the exact same `loadModule("core/...")`
calls used in dev mode keep working unchanged in the packed output.

## Roadmap

- [ ] `core/types/Object.lua` — nested message support
      (`metadata/<MessageName>.lua` per message, offsets relative to
      the sub-struct's own base pointer)
- [ ] Repeated/array field support
      (`ptr+0x0` backing array, `+0x8` size, `+0xC` capacity)
- [ ] Fill in remaining unknown offsets (`0xBAAD` placeholders) in
      `metadata/GameStatus.lua`
- [ ] Additional modules beyond `GameStatus`: `Vehicle`, `Garage`,
      `TeamEvent`, ...