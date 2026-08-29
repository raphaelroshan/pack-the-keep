# P27 Enemy Attack Styles

## Player-facing purpose

Enemy contact should communicate role through motion. A Raider closing with a defender, an Ash Slinger firing through smoke, and a Sapper striking a support dependency should not share the same generic red line.

## Data shape

Every enemy declares one required `attack_style`:

- `melee`: Raider, Climber, Shield Guard, Shieldbreaker.
- `ranged`: Ash Slinger.
- `demolition`: Sapper, Siege Beast.

The style affects presentation only. Damage, targeting, cadence, armor, protection, and outcome resolution remain authoritative in `PackKeepState`.

## Presentation

- Melee impacts show a compact lunge and slash from the enemy toward the target.
- Ranged impacts show a travelling hostile projectile with a short tail.
- Demolition impacts show a heavy advancing strike followed by a double impact ring.
- Piece damage labels say `HP`; room damage labels say `STRUCTURE`.
- Reduced motion keeps one static role-colored impact mark without travel or lunge.

## Acceptance criteria

1. All enemy definitions provide a validated supported attack style.
2. Resolved target impacts carry the originating enemy style without changing damage.
3. Melee, ranged, and demolition styles produce distinct presentation traces.
4. Piece and room damage labels use the correct target language.
5. Reduced motion removes travel while retaining a visible hit.
6. Save/replay state is unchanged by the presentation field.

## Non-goals

- Collision physics, dodging, knockback, or sub-tick hit authority.
- New damage types, resistances, status effects, or save fields.
- Final authored animation sheets or sound assets.
