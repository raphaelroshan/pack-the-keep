# P17 Real-time Assault Visual Verification

## Scope

The P17 checkpoint verifies that continuous battle playback preserves the keep as the primary visual surface and that expanded desktop layouts remain readable without becoming sparse or cluttered.

## Captures reviewed

- 1600×900: battle begins live, the fort expands beyond its 1280×720 minimum, the command rail remains visible, pause is the primary combat action, manual step is secondary, and a defender engagement trace reaches the active threat.
- 2560×1440: the fort and command rail remain side-by-side, the board receives additional vertical space, and the 125% readability baseline prevents the interface from appearing physically undersized.

## Acceptance result

- Enemy movement uses fractional presentation time rather than snapping only after a deterministic tick.
- Transient engagement lines and impact rings communicate defender commitments without changing simulation state.
- Reduced motion suppresses the transient engagement animation and retains deterministic combat.
- 1280×720 remains supported through responsive stacking; 1600×900 is the new default; 1920×1080 and 2560×1440 are selectable.
- No final-art claim is made. The procedural board remains a functional vertical-slice renderer.
