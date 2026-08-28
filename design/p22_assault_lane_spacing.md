# P22 Assault Lane and Timeline Spacing

## Player-facing purpose

The gate approach and assault timeline should read as two separate layers: threats occupy the battlefield, while the footer explains when they will make contact.

## Behavior

- Reserve a clear vertical apron beneath the two fort floors for approach markers and their status labels.
- Place the assault timeline below that apron with enough room for selection rings and its next-contact summary.
- Preserve the existing fort geometry, enemy paths, arrival timing, timeline interaction, and responsive scaling.
- Keep the additional height inside the existing scroll-safe page layout.

## Acceptance criteria

1. At battle tick zero, the lowest living ground-route enemy label ends above the timeline bar with visible separation.
2. Focus rings and enemy-specific labels do not overlap the timeline tick labels.
3. The complete timeline and next-contact summary fit inside the canvas design bounds.
4. Hit testing and serialized simulation state remain unchanged.
5. The layout remains readable at the 1600×900 default and reachable at 1280×720.

## Non-goals

- Enemy path or timing changes.
- Camera movement or zoom controls.
- New combat rules, content, or save fields.
- Reworking the command rail or global screen hierarchy.
