# Pack the Keep

Pack the Keep is an agent-first Godot 4.x prototype for a premium single-player Windows strategy game targeting Steam and Epic Games Store. Its central mechanic is choosing a commander, opening coherent equipment-and-soldier packs, arranging a compact keep from a top-down view, and adapting when an invasion tests the resulting doctrine.

## Current state

The repository contains a playable vertical-slice shell and deterministic keep-state foundation. The main scene demonstrates commander selection, scenario selection, pack opening, top-down piece placement, invasion doctrines, wave progress, commander abilities, authored event choices, and saving prototype state. P7 adds the Runner Network and Fallback Convoy, four mobile-response pieces, Rolling Breach, and The Relief Road. P8 adds a validated three-event Relief Road chain whose typed effects are owned by `PackKeepState`. P9 adds persistent Campaign Ledger progression. Roadside Intelligence reveals the next authored wave composition for one less starting morale, while Hardened Vanguard gives every enemy two additional health as an optional no-reward challenge; exactly one modifier or none may be selected. Event and progression state persist through save schema 4. P10 persists accessibility, UI scale, keyboard/controller bindings, display/audio choices, bounded event-feed retention, optional threat auto-pause, and semantic audiovisual cues outside the deterministic simulation. P11 includes three isolated teaching pairs—armor, signal disruption, and protection piercing—plus Three Bells at Dusk, a three-wave challenge that composes all three while preserving two viable two-pack answers. P12 adds a packaged Windows smoke gate for offline launch, controller/remap/scaling, pause/manual-step, clean teardown, relocated reinstall continuity, pre-mutation nested validation with non-mutating run/settings primary-backup recovery, a machine-readable readiness audit, and a local 54-case all-scenario viability matrix whose uninterrupted and save-resumed runs must match exactly. P13 integrates `workshop_can_wait`, bounded Ledger/Results history, The Wrong Wall chain, Mara Venn's Second Door arc, and the deterministic one-in-three Old Drain occurrence. P14 extracts a stateless authored-event panel, adds a machine-readable event schema with bounded scheduling rules, and expands packaged Windows verification across clean-install, relocated reinstall, stale-backup, missing-profile, and schema-upgrade cases. P15 adds Ash Ford Redoubt as a second data-driven defensive identity: a different room graph, visible river causeway, Runner Network plus Field Engineers doctrine, and shallow distributed repairs. The battle remains a real-time presentation over deterministic one-second steps, and the procedural board renderer keeps placement, routes, targets, armor, signals, protection, condition, and event consequences readable without claiming final art.

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

A successful run prints `PASS: Pack the Keep battle-state tests` and exits with code 0. Agents must run this command after changes to commanders, packs, grid rules, pieces, wave logic, abilities, scenarios, variation, save state, or presentation callbacks. The repository verification wrapper also runs `tests/test_p1_balance.gd`, the tracked `tests/test_p2_ui.gd`, `tests/test_p3_ui.gd`, and `tests/test_initial_combat.gd`; the former replays both commanders across all three P1 scenarios, compact/recovery/open-yard layouts, and two deterministic seeds, while the UI tests verify pause, speed, manual stepping, named actions, keyboard-equivalent placement, presentation-only accessibility/audio toggles, deterministic enemy hit-testing, map/dropdown focus synchronization, focus cycling, preview invariance, paused intervention, finite ranged ammunition, melee no-ammo behavior, recovery reloads, and same-seed auto-battle replay. The internal P3 gate additionally runs content/framework validators, policy checks, Godot editor parsing, a headless scene smoke test, and a real virtual-display preparation/battle capture.

## Repository map

