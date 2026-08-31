## CommunityEvent

Read and write fields off whichever `CommunityEvent` (CommunityShowcase)
struct is currently active in memory. Like the other event modules,
every method is metadata-driven — the field list comes from
`metadata/CommunityEvent.lua`. Unlike `PublicEvent` and `TeamEvent`
which use AOB byte-signature scanning, CommunityEvent uses
string-search resolution: it searches for the ASCII bytes of
`"community Showcase\0"` and validates hits via a vtable marker
(`0x6D6F631E` at `base + 0x8`). This is a simpler struct than
PublicEvent/TeamEvent — no reward/loot fields, no contentVersion.

### CommunityEvent.get(fieldName)

Reads a single field by its dotted name and returns it as a plain Lua
value. Resolves (and caches) the currently-active event's base
address on first use.

**Parameters**

- `fieldName` (string) — the field's dotted name as declared in `metadata/CommunityEvent.lua`, e.g. `"startTime"` or `"sessionEntry.entryFeeTickets"`

**Returns**

(number | string | table) — the field's current value, typed according to its metadata entry

```lua
local startTime = Nebula.CommunityEvent.get("startTime")
local tickets = Nebula.CommunityEvent.get("sessionEntry.maxEventTickets")
```

### CommunityEvent.get()

Called with no argument, resolves the currently-active event's base
address immediately and returns an accessor/context object with its
own `get(fieldName)` bound to that exact snapshot. Prefer this over
the plain `get(fieldName)` form when reading several fields off the
same event.

**Returns**

(table) — an object with a `get(fieldName)` field, or `nil` plus an error string if no event is currently active

```lua
local event = Nebula.CommunityEvent.get()
event.get("name")
event.get("sessionEntry.maxEventTickets")
```

### CommunityEvent.set(fieldName, value)

Writes a field value to the currently-active CommunityEvent struct.
Returns a chainable operation object supporting `:dry()`.

**Parameters**

- `fieldName` (string) — the field's dotted name
- `value` (number | string | table) — the value to write

**Returns**

(table) — a chainable operation object; already executed

```lua
Nebula.CommunityEvent.set("startTime", 1700000000)
Nebula.CommunityEvent.set("startTime", 1700000000):dry()
```

### CommunityEvent.fields()

Lists every field's dotted id that has a verified (non-placeholder)
offset. Fields still at the `0xBAAD` placeholder in
`metadata/CommunityEvent.lua` are excluded.

**Returns**

(table) — a sorted array of dotted field-name strings

```lua
for _, id in ipairs(Nebula.CommunityEvent.fields()) do
    print(id)
end
```

### CommunityEvent.meta(fieldName)

Introspects a field's declared metadata without reading its live
value.

**Parameters**

- `fieldName` (string) — the field's dotted name

**Returns**

(table) — `{ type, offset, repeated, known }`

```lua
local meta = Nebula.CommunityEvent.meta("minRankToJoin")
print(meta.type, meta.offset, meta.known)
```

> **Offset verification status**: CommunityEvent's offsets have been
> cross-referenced against the IL2CPP struct dump (`libcocos2dcpp.cs`).
> The dump shows the game stores event definitions in
> `Dictionary<string, Pointer<EventDefinition>>` — the same
> `EventDefinition` struct (Size 0x5D8, Confidence: exact) backs
> PublicEvent, TeamEvent and CommunityEvent. All header offsets in
> `metadata/CommunityEvent.lua` match exactly (`id` 0x8, `name` 0x20,
> `description` 0x38, `eventIcon` 0x80, `minRankToJoin` 0x140,
> `startTimeLive` 0x14C, `startTime` 0x150, `endTime` 0x154,
> `sessionEntry` 0x160), as do the `gameMode` children (`duration` 0x21C,
> `joinWindow` 0x220, `maxSessionParticipants` 0x2D0, `levelPools` 0x2F0).
> `startTime` was corrected from `0x14C` to `0x150` during verification;
> `0x14C` is `startTimeLive` in the dump, now exposed as its own field.

</parameter>