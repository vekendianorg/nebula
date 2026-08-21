## PublicEvent

Read fields off whichever `PublicEvent` struct is currently active in
memory. Like `GameStatus`, every method is metadata-driven — the
field list comes from `metadata/PublicEvent.lua`, not from hardcoded
offsets in this module. Unlike `GameStatus`'s single fixed struct,
there can be several `PublicEvent` instances in memory at once
(past/current/upcoming events); base resolution picks out whichever
one's `startTime`/`endTime` window contains the current time — see
[Base address resolution](#base-address-resolution).

### PublicEvent.get(fieldName)

Reads a single field by its dotted name and returns it as a plain Lua
value. Resolves (and caches) the currently-active event's base
address on first use.

**Parameters**

- `fieldName` (string) — the field's dotted name as declared in `metadata/PublicEvent.lua`, e.g. `"startTime"` or `"gameMode.duration"`

**Returns**

(number | string | table) — the field's current value, typed according to its metadata entry

```lua
local startTime = Nebula.PublicEvent.get("startTime")
local duration = Nebula.PublicEvent.get("gameMode.duration")
```

### PublicEvent.get()

Called with no argument, resolves the currently-active event's base
address immediately and returns an accessor/context object with its
own `get(fieldName)` bound to that exact snapshot. Prefer this over
the plain `get(fieldName)` form when reading several fields off the
same event, so a sequence of reads stays consistent even if
resolution were to happen again in between. No separate step is
needed to trigger resolution — `get()` alone does it.

**Returns**

(table) — an object with a `get(fieldName)` field, or `nil` plus an error string if no event is currently active

```lua
local event = Nebula.PublicEvent.get()
event.get("minTeamSizeToJoin")
event.get("gameMode.pointsSystem.gemsToPointsConversion")
```

### PublicEvent.fields()

Lists every field's dotted id that has a verified (non-placeholder)
offset. Fields still at the `0xBAAD` placeholder in
`metadata/PublicEvent.lua`, and per-element `Array` templates (see
[Per-element templates](#per-element-templates-elements)), are
excluded.

**Returns**

(table) — a sorted array of dotted field-name strings

```lua
for _, id in ipairs(Nebula.PublicEvent.fields()) do
    print(id)
end
```

### PublicEvent.meta(fieldName)

Introspects a field's declared metadata without reading its live
value.

**Parameters**

- `fieldName` (string) — the field's dotted name

**Returns**

(table) — `{ name, type, offset, repeated, known, address }` — `address` is only populated once a base has been resolved

```lua
local meta = Nebula.PublicEvent.meta("minTeamSizeToJoin")
print(meta.name, meta.type, meta.offset, meta.known)
```
