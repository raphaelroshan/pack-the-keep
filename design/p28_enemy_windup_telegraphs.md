# P28 Enemy Wind-up Telegraphs

## Player-facing purpose

The player should be able to anticipate the next hit from the board itself. Cadence bars communicate timing numerically, while a restrained role-specific wind-up communicates what kind of attack is about to land and where attention is needed.

## Data shape

No new authoritative data is added. The presentation combines the existing enemy `attack_style`, target, and read-only `enemy_attack_timing()` projection.

The wind-up begins after 55% of the current strike interval has elapsed and exposes a normalized intensity from zero to one.

## Presentation

- `melee`: a short directional chevron and forward pressure mark toward the target.
- `ranged`: a violet charge orb and faint aim line toward the target.
- `demolition`: an amber brace and concentric weight rings around the attacker.
- Reduced motion uses a static style glyph at constant size and opacity.
- Wind-ups appear only for contacted, living enemies with a valid target and a strike still inside the six-tick assault.

## Acceptance criteria

1. A read-only wind-up projection reports active state, style, target, and normalized intensity.
2. No wind-up appears during approach, without a target, or during the first half of an attack interval.
3. Melee, ranged, and demolition wind-ups have distinct silhouettes and colors.
4. Pause freezes the wind-up because it reads the existing battle clock.
5. Reduced motion removes pulsing and travel without removing the warning.
6. Serialized simulation state is unchanged by wind-up inspection or drawing.

## Non-goals

- Interrupts, parries, dodges, or player-issued target changes.
- A second attack timer or sub-tick damage.
- New save fields, physics, animation trees, or authored sound assets.
