# P23 Board Label Clarity

## Player-facing purpose

The fort should read as a tactical board rather than a stack of overlapping debug labels. Placed defenders must remain identifiable while room condition remains visible.

## Behavior

- Fit room and defender names to their available board width using stable compact labels when needed.
- When a defender overlaps a room, suppress the room's name and numeric state text beneath it while retaining the room boundary and condition bar.
- Keep full room and defender names, health, status, assignment, and purpose in the existing inspector.
- Preserve high-contrast colors, placement outlines, hit testing, and simulation behavior.

## Acceptance criteria

1. Every rendered room and defender label fits its allotted width.
2. A room overlapped by a placed defender does not draw competing name/state text beneath the defender.
3. Room condition bars remain visible for occupied rooms.
4. Full labels and state remain available through inspection.
5. Label projection does not mutate serialized keep state.

## Non-goals

- Changing room geometry or piece footprints.
- Replacing procedural board art.
- Removing condition bars, placement boxes, or inspector details.
- Changing combat, placement, targeting, or save data.
