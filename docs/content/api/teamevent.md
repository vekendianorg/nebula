## TeamEvent

Read fields off whichever `TeamEvent` struct is
currently active in memory. Same surface as `PublicEvent` —
`get(fieldName)`, `get()`, `fields()`, `meta(fieldName)` — but
its metadata mirrors `PublicEvent`'s shared header while patching its
own divergent tail (`multiRaceGameModes`, `winningTeamReward` instead
of `fixedVehicles`/`specialFeatures`/`eventSpecials`/`premiumEventRewards`),
and it resolves its base address independently — see
`metadata/TeamEvent.lua` and [Mirrored metadata](#mirrored-metadata).

### TeamEvent.get(fieldName)

Reads a single field by its dotted name and returns it as a plain Lua
value. Resolves (and caches) the currently-active event's base
address on first use.

**Parameters**

- `fieldName` (string) — the field's dotted name as declared in `metadata/TeamEvent.lua`, e.g. `"minTeamSizeToJoin"` or `"sessionEntry.entryFeeTickets"`

**Returns**

(number | string | table) — the field's current value, typed according to its metadata entry

```lua
local minSize = Nebula.TeamEvent.get("minTeamSizeToJoin")
local fee = Nebula.TeamEvent.get("sessionEntry.entryFeeTickets")
```

### TeamEvent.get()

Called with no argument, resolves the currently-active team event's
base address immediately and returns an accessor/context object with
its own `get(fieldName)` bound to that exact snapshot. No separate
step is needed to trigger resolution.

**Returns**

(table) — an object with a `get(fieldName)` field, or `nil` plus an error string if no team event is currently active

```lua
local TeamEvent = Nebula.TeamEvent.get()
TeamEvent.get("minTeamSizeToJoin")
TeamEvent.get("sessionEntry.numberOfParallelSessions")
```

### TeamEvent.fields()

Lists every field's dotted id that has a verified (non-placeholder)
offset — same rules as `PublicEvent.fields()`.

**Returns**

(table) — a sorted array of dotted field-name strings

```lua
for _, id in ipairs(Nebula.TeamEvent.fields()) do
    print(id)
end
```

### TeamEvent.meta(fieldName)

Introspects a field's declared metadata without reading its live
value.

**Parameters**

- `fieldName` (string) — the field's dotted name

**Returns**

(table) — `{ name, type, offset, repeated, known, address }` — `address` is only populated once a base has been resolved

```lua
local meta = Nebula.TeamEvent.meta("minTeamSizeToJoin")
print(meta.name, meta.type, meta.offset, meta.known)
```
