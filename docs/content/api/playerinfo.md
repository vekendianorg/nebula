<!--
  API reference for the PlayerInfo module — the parent object of the
  player's save data. Every function lives in its own ### heading;
  the build script parses these into the "API Reference" section of
  docs.html and the search index automatically.

  Format for each function:

    ### module.functionName(args)

    One-line summary shown in search results and the TOC tooltip.

    **Parameters**

    - `paramName` (type) — description

    **Returns**

    (type) — description

    ```lua
    -- one or more short usage examples
    ```

  IMPORTANT: leave a blank line after **Parameters** and **Returns**
  labels, before the list/text that follows. Markdown treats
  consecutive lines as one paragraph otherwise.
-->

## PlayerInfo

The player's save-data parent object — the struct the
`"startup_count"` signature scan actually lands on. There is no
separate GameStatus module: the save struct is PlayerInfo's child
(`mGameStatus` @0x148), and every save field is reachable as a
dotted `gameStatus.*` path. Bound to the PlayerInfo metadata
snapshot via `Nebula.defineApi()`.

```lua
Nebula.PlayerInfo.get("gameStatus.coins")
Nebula.PlayerInfo.set("gameStatus.playerName", "Hillbilly")
```

### PlayerInfo.get(fieldId)

Reads a single field by dotted path. The path is resolved against
the versioned struct metadata (see the guide's [Versioned
metadata](#versioned-metadata) section): child structs descend with
`.`, array elements index with `[n]` (1-based).

**Parameters**

- `fieldId` (string) — dotted field path, e.g. `"startupCount"`, `"gameStatus.coins"`, `"gameStatus.achievements[1]"`

**Returns**

(number | string | boolean | table) — the field's current value, typed according to its metadata entry; BitMask fields return a boxed table (see `:has()`/`:enable()`), repeated fields return a plain Lua array of decoded elements

```lua
local coins  = Nebula.PlayerInfo.get("gameStatus.coins")
local flags  = Nebula.PlayerInfo.get("gameStatus.flags") -- boxed BitMask
local part   = Nebula.PlayerInfo.get("gameStatus.vehicleStatus[1].tuningPartPresets[1].equippedParts[1]")
local status = Nebula.PlayerInfo.get("startupStatus")    -- Enum -> string name
```

### PlayerInfo.get()

With no argument, resolves the base address once (the scan result is
cached for the session) and returns an accessor bound to that exact
struct address — read many fields without re-resolving per call.

**Returns**

(table | nil) — accessor with a `.base` address and a `.get(fieldId)` method, or nil if the base could not be resolved

```lua
local pi = Nebula.PlayerInfo.get()
if pi then
    print(pi.get("startupCount"), pi.get("sceneName"))
end
```

### PlayerInfo.set(fieldId, value)

Writes a single field by dotted path. Returns a chainable operation
object supporting `:dry()` and `:verify()` — calling `set()` alone
executes the write immediately, and the returned object is only
needed when you want one of those modifiers explicitly.

Indexed element paths (`"gameStatus.achievements[1]"`) accept a
**table value to write the whole element struct**: only the keys you
provide are written — sibling fields stay intact, the existing
instance is edited in place (never re-allocated), and unknown keys
are a safe no-op. A non-table value for an element path is rejected
with `value_not_table`; a null element pointer with
`null_element_ptr`.

`:dry()` validates the path and value without touching memory.
`:verify()` reads the value back through the same path and compares
it against what the operation wrote — tables compare recursively
over the expected keys only (so partial element writes verify
cleanly), numbers with a small float32 tolerance. The result lands
on `op._verified` / `op._actual`.

**Parameters**

- `fieldId` (string) — dotted field path, as for `get()`
- `value` (number | string | boolean | table) — the new value; must match the field's declared type; element paths take a partial struct table

**Returns**

(table) — a chainable operation object; already executed. Check `op._ok`/`op._err` for the outcome, `op._verified`/`op._actual` after `:verify()`.

```lua
Nebula.PlayerInfo.set("gameStatus.coins", 999)
Nebula.PlayerInfo.set("gameStatus.playerName", "Hillbilly")
Nebula.PlayerInfo.set("sceneName", "garage_2")

-- Whole element-struct write: partial keys, siblings intact
Nebula.PlayerInfo.set("gameStatus.achievements[1]", { steps = 5, unlocked = true })

-- Validate without touching memory
Nebula.PlayerInfo.set("gameStatus.coins", 999):dry()

-- Read-back verification
local op = Nebula.PlayerInfo.set("gameStatus.coins", 999):verify()
if not op._verified then
    print("mismatch; actual:", op._actual)
end
```

### PlayerInfo.fields()

Lists every offset-verified field id the resolved struct metadata
defines — every dotted path that is safe to pass to `get()` /
`set()`. Fields whose offsets are still `0xBAAD` placeholders are
excluded.

**Returns**

(string[]) — sorted dotted field ids

```lua
for _, id in ipairs(Nebula.PlayerInfo.fields()) do
    print(id)
end
```

### PlayerInfo.meta(fieldId)

Introspects a field without reading its value.

**Parameters**

- `fieldId` (string) — dotted field path

**Returns**

(table | nil) — `{ name, type, offset, repeated, known, ... }`; `known` is false while the offset is still a `0xBAAD` placeholder

```lua
local meta = Nebula.PlayerInfo.meta("gameStatus.coins")
print(meta.name, meta.type, meta.offset, meta.known)
```
