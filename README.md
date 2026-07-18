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
anti-cheat checksum handling, array containers — is hidden behind a
small set of reusable type modules, driven entirely by metadata
tables.

## Philosophy

- Open source
- Compatibility first
- Pure Lua + GG API (no LuaJava)
- Headless (no UI)
- Metadata-driven

## Status

Actively in development. Base address resolution, scalar types,
bitmasks, repeated/array fields, and one message type (`Achievement`)
are working and tested against a live game. Nested single-message
(`Object`) support is still a placeholder.

---

## Install

Nebula can be loaded two ways: from a **local** copy of the packed
file on your device, or fetched fresh over the network from **cloud**
(GitHub) every time the script runs. Both end with the same thing —
a `Nebula` global with `Nebula.GameStatus` on it.

### Local

1. Grab a packed build (see [Packing for release](#packing-for-release)
   below) — either build one yourself or download a prebuilt one from
   the repo's `build/` folder.
2. Put the `.lua` file anywhere on your device GG can read, e.g.
   `/storage/sdcard0/#Vekendian/nebula/build/nebula-0.0.1.lua`.
3. Load it from your script:

```lua
local Nebula = dofile("/storage/sdcard0/#Vekendian/nebula/build/nebula-0.0.1.lua") -- or whatever how you load another Lua

Nebula.GameStatus.get("coins")
```

Local loading needs no network access and survives GG restarts — the
tradeoff is you're responsible for re-downloading a new packed build
yourself whenever Nebula updates.

### Cloud

GG's `gg.makeRequest` can fetch a URL's contents directly into a
string, which `load()` can then compile and execute.

```lua
local Nebula = load(gg.makeRequest("https://raw.githubusercontent.com/vekendianorg/nebula/refs/heads/main/build/nebula-0.0.1").content)()

Nebula.GameStatus.get("coins")
```

Cloud loading always pulls the exact bytes at that URL, so pin to a
specific tagged build path (like `nebula-0.0.1` above) rather than a
`main`-tracking "latest" file if you want reproducible behavior —
swap the version segment in the URL when you want to move to a newer
release. The tradeoff versus local is an extra network round-trip on
every script run, and the script silently breaking if the URL ever
goes away or GitHub is unreachable.

---

## Project structure

```
Nebula
├── main.lua                    -- entry point / dev-mode module loader
├── bundle.py                   -- packs src/ into a single distributable .lua
│
├── api/
│   └── GameStatus.lua          -- public get/set/has/add/sub/meta surface
│
├── core/
│   ├── Memory.lua               -- gg.getValues/setValues wrapper, base resolution, verbose timing
│   ├── Type.lua                 -- type registry (name -> get/set implementation)
│   ├── Repeated.lua              -- repeated/array field container walker
│   └── types/
│       ├── Int32.lua
│       ├── Bool.lua
│       ├── Float.lua
│       ├── String.lua
│       ├── SafeInt32.lua
│       ├── BitMask.lua
│       └── Achievement.lua       -- example named message type
│
└── metadata/
    ├── GameStatus.lua            -- field table: offsets, types, per field
    └── enums/
        └── GameStatusFlag.lua    -- bit name -> value map for the `flags` field
```

## How it fits together

1. **`metadata/GameStatus.lua`** declares every known field on the
   `GameStatus` struct: its byte offset, whether it's a repeated
   field, and which type it is.
2. **`core/Type.lua`** is a registry mapping a type name (`"Int32"`,
   `"String"`, `"Achievement"`, ...) to the module implementing
   `get(base, field)` / `set(base, field, value)` for it.
3. **`core/Memory.lua`** is the only file that talks to `gg.*`
   directly — every read/write in Nebula goes through it. It also
   owns the (expensive) signature scan that locates the live
   `GameStatus` struct in memory, and optional verbose per-call
   timing (see [Verbose logging](#verbose-logging)).
4. **`core/Repeated.lua`** walks array/repeated-field containers,
   dispatching each element to its declared element type
   (`field.type`) rather than being a type itself — `api/GameStatus.lua`
   calls it directly whenever `field.repeated == true`.
5. **`api/GameStatus.lua`** ties it together: looks up a field in
   metadata, resolves (and caches) the struct base address, and
   dispatches to the right type module or to `Repeated`.

Adding a new field is a metadata edit. Adding a new scalar or message
type is a new file in `core/types/`. Neither requires touching the
public API.

---

## Usage

```lua
-- Read
local coins = Nebula.GameStatus.get("coins")

-- Write
Nebula.GameStatus.set("coins", 999)

-- Dangerous fields require an explicit :force()
Nebula.GameStatus.set("cheater", true):force()

-- Validate without touching memory
Nebula.GameStatus.set("coins", 999):dry()

-- Cheap existence check, no full decode
Nebula.GameStatus.has("device")

-- Numeric read-modify-write shortcuts (same :force()/:dry() chain as set())
Nebula.GameStatus.add("coins", 1000)
Nebula.GameStatus.sub("coins", 500)
Nebula.GameStatus.add("coins", 1000):dry()

-- Introspect a field without reading its value
local meta = Nebula.GameStatus.meta("coins")
print(meta.name, meta.type, meta.offset, meta.risk, meta.known)

-- BitMask fields decode into a boxed value with its own methods
local flags = Nebula.GameStatus.get("flags")
flags:has("DebuggerDetected")
flags:enable("IsPitCrew")
flags:disable("MemoryHacker")
Nebula.GameStatus.set("flags", flags)

-- Repeated fields return a plain Lua array of decoded elements
local achievements = Nebula.GameStatus.get("achievements")
for i, achievement in ipairs(achievements) do
    print(achievement.id, achievement.unlocked, achievement.steps)
end
```

`set()`, `add()`, and `sub()` all execute immediately by default —
the returned object is only needed if you want to call `:force()`
(bypass the dangerous-field guard) or `:dry()` (validate everything
except the actual memory write) explicitly.

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
| `BitMask` | direct 4-byte int at `base + offset`, boxed with `:has()`/`:enable()`/`:disable()`/`:toggle()` |
| `Achievement` | pointer to a struct (`id`/`unlocked`/`steps`); example of a named message type |

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

### BitMask

Fields of this type are a plain 4-byte int at `base + offset`, but
`get()` returns a boxed instance instead of a raw number:

```lua
local flags = Nebula.GameStatus.get("flags")
flags:has("DebuggerDetected")   -- bit membership check
flags:enable("IsPitCrew")       -- set a bit
flags:disable("MemoryHacker")   -- clear a bit
flags:toggle("SomeFlag")        -- flip a bit
Nebula.GameStatus.set("flags", flags)  -- accepts the boxed instance or a raw int
```

The bit-name-to-value mapping comes from `field.enum` in metadata,
pointing at a file under `metadata/enums/` (e.g. `GameStatusFlag.lua`).

`meta("flags").flags` also decodes the live value into a plain
`{ FlagName = true/false, ... }` table for quick introspection,
separate from the boxed value's own `:has()`.

### Repeated / array fields

A field with `repeated = true` is a container, walked by
`core/Repeated.lua` rather than a type module directly:

```
base + field.offset = ptr        -- this address IS the container header

ptr + 0x0   arrayPtr   (int64, pointer to backing array)
ptr + 0x8   size       (int32, live element count)
ptr + 0xC   capacity   (int32, allocated slot count)
ptr + 0x10  allocSlots (int32, next-pow2 of size — derived, not authoritative)
```

Element slots sit 8 bytes apart starting at `arrayPtr`. For
message/custom element types (anything that isn't a known inline
scalar), each slot holds a **pointer** to the element's own struct.

`size`/`capacity` are sanity-bounded before being trusted (rejected
if negative, over a fixed ceiling, or `size > capacity`) — a
misread/garbage header fails cleanly with a descriptive error instead
of driving a runaway loop or table allocation.

`Repeated.get()` batches aggressively: message types can optionally
implement `M.specs(base)` / `M.parse(results)` (see `Achievement.lua`)
to describe their field reads without doing I/O, letting `Repeated`
collect every element's reads into one cross-element `gg.getValues`
call instead of one call per element. Types without this interface
fall back to a plain per-element `get()`.

`Repeated.set()` only ever writes into existing slots and never grows
the backing array or allocates new element structs — Nebula doesn't
own the game's allocator, so a write larger than `capacity` fails
cleanly with `capacity_exceeded` rather than attempting anything
unsafe.

---

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

---

## Dangerous fields

Some fields are gated behind `:force()` to prevent accidental writes
(currently just `cheater`). Calling `set()`, `add()`, or `sub()` on a
dangerous field without `:force()` fails with
`dangerous_field_requires_force`.

---

## Verbose logging

Two independent, opt-in logging switches:

```lua
Nebula.log = true      -- api/GameStatus.lua: high-level get/set/has/add/sub/dry logging
Nebula.verbose = true  -- core/Memory.lua: per-call gg.getValues/setValues timing
```

`Nebula.verbose` is useful for tracking down slowness — it prints the
call kind, batch size, and elapsed time for every single `gg.*`
round-trip, e.g.:

```
[Nebula.Memory] readBatch    count=36   4.00ms
```

Both default to `false`; `main.lua`'s field-test loop leaves them off
unless you flip them on for debugging.

---

## Packing for release

```
python bundle.py                 # pack src/ -> build/nebula-<version>.lua equivalent
python bundle.py -m              # + strip comments / minify
python bundle.py -o out.lua      # custom output path
python bundle.py -v 1.0.0        # inject version string
```

The bundler walks `src/`, embeds every module into a `__vfs` table,
strips `main.lua`'s native loader block, and replaces it with a
VFS-aware `loadModule()` — so the exact same `loadModule("core/...")`
calls used in dev mode keep working unchanged in the packed output.
This is what makes both [local](#local) and [cloud](#cloud) loading
work from a single distributable file with no directory structure
required at runtime.

---

## Roadmap

- [ ] `core/types/Object.lua` — nested single-message support
      (`metadata/<MessageName>.lua` per message, offsets relative to
      the sub-struct's own base pointer)
- [ ] Fill in remaining unknown offsets (`0xBAAD` placeholders) in
      `metadata/GameStatus.lua`
- [ ] Additional message types beyond `Achievement`
      (`DriverCustomization`, `RewardManagerStatus`, `VipStatus`,
      `CommunityEvent`, ...)
- [ ] Additional modules beyond `GameStatus`: `Vehicle`, `Garage`,
      `TeamEvent`, ...
