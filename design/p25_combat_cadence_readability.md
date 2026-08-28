# P25 Combat Cadence Readability

## Player-facing purpose

Heavy attackers and demolition threats now strike less frequently than skirmishers. The live battle should show that timing clearly enough for a player to decide when to pause or spend a commander ability without reading the event feed after the fact.

## Read-only timing projection

- `PackKeepState.enemy_attack_timing(index)` derives cadence from the enemy definition, authored arrival, current battle step, and target state.
- Before contact it reports the authored contact tick as the next strike.
- At and after contact it reports the next tick on which the cadence modulus permits an attack.
- The projection never advances the clock, reserves a target, or changes serialized state.

## Presentation

- Enemy hover details name the strike cadence and next strike tick.
- The focused response card includes a dedicated `STRIKE` line.
- Contacted enemies carry a thin cadence meter above their health bar that fills toward the next strike.
- Arrival telegraphs, focus rings, health bars, target lines, and the six-tick timeline remain visually distinct.

## Acceptance criteria

1. A one-tick Raider cadence and two-tick Sapper/Shieldbreaker cadence produce deterministic next-strike projections.
2. Pre-contact timing reports the arrival tick; post-contact timing advances to the next valid strike tick.
3. Timing inspection does not mutate authoritative or serialized state.
4. Map and timeline tooltips expose matching cadence text.
5. The focused response card exposes the same next-strike tick.
6. The cadence meter remains presentation-only and does not overlap enemy health or focus rings.

## Non-goals

- Player-issued interrupts, focus fire, stuns, or attack-speed upgrades.
- Sub-tick authoritative attacks or collision-based hit timing.
- New save fields or a generalized status-effect system.
