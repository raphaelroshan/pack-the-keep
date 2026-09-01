# P61 — Room Label Legibility

## Player-facing purpose

Keep every room function identifiable on the board at normal play distance. Compact two-cell rooms should no longer show accidental ellipses such as `Works...` or `Barrac...`; purposeful short labels may be used where the full structural name cannot fit, while inspection continues to expose the complete authored name and role.

## Data shape

`BoardVisualRegistry.room_display_label(keep_id, room_id, fallback_name)` owns stable keep-specific presentation labels. `KeepCanvas.room_label_snapshot(room_id)` returns the chosen board label, fitted font size, available width, measured width, and fit result.

No room identifier, display name, geometry, condition, target priority, save field, or simulation rule changes.

## Acceptance criteria

1. Every active room label fits its board rectangle without an ellipsis at the supported base canvas.
2. Greywatch uses `Supply` and `Tower`; Ash Ford and Twinwatch use their own stable functional shorthand rather than inheriting Greywatch labels through shared room IDs.
3. Critical-room markers retain reserved space.
4. Empty placement slots retain their warm outline but no longer repeat `PLACE` across the room-name strip.
5. Room inspection still presents the complete authoritative room name and role.
6. Rendering and label snapshots do not mutate `KeepState`.
7. A real 1600×900 Preparation/Battle capture shows readable labels without increasing board density.

## Test cases

- Enumerate every room in Greywatch, Ash Ford, and Twinwatch and assert its label snapshot fits.
- Assert stable short labels for Supply Room and North Tower.
- Assert Workshop and Barracks remain unabridged through font fitting.
- Assert board rendering and high contrast preserve authoritative state.
