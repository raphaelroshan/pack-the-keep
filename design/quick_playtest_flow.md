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

A fresh run begins at the title screen. `Start Game — Quick Playtest` opens Preparation with exactly two starter pieces, an active Gatehouse Lock scenario, and a readable fort. The quick action opens Battle, starts wave 1, advances one step, and leaves the battle active and paused. After a non-collapse wave resolves, Results preserves the explicit two-action repair interval. Once the tester finishes recovery, the next authored wave starts automatically and returns to paused Battle for inspection. Existing deterministic tests, placement-box behavior, focus selection, pause/speed controls, health/ammo overlays, results, and save behavior remain unchanged.

## Refinement: one primary action beside the fort

The playtest now exposes one prominent primary action directly above the fort instead of requiring the tester to find the action in the scrolling command table. Its label changes with the state: `RUN QUICK TEST — ONE BATTLE STEP` in Preparation, `ADVANCE ONE STEP — INSPECT` in Battle, `CONTINUE — START WAVE N/3` in inter-wave Results, and `RESTART QUICK PLAYTEST` in terminal Results. A compact status line explains the current step, pause state, and the available keyboard alternatives.

This reduces first-run search cost while preserving access to the full command table. Empty preparation disables the quick action until a defender is placed; active Battle keeps the action paused and inspectable; inter-wave Results requires explicit recovery completion before the primary action starts the next authored wave; terminal Results restarts the same deterministic preset rather than silently starting a fourth wave.
