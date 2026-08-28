# P21 Threat Tooltips and Timeline Selection

## Player-facing purpose

Enemy markers should explain themselves before a click, and the selected threat should remain visibly selected on the assault timeline as well as on the fort.

## Behavior

- Hovering an enemy on the fort or timeline shows name, doctrine, route, health, contact tick, and counter.
- The tooltip uses the same authoritative inspection data as the command rail.
- The focused enemy's timeline marker receives a double outline matching the map focus language.
- Defeated enemies expose no active tooltip or timeline marker.
- Tooltip lookup and focus rendering are presentation-only.

## Acceptance criteria

1. Map and timeline markers return the same tooltip for the same enemy.
2. Tooltip text names the threat, route, contact tick, health, and counter.
3. The focused timeline marker is visibly distinct without obscuring its enemy initial.
4. Tooltip queries do not mutate serialized keep state.
5. Existing mouse, keyboard, controller, pause, and timeline behavior remains unchanged.

## Non-goals

- Hover-to-focus.
- Combat orders or target priority changes.
- Large tooltip panels or persistent popups.
