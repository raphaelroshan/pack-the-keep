# Pack the Keep

Pack the Keep is an agent-first Godot 4.x prototype for a premium single-player Windows strategy game targeting Steam and Epic Games Store. Its central mechanic is choosing a commander, opening coherent equipment-and-soldier packs, arranging a compact keep from a top-down view, and adapting when an invasion tests the resulting doctrine.

## Current state

The repository contains a playable, deterministic Early Access candidate with a polished main-menu → War Council → Preparation → real-time Battle → Recovery → Results flow. It supports four commanders, three defensive keeps, fifteen coherent packs, twenty-nine pieces, twelve enemy types, fourteen doctrines, twenty authored scenarios, and fourteen events. Save schema 4, settings schema 5, controller navigation, accessibility options, 1280×720 through 2560×1440 layouts, packaged Windows lifecycle checks, deterministic pause/speed behavior, and the complete First Watch tutorial remain covered by automated gates. The all-scenario matrix now covers 228 commander/scenario/seed cases and 456 uninterrupted/save-resumed simulations. `0.58.0-recovery-action-order` preserves the completed investment roadmap while giving every phase truthful framing, bounded tactical labels, progressive War Council disclosure, and actionable-first Recovery choices; human P16 observation and public distribution remain under explicit owner control.

P51 adds the Quartermaster reserve-economy lens, Twinwatch Bastion's paired-post defense, Road Wardens versus Outriders as a prepared-tempo lesson, and Lantern Watch versus Gloam Knives as a visibility lesson. The Twilight Road completes P51 by teaching those two enemy questions separately, then combining them while preserving prepared-route and flexible-response two-pack plans. Human private-alpha sessions and public distribution approval remain explicitly pending.

P43 adds session-only, opt-in local playtest observation for coarse screen/action counts and an explicit JSON export; it never uploads data and never treats those counts as human evidence. `tools/capture_vertical_slice.gd` produces a stable nine-screen visual sequence for before/after review. P44 adds a read-only Battle presentation snapshot so live state, command availability, threat focus, and response previews no longer have to be assembled directly by the main UI controller. P45 adds a `--debug-ui`-only overlay for layout bounds, focus ownership, viewport size, and clipping diagnostics; normal launches never instantiate it. P46 gives Escape/controller-back a consistent route and confirms before discarding changes not stored in Continue Saved Run. P47 makes every tagged pre-alpha release a self-contained P16 cohort by publishing the exact executable, smoke report, provenance manifest, observer brief, four unfilled matrix templates, release manifest, and source archive together. P48 fits windowed launches inside the active display and gives War Council and Preparation deliberate two-column and stacked compositions based on effective width after UI scaling, keeping their primary actions controller-reachable at 1280×720 through 2560×1440. P49 reuses the authored Greywatch background as restrained stone and timber material layers beneath unchanged tactical geometry, while selected rooms and defenders gain an on-board identity, condition, purpose, and next-action plate. K3 completes the screen-level presentation boundary: War Council, Preparation, Battle, Recovery, and terminal Results now render from deterministic read-only snapshots while commands, focus, simulation, and saves remain under their existing owners. K4 gives each assault an eight-beat visual grammar—forecast, approach, target lock, wind-up, defender response, hostile impact, consequence, and settle—with speed-scaled effects and a static reduced-motion form. K5 separates aftermath decisions from final explanation: Recovery now states the sacrificed alternative beside its first priority, while terminal Results leads with the run's decisive success and remaining cost before the phase timeline. K6 adds the Standard Cutter, a readable assigned-specialist hunter, plus Cut the Chain and The Cut Standard; precision interception and a mobile reserve remain distinct viable answers. K7 exposes the already-deterministic scenario variation before entry and closes the run with a mastery comparison covering seed pressure, doctrine fit, recovery commitment, opened packs, and the first uncovered doctrine worth testing next. K8 consolidates accessibility, persistence, controller, audio, package lifecycle, migration, performance, provenance, failure recovery, and known limitations into one CI-enforced private-alpha gate while keeping every release and human-approval flag false. P54 now kills the packaged Windows process after malformed primaries and valid backups are flushed, then proves run/settings recovery and clean current-schema rewrites on relaunch.

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

For repeatable visual evidence, run Godot with a graphical renderer:

```bash
godot --path . --script res://tools/capture_vertical_slice.gd -- --output-dir=/absolute/output/path --width=1280 --height=720 --ui-scale-index=3
```

The optional width, height, and UI-scale index (`0`–`4` for 80%–200%) make responsive comparisons repeatable. Add `--inspect-starting-defender` to capture the P49 on-board selection treatment, or `--capture-battle-exchange` to freeze phase one at a requested K4 exchange point with `--battle-exchange-progress=0.28`. The harness writes nine ordered PNGs plus `capture-manifest.json`. It is automated visual evidence, not a human playtest result.

## Repository map

