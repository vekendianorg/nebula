# Nebula

A metadata-driven memory SDK for HCR2 (Hill Climb Racing 2), built for
GameGuardian's Lua environment.

Instead of writing raw `gg.getValues`/`gg.setValues` calls scattered
across scripts, Nebula gives you a typed, declarative API:

```lua
Nebula.PlayerInfo.get("gameStatus.coins")
Nebula.PlayerInfo.set("gameStatus.coins", 999)
```

The low-level memory work, pointer chasing, string encoding,
anti-cheat checksum handling, array containers, is hidden behind a
small set of reusable type modules, driven entirely by metadata
tables.

## Philosophy

- Open source
- Compatibility first
- Pure Lua + GG API (no LuaJava)
- Headless (no UI)
- Metadata-driven
- A guest in your script, Nebula loads into your host script
  without touching your globals (see
  [Embedding](#embedding-nebula-in-your-own-script))

## Status

**v1.0.0.** Base address resolution, scalar types, bitmasks,
repeated/array fields, nested objects, inline struct arrays, and four
API surfaces (`PlayerInfo`, `GameData`, `PublicEvent`, `TeamEvent`,
`CommunityEvent`) are working and tested. The `lootDefinition`
sub-struct with all 14 nested array fields is fully readable,
including object arrays with inline C++ struct elements. Chest type
enums (Int32 ↔ string) are handled bidirectionally for both get and
set. Metadata is shipped as complete snapshots for game versions
**1.73** and **1.74** (107 struct files and 752 enum tables per
version). All of it is enforced by a 300-check spec suite covering
the API, the array/trace machinery, and the host-script
encapsulation contract.

---

## Quickstart

```lua
-- 1. Load the SDK (packed build, see Install for both variants)
local Nebula = dofile("/sdcard/nebula/nebula-1.0.0")

-- 2. Read and write player save data through PlayerInfo
local coins = Nebula.PlayerInfo.get("gameStatus.coins")
Nebula.PlayerInfo.set("gameStatus.playerName", "Hillbilly")

-- 3. Validate the write actually landed in memory
Nebula.PlayerInfo.set("gameStatus.coins", 999):verify()
```

That's the whole mental model: **every field is a dotted path**,
resolved against versioned struct metadata, read and written through
one memory layer. `gameStatus.*` paths reach the player's save
(PlayerInfo's child struct); plain paths like `startupCount` or
`sceneName` read PlayerInfo's own fields.

---

## Install

Nebula can be loaded two ways: from a **local** copy of the packed
file on your device, or fetched fresh over the network from **cloud**
(GitHub) every time the script runs. Both end with the same thing -
a `Nebula` table with every API surface wired onto it.

### Local

1. Grab a packed build (see [Packing for release](#packing-for-release)):
   either build one yourself with `python bundle.py -o
   build/nebula-1.0.0`, or download a prebuilt one from the repo's
   `build/` folder.
2. Put it anywhere on your device GG can read, e.g.
   `/storage/sdcard0/nebula/nebula-1.0.0`.
3. Load it from your script:

```lua
local Nebula = dofile("/storage/sdcard0/nebula/nebula-1.0.0")

Nebula.PlayerInfo.get("gameStatus.coins")
```

Note the release artifacts in `build/` carry **no `.lua` extension** -
just `nebula-1.0.0`. That's deliberate: `dofile()`/`loadfile()` don't
care about extensions, and the cloud fetch (below) serves the exact
same bytes, so local and cloud loading stay byte-identical. If the
missing extension bothers you or your file manager, pass an explicit
`-o build/nebula-1.0.0.lua` to the bundler, nothing about the
artifact changes otherwise.

Local loading needs no network access and survives GG restarts, the
tradeoff is you're responsible for re-downloading a new packed build
yourself whenever Nebula updates.

One note on `require()`: don't use it with a dotted file name. Lua
treats dots in a module name as directory separators, so
`require("nebula-1.0.0")` looks for `nebula-1/0/0.lua` and fails even
though the file is right there. Load the packed build with `dofile()`
(as above), or rename the artifact without dots, e.g.
`nebula_1_0_0.lua`, if you prefer `require()`. Also remember
`require()` caches modules in `package.loaded`: a re-require in the
same session returns the stale first load, which is why `dofile()` is
the recommended pattern for a per-session SDK.

### Cloud

GG's `gg.makeRequest` can fetch a URL's contents directly into a
string, which `load()` can then compile and execute.

```lua
local Nebula = load(gg.makeRequest("https://raw.githubusercontent.com/vekendianorg/nebula/refs/heads/main/build/nebula-1.0.0").content)()

Nebula.PlayerInfo.get("gameStatus.coins")
```

Cloud loading always pulls the exact bytes at that URL, so pin to a
specific tagged build path (like `nebula-1.0.0` above) rather than a
`main`-tracking "latest" file if you want reproducible behavior -
swap the version segment in the URL when you want to move to a newer
release. The tradeoff versus local is an extra network round-trip on
every script run, and the script silently breaking if the URL ever
goes away or GitHub is unreachable.

---

## Embedding Nebula in your own script

Nebula is designed to be a *guest* in the host script's
environment. Loading it will never clobber anything you own:

- **One global, deliberately.** The only global Nebula ever writes
  is the exported `Nebula` table. No `scriptDir`, no `loadModule`,
  no `__vfs`, your identically-named globals are neither read by
  modules nor overwritten.
- **Merge-tolerant export.** If a `Nebula` table already exists
  when you load the SDK, it is adopted as-is: your keys survive,
  the SDK only fills in its own reserved keys
  (`PlayerInfo`, `GameData`, `defineApi`, `PublicEvent`,
  `TeamEvent`, `CommunityEvent`, `Type`, `Memory`, `Cache`,
  `VERSION`).
- **Read-honored config.** The config keys `log`, `verbose`,
  `traceMem` (and `embed`, see below) are only set when absent -
  pre-set them before loading and your values win.
- **Private module environment.** Modules see your globals
  (`gg`, `print`, `io`, ...) read-only through a passthrough, but
  resolve `scriptDir` / `loadModule` / `Nebula` to the SDK's own
  private entries.
- **Catchable failures.** By default a module-load failure alerts
  the user and exits (the SDK cannot work without its modules).
  Set `embed = true` before loading to make failures raise a
  catchable Lua error instead of killing YOUR script.

Typical host script:

```lua
-- pre-configure + adopt the export
Nebula = { embed = true, log = true }

local chunk = loadfile("/sdcard/nebula/main.lua")
if not chunk then print("main.lua missing") return end
local ok, err = pcall(chunk)
if not ok then print("nebula failed: " .. tostring(err)) return end

-- fully wired, your environment untouched
Nebula.PlayerInfo.get("gameStatus.coins")
```

`src/test.lua` and `src/benchmark.lua` are written against this
contract, use them as templates. The contract is enforced by
`test/encapsulation_spec.lua`.

---

## Project structure

```
nebula
├── src/
│   ├── main.lua                -- entry point / encapsulated dev-mode module loader
│   ├── bundle.py               -- (repo root) packs src/ into a single distributable .lua
│   ├── test.lua                -- host-script usage example
│   ├── benchmark.lua            -- timing benchmark, also a host-script example
│   │
│   ├── api/                    -- one public surface per module
│   │   ├── PlayerInfo.lua      -- player save parent: get/set/fields/meta over
│   │   │                       --   dotted paths, incl. gameStatus.* children
│   │   ├── GameData.lua        -- global config singleton; same defineApi surface
│   │   ├── PublicEvent.lua     -- get/fields/meta surface; get() returns an event accessor
│   │   ├── TeamEvent.lua       -- same surface as PublicEvent; separate base resolution
│   │   └── CommunityEvent.lua  -- string-search resolution; vtable-marker validation
│   │
│   ├── core/                   -- the machinery under the API layer
│   │   ├── defineApi.lua       -- generic API-to-struct bridge every api/ module is built on
│   │   ├── Memory.lua          -- the ONLY file that talks to gg.*; base resolution, batch I/O
│   │   ├── Path.lua            -- dotted-path parser and resolver ("gameStatus.coins", "a[1].b")
│   │   ├── Field.lua           -- field metadata access helpers
│   │   ├── Type.lua            -- type registry (name -> get/set implementation)
│   │   ├── Repeated.lua        -- repeated/array field container walker
│   │   ├── Struct.lua          -- struct element reader/writer (nested templates)
│   │   ├── ZeroPage.lua        -- safe scratch-page allocator for array growth
│   │   ├── Trace.lua           -- per-operation tracing/log-line machinery
│   │   ├── Logfile.lua         -- nebula.log sink (crash-safe, line-flushed)
│   │   ├── Cache.lua           -- persistent address cache (survives restarts)
│   │   └── types/              -- one file per field type:
│   │       ├── Int32.lua / Int64.lua / Bool.lua / Float.lua
│   │       ├── String.lua      -- inline + indirected C++ std::string ABIs
│   │       ├── SafeInt.lua / SafeInt32.lua / JSONSafeInt.lua  -- anti-cheat protected ints
│   │       ├── BitMask.lua     -- boxed bit flags with :has()/:enable()/:disable()/:toggle()
│   │       ├── Enum.lua        -- Int32 <-> string enum (chest types, etc.)
│   │       ├── Color3B.lua / Vec2.lua             -- packed small structs
│   │       └── Object.lua / Array.lua             -- pointer-backed and typed-array elements
│   │
│   └── test/                   -- spec suite (plain Lua 5.4+ / lupa; see Testing)
│       ├── array_trace_spec.lua     -- 229 checks: containers, tracing, Logfile
│       ├── defineApi_spec.lua       -- 32 checks: API bridge, metadata resolution
│       └── encapsulation_spec.lua   -- 39 checks: host-script contract, packed artifact
│
├── metadata/                   -- versioned struct/enum snapshots (loaded via VFS in packed builds)
│   ├── manifest.lua            -- version resolver: running game version -> snapshot folder
│   ├── 1.73/                   -- complete snapshot for game 1.73.x
│   │   ├── structs/            -- 98 struct metadata files
│   │   └── enums/              -- 752 enum value tables
│   └── 1.74/                   -- complete snapshot for game 1.74.x
│       ├── structs/            -- 107 struct metadata files
│       └── enums/              -- 752 enum value tables
│
├── docs/                       -- documentation site (content/*.md -> docs.html)
└── build/                      -- packed release artifacts (nebula-<version>.lua)
```

## How it fits together

1. **`metadata/<version>/structs/PlayerInfo.lua`** declares every
   known field on the `PlayerInfo` struct: its byte offset, whether
   it's a repeated field, and which type it is. The right version
   folder is picked automatically from the running game's version by
   **`metadata/manifest.lua`**, e.g. a game running `1.74.2`
   resolves the `1.74` folder. A new snapshot file is only added
   when the struct's layout actually changes.
2. **`core/Type.lua`** is a registry mapping a type name (`"Int32"`,
   `"String"`, `"SafeInt32"`, ...) to the module implementing
   `get(base, field)` / `set(base, field, value)` for it.
3. **`core/Memory.lua`** is the only file that talks to `gg.*`
   directly, every read/write in Nebula goes through it. It also
   owns the (expensive) signature scan that locates the live
   `PlayerInfo` struct in memory, and optional verbose per-call
   timing (see [Logging](#logging)).
4. **`core/Path.lua`** parses the dotted field id, indexing
   (`vehicleStatus[1]`), child-struct descent (`gameStatus.coins`),
   and repeated-element paths, and resolves it to a concrete
   address plus field metadata.
5. **`core/Repeated.lua`** walks array/repeated-field containers,
   handling two container ABIs: protobuf `RepeatedField` (explicit
   size/capacity as INT32) and C++ `std::vector` (begin/end/capEnd
   pointers as INT64, size computed from pointer difference). The
   container type is selected via the `container` field shadow.
6. **`core/Struct.lua`** reads/writes struct elements using a
   metadata template. It handles nested objects (pointer-backed
   containers), namespace containers, leaf fields, and Array fields
  , batch-reading all array vector headers in a single
   `gg.getValues` call for performance. Empty arrays and zero-value
   scalars are suppressed from output for clean results.
7. **`core/defineApi.lua`** ties it together for every `api/`
   module: looks up a field in metadata, resolves (and caches) the
   struct base address, dispatches to the right type module or
   `Repeated`, and provides the shared `get` / `set` / `fields` /
   `meta` surface. `api/PlayerInfo.lua` and friends are thin
   configs around it.

Adding a new field is a metadata edit. Adding a new scalar or message
type is a new file in `core/types/` (plus a
`Nebula.Type.register(name, impl)` call). Neither requires touching
the public API.

### Versioned metadata

Struct metadata is versioned by game version, not hand-picked per
API call. `metadata/manifest.lua` resolves the running game's
two-component version (e.g. `1.74`, from a game running `1.74.2`)
to the closest version folder at or below it; if the game is older
than every known folder, the oldest one is used rather than failing.
Each version folder (`1.73`, `1.74`) is a COMPLETE snapshot, there
are no runtime diff/merge chains. To cut a new version, copy the
whole folder and edit only the structs/enums that actually changed.

Two loaders, one shared version step (`resolveCurrentVersion`):
- `M.load("PlayerInfo")` → `metadata/<version>/structs/PlayerInfo.lua`
- `M.loadEnum("ChestType")` → `metadata/<version>/enums/ChestType.lua`

Structures shared by several APIs keep a single snapshot:
`EventDefinition` is the one physical struct behind
`Nebula.PublicEvent`, `Nebula.TeamEvent` and
`Nebula.CommunityEvent`, bound via
`Nebula.defineApi({ struct = "EventDefinition", resolve = ... })`.
If the shared schema changes, update the snapshot once and all
three event APIs see the new fields. The API layer remains
separate: each event type has its own base-address resolver
(AOB scan or string search) while consuming the same metadata
schema.

### Per-element templates (`elements`)

A field typed `"Array"` can carry an `elements` sub-table
(`specialFeatures`, `eventRewards`) describing each array element's
own field layout. `core/Struct.lua` reads these templates
recursively, supporting nested `Object` containers (pointer-backed
sub-structs like `lootDefinition`), `Array` fields with `elements`
(struct arrays) or `elementType` + `elementStride` (simple typed
arrays), and leaf fields.

Two container ABIs are supported:
- **protobuf `RepeatedField`**: `{arrayPtr:INT64, size:INT32, capacity:INT32}`, used by GameStatus achievements
- **C++ `std::vector`**: `{begin:INT64, end:INT64, capEnd:INT64}`, size = `(end-begin)/stride`, used by PublicEvent/TeamEvent arrays

## Usage

### PlayerInfo

`PlayerInfo` is the parent object of the player's save data, the
struct the base scan actually lands on. The save itself
(`GameStatus`) is PlayerInfo's child struct (`mGameStatus` @0x148)
and every save field is reachable as a dotted path:

```lua
-- Read
local coins = Nebula.PlayerInfo.get("gameStatus.coins")
local name  = Nebula.PlayerInfo.get("gameStatus.playerName")

-- PlayerInfo's own fields
Nebula.PlayerInfo.get("startupCount")
Nebula.PlayerInfo.get("sceneName")
Nebula.PlayerInfo.get("sessionDiamonds.startObf")  -- inline SessionTracker container
Nebula.PlayerInfo.get("startupStatus")             -- Enum decodes to a string
Nebula.PlayerInfo.get("currentRace.seed")          -- non-null only mid-race

-- Array index access (1-based)
local part = Nebula.PlayerInfo.get(
    "gameStatus.vehicleStatus[1].tuningPartPresets[1].equippedParts[1]")

-- Write scalar
Nebula.PlayerInfo.set("gameStatus.coins", 999)

-- Write nested array element
Nebula.PlayerInfo.set(
    "gameStatus.vehicleStatus[1].tuningPartPresets[1].equippedParts[1]",
    "new_part")

-- Write a whole element struct (partial keys allowed, only the
-- provided keys are written, sibling fields stay intact)
Nebula.PlayerInfo.set("gameStatus.achievements[1]", { steps = 5 })

-- Validate without touching memory
Nebula.PlayerInfo.set("gameStatus.coins", 999):dry()

-- Read-back verification: fails loudly if memory disagrees with
-- what was written (op._verified / op._actual carry the result)
Nebula.PlayerInfo.set("gameStatus.coins", 999):verify()

-- Introspect a field without reading its value
local meta = Nebula.PlayerInfo.meta("gameStatus.coins")
print(meta.name, meta.type, meta.offset, meta.known)

-- List every offset-verified field id
for _, id in ipairs(Nebula.PlayerInfo.fields()) do
    print(id)
end

-- BitMask fields decode into a boxed value with its own methods
local flags = Nebula.PlayerInfo.get("gameStatus.flags")
flags:has("DebuggerDetected")
flags:enable("IsPitCrew")
flags:disable("MemoryHacker")
Nebula.PlayerInfo.set("gameStatus.flags", flags)

-- Repeated fields return a plain Lua array of decoded elements
local achievements = Nebula.PlayerInfo.get("gameStatus.achievements")
for i, achievement in ipairs(achievements) do
    print(achievement.id, achievement.unlocked, achievement.steps)
end
```

`set()` executes immediately, the returned object is only needed if
you want to call `:dry()` (validate everything except the actual
memory write) or `:verify()` (read the value back and compare it
against what was written) explicitly. Check `op._ok` / `op._err`
for the outcome, `op._verified` / `op._actual` after `:verify()`.

`get()` with no id returns an accessor bound to the currently
resolved base address, read several fields without re-resolving:

```lua
local pi = Nebula.PlayerInfo.get()
if pi then
    print(pi.get("startupCount"), pi.get("sceneName"))
end
```

Full reference: `content/api/playerinfo.md`, `get`, bound `get()`,
`set` (with `:dry()`/`:verify()`), `fields`, `meta`.

### GameData

Unlike PlayerInfo (the player's save), `GameData` is the game's
global configuration singleton, exactly one per running game. The
base is found via AOB byte-signature scanning (first validated
candidate wins, cached for subsequent calls).

```lua
-- Read a tuning value
Nebula.GameData.get("maxVisibleRange")

-- Struct-element arrays support indexed dotted paths
Nebula.GameData.get("leagueDefinitions[1].title")

-- Bound accessor, resolve the base once, then read many fields
local gd = Nebula.GameData.get()
if gd then
    print(gd.get("minVisibleRange"), gd.get("maxVisibleRange"))
end

-- Enum fields decode to their string names on read
Nebula.GameData.get("tutorialRubberbandingType") -- "Static" | "Dynamic" | "OnlyBoost"

-- Writes are GLOBAL: they change the running game's configuration
-- for every system that reads it, not just the local player
Nebula.GameData.set("tutorialRubberbandingType", "Dynamic")

-- Same chainable ops as PlayerInfo, element-struct writes included
Nebula.GameData.set("leagueDefinitions[1]", { title = "Pro League" }):verify()
```

Full reference: `content/api/gamedata.md`, `get`, bound `get()`,
`set`, `fields`, `meta`.

### PublicEvent / TeamEvent / CommunityEvent

```lua
-- Single field, resolves (and caches) the currently-active event's
-- base address under the hood
Nebula.PublicEvent.get("startTime")
Nebula.TeamEvent.get("sessionEntry.entryFeeTickets")
Nebula.CommunityEvent.get("minRankToJoin")

-- get() with no id returns an event accessor bound to the
-- currently-active struct's base address, read multiple fields off
-- that exact snapshot instead of re-resolving per call
local TeamEvent = Nebula.TeamEvent.get()
TeamEvent.get("minTeamSizeToJoin")
TeamEvent.get("sessionEntry.numberOfParallelSessions")

local PublicEvent = Nebula.PublicEvent.get()
PublicEvent.get("gameMode.duration")
PublicEvent.get("gameMode.pointsSystem.gemsToPointsConversion")

local CommunityEvent = Nebula.CommunityEvent.get()
CommunityEvent.get("name")
CommunityEvent.get("sessionEntry.maxEventTickets")

-- List every field with a verified (non-placeholder) offset
for _, id in ipairs(Nebula.TeamEvent.fields()) do
    print(id)
end

-- Introspect a field without reading its value
local meta = Nebula.PublicEvent.meta("minTeamSizeToJoin")
print(meta.name, meta.type, meta.offset, meta.known)
```

`Nebula.TeamEvent.get()` (and `PublicEvent`, `CommunityEvent`) with
no id resolves the base immediately and hands back an object bound
to that specific struct address, the plain `get(id)` form
re-resolves (from cache) on every call instead. Both end up calling
the same underlying reader, so pick whichever reads better for the
call site: one field → the plain form; several fields off the same
event → the accessor form.

CommunityEvent uses string-search resolution (searching for the
ASCII bytes of `"community Showcase\0"`) with vtable-marker
validation (`0x6D6F631E` at `base + 0x8`), rather than the AOB
byte-signature scanning used by PublicEvent and TeamEvent.

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
| `Int32` / `Int64` | direct signed int at `base + offset` |
| `Bool` | single byte at `base + offset`, `0x00`/`0x01` |
| `Float` | direct 4-byte float at `base + offset` |
| `String` | inline or pointer-deref; two encodings (inline/long), auto-detected on read |
| `SafeInt32` | pointer at `base + offset` to an anti-cheat-protected int struct |
| `JSONSafeInt` | SafeInt variant used in JSON-serialized structs |
| `BitMask` | direct 4-byte int at `base + offset`, boxed with `:has()`/`:enable()`/`:disable()`/`:toggle()` |
| `Enum` | Int32 ↔ string enum, decodes to names on read (chest types, etc.) |
| `Color3B` / `Vec2` | packed multi-word small structs |
| `Object` | pointer-backed sub-struct (namespace containers, nested objects) |
| `Array` | typed or struct-array container, see [Repeated / array fields](#repeated--array-fields) |

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
inline struct. The struct itself (0x28 bytes) lives at that pointer:

```
structPtr + 0x18  safeValue
structPtr + 0x1C  key
structPtr + 0x20  checksum
structPtr + 0x24  keyChecksum
```

Values are XOR-encoded against a single account-wide static key
(`gameStatus.safeIntStaticKey`, offset `0x6AC`), resolved internally
by `core/types/SafeInt32.lua`, individual fields don't declare it.

### BitMask

Fields of this type are a plain 4-byte int at `base + offset`, but
`get()` returns a boxed instance instead of a raw number:

```lua
local flags = Nebula.PlayerInfo.get("gameStatus.flags")
flags:has("DebuggerDetected")   -- bit membership check
flags:enable("IsPitCrew")       -- set a bit
flags:disable("MemoryHacker")   -- clear a bit
flags:toggle("SomeFlag")        -- flip a bit
Nebula.PlayerInfo.set("gameStatus.flags", flags)  -- accepts the boxed instance or a raw int
```

The bit-name-to-value mapping comes from `field.enum` in metadata,
pointing at a file under `metadata/<version>/enums/` (e.g.
`GameStatusFlag.lua`).

`meta("...flags").flags` also decodes the live value into a plain
`{ FlagName = true/false, ... }` table for quick introspection,
separate from the boxed value's own `:has()`.

### Repeated / array fields

A field with `repeated = true` (or type `"Array"`) is a container,
walked by `core/Repeated.lua` rather than a type module directly:

```
base + field.offset = ptr        -- this address IS the container header

ptr + 0x0   arrayPtr   (int64, pointer to backing array)
ptr + 0x8   size       (int32, live element count)
ptr + 0xC   capacity   (int32, allocated slot count)
ptr + 0x10  allocSlots (int32, next-pow2 of size, derived, not authoritative)
```

Element slots sit 8 bytes apart starting at `arrayPtr`. For
message/custom element types (anything that isn't a known inline
scalar), each slot holds a **pointer** to the element's own struct.

`size`/`capacity` are sanity-bounded before being trusted (rejected
if negative, over a fixed ceiling, or `size > capacity`), a
misread/garbage header fails cleanly with a descriptive error instead
of driving a runaway loop or table allocation.

`Repeated.get()` batches aggressively: it collects every element's
field reads into one cross-element `gg.getValues` call instead of one
call per element.

`Repeated.set()` writes into existing slots; growing a container
allocates elements from `core/ZeroPage.lua`'s scratch page, a write
larger than `capacity` fails cleanly with `capacity_exceeded` rather
than attempting anything unsafe.

---

## Base address resolution

### PlayerInfo

`Memory.resolvePlayerInfoBase()` locates the live `PlayerInfo`
struct by:

1. Searching each memory region (`gg.REGION_C_ALLOC`, then
   `gg.REGION_OTHER`) for the `"startup_count"` string constant
   (AOB hex signature).
2. For each hit, reading a pointer at `hit + 0x1F` and
   sanity-checking it's in a plausible address range (rules out AOB
   false-positives landing inside unrelated string literals).
3. Validating a version marker at `ptr + 0x10` against a known set
   of values.
4. The PlayerInfo base is `ptr - 0xC8`. The `GameStatus` save struct
   is its child at `base + 0x148`, which is why every save field
   is a `gameStatus.*` dotted path.

`api/PlayerInfo.lua` (via `defineApi`) caches the result for the
lifetime of the script session and applies a short failure cooldown;
the scan only runs once unless the game restarts or resolution is
forced.

### PublicEvent / TeamEvent

AOB byte-signature scanning for stable config constants (e.g.
`eventTicketRefillTime=14400` for TeamEvent,
`gemsToPointsConversion=6` for PublicEvent), followed by structural
validation (`contentVersion`, `startTime`, `endTime`). Results are
merged with a persistent address cache (`core/Cache.lua`) so cached
addresses survive signature field modifications. The AOB scan
always runs regardless of cache state.

### CommunityEvent

String-search resolution instead of AOB: searches for the ASCII
bytes of `"community Showcase\0"`, refines by first byte (`0x24`),
then validates each hit by checking the vtable marker `0x6D6F631E`
at `hit - 0x18`. Struct base = `hit - 0x20`. Same cache integration
as PublicEvent/TeamEvent, the string scan always runs, and cached
addresses passing vtable validation are kept. Unlike the other event
modules, CommunityEvent validation uses the vtable marker rather
than timestamp fields.

---

## Logging

Three independent, opt-in switches (all default `false`, all
read-honored, see
[Embedding](#embedding-nebula-in-your-own-script)):

```lua
Nebula.log      = true  -- high-level get/set/resolve trace lines
Nebula.verbose  = true  -- per-call gg.getValues/setValues timing
Nebula.traceMem = true  -- raw per-address memory-I/O dump (noisy)
```

- **`Nebula.log`**, one line per API operation: the dotted path,
  resolved address, decoded value, and failures:
  `[PlayerInfo] [get] PATH=gameStatus.coins ADDR=0x7A00000100 -> 999`
- **`Nebula.verbose`**, timing for every single `gg.*` round-trip:
  `[Nebula.Memory] readBatch    count=36   4.00ms`, useful for
  tracking down slowness.
- **`Nebula.traceMem`**, every raw address read or written with its
  value, cross-checkable directly in GG's memory viewer:
  `[Memory] [write] addr=0x7A00000108 flags=4/INT32 <- 42`

While `Nebula.log` is on, all diagnostics go to `nebula.log` next to
the script instead of the console, written and flushed line by line
(`core/Logfile.lua`), so the full trace survives a crash. If the
file can't be opened, lines fall back to `print`. An explicit
`Logfile.setPath(path)` overrides the default sink for the session.

---

## Testing

The SDK is guarded by a 300-check spec suite in `src/test/`, runnable
on plain Lua 5.4+ (or via Python's `lupa`):

```
cd src
lua test/array_trace_spec.lua        # 229 checks: containers, trace, Logfile
lua test/defineApi_spec.lua         #  32 checks: API bridge, metadata
lua test/encapsulation_spec.lua     #  39 checks: host-script contract
```

The encapsulation spec additionally exercises the **packed**
artifact, build it first:

```
python3 bundle.py -o /tmp/nebula_enc_packed.lua
```

Every check is a mock-driven, byte-addressable simulation of the GG
memory API, no device needed. If you change metadata, a type module,
or the loader, rerun all three.

---

## Packing for release

```
python bundle.py                 # pack src/ -> nebula_packed.lua
python bundle.py -o out.lua      # custom output path
python bundle.py -o build/nebula-1.0.0   # release convention: no extension
python bundle.py -v 1.0.0        # inject version string
```

Release artifacts follow the `nebula-<version>` convention with **no
`.lua` extension**, see the note under [Local](#local).

The bundler walks `src/`, embeds every module's SOURCE into a
private `__vfs` table (compiled lazily inside the module
environment), strips `main.lua`'s encapsulated loader block, and
replaces it with a VFS-aware prologue, so the exact same
`loadModule("core/...")` calls used in dev mode keep working
unchanged in the packed output. This is what makes both
[local](#local) and [cloud](#cloud) loading work from a single
distributable file with no directory structure required at runtime.

The packed artifact honors the same [host-script
contract](#embedding-nebula-in-your-own-script) as dev mode: its
only global write is the exported `Nebula` table.

---

## Roadmap

- [ ] Additional message/struct types beyond the current snapshot
      coverage (`DriverCustomization`, `RewardManagerStatus`,
      `VipStatus`, ...)
- [ ] Additional modules beyond PlayerInfo: `Vehicle`, `Garage`, ...
- [ ] On-device re-verification of flagged 1.73 structs (CustomChest
      dump Size 0x150 vs legacy 0x50-stride layout; field-order swap
      in UnlockablePaint / UnlockableSpriteVariant)
- [x] Extract every inline element template into its own per-class
      versioned snapshot under `metadata/<version>/structs/<Class>.lua`,
      cross-verified against the IL2CPP dump
- [x] Fill in remaining unknown offsets (`0xBAAD` placeholders) -
      all offsets verified against the dump
- [x] Host-script encapsulation contract (single exported global,
      private module environment, embed-mode failures), enforced by
      `test/encapsulation_spec.lua`
