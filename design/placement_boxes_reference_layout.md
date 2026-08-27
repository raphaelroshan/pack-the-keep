# Pack the Keep — Reference-Informed Placement Boxes

## Intent

Make the fort read as a place where defenders can be positioned, not merely as a diagram. The board remains a deterministic procedural placeholder, but every visible room and upper wall area exposes a clear placement box that can accept a selected piece through the existing grid placement flow.

The supplied reference informs the high-level composition only: a centered fort, distinct rooms and wall sections, strong silhouettes, visible approaches, and side controls. No external assets, exact UI, or copied composition are introduced.

## Placement contract

Each authoritative room receives one highlighted recommended placement box sized for a small defender footprint. The boxes are visual affordances, not a new simulation restriction. Exact placement continues to use the existing floor grid, piece footprint validation, overlap checks, materials, availability, and assignment rules in `keep_state.gd`.

A tester may click or hover any valid grid cell, arm placement, and place a unit on the wall walk, courtyard, or keep room when the authoritative state accepts it. Occupied boxes remain visible beneath the placed piece so the player can understand where the object lives and can compare placement choices.

## Visual hierarchy

The ground fort remains the primary board: outer wall ring, corner towers, open gate, courtyard, and interior rooms. The upper board remains a separate wall-walk view with tower and chapel areas. Placement boxes use a low-contrast warm outline and a small `PLACE` marker so they do not compete with health, ammo, enemy, target, or breach overlays.

The map keeps the existing gate-entry path and enemy route lines. Placement boxes never replace those combat cues.

## Acceptance criteria

At 1280x720, the fort and upper wall remain visible during preparation and combat. Every room and wall area has at least one visible placement box. A selected piece preview still changes the box to valid or invalid using the existing authoritative validator. Placing or selecting a box does not mutate state until the normal placement command succeeds. Existing deterministic state, combat, focus, pause, speed, health, and ammo behavior remains unchanged.

## Art boundary

This is a functional procedural board pass. Final illustrated or pixel-art map assets remain optional and must preserve the same room IDs, floor coordinates, placement cells, and route overlays if added later.
