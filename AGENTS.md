# AGENTS

This repository is a small Quickshell/QML setup. Use the notes below
when making changes.

## Scope

- Applies to the whole repo.
- No additional AGENTS files exist today.

## Environment

- Uses Nix flakes for a dev shell.
- Main entry point is `src/shell.qml`.
- QML modules live under `src/ui`, `src/data`, `src/theme`.

## Build / Run / Test / Lint

### Dev Shell

- `nix develop`
  - Drops you into a shell with `quickshell` and related tools.
  - Required for running `qs` if not installed globally.

### Run (manual)

- `qs --path src/shell.qml`
  - Starts the shell with the main QML file.

### Build

- No build step is defined in the repo.
- If you add one, document it here.

### Lint

- No lint config is present (no `qmllint`, ESLint, etc.).
- If you introduce linting, add the command here.

### Tests

- No automated tests are defined in the repo.
- There is no single‑test command yet.
- If tests are added, include:
  - Full test suite command.
  - Single test command (e.g. `qmllint path/to/Test.qml`).

## Cursor / Copilot Rules

- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` found.
- If those files are added later, mirror their guidance here.

## Code Style (QML)

### Imports

- Group imports in this order:
  1. Qt modules (`QtQuick`, `QtQuick.Layouts`).
  2. Quickshell modules (`Quickshell`, `Quickshell.Io`).
  3. Local imports (`"../.."`, `"theme"`, `"ui/..."`).
- Separate groups with a blank line.
- Use relative imports for local QML modules.

### Formatting

- Indentation is 4 spaces.
- Braces follow the Qt/QML style:
  - Opening brace on the same line as the type.
  - Closing brace aligned with the type.
- Keep one property per line.
- Prefer blocks for nested objects (e.g. `font { ... }`).
- Leave a blank line between major blocks (e.g. between `Timer` and `Process`).
- Avoid trailing spaces.

### Naming

- QML components: `PascalCase` filenames (e.g. `AudioWidget.qml`).
- QML ids: `lowerCamelCase` (e.g. `statsRow`).
- Properties: `lowerCamelCase` (e.g. `powerProfileTarget`).
- Constants / theme values: `Theme.colCyan`, `Theme.fontSize`.
- Avoid one‑letter names unless the scope is tiny (e.g. array reduce).

### Types & Properties

- Prefer explicit types for QML properties:
  - `property int`, `property bool`, `property string`.
- Use `readonly property` for constants and theme values.
- Use `property var` only when needed for dynamic values.
- Keep computed values in functions, not in long inline expressions.

### Control Flow

- Prefer early returns for guard clauses (see `SystemData.qml`).
- Keep `if` bodies short; use braces for multi‑line blocks.
- Use `switch` for small, explicit mappings.
- Avoid deeply nested ternaries; break into helper functions.

### Error Handling / Defensive Code

- Check data before parsing (e.g. `if (!data) return`).
- Validate array lengths before indexing.
- Use `isNaN` checks when parsing numeric output.
- When running `Process` commands, handle empty output gracefully.

### Process / Timer Usage

- Keep command arrays explicit (avoid string concatenation unless needed).
- Prefer `Process` + `SplitParser` for streaming output.
- Use `Timer` for refresh loops instead of manual `setInterval` patterns.
- Keep polling intervals reasonable (current patterns: 500–2000ms).

### UI Layout

- Use `RowLayout`/`Layout` for layout behavior.
- Keep layout margins and spacing centralized in the parent container.
- Prefer `implicitWidth/implicitHeight` based on inner content.
- Use `Theme` values for dimensions and colors.

### Strings & Icons

- Use double quotes for strings.
- Keep glyph strings in a single map/object (see `audioIcons`).
- Avoid hard‑coding colors; use `Theme` colors instead.

### Comments

- Avoid adding inline comments unless requested.
- If a comment is needed, keep it short and local.

### File Organization

- `src/theme` contains palette and sizing constants.
- `src/data` owns system data providers and `Process` integration.
- `src/ui` contains visual components only; no heavy logic.
- Keep logic in `data` and presentation in `ui`.

## Suggested Workflow

1. Enter dev shell: `nix develop`.
2. Run: `qs --path src/shell.qml`.
3. Make QML changes in `src/ui` or `src/data`.
4. Restart Quickshell to validate changes.

## When Updating This File

- Add real build/lint/test commands as they appear.
- If a test framework is added, document single‑test usage.
- Sync with any new Cursor or Copilot instructions.
