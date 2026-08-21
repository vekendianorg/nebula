# Contributing to Nebula

This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful
and inclusive environment for all contributors.

## How to Contribute

### Reporting Issues

- Use the GitHub issue tracker to report bugs or request features
- Include steps to reproduce the issue when applicable
- Mention the game version and any relevant device information

### Suggesting Enhancements

- Open an issue describing your proposed enhancement
- Explain the use case and expected behavior
- If possible, include examples of how the feature would be used

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the coding standards below
4. Test your changes on a real GameGuardian environment when possible
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Setup

Nebula is pure Lua targeting GameGuardian's runtime. There is no
build step for development — edit files in `src/` and load `main.lua`
directly in GG.

To create a distributable build:

```bash
python bundle.py                 # pack src/ -> build/nebula-<version>.lua
python bundle.py -m              # + strip comments / minify
python bundle.py -v 1.0.0        # inject version string
```

## Project Architecture

Nebula is metadata-driven. Understanding these layers is essential:

- **`metadata/`** — Field definitions (offsets, types). Adding a new
  field is usually just a metadata edit.
- **`core/types/`** — Type implementations (`get`/`set` for each
  type). Adding a new scalar type means adding a file here and
  registering it in `core/Type.lua`.
- **`core/`** — Infrastructure (`Memory.lua`, `Repeated.lua`,
  `Struct.lua`). Only `Memory.lua` talks to `gg.*` directly.
- **`api/`** — Public API surfaces. Each module resolves its own base
  address and dispatches to the core layer.

See the README's "How it fits together" section for full details.

## Coding Standards

### Lua Style

- Use 4-space indentation
- Prefer local variables over globals
- Follow existing naming conventions in the codebase
- Do not add comments unless asked or necessary for clarity

### Metadata Conventions

- Use `0xBAAD` as placeholder for unknown offsets
- Document offset sources (e.g., "verified on-device", "from Gentle 2.7")
- Keep field tables sorted logically (by offset or alphabetically)

### Type Module Interface

All type modules must implement:

```lua
M.get(base, field)    -- returns value, error
M.set(base, field, value) -- returns ok, error
```

Optional batching interface for repeated fields:

```lua
M.specs(base)         -- returns array of {address, flags}
M.parse(results)      -- returns decoded value
```

### Testing

- Test against a live game when possible
- Use `main.lua`'s test harness as a reference
- Enable `Nebula.verbose = true` to debug memory operations
- Verify both get and set paths for writable fields

## Documentation

If your change affects the public API or adds new functionality:

1. Update `docs/content/guide.md` for prose documentation
2. Create or update `docs/content/api/<module>.md` for API reference
3. Regenerate the docs site:

```bash
cd docs
/data/data/com.termux/files/usr/bin/python3 scripts/build_docs.py
```

The generated `docs.html` should be committed alongside your changes.

## Commit Messages

- Use imperative mood ("Add feature" not "Added feature")
- Keep the first line under 72 characters
- Reference issue numbers when applicable

## License

By contributing, you agree that your contributions will be licensed
under the MIT License. See [LICENSE](LICENSE) for details.