| Path | Purpose |
| --- | --- |
| `design/design_prompt.md` | Full product, systems, art, scope, and implementation prompt. |
| `AGENTS.md` | Persistent operating rules for coding agents. |
| `docs/agent_feeding_guide.md` | Staged prompts for building the game one risk slice at a time. |
| `docs/agent_handoff_roadmap.md` | Detailed post-v0.10.0 roadmap, content schemas, UX plan, testing framework, and GPT-agent handoff contract. |
| `docs/decision_log.md` | Architecture and scope decisions. |
| `design/p5_recovery_action_cards.md` | P5 contract for authoritative, state-aware recovery choices. |
| `design/p5_causal_final_report.md` | P5 contract for deterministic outcome lessons and replay experiments. |
| `design/p5_layout_summary_and_commander_comparison.md` | P5 contract for read-only spatial evidence across both commander doctrines. |
| `docs/setup.md` | Local Godot, Git, platform, and release setup. |
| `data/packs/` | Runtime pack definitions loaded and validated by the content catalog. |
| `data/commanders/` | Runtime commander identities, abilities, doctrine text, and starting resources. |
| `data/pieces/` | Runtime defensive-piece footprints, combat profiles, availability, and assignments. |
| `data/enemies/` | Runtime enemy actors, timing, routes, target priorities, counters, and telegraphs. |
| `data/doctrines/` | Runtime invasion compositions, forecast questions, pressure summaries, and counter families. |
| `data/keeps/` | Runtime room graphs, geometry, spatial rules, recovery profiles, and board labels. |
| `data/scenarios/` | Runtime keep selection, objectives, recommended pack doctrines, three-wave plans, lessons, and bounded seed variations. |
| `data/events/` | Runtime authored-event triggers, choices, requirements, typed effects, and follow-up links. |
| `data/modifiers/` | Runtime progression modifiers, unlock sources, information effects, and starting trade-offs. |
| `src/core/content_catalog.gd` | Deterministic loader and validator for externalized runtime content. |
| `src/core/keep_state.gd` | Deterministic commander, pack, grid, piece, invasion, ability, recovery, and save logic. |
| `src/ui/main.gd` | Prototype keep display, procedural square-fort map, gate-entry presentation, and command UI. |
| `design/visual_fort_initial_run.md` | Visual-first fort, placement-zone, and gate-entry contract. |
| `design/top_down_board_art_direction.md` | Map-first pixel-board art direction and overlay rules. |
| `scenes/Main.tscn` | Main scene entry point. |
| `tests/test_keep_state.gd` | Headless deterministic state tests. |
| `tests/test_initial_combat.gd` | Initial real-time auto-battle, ammunition, reload, and replay tests. |
| `data/` | Future externalized commander, pack, piece, and wave definitions. |
| `assets/` | Future 2D art and audio assets. |

## Agent-first operating model

Give the agent the persistent context prompt in `docs/agent_feeding_guide.md`, then assign one narrow player-facing behavior with acceptance criteria and an exact verification command. A good task names the commander, pack, piece, or invasion behavior and states what must remain out of scope. Do not ask the agent to “build the whole tower-defense game.”

## Recommended implementation order

First stabilize the current grid and headless tests. Then move commander, pack, piece, and enemy definitions into data-driven files without changing behavior. Add command/result boundaries, piece selection, defender assignment, wave composition, damage and repair, authored teaching scenarios, visual feedback, and final 2D art. Add Steam and Epic adapters only after offline save behavior and deterministic defense simulation are stable.

A later Windows alpha should still add platform adapters, achievements, cloud-safe saves, crash reporting, authored animation sheets, and a fuller soundscape. P10 establishes controller navigation, keyboard/controller remapping, user-persistent display/window controls, effects volume, reduced motion, and high-contrast presentation without moving those services into the core keep simulation.

## Implemented first battle slice

The current battle slice is **Greywatch Keep**, a two-floor 12×8 keep defended by **The Castellan** or **The Warden**. It implements four basic defenders—Pike Squad, Repair Station, Fire Team, and Scout Post—and four enemy doctrines: Raider gate assault, Sapper distributed sabotage, Climber wall bypass, and Siege Beast area pressure.

Battles now resolve through explicit phases: **forecast, approach, contact, intervention, and outcome**. The player advances one deterministic battle step at a time, reads the doctrine and likely target, and may use Castellan **Lockdown** once per wave. The report explains counter damage, enemy arrival, target selection, room damage, repair, breach, and recovery. A wave ends as a hold, partial breach, or collapse; partial breach remains recoverable.

See [`design/first_keep_battle_slice.md`](design/first_keep_battle_slice.md) for the complete battle contract, enemy mechanics, keep layout, timing, targeting, resources, and deliberate exclusions. The authoritative test suite is now `tests/test_keep_state.gd`, and the machine-readable active-slice declaration is stored in `content/content_manifest.json` and `content/gameplay_framework.json`.

