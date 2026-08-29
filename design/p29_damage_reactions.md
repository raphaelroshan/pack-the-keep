# P29 Damage Reactions

## Player-facing purpose

When an attack lands, the target's health bar and body should make the loss immediately legible. Players should not need to compare two static bars or read the event feed to understand which defender or room was hurt.

## Data shape

Resolved presentation impacts retain the authoritative target value immediately before and after a combat tick:

- `before_value`
- `after_value`
- existing target kind, target ID, source enemy, attack style, and net damage

These fields live only in the transient UI exchange. They are not serialized and do not change combat resolution.

## Presentation

- A recently damaged health bar retains a short amber loss segment between its new and previous values.
- A struck defender makes a small recoil away from the attacker and receives a brief role-colored outline.
- A damaged room keeps its geometry fixed and receives the same brief outline plus the structure-loss trail.
- Reduced motion removes recoil while retaining the static outline and damage trail.

## Acceptance criteria

1. Target impacts expose exact before and after values derived from authoritative state.
2. Health-bar trails match the normalized lost interval and never exceed the bar bounds.
3. Only piece targets recoil; room geometry never moves.
4. Reduced motion returns zero recoil while retaining visible damage feedback.
5. Damage-feedback queries do not mutate serialized state.
6. Existing deterministic outcomes and save compatibility remain unchanged.

## Non-goals

- Physics knockback, interruption, invulnerability frames, or hit stun.
- Persistent combat log state or new save fields.
- Final sprite animation sheets or particles.
