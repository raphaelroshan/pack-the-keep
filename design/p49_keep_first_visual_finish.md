# P49 — Keep-first authored visual finish

## Player-facing purpose

Make the fortress feel like the place where decisions happen, rather than a diagram underneath flat cards. The board should retain its exact tactical geometry while gaining a coherent stone, timber, earth, and brass surface language derived from the existing Greywatch art kit. Selecting a room or defender should leave an unmistakable mark on the board and summarize the next useful action without requiring the player to hunt through the command rail.

## Presentation contract

- The existing `greywatch_background.png` is reused as an authored material source for Greywatch floor surfaces. It does not define coordinates, collision, routes, rooms, or placement legality.
- Ground and upper floors use different source regions and overlays so they remain distinct at normal play distance.
- Procedural wall rings, room rectangles, connections, health bars, target lines, actors, placement guides, focus rings, tutorial highlights, and battle effects remain above the authored texture.
- State colors remain authoritative and readable. Texture opacity decreases in high-contrast mode, while frames, critical-room marks, health bars, and focus outlines strengthen.
- A selected room or defender receives a redundant outline plus a compact on-board subject plate naming identity, condition, purpose, and next action.
- Enemy focus keeps its existing battle treatment; P49 does not change threat selection or combat presentation timing.
- Ash Ford retains its river treatment until it receives its own authored asset slice.

## Authority and invariants

This is presentation-only. `PackKeepState`, content definitions, room and piece geometry, hit testing, targeting, damage, resources, placement, recovery commands, save schemas, and replay keys do not change. The authored texture and selected-subject projection are never serialized.

## Acceptance criteria

1. Greywatch reports and draws an authored surface layer while Ash Ford remains on its existing terrain-specific fallback.
2. The board layer order and exact cell, room, and piece geometry remain unchanged.
3. Ground and upper floors use distinct authored source regions and material overlays.
4. Room state fills, critical-room cues, health bars, placement previews, target lines, actors, and tutorial focus remain readable above the texture.
5. Clicking a room or defender produces an on-board selection outline and subject plate derived from authoritative inspection data.
6. High contrast reduces texture noise and strengthens selection/frame cues.
7. Refreshing, selecting, drawing, and changing accessibility settings do not mutate serialized run state.
8. 1280×720 and 2560×1440 captures preserve the responsive P48 layout contract.

## Non-goals

- No new generated image, third-party asset, animation sheet, unit portrait, or sound file.
- No board geometry, room graph, placement coordinate, route, hit-test, simulation, balance, or save change.
- No Ash Ford art replacement in this slice.
- No claim that automated visual review proves player preference.