## Implemented repair interval

After a **Held** or **Partial Breach** result, Greywatch opens an authored two-action repair interval. The player can repair a room for 8 materials, repair a damaged piece for 6 materials, assign a unit to its specialist room, clear an old assignment, or close the interval early. The next wave is blocked until the interval closes; collapse skips the interval and returns to preparation.

The implemented assignment rules are Pike Squad → Gate, Repair Station → Workshop, Fire Team → Inner Yard, and Scout Post → North Tower. Assignments are persisted in the state and reported during battle. A Repair Station assigned to Workshop prioritizes that room and repairs it for 12 instead of 8 during contact. The detailed contract is in [`design/greywatch_repair_and_room_assignments.md`](design/greywatch_repair_and_room_assignments.md).

## Enemy actors and menu flow

Raiders, Sappers, Climbers, and Siege Beasts are concrete active actors in the prototype. Their route, health, doctrine role, and current target are shown in the enemy readout, while colored markers appear on the Greywatch map: red for Gate pressure, amber for support sabotage, violet for upper-floor bypass, and an enlarged ember marker for Siege Beast area pressure.

The prototype now exposes four menu states: **Title**, **Preparation**, **Battle**, and **Results**. Title begins the run, Preparation handles packs, placement, repair, and assignment, Battle exposes the forecast and can run automatically at 0.5×/1×/2× or advance one step at a time, and Results exposes the outcome and recovery path. Space pauses or resumes, `1`/`2`/`3` select speed, `N` steps once, `R` arms placement, Escape cancels, `M` toggles feedback tones, and `C` toggles high-contrast cues. The visible map includes room condition bars, explicit state words, piece health bars, declared target lines, and an `AREA` radius marker for Siege Beast pressure. Navigation, timing, focus, and response previews are UI layers over `PackKeepState`; they do not create a second game-state authority. See [`design/enemy_presentation_and_menu_flow.md`](design/enemy_presentation_and_menu_flow.md), [`design/p2_presentation_and_input.md`](design/p2_presentation_and_input.md), and [`design/p3_focus_and_response.md`](design/p3_focus_and_response.md) for the presentation contracts.

## Unit availability and combat metrics

Greywatch now begins with **Pike Squad** and **Narrow Gate** as starter pieces. Opening a pack during Preparation unlocks its pieces for placement: the first Preparation permits two pack openings, while later Preparations permit one. Packs cannot be opened during an invasion or repair interval, and unavailable pieces are disabled in the command table.

Unit instances track `max_health`, `health`, `condition`, `disabled`, attack count, damage dealt, stopped targets, last target, and assignment. Enemies track maximum health, current HP, damage taken, received attacks, target, and defeat state. A compact aggregate metric record reports battle steps, unit attacks, damage dealt, enemy attacks, room damage, piece damage, repairs, disabled units, and defeated enemies. See [`design/unit_availability_and_combat_metrics.md`](design/unit_availability_and_combat_metrics.md) for the full contract.

## Unit availability and combat metrics

Greywatch begins with **Pike Squad** and **Narrow Gate** as starter pieces. Opening a pack during Preparation unlocks its pieces for placement; the first Preparation permits two pack openings and later Preparations permit one. Packs are unavailable during an invasion or repair interval, and unavailable pieces are disabled in the command table.

Unit instances now track `max_health`, `health`, `condition`, `disabled`, attack count, damage dealt, stopped targets, last target, and assignment. Enemy instances track maximum health, current HP, damage taken, received attacks, target, and defeat state. The compact combat record reports battle steps, unit attacks, damage dealt, enemy attacks, room damage, piece damage, repairs, disabled units, and defeated enemies. See [`design/unit_availability_and_combat_metrics.md`](design/unit_availability_and_combat_metrics.md) for the complete contract.

## P0 alpha foundation

