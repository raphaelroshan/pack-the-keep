# P10 — Controller Navigation, Remapping, and UI Scaling

## Intent

The complete Greywatch loop should remain operable without a mouse and readable at several desktop UI scales. Input bindings and scale are player preferences, never simulation state.

## Behavior

- Native focus navigation starts on a useful control whenever Title, Preparation, Battle, or Results opens.
- Primary battle, placement, focus, and presentation actions have keyboard and controller bindings.
- A player can select a supported action, capture a replacement keyboard key or controller button, and reset all supported actions to project defaults.
- Rebinding one device type preserves the other device type, so adding a controller preference does not remove keyboard access.
- Controller Accept and D-pad directions remain reserved for menu navigation and cannot be captured as global command shortcuts.
- UI scale cycles through 80%, 100%, 125%, and 150%, applies immediately through the root window content scale, and persists.
- This slice introduced settings schema 2, which loads schema-1 accessibility files with default scale and project-default bindings; the later display/audio slice migrates it to schema 3.
- Scaling, focus movement, and binding changes do not mutate `PackKeepState` or alter deterministic outcomes.

## Supported remappable actions

- Pause/resume battle.
- Advance one battle step.
- Commander ability.
- Arm placement.
- Cancel placement.
- Cycle focused enemy.
- Inspect focused enemy.
- Focus the combat report.

Accessibility toggles remain controller-operable through native directional focus plus Accept; they do not consume extra global controller shortcuts.

## Acceptance criteria

- Every supported action retains at least one usable binding after capture or reset.
- Controller events dispatch through the same named-action handlers as keyboard events.
- A newly opened screen exposes a focused primary control without requiring mouse movement.
- A new UI instance restores scale and custom bindings from the settings file.
- Schema-1, malformed, and future settings files use safe defaults.
- Serialized authoritative state is byte-for-byte unchanged by scale, focus, or rebinding operations.
- A 125% capture keeps the primary board facts and settings labels readable through the scroll-safe layout.

## Non-goals

- No per-axis deadzone editor, chorded bindings, localization, fullscreen/resolution selector, or audio mixer in this slice.
- No controller rumble and no simulation command may depend on the active input device.
