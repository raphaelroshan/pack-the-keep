# P18 Combat Impact and Pacing

## Player-facing purpose

Continuous playback should make it obvious who attacked, what kind of response occurred, and where enemy pressure landed. A resolved combat tick should read as a short exchange rather than a static line appearing over the board.

## Authority boundary

`PackKeepState` remains the sole authority for targeting, damage, ammunition, contact, defeat, and outcomes. The UI may snapshot state immediately before a deterministic tick and compare it with state immediately afterward to produce presentation-only effects. Those effects are never serialized and never feed back into combat.

## Presentation shape

- Ranged defenders show a short travelling bolt or ember with a fading trail.
- Melee defenders show a compact lunge arc rather than a full-map projectile.
- Damaged enemies show a brief impact ring and exact damage label.
- Enemy damage to rooms or defenders shows a red pressure stroke, impact ring, and exact damage label at the affected target.
- Enemies within the final second before arrival show a restrained `CONTACT` telegraph.
- Reduced motion replaces travelling effects with static, short-lived impact marks and keeps the contact label readable.
- Combat cues distinguish a defender volley from enemy structural impact while respecting mute and effects volume.

## Acceptance criteria

1. Defender traces carry their data-driven melee/ranged style and animate differently.
2. Damage to a room or defender produces a target impact derived from authoritative before/after state.
3. Contact telegraphs are calculated from battle step, fractional presentation clock, and authored arrival step without mutating state.
4. Pause freezes simulation while existing presentation effects may finish; manual step still resolves exactly one tick.
5. Reduced motion suppresses travel and jitter but preserves static impact and contact information.
6. Existing seeded outcomes, save compatibility, controller input, and packaged smoke behavior remain unchanged.

## Tests

- UI smoke verifies style metadata, projectile progress, contact telegraph timing, target-impact detection, and reduced-motion fallback.
- Semantic cue coverage includes `volley` and `impact` profiles.
- Full deterministic, UI, persistence, packaging, and scenario-matrix verification remains required.

## Non-goals

- Projectile collision or physics.
- Continuous authoritative damage.
- Camera shake, screen-filling particles, or effects that hide targets.
- New unit, enemy, doctrine, or save fields.