| Path | Purpose |
| --- | --- |
| `design/design_prompt.md` | Full product, systems, art, scope, and implementation prompt. |
| `AGENTS.md` | Persistent operating rules for coding agents. |
| `docs/agent_feeding_guide.md` | Staged prompts for building the game one risk slice at a time. |
| `docs/agent_handoff_roadmap.md` | Detailed post-v0.10.0 roadmap, content schemas, UX plan, testing framework, and GPT-agent handoff contract. |
| `docs/game_quality_transformation_plan.md` | Game-quality transformation plan for visual identity, screen flow, battle feedback, recovery/results UX, human playtesting, and staged AI execution. |
| `docs/ai_game_quality_execution_plan.md` | Execution-first AI sequence based on latest automated and visual tests; human testing is optional, not blocking. |
| `docs/investment_evaluation_roadmap.md` | PTK-I1 through PTK-I6 investment-evaluation gates and required evidence. |
| `docs/investment_vertical_completion.md` | Implemented first-plan, persistence, campaign-continuation, visual, and machine-ledger evidence. |
| `docs/visual_evidence_gallery.md` | Versioned internal screenshots from the `0.20.0-first-watch` capture set with Kickstarter archive guidance. |
| `docs/kickstarter_bonus_content.md` | Standalone backer-facing archive concept, suggested copy, provenance, and release guardrails. |
| `docs/latest_test_report_2026-09-01.md` | Latest main-branch automated and visual smoke-test results, screenshots, findings, and next roadmap steps. |
| `docs/latest_visual_review_2026-09-01.md` | Fresh latest-main visual review, exact build metadata, screenshots, findings, and execution priorities. |
| `docs/p16_human_playtest_protocol.md` | Controlled alpha session matrix, observation rules, privacy boundary, and evidence workflow. |
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
| `data/regions/` | Runtime settlement, route anchors, political outcomes, and bounded next-run support. |
| `data/scenarios/` | Runtime keep selection, objectives, recommended pack doctrines, three-wave plans, lessons, and bounded seed variations. |
| `data/events/` | Runtime authored-event triggers, choices, requirements, typed effects, and follow-up links. |
| `data/modifiers/` | Runtime progression modifiers, unlock sources, information effects, and starting trade-offs. |
| `src/core/content_catalog.gd` | Deterministic loader and validator for externalized runtime content. |
| `src/core/keep_state.gd` | Deterministic commander, pack, grid, piece, invasion, ability, recovery, and save logic. |
| `src/ui/main.gd` | Prototype keep display, procedural square-fort map, gate-entry presentation, and command UI. |
| `playtests/sessions/` | Human-authored P16 session evidence; automation validates but never fabricates it. |
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

## v0.21.0 terminal debrief

Completed scenarios now replace the recovery command rail with a dedicated final debrief while preserving the damaged keep beside it. The panel presents the outcome, resources, complete assault timeline, causal chain, persistent room and defender damage, authored consequences, and one concrete replay experiment. Review Setup remains the dominant action, while Save Result and Return to Main Menu are secondary. The debrief is derived entirely from existing authoritative state and adds no run-save fields.

## v0.21.1 preparation brief

Ordinary Preparation now presents the active doctrine question, the layout's visible answer, and one unresolved weakness immediately above **Begin Assault**. The compact summary derives from existing forecast, scenario, layout, and placed-piece read models, while detailed pack and layout information remains in the command rail. It never scores the build or guarantees an outcome, First Watch retains its authored objective card, and rendering the summary does not mutate the keep.

## v0.22.0 board visual hierarchy

The procedural fortress renderer now uses a central visual registry and an explicit structural-to-tactical layer order. Ground forts, river defenses, and upper wall walks have distinct surfaces and frames; critical rooms have a redundant shape cue; defenders use dark role cards and role-family badges; and every enemy family has its own silhouette in both the approach lane and assault timeline. Existing health, damage, focus, placement, hit-testing, targeting, and save behavior remain authoritative and unchanged.

## v0.22.1 battle audio cues

The generated feedback tones now live in a focused `BattleAudioCueService` with one semantic vocabulary for assault start, contact, defender response, hostile impact, breach, recovery, and terminal outcome. The service remains offline and presentation-only, honors mute and effects volume, uses a minimal sequence with reduced motion, and records semantic requests in headless tests without opening an audio device or touching simulation time.

## v0.22.2 assault readiness

The first assault now opens at tick zero with a focused **Sound the Bell** ready state, leaving the fortress, incoming roster, routes, targets, timeline, and response preview visible before time advances. Later phases pause only when the doctrine changes or a new enemy family appears; identical pressure can continue live. Readiness uses the existing pause input, blocks manual stepping until acknowledged, and is re-derived when a tick-zero save is loaded without changing the save schema.

## v0.24.0 inspection hierarchy

Rooms, defenders, and enemies now share one tactical inspection card that answers what the selection is, its current health or condition, why it matters, and what to do next. Explicit inspection reveals the card in the rail, automatic threat focus does not steal scroll, and enemy counters use player-facing names rather than internal IDs.

## v0.23.2 Preparation hierarchy

