<!--
  API reference source file.

  Each function is documented in its own ### heading inside a module
  file like this one. The build script (scripts/build_docs.py) parses
  these into the "API Reference" section of docs.html and adds each
  function to the search index automatically — you don't need to touch
  any HTML or the search index by hand.

  Format for each function:

    ### module.functionName(args)

    One-line summary shown in search results and the TOC tooltip.

    **Parameters**

    - `paramName` (type) — description
    - `paramName` (type, optional) — description

    **Returns**

    (type) — description

    ```lua
    -- one or more short usage examples
    ```

    IMPORTANT: leave a blank line after **Parameters** and **Returns**
    labels, before the list/text that follows. Markdown treats
    "**Label**\n- item" (no blank line) as one merged block instead of
    a heading-like label followed by its own list — the blank line is
    what keeps them styled as separate pieces.

    Optional free-form notes/paragraphs after the example are fine —
    anything after the last code block and before the next ### heading
    is treated as additional prose for that function.

  Add a new function by copy-pasting a ### block. Add a new module by
  creating a new file in content/api/ — the build script picks up every
  .md file in that directory automatically, no registration needed.
-->

## GameStatus

Read and write typed fields on the player's save-game struct. All
methods are metadata-driven — the field list comes from
`metadata/gamestatus.lua`, not from hardcoded offsets in this module.

### GameStatus.get(fieldName)

Reads a single field by name and returns it as a plain Lua value (or a
boxed value for `BitMask`/message-type fields — see [Type modules](#type-modules)).

**Parameters**

- `fieldName` (string) — the field's name as declared in `metadata/gamestatus.lua`

**Returns**

(number | string | boolean | table) — the field's current value, typed according to its metadata entry

```lua
local coins = Nebula.GameStatus.get("coins")
local flags = Nebula.GameStatus.get("flags") -- BitMask fields return a boxed table, see :has()/:enable()
```

### GameStatus.set(fieldName, value)

Writes a single field by name. Values are validated against the
field's declared type before the write happens — passing a string to
an `Int32` field, for example, raises a Lua error instead of silently
corrupting memory.

**Parameters**

- `fieldName` (string) — the field's name as declared in `metadata/gamestatus.lua`
- `value` (number | string | boolean | table) — the new value; must match the field's declared type

**Returns**

(boolean) — `true` if the write succeeded

```lua
Nebula.GameStatus.set("coins", 999)
Nebula.GameStatus.set("playerName", "Hillbilly")
```

Dangerous fields (see [Dangerous fields](#dangerous-fields)) additionally
require `:force()` or `:dry()` to be called explicitly — see that section
for why.
