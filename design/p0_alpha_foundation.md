# Pack the Keep P0 alpha foundation

## Purpose

P0 converts the Greywatch prototype from a command-table demonstration into a direct, inspectable player loop. It keeps the current deterministic state model and four-screen flow, but makes the keep grid and pack choices the primary preparation interface.

## P0 decisions

| Surface | Decision | Trade-off |
|---|---|---|
| Placement | Select a piece, click a grid cell, and see a footprint preview before committing. The preview reports valid/invalid placement, floor, cost, role, and remaining materials. | More UI state than “place at next slot,” but the player can understand spatial decisions. |
| Selection | Click a room, piece, or active enemy to open a compact inspector. Keyboard focus and the existing option controls remain available as a fallback. | The map gains interaction responsibility, but the simulation remains the only authority. |
| Pack choice | Preparation shows a three-card offer: each card previews doctrine, pieces, costs, and spatial role. The player may open one offer and reserve one other offer for the next preparation. | A small reserve state is added, but there is no rarity, duplicate pack, or collectible-inventory system. |
| Save | Save files use a schema version, write to a temporary path before replacement, and expose Load, New Run, and Reset Run. Invalid or incompatible files are rejected without replacing the current state. | More filesystem code and explicit error messages, in exchange for safe external testing. |
| Controls | The command table is grouped into Preparation, Battle, Recovery, and Save sections; direct map actions are normal play, while “Place at next slot” remains a deterministic fallback. | The panel remains dense at 1280×720, so it uses a scroll container rather than removing existing test controls. |

## Interaction contract

1. In Preparation, selecting an available piece arms placement mode and shows its role, footprint, cost, and preferred floor.
2. Moving over the keep grid updates a ghost footprint. Green means the piece fits and the player can afford it; red means the simulation rejects the location or the resource cost.
3. Clicking a valid cell calls the existing `place_piece` command. The UI never mutates the pieces dictionary directly.
4. Clicking a room, placed piece, or enemy updates the inspector. The inspector explains health/condition, assignment, role, target, route, or the active doctrine.
5. Starting a wave or opening a repair interval exits placement mode and clears the preview.
6. Invalid commands remain invalid at the state layer, even if a UI control is accidentally triggered.

## Pack-choice contract

The offer set is deterministic and limited to `pike_line`, `field_engineers`, `firekeepers`, and `scouts`. A pack card shows name, doctrine, contained pieces, pack cost, and a concise “solves / asks” summary. Opening an offer consumes one preparation opening and moves the pack into `owned_packs`. Reserving an offer does not grant its pieces and can be changed only while the preparation offer is open. A reserved pack is shown as a named card in the next preparation and is still subject to duplicate and opening rules.

## Save-recovery contract

The save payload contains `schema_version`, `game_id`, and the existing deterministic state. P0 accepts schema version 1 and can load legacy payloads with no version by treating them as version 1. It rejects non-dictionaries, another game ID, future schema versions, malformed JSON, and invalid required collections. The UI keeps the current state if a load fails, reports the reason, and offers New Run as a clean replacement.

## P0 acceptance tests

- A player can place at least one starter and one pack-gated piece by clicking the map rather than using the fallback placement button.
- A valid preview turns green; an overlap, out-of-bounds cell, unavailable piece, or unaffordable piece turns red and does not change the state.
- Clicking a room/piece/enemy produces an inspector with the authoritative details.
- The pack offer preview lists pieces and doctrine before opening; reserve state is deterministic and does not grant pieces.
- Duplicate and exhausted pack openings fail cleanly.
- Save/load round-trips P0 selection/offer state without changing battle results.
- Malformed and future-version saves are rejected without destroying the current run.
- Existing deterministic battle, repair interval, assignment, content, policy, parser, and scene smoke tests continue to pass.