Preparation now reads as three numbered stages: choose a doctrine pack, place and inspect defenders, then commit the defense. Piece and floor controls live together, while the pack catalogue, authored doctrine selector, and full layout analysis are collapsed behind an Advanced control. The fortress, current question/answer/weakness brief, and primary assault action remain dominant.

## v0.23.1 pack offer card

Preparation now presents the selected pack as a complete doctrine offer rather than a raw dropdown preview. The card shows contents and placement costs, opening cost, strength, limitation, spatial demand, strategic question, opening budget, and Available/Reserved/Opened/No Openings state. Card browsing is presentation-only; Open and Reserve retain the existing authoritative commands, and the advanced dropdown remains as a fallback.

## v0.23.0 War Council choice cards

The War Council now presents commander and defense as two compact game-facing cards. Commander identity, passive strength, intervention, limitation, and first strategic question sit beside the selected keep, objective, teaching question, authored pressure arc, difficulty, peak pressure, terminal rule, and fixed run commitments. Previous/Next card actions use the existing authoritative selection handlers, while the original dropdowns remain under **Advanced Selection** as a secondary fallback. First Watch visibly locks both paths, and the cards stack at 125% scale.

## v0.22.3 recovery hierarchy

Inter-wave Aftermath now places a compact Recovery Lull brief above the damaged fortress. It states what changed, why the damage matters, what the next phase will test, how many actions and materials remain, and one advisory first priority with its trade-off. The command rail now reads **Choose What Survives** while retaining the exact authoritative repair, assignment, clear, and finish commands; terminal Results remains a separate debrief.

## Implemented first battle slice

The current battle slice is **Greywatch Keep**, a two-floor 12×8 keep defended by **The Castellan** or **The Warden**. It implements four basic defenders—Pike Squad, Repair Station, Fire Team, and Scout Post—and four enemy doctrines: Raider gate assault, Sapper distributed sabotage, Climber wall bypass, and Siege Beast area pressure.

Battles resolve through explicit phases: **forecast, approach, contact, intervention, and outcome**. Assaults begin in continuous playback over deterministic one-second ticks; the player reads doctrine and likely targets while enemies move, pauses for inspection when needed, and may use Castellan **Lockdown** once per authored assault phase. The report explains counter damage, enemy arrival, target selection, room damage, repair, breach, and recovery. Each phase ends as a hold, partial breach, or collapse; partial breach remains recoverable.

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


## Temporary asset kit

The testing-only art, audio, VFX, and animation kit is documented in [`docs/temporary_asset_kit.md`](docs/temporary_asset_kit.md). Curated CC0 files are under [`assets/temporary/`](assets/temporary/), with machine-readable provenance in [`assets/temporary/manifest.json`](assets/temporary/manifest.json). These assets support breadth, combat timing, and feel testing; they are not the final Greywatch, commander, or enemy art direction.


## Early Access breadth contract

The skeletal-but-playable Early Access target is defined in [`docs/early_access_requirements.md`](docs/early_access_requirements.md). It preserves Greywatch as the quality anchor while requiring three distinct playable keeps, broader commander/pack/enemy coverage, multiple viable defensive plans, complete recovery and Results loops, and release-safe persistence before Early Access claims are made.

Run `python3 tools/validate_early_access_progress.py` to compare the tracked milestone ledger with the runtime catalog and per-keep scenario floor. PTK-EA-1 through PTK-EA-6 are implemented and the automated candidate gate is ready; human P16 evidence and owner distribution approval remain separate and pending.

| `docs/early_access_requirements.md` | Skeletal-but-playable Early Access breadth floor, quality gates, and agent-executable expansion order. |
| `docs/early_access_decision.md` | Decision record explaining the breadth-versus-depth and spectacle-versus-readability trade-offs. |
| `content/early_access_progress.json` | Machine-readable Early Access floor, current inventory, milestone status, evidence, and release boundary. |


## Investment evaluation roadmap

The full creative vertical and skeletal Early Access campaign requirements are defined in [`docs/investment_evaluation_roadmap.md`](docs/investment_evaluation_roadmap.md). The dated build audit and screenshots are in [`docs/investment_evaluation_review_2026-09-02.md`](docs/investment_evaluation_review_2026-09-02.md). The current investment gate is PTK-I1: lock Greywatch as a complete creative vertical before adding more breadth.


## GPT-5.6 investment execution packets

For a complete Greywatch creative vertical and differentiated Early Access skeleton, issue the larger dependency-aware tasks in [`docs/gpt56_investment_execution_packets.md`](docs/gpt56_investment_execution_packets.md). The current first gate is PTK-GPT56-1 after the latest automated and visual audit.
| `docs/gpt56_investment_execution_packets.md` | Larger dependency-aware tasks for a complete Greywatch creative vertical and differentiated Early Access campaign skeleton. |
| `docs/latest_gpt56_improvement_review_2026-09-03.md` | Latest post-change verification, visual evidence, corrected title status, and next GPT-5.6 task. |
