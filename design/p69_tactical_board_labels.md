# P69 — Tactical board label hierarchy

## Player-facing purpose

Keep the fort readable at contact. A focused threat should communicate focus and arrival state as one compact badge, while keep-specific spatial rules should sit in a reserved status plate instead of competing with room names, units, and routes.

## Data and ownership

- `KeepState` remains authoritative for enemy arrival, focus inputs, and spatial-rule state.
- `KeepCanvas` derives read-only badge snapshots and rectangles from that state.
- Badges never change targeting, timing, damage, placement legality, or replay keys.

## Acceptance criteria

1. A focused approaching threat shows `FOCUS · Tn`; at contact it shows `FOCUS · CONTACT`.
2. An imminent non-focused threat can show a compact contact-tick badge without adding free-floating text.
3. A threat badge never intersects its actor marker or health bar and remains above the assault timeline.
4. Clear Causeway and Paired Bastions status use a backed plate in the board's reserved upper band rather than text across tactical cells.
5. High contrast changes badge contrast only; reduced motion and all simulation outcomes remain unchanged.

## Verification

- Extend deterministic UI coverage for focus/contact transitions, badge bounds, spatial-rule plate data, and state immutability.
- Run the focused board/battle tests and full `scripts/verify.sh`.
- Capture the full flow at normal rendering and inspect Preparation, Assault, and Recovery at 1600×900 plus the existing large-text layout gate.
