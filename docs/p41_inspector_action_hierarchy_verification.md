# P41 Inspector Action Hierarchy Verification

- Build: `0.24.0-inspector-hierarchy`
- Local render: Godot 4.7.2, macOS, 1600×900 at 100% scale
- Scope: presentation inspection; human comprehension remains pending

Rooms, defenders, and enemies now share one dedicated tactical inspection card. Every selection presents a type and location/phase header, player-facing name, numeric health or condition, tactical purpose, and one contextual next action before the retained detailed readout.

Explicit map, timeline, and dropdown inspection brings the card into view. Automatic threat focus still populates it without stealing the command rail at assault start. Enemy counter names are resolved to player-facing unit names instead of stable content IDs.

The card re-reads authoritative state on refresh, so damage and recovery changes remain current without adding serialized presentation fields or commands. Focused coverage checks all three subject types, friendly naming, non-mutating refresh, and 125% stacking.
