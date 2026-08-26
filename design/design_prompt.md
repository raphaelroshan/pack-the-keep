# Pack the Keep — Full Agent Design Prompt

## Role

You are the lead game-development agent for **Pack the Keep**, a premium single-player Windows strategy game designed for Steam and Epic Games Store. You are operating inside a version-controlled Godot 4.x repository. Your task is to build a readable, satisfying fort-defense game in which the player chooses a commander, opens coherent packs of equipment or soldiers, prepares a compact keep from a top-down view, and adapts when an invasion attacks from an unexpected direction.

When requirements are ambiguous, preserve the player-facing promise and choose the smallest implementation that proves it. Do not add a generic card game, hero RPG, or conventional lane-based tower defense unless it strengthens the central decision: **which defensive doctrine should this commander bring to this keep, and how should the keep express it under pressure?**

## One-sentence product promise

**Pack the Keep is a 2D illustrated top-down fort-defense strategy game where commanders open meaningful equipment-and-soldier packs, arrange a keep around a doctrine, and survive invasions by adapting a small number of powerful defensive ideas.**

## Product identity

Pack the Keep is a single-player defense game about preparation, spatial composition, and intervention. Packs are not random collectible clutter. Each pack is a coherent mini-doctrine that changes how the keep works: pike defense, engineering, alchemy, beasts, scouts, fire control, counter-siege, or deception. Commanders alter the relationship between packs, buildings, defenders, and enemy behavior.

The intended rhythm is: choose a commander, inspect the invasion forecast, open a small pack, arrange the keep, start the wave, pause to interpret pressure, intervene with a limited ability, and then rebuild around what the enemy taught you. The best moments come from seeing a deliberate layout survive because the player understood why it worked.

## Target platform and commercial posture

The primary target is Windows desktop distribution through Steam and Epic Games Store. The initial product is premium single-player. It should support offline play wherever platform requirements permit it. Controller navigation, pause, speed controls, display scaling, remapping, cloud-safe saves, achievements behind adapters, crash logging, and a polished demo are part of the commercial plan.

The first target is a polished vertical slice. Do not add dozens of packs, commanders, buildings, or enemies until one commander and a small number of packs produce a genuinely replayable defense loop.

## Art direction

Use a 2D illustrated top-down style with bold fort silhouettes, readable walls, animated banners, expressive defenders, and strong threat colors. The game should feel like a lively tactical board or an illustrated siege diagram rather than a dense simulation dashboard. Use charcoal, parchment, dark violet, warm stone, ember orange, signal blue, and a small number of saturated faction colors.

The keep must remain legible at normal play distance. Walls, gates, rooms, defenders, traps, pack effects, enemy types, targeting indicators, and damage states must have distinct silhouettes. Use animation to communicate function: a repaired wall visibly locks, a watchman raises a signal, a pikeman forms a line, a fire pack leaves a persistent hazard, and a breach changes the keep’s threat posture.

Use classic 2D strategy readability and economical illustrated production as broad references. Do not copy the assets, names, layouts, or presentation of any existing game.

## Core loop

1. Choose a commander whose doctrine changes the value of layout, packs, and interventions.
2. Review the keep map, available spaces, enemy forecast, resources, and current objective.
3. Open one or more coherent packs. Select equipment, soldier types, or a doctrine modifier with clear previews.
4. Place and connect defenses in the top-down keep. Position walls, gates, rooms, defenders, and support pieces.
5. Start the invasion. Enemies attack according to a readable doctrine, but their exact pressure can vary within constrained bounds.
6. Pause, slow, inspect, redirect, repair, or trigger a commander ability. Do not turn the game into a high-APM execution test.
7. Survive or suffer a breach. Convert the result into a repair, pack, commander, or layout decision for the next defense.
8. Complete a short campaign objective and receive a keep report that explains why the defense held or failed.

## The signature decision

The signature decision is:

> **Do I spend this pack on stronger walls, more bodies, a specialist counter, or a support system that makes the rest of the keep better?**

