# Pack the Keep — Quick Playtest Flow

## Intent

Make the internal build immediately playable by a new tester. The main menu offers a clear `Start Game — Quick Playtest` button that opens a deterministic Greywatch preparation state instead of requiring the tester to configure the full prototype first.

## Preset

The button resets seed `3307`, selects the Gatehouse Lock scenario and Gate Assault doctrine, and applies the existing recommended starter layout through the authoritative placement API. The preset contains Pike Squad and Narrow Gate, remains editable, and opens on the Preparation screen with the fort board visible.

The menu also retains `Open Empty Preparation` for testing the unseeded setup path. This keeps the quick path convenient without removing access to the broader preparation controls.

## Test action

`Quick test: advance one battle step` starts the staged Gatehouse Lock invasion and resolves one manual deterministic step. The action intentionally leaves the battle paused so a tester can see the enemy route, gate-entry state, target information, defender overlays, and event text before pressing Space or N for more steps.

The action is a presentation convenience. It does not add a second simulation path, alter the seed, bypass placement validation, or change combat resolution. Repeated use while a wave is active is safely blocked with a direction to use Space or N.

## Acceptance criteria

A fresh run begins at the title screen. `Start Game — Quick Playtest` opens Preparation with exactly two starter pieces, an active Gatehouse Lock scenario, and a readable fort. The quick action opens Battle, starts the invasion, advances one step, and leaves the battle active and paused. Existing deterministic tests, placement-box behavior, focus selection, pause/speed controls, health/ammo overlays, results, and save behavior remain unchanged.
