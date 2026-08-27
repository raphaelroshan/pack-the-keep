# Pack the Keep — Top-Down Board Art Direction

## Visual intent

The fort should read as a **playable board first** and a command interface second. The target is a compact, hand-crafted pixel-art strategy surface with the approachable readability of contemporary pixel-art fort builders, without copying any specific game’s assets, UI, or composition. The closest useful reference is the visual principle of a small, colorful, top-down settlement board: clear silhouettes, chunky masonry, strong floor boundaries, warm light sources, and objects that remain legible when scaled down.

The board must show the keep continuously during Preparation, placement, and Battle. Command text, inspector information, and scenario details may sit beside or below it, but they must not replace the map as the primary spatial explanation.

## Board composition

The default 1280×720 layout presents a ground fort and an upper wall board side by side. The ground fort is a square wall ring with four corner towers, an open central courtyard, named interior rooms, and a bottom-center open gate. The upper board is a wall-walk and post layer with its own room markers. The two surfaces share the same coordinate logic as the deterministic grid and the same placement hit-testing path.

| Spatial element | Required visual language | Interaction meaning |
|---|---|---|
| Outer walls | Thick warm stone ring with repeated block or crenellation marks | Wall placement and early response line |
| Corner towers | Chunky square silhouettes with torch or cap highlights | Strong wall identity and landmarks |
| Courtyard | Open, darker paved square inside the ring | Flexible close-defense zone |
| Keep rooms | Named interior blocks with condition bars | Protected functions and support targets |
| Open gate | Dark opening at the bottom center, warm threshold line, `OPEN GATE` label | All initial placeholder attackers enter here |
| Gate approach | Short visible lane from the gate toward the courtyard | Enemy movement and threat direction |
| Upper wall | Blue-slate wall-walk board with posts and room markers | Ranged and anti-climber placement |

## Overlay rules

Gameplay overlays sit on the board rather than in a separate debug window. A placement preview shows a footprint, `VALID`/`INVALID`, and the current zone word: `WALL`, `COURTYARD`, or `KEEP`. Placed pieces show a compact silhouette, health bar, combat style, zone word, and ammunition when relevant. Active enemies use high-contrast placeholder markers with a stable name/HP label, a route or target line, and a focused outline when selected. The open gate and gate-entry lane remain visible behind these overlays.

Color is supportive but not required. Shape, labels, line patterns, bars, and spatial position must communicate state if color vision is unavailable. Reduced motion should freeze transient cues without removing the selected target, route, health, ammo, or zone information.

## Interaction model

Mouse placement, enemy selection, and room inspection use the same map coordinates. Hovering a cell updates the footprint preview without mutating authoritative state. Clicking a valid cell commits placement only during Preparation. Clicking an active enemy marker selects it during Battle. Keyboard focus cycling must select the same stable enemy indices as mouse hit-testing. Pause keeps the board visible and allows inspection or legal commander intervention before the next authoritative one-second step.

## Art asset boundary

A generated map asset is desirable for the next art window, but it must not be claimed unless it is actually generated and integrated. Until then, the deterministic KeepCanvas renderer is a functional board treatment with pixel-like blocks, towers, torches, paving, and readable overlays. Future generated tiles or a background texture may replace the visual layer while preserving the geometry, hitboxes, labels, and simulation contract.

## Acceptance criteria

A first-time tester should be able to answer these questions from the board alone: Where is the keep? Where is the courtyard? Which side is the open gate? Where will attackers enter? Which pieces are on the wall versus inside the keep? Is the selected placement valid? Which enemy is currently approaching? What is that enemy targeting? How much health and ammunition remain? The 1280×720 screenshot gate must show the fort board during both placement and active battle without the map being pushed entirely below the visible area.