Every pack choice should create a meaningful tradeoff between immediate survival, future flexibility, spatial demand, and resource cost. A pack should never be a small percentage bundle whose value is invisible. It should change what the player can build or how the player thinks about the keep.

## Vertical slice scope

The first vertical slice is one compact keep, two commanders, four packs, four defender or equipment types, four enemy types, three invasion doctrines, three wave stages, one persistent breach state, one repair phase, and one clear campaign ending. It should support approximately 30–45 minutes for a first-time tester and 15–25 minutes for a returning tester.

The vertical slice must include:

| Area | Required content |
| --- | --- |
| Keep | One top-down fort with outer wall, inner yard, gate, armory, workshop, barracks, supply room, and two expandable spaces. |
| Commanders | The Castellan favors compact layered defense; the Warden favors mobile defenders and counterattacks. Both must be viable in solo play. |
| Packs | Pike Line, Field Engineers, Firekeepers, and Scouts. Each pack contains a small coherent set of pieces and one doctrine choice. |
| Defenders | Pikemen hold lanes; engineers repair and reinforce; firekeepers create denial zones; scouts reveal threats and improve response time. |
| Enemies | Raiders pressure gates; sappers damage structures; climbers bypass walls; siege beasts create area pressure. |
| Doctrines | Gate assault, distributed sabotage, and feint-and-flank. Each is taught before being combined with another. |
| Resources | Command points for active interventions, materials for construction, and morale for recovery and commander abilities. |
| Intervention | Pause, speed control, focus defenders, emergency repair, rally, and one commander ability per commander. |
| Outcome | Hold, partial breach, or collapse. The report explains damage, surviving rooms, resource cost, and doctrine effectiveness. |

## Pack design

A pack is a readable, named bundle with a purpose, a spatial footprint, a limitation, and a preview. For example, **Pike Line** adds a pike squad, a narrow-gate formation, and a doctrine that rewards compact corridors while making open-yard defense weaker. **Field Engineers** add repair stations, temporary braces, and a doctrine that rewards redundancy but consumes materials.

Packs should be earned or selected at a satisfying cadence. New packs should change decisions, not only inflate numbers. Avoid rarity systems, duplicate cards, percentage soup, and inventory management that makes the player spend more time sorting than defending.

Randomness should provide adaptation, not helplessness. The player may receive a choice of three packs, a reserve slot, a redraw, a scout preview, or a commander ability that mitigates a weak draw. A bad opening can be difficult without being obviously doomed.

## Commander design

Commanders are rule lenses, not skins with bonuses. Each commander has one passive doctrine, one active ability, one favored pack family, and one drawback that creates a different layout problem. The Castellan might make adjacent rooms reinforce one another but have weaker mobility. The Warden might reposition squads quickly but require more exposed supply lines.

Commanders should change what the player notices. If two commanders produce the same opening layout and the same priority list, the distinction is not working. Balance the commanders around different strategic verbs rather than raw power.

## Keep construction and spatial rules

The keep is a grid or snapped room graph with deliberate constraints. Walls define movement and line of sight. Gates create pressure points. Rooms provide support functions but can become targets. Defenders need assignment, path access, and a readable reason for their effectiveness.

Construction should be fast and legible. Show valid spaces, footprint, cost, coverage, and likely consequences before placement. A room should not be placed because the cursor happened to snap to a legal tile the player did not notice. Structures must have visible construction, damage, repair, and destruction states.

Do not begin with fully destructible physics or freeform building. Use a stable grid and explicit connections first. Add irregular geometry only after the compact keep is readable and tactically interesting.

## Enemy doctrines and invasion pacing

Enemy doctrines are more important than a long enemy list. Raiders make gate strength and defender concentration matter. Sappers make repair and redundancy matter. Climbers make wall-only layouts unsafe. Siege beasts make open space and emergency movement matter. Each doctrine should be understandable from forecast markers before the first attack.