Greywatch now supports direct map interaction in Preparation. Arm an available piece, hover either floor, and read the green valid or red invalid footprint before clicking to place it. Clicking a room or placed piece opens an authoritative inspector; active enemies can be inspected from the command table. Pack offers show contained pieces, material cost, doctrine, the problem they solve, and their spatial demand. One offer can be reserved without unlocking its pieces. The command table is scrollable at the 1280×720 target, and the save controls support atomic replacement, schema/game validation, future-version rejection, Load, and New run / reset.

The detailed P0 contract is in [`design/p0_alpha_foundation.md`](design/p0_alpha_foundation.md), and the expanded deterministic coverage is in [`tests/test_keep_state.gd`](tests/test_keep_state.gd).

## Initial real-time auto-battle

The initial run is a real-time presentation of an auto-battle rather than a click-by-click combat system. The player arranges the keep and starts an invasion; enemies advance along authored routes, resolve behavior-based targets at their arrival steps, and attack on contact. Defenders act automatically. Pike Squad is a melee Gate Road counter and uses no ammunition. Fire Team and Fire Brazier are ranged counters with finite rounds; their ammunition is visible in the inspector and spent in the deterministic combat metrics. Repair Station and Scout Post are support roles that improve recovery or warning rather than direct damage.

Floor and assignment affect response strength. The Castellan’s adjacency, The Warden’s open lanes, specialist assignments, and commander skills modify the automatic routine. Lockdown and Rally are once-per-wave interventions that are armed by the player and resolve on the next authoritative step. A Hold grants recovery, a Partial Breach opens a repair interval, and Collapse returns the run to preparation with surviving ranged defenders reloaded. The complete contract is [`design/initial_real_time_auto_battle.md`](design/initial_real_time_auto_battle.md), with deterministic coverage in [`tests/test_initial_combat.gd`](tests/test_initial_combat.gd).

## P3 focus and response

P3 makes the battle map the primary focus surface. During an active invasion, clicking an enemy marker selects it; Tab and Shift+Tab cycle active enemies, and `E` focuses the current threat. Selection uses the marker radius plus fixed padding, then resolves overlap by nearest center and stable enemy index. The focused enemy receives a double outline, `FOCUSED` label, stronger target line, synchronized dropdown selection, and a response card naming its threat, target or approach state, counter family, commander ability state, and whether the battle is paused for preview. Selection and preview do not mutate authoritative state.

After a Hold or Partial Breach, the command table ranks the most consequential rooms using criticality, condition, and stable room ID. This is advisory guidance over the existing repair commands, not a new recovery authority. The complete contract is in [`design/p3_focus_and_response.md`](design/p3_focus_and_response.md), with coverage in [`tests/test_p3_ui.gd`](tests/test_p3_ui.gd).

## P1 content and replayability

The P1 slice adds two differentiated rule lenses. The Castellan retains compact adjacency and Lockdown; The Warden starts with fewer materials, benefits from open response lanes and signal coverage, and uses Rally once per wave to coordinate the next response. The three authored scenarios are Gatehouse Lock, The Wrong Wall, and Open Yard Net. Each has a different objective, doctrine sequence, wave composition, and seed-derived bounded variation. A Siege Beast now arrives under Area Pressure and damages up to three prioritized nearby rooms on impact, making refuge and recovery matter without introducing irreversible loss.

See [`design/p1_content_and_replayability.md`](design/p1_content_and_replayability.md) for the P1 contract, [`tests/test_keep_state.gd`](tests/test_keep_state.gd) for commander/area-pressure/scenario coverage, [`tests/test_p1_balance.gd`](tests/test_p1_balance.gd) for the bounded replay matrix, and [`tests/test_initial_combat.gd`](tests/test_initial_combat.gd) for ammunition, reload, melee, and same-seed auto-battle replay coverage.

## Internal base-game test release

The repository includes a small internal test-release presentation for Greywatch. It uses a generated first-pass visual kit—Greywatch background, Castellan portrait, defender and enemy icons—while leaving the deterministic simulation and battle rules as the source of truth. The Warden currently uses a clearly labeled tinted shared portrait treatment and Siege Beast uses an enlarged procedural threat marker until a later image-generation window. P2 adds code-generated feedback tones only; it does not claim authored sound effects or final animation sheets. The test checklist, asset manifest, and deliberate production boundaries are documented in [`docs/internal_test_release.md`](docs/internal_test_release.md).
