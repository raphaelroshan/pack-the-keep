# Pack the Keep

Pack the Keep is an agent-first Godot 4.x prototype for a premium single-player Windows strategy game targeting Steam and Epic Games Store. Its central mechanic is choosing a commander, opening coherent equipment-and-soldier packs, arranging a compact keep from a top-down view, and adapting when an invasion tests the resulting doctrine.

## Current state

The repository contains a playable vertical-slice shell and deterministic keep-state foundation. The main scene demonstrates commander selection, pack opening, top-down piece placement, invasion doctrines, wave progress, commander abilities, and saving prototype state. The drawn keep is intentional prototype presentation; final 2D art can replace it without changing the simulation contract.

Godot is not installed in the sandbox used to generate this package. The project has been scaffolded and statically reviewed but not launched here. Install Godot 4.x locally before feature development.

## Run the prototype

From the project root:

```bash
godot --path . --editor
```

Press **F5** to run the project or **F6** to run the current scene.

## Run tests

```bash
godot --headless --path . --script res://tests/test_keep_state.gd
```

A successful run prints `PASS: Pack the Keep state tests` and exits with code 0. Agents must run this command after changes to commanders, packs, grid rules, pieces, wave logic, abilities, or save state.

## Repository map

| Path | Purpose |
| --- | --- |
| `design/design_prompt.md` | Full product, systems, art, scope, and implementation prompt. |
| `AGENTS.md` | Persistent operating rules for coding agents. |
| `docs/agent_feeding_guide.md` | Staged prompts for building the game one risk slice at a time. |
| `docs/decision_log.md` | Architecture and scope decisions. |
| `docs/setup.md` | Local Godot, Git, platform, and release setup. |
| `src/core/keep_state.gd` | Deterministic commander, pack, grid, piece, invasion, ability, recovery, and save logic. |
| `src/ui/main.gd` | Prototype keep display and command UI. |
| `scenes/Main.tscn` | Main scene entry point. |
| `tests/test_keep_state.gd` | Headless deterministic state tests. |
| `data/` | Future externalized commander, pack, piece, and wave definitions. |
| `assets/` | Future 2D art and audio assets. |

## Agent-first operating model

Give the agent the persistent context prompt in `docs/agent_feeding_guide.md`, then assign one narrow player-facing behavior with acceptance criteria and an exact verification command. A good task names the commander, pack, piece, or invasion behavior and states what must remain out of scope. Do not ask the agent to “build the whole tower-defense game.”

## Recommended implementation order

First stabilize the current grid and headless tests. Then move commander, pack, piece, and enemy definitions into data-driven files without changing behavior. Add command/result boundaries, piece selection, defender assignment, wave composition, damage and repair, authored teaching scenarios, visual feedback, and final 2D art. Add Steam and Epic adapters only after offline save behavior and deterministic defense simulation are stable.

A full Windows build should eventually include controller support, display scaling, remapping, pause and speed controls, safe save migration, platform adapters, achievements, cloud-safe saves, crash reporting, and a polished demo. These services should remain outside the core keep simulation.

## Implemented first battle slice

The current battle slice is **Greywatch Keep**, a two-floor 12×8 keep defended by **The Castellan**. It implements four basic defenders—Pike Squad, Repair Station, Fire Team, and Scout Post—and three enemy doctrines: Raider gate assault, Sapper distributed sabotage, and Climber wall bypass.

Battles now resolve through explicit phases: **forecast, approach, contact, intervention, and outcome**. The player advances one deterministic battle step at a time, reads the doctrine and likely target, and may use Castellan **Lockdown** once per wave. The report explains counter damage, enemy arrival, target selection, room damage, repair, breach, and recovery. A wave ends as a hold, partial breach, or collapse; partial breach remains recoverable.

See [`design/first_keep_battle_slice.md`](design/first_keep_battle_slice.md) for the complete battle contract, enemy mechanics, keep layout, timing, targeting, resources, and deliberate exclusions. The authoritative test suite is now `tests/test_keep_state.gd`, and the machine-readable active-slice declaration is stored in `content/content_manifest.json` and `content/gameplay_framework.json`.

## Implemented repair interval

After a **Held** or **Partial Breach** result, Greywatch opens an authored two-action repair interval. The player can repair a room for 8 materials, repair a damaged piece for 6 materials, assign a unit to its specialist room, clear an old assignment, or close the interval early. The next wave is blocked until the interval closes; collapse skips the interval and returns to preparation.

The implemented assignment rules are Pike Squad → Gate, Repair Station → Workshop, Fire Team → Inner Yard, and Scout Post → North Tower. Assignments are persisted in the state and reported during battle. A Repair Station assigned to Workshop prioritizes that room and repairs it for 12 instead of 8 during contact. The detailed contract is in [`design/greywatch_repair_and_room_assignments.md`](design/greywatch_repair_and_room_assignments.md).

## Enemy actors and menu flow

Raiders, Sappers, and Climbers are now concrete active actors in the prototype. Their route, health, doctrine role, and current target are shown in the enemy readout, while colored markers appear on the Greywatch map: red for Gate pressure, amber for support sabotage, and violet for upper-floor bypass.

The prototype now exposes four menu states: **Title**, **Preparation**, **Battle**, and **Results**. Title begins the run, Preparation handles packs, placement, repair, and assignment, Battle advances the forecasted invasion one step at a time, and Results exposes the outcome and recovery path. Navigation is a UI layer over `PackKeepState`; it does not create a second game-state authority. See [`design/enemy_presentation_and_menu_flow.md`](design/enemy_presentation_and_menu_flow.md) for the presentation contract.

## Unit availability and combat metrics

Greywatch now begins with **Pike Squad** and **Narrow Gate** as starter pieces. Opening a pack during Preparation unlocks its pieces for placement: the first Preparation permits two pack openings, while later Preparations permit one. Packs cannot be opened during an invasion or repair interval, and unavailable pieces are disabled in the command table.

Unit instances track `max_health`, `health`, `condition`, `disabled`, attack count, damage dealt, stopped targets, last target, and assignment. Enemies track maximum health, current HP, damage taken, received attacks, target, and defeat state. A compact aggregate metric record reports battle steps, unit attacks, damage dealt, enemy attacks, room damage, piece damage, repairs, disabled units, and defeated enemies. See [`design/unit_availability_and_combat_metrics.md`](design/unit_availability_and_combat_metrics.md) for the full contract.

## Unit availability and combat metrics

Greywatch begins with **Pike Squad** and **Narrow Gate** as starter pieces. Opening a pack during Preparation unlocks its pieces for placement; the first Preparation permits two pack openings and later Preparations permit one. Packs are unavailable during an invasion or repair interval, and unavailable pieces are disabled in the command table.

Unit instances now track `max_health`, `health`, `condition`, `disabled`, attack count, damage dealt, stopped targets, last target, and assignment. Enemy instances track maximum health, current HP, damage taken, received attacks, target, and defeat state. The compact combat record reports battle steps, unit attacks, damage dealt, enemy attacks, room damage, piece damage, repairs, disabled units, and defeated enemies. See [`design/unit_availability_and_combat_metrics.md`](design/unit_availability_and_combat_metrics.md) for the complete contract.

## Internal base-game test release

The repository now includes a small internal test-release presentation for Greywatch. It uses a generated first-pass visual kit—Greywatch background, Castellan portrait, defender and enemy icons—while leaving the deterministic simulation and battle rules as the source of truth. The test checklist, asset manifest, and deliberate production boundaries are documented in [`docs/internal_test_release.md`](docs/internal_test_release.md).
