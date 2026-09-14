## TeamEvent

Read and write fields off whichever `TeamEvent` struct is
currently active in memory. Same surface as `PublicEvent` —
`get(fieldName)`, `get()`, `set(fieldName, value)`, `fields()`,
`meta(fieldName)` — bound to the same shared
`metadata/<version>/structs/EventDefinition.lua` struct as
`PublicEvent` and `CommunityEvent` (see
[Versioned metadata](#versioned-metadata)), including its
`multiRaceGameModes`/`winningTeamReward` tail fields, and it resolves
its base address independently.

### TeamEvent.get(fieldName)

Reads a single field by its dotted name and returns it as a plain Lua
value. Resolves (and caches) the currently-active event's base
address on first use.

**Parameters**

- `fieldName` (string) — the field's dotted name as declared in `metadata/<version>/structs/EventDefinition.lua`, e.g. `"minTeamSizeToJoin"` or `"sessionEntry.entryFeeTickets"`

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

### TeamEvent.set(fieldName, value)

Writes a field value to the currently-active TeamEvent struct.
Returns a chainable operation object supporting `:dry()`.

**Parameters**

- `fieldName` (string) — the field's dotted name
- `value` (number | string | table) — the value to write

**Returns**

(table) — a chainable operation object; already executed

```lua
Nebula.TeamEvent.set("startTime", 1700000000)
Nebula.TeamEvent.set("startTime", 1700000000):dry()
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

> **Offset verification status**: TeamEvent's header comes from the
> same shared `metadata/<version>/structs/EventDefinition.lua` snapshot
> as PublicEvent, which has been fully cross-referenced
> against the IL2CPP struct dump (`libcocos2dcpp.cs`). The dump shows
> team event definitions are stored in
> `Dictionary<string, Pointer<EventDefinition>>` — the same
> `EventDefinition` struct (Size 0x5D8, Confidence: exact) backs
> PublicEvent, TeamEvent and CommunityEvent. TeamEvent's unique tail
> fields are confirmed: `multiRaceGameModes` at `0x500` and
> `winningTeamReward` at `0x520`. The previously-unverified mirrored
> fields (`eventRewards` 0x528, `rotatingEventRewards` 0x558,
> `rotatingEventRewardsInterval` 0x570, `mainEventRewards` 0x578) are
> all confirmed by the dump.