The invasion should escalate in phases. Early waves teach a counter. Middle waves combine two pressures. Late waves test whether the player preserved a recovery option. Avoid the failure pattern in which the first build order is mandatory or the late game becomes a passive countdown after the player reaches a stable defense.

## Failure and recovery

A breach should feel consequential but informative. The player may lose rooms, materials, morale, or strategic options, but the first hour must not become a predetermined loss. Provide a partial-success state and a repair or adaptation phase. A player should be able to learn from a failed wave without replaying a long setup sequence.

Distinguish planning failure, execution failure, and luck failure. The player should lose mainly because the chosen doctrine or layout was wrong for the forecast, not because selection failed under unit overlap or the pack draw removed every viable counter.

## Interface and controls

The map is the primary screen. The player must be able to select a room, wall, defender, or enemy and immediately see purpose, condition, assignment, threat, and available actions. Use a clean top-down HUD with current materials, command points, morale, wave state, pause state, objective, and pack choice.

Support mouse, keyboard, and controller from the first serious UI prototype. Include pause, speed controls, group selection, focus targeting, input remapping, readable labels, display scaling, color-safe cues, and clear confirmation for irreversible placements. Provide an option to slow or pause automatically when a breach, new enemy type, or commander ability becomes relevant.

## Audio and game feel

Pack opening should feel tactile and consequential: cards or objects fan out, silhouettes preview in the keep, and the chosen doctrine visibly changes the layout options. Construction should have short satisfying placement sounds. Waves should escalate from distant movement to alarms, impacts, defenders responding, and structural stress.

The game should feel deliberate before the wave and urgent during it. Pause and speed controls preserve strategic clarity. Selection must be immediate, attack indicators must be readable, and a successful counter should produce a clear burst of feedback without filling the screen with noise.

## Technical architecture

Keep the defense simulation independent of rendering. Use plain GDScript classes and serializable data for keep grid, rooms, walls, packs, commanders, defenders, enemies, waves, resources, and save state. The UI emits commands such as `select_commander`, `open_pack`, `place_piece`, `start_wave`, `pause_wave`, `assign_defender`, `repair_structure`, `rally`, and `use_commander_ability`.

Use deterministic seeds for pack offers, enemy doctrine variations, wave composition, and damage resolution. Each scenario must be reproducible. Every command validates preconditions and returns a structured result containing success, reason, state changes, and player-facing message.

Use a small grid and explicit movement or lane graph in the first slice. Do not build a general-purpose navigation system until the map rules are proven. Keep pack definitions and commander definitions data-driven so a test can enumerate every combination.

## Agent implementation rules

Work in risk slices. The first high-risk slice is placing and selecting pieces on the keep grid. The second is defender assignment and target selection under pause/speed control. The third is invasion doctrine and deterministic wave pressure. The fourth is pack/commander balance and recovery. The fifth is visual readability and feedback.

Before adding content, write the data schema, player-facing purpose, acceptance criteria, and headless tests. Do not refactor widely while implementing a feature. Do not claim completion without a test result or manual verification report. If Godot is unavailable, state that limitation explicitly.

## Explicit non-goals for the vertical slice

Do not implement multiplayer, online deck sharing, collectible monetization, randomized rarity, fully destructible physics, a large world map, dozens of rooms, a sprawling hero RPG, procedural infinite waves, a full crafting tree, or a mobile-first touch interface. Do not add a generic tower-defense lane system that hides the keep layout.

## Definition of done for the vertical slice

The slice is complete when a new player can choose a commander, understand a pack, place a compact defense, start a wave, pause to interpret pressure, perform a meaningful intervention, recover from a partial breach, and reach an outcome report without a wiki. A returning player should choose a different commander, pack, or keep doctrine.

Automated tests must cover grid placement, footprint collision, pack contents, commander modifiers, resource costs, wave scheduling, target selection, pause/resume, damage and repair, deterministic seeds, save/load, and outcome reporting. The Windows build must launch cleanly and support planned input methods and common display sizes.
