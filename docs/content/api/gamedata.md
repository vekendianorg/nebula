## GameData

Read and write fields on the game's global configuration singleton.
Unlike `GameStatus` (the player's save) and the event modules
(per-instance structs in memory), there is exactly one `GameData` per
running game. Every method is metadata-driven — the field list comes
from `metadata/<version>/structs/GameData.lua` (the version folder is
picked automatically from the running game's version, e.g. `1.74.2`
resolves `1.74` — see [Versioned metadata](#versioned-metadata)), not
from hardcoded offsets in this module. The struct's layout is supplied
whole by the IL2CPP dump (Size `0x548`, Confidence: exact) — all 141
declared fields are offset-verified with no placeholders, and the
layout is identical across the 1.73 and 1.74 snapshots (only nested
templates like `ReviewConditions` keep resolving per-version through
the manifest).

The base address is resolved via AOB byte-signature scanning — the scan
is authoritative for fresh discovery, with a validated cache as a
supplement. Since `GameData` is a singleton, the first validated
candidate wins rather than the per-instance enumeration used by the
event modules.

**Writes are global**: mutating a field here changes the running
game's configuration for every system that reads it, not just the
local player. Prefer reads for inspection, and keep writes to the
tuning values you actually mean to change.

### GameData.get(fieldName)

Reads a single field by its dotted name and returns it as a plain Lua
value, typed according to its metadata entry. `Enum` fields (e.g.
`tutorialRubberbandingType`) return the decoded string name
(`"Static"`, `"Dynamic"`, `"OnlyBoost"`); `Array` fields return a Lua
table; nested struct-element arrays (`leagueDefinitions`,
`seasonLeagueDefinitions`, `adventurerRankDefinitions`,
`teamSeasonDivisions`) support indexed dotted paths.

**Parameters**

- `fieldName` (string) — the field's dotted name as declared in `metadata/<version>/structs/GameData.lua`, e.g. `"maxVisibleRange"` or `"leagueDefinitions[1].title"`

**Returns**

(number | string | boolean | table) — the field's current value, typed according to its metadata entry

```lua
local showGhosts = Nebula.GameData.get("showMoreGhostsMode")
local leagueName = Nebula.GameData.get("leagueDefinitions[1].title")
local rbType = Nebula.GameData.get("tutorialRubberbandingType") -- "Static" | "Dynamic" | "OnlyBoost"
```

### GameData.get()

Called with no argument, resolves the singleton's base address
immediately and returns an accessor object with its own
`get(fieldName)` bound to that base. Prefer this over the plain
`get(fieldName)` form when reading several fields in a row.

**Returns**

(table) — an object with `base` and a `get(fieldName)` field, or `nil` plus an error string (`"no_game_data"`) if no candidate base survived validation

```lua
local gd = Nebula.GameData.get()
if gd then
    print(string.format("GameData base=0x%X", gd.base))
    print(gd.get("minVisibleRange"), gd.get("maxVisibleRange"))
end
```

### GameData.set(fieldName, value)

Writes a field value to the singleton struct. Returns a chainable
operation object supporting `:dry()` (resolves the field path without
writing) and `:verify()` (reads the value back and compares it
against what was written).

Indexed element paths (`"leagueDefinitions[1]"`) accept a **table
value to write the whole element struct**: only the keys you provide
are written — sibling fields stay intact, the existing instance is
edited in place (never re-allocated), and unknown keys are a safe
no-op. A non-table value for an element path is rejected with
`value_not_table`; a null element pointer with `null_element_ptr`.

**Parameters**

- `fieldName` (string) — the field's dotted name
- `value` (number | string | boolean | table) — the value to write; `Enum` fields accept either the string name or the numeric id; element paths take a partial struct table

**Returns**

(table) — a chainable operation object; already executed. After
`:verify()`, `op._verified` (boolean) and `op._actual` (the decoded
read-back value) carry the comparison result

```lua
Nebula.GameData.set("maxVisibleRange", 1200.0)
Nebula.GameData.set("tutorialRubberbandingType", "Dynamic")
Nebula.GameData.set("maxVisibleRange", 1200.0):dry()

-- Whole element-struct write: partial keys, siblings intact
Nebula.GameData.set("leagueDefinitions[1]", { title = "Pro League" })

-- Read-back verification: _verified is true only if memory matches
local op = Nebula.GameData.set("maxVisibleRange", 1200.0):verify()
if not op._verified then
    print("game overwrote it; actual:", op._actual)
end
```

### GameData.fields()

Lists every offset-verified field's id, including dotted paths into
nested struct-element arrays.

**Returns**

(table) — a sorted array of field-name strings

```lua
for _, id in ipairs(Nebula.GameData.fields()) do
    print(id)
end
```

### GameData.meta(fieldName)

Introspects a field's declared metadata without reading its live
value.

**Parameters**

- `fieldName` (string) — the field's name as declared in `metadata/<version>/structs/GameData.lua`

**Returns**

(table) — `{ name, type, offset, repeated, known, address }` — `address` is only populated once a base has been resolved

```lua
local meta = Nebula.GameData.meta("minVisibleRange")
print(meta.name, meta.type, meta.offset, meta.known)
```

> **Enum provenance note**: the only `Enum`-typed GameData field,
> `tutorialRubberbandingType`, is backed by
> `metadata/<version>/enums/GameData_RubberbandingType.lua`, which was
> auto-generated from a bulk enum dump rather than individually
> curated like `ChestType`/`TuningRarity`/`UnlockType` — verify a
> given id against on-device behavior before relying on it for
> anything write-side.
