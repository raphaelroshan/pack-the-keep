# P20 Threat Focus Handoff

## Player-facing purpose

The live battle should open with a useful response preview instead of an empty inspector. When the focused threat is defeated, focus should move predictably to the next urgent enemy. The timeline's arrival markers should also act as direct focus targets.

## Focus rules

- On assault start or loaded active battle, focus the highest-priority living threat automatically.
- Prefer enemies already in contact, then earlier authored arrival, then higher damage, then lower stable enemy index.
- Preserve a player's current focus while that enemy remains alive.
- When that enemy is defeated, hand focus to the next priority without changing combat targeting.
- Clicking an enemy marker on the fort or its arrival marker on the timeline uses the same focus command.
- Keep the enemy dropdown synchronized after every UI refresh.

## Authority boundary

Focus is presentation state only. It reads enemy definitions and runtime state but never changes defender commitment, enemy targets, arrival timing, damage, or serialization.

## Acceptance criteria

1. Battle starts with a focused enemy and populated response preview.
2. A living manually focused enemy remains selected across ticks.
3. A defeated focus hands off deterministically to the next priority.
4. Timeline arrival markers are clickable at every supported display scale.
5. Dropdown, map outline, timeline selection, inspector, and response preview agree.
6. Live status, metrics, event feed, and timeline refresh after each resolved tick.

## Tests

- UI smoke covers initial focus, stable priority, manual preservation, defeated handoff, timeline hit testing, dropdown synchronization, and serialized-state invariance.
- Existing focus, controller, combat, and display regressions remain green.

## Non-goals

- Player-issued focus-fire or retarget commands.
- Changing the deterministic defender target heuristic.
- Selecting defeated enemies.
- A new tactical resource or command-point cost.
