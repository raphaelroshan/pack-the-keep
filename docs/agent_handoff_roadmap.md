# Pack the Keep — GPT-Agent Development Roadmap and Handoff Specification

**Document status:** Active planning contract for post-v0.10.0 development
**Current release baseline:** `v0.12.0-alpha-packaged-smoke`
**Engine:** Godot 4.x, GDScript-first
**Target:** Premium single-player Windows strategy game for Steam and Epic Games Store
**Primary keep:** Greywatch Keep
**Authoring posture:** Agent-first, deterministic, private/internal until a human-approved alpha release

> **Core promise:** Choose a commander, open coherent equipment-and-soldier packs, arrange a readable top-down keep, and adapt when an invasion tests the doctrine that the player built.

This document is intended to be handed to a GPT coding agent together with `AGENTS.md`, `design/design_prompt.md`, `README.md`, `docs/decision_log.md`, and the relevant source and test files. It is both a product roadmap and an implementation contract. The agent must treat the sections marked **Invariant**, **Acceptance gate**, and **Do not** as binding constraints unless the human owner explicitly changes them.

---

## 1. Current baseline and immediate objective

Pack the Keep currently has a playable Greywatch vertical slice. The authoritative simulation is in `src/core/keep_state.gd`; the runtime-built presentation and fort renderer are in `src/ui/main.gd`; the main scene is `scenes/Main.tscn`; machine-readable capability declarations are in `content/content_manifest.json` and `content/gameplay_framework.json`.

The current slice supports two commanders, seventeen active defender pieces/equipment, nine packs, seven enemy types, eight invasion doctrines, eight authored scenarios, two mutually exclusive run modifiers, a two-floor square fort, deterministic six-step combat waves, repair and assignment intervals, finite ranged ammunition, authored armor and armor-piercing counters, nearby ranged support, linked signal redundancy, bounded forecast disruption, adjacent room/piece protection, protection-piercing target selection, commander abilities, pause/speed/manual-step controls, controller navigation/remapping, persistent presentation settings, map-first enemy focus, placement previews, save/load, a quick-playtest flow, and three-wave authored sequences that advance only after explicit recovery completion.

P11 content breadth is complete. Three teaching pairs are implemented: Crossbow Watch versus Shielded Advance, Bell Guard versus Smoke and Signal, and Shieldwall versus Break the Line. Three Bells at Dusk composes all three questions across two viable two-pack baselines. The Campaign Ledger offers Roadside Intelligence or the Hardened Vanguard durability challenge through one data-driven selection boundary. P12 alpha hardening is now in progress: Windows artifacts must launch, exercise offline gameplay, write only beneath an isolated user profile, and shut down cleanly before CI accepts the package. The next bounded objective is malformed-save recovery.

The next objective is not to add a large roster. The next objective is to make Greywatch feel like a complete, legible, replayable game loop and to establish safe extension points so new content can be added without turning the core simulation into an opaque collection of special cases.

### P4 completion means the following is now the reference behavior

| Capability | Current contract |
|---|---|
| Recovery | A resolved Hold or Partial Breach opens a bounded two-action interval. The player may repair, repair a piece, assign, clear an assignment, or finish early. |
| Wave sequence | Finishing recovery explicitly starts the next authored wave once, paused for inspection. There is no silent auto-skip and no fourth wave. |
| Feedback | Recovery advice names the next doctrine and a trade-off target. Results record a compact wave history and deterministic replay key. |
| Layout agency | The fort remains visible during placement and combat. A selected piece can be removed during Preparation without refund so the player can test another layout. |
| Presentation boundary | UI displays state and emits commands. It does not own combat, damage, targeting, placement, or recovery rules. |
| Art boundary | The current fort is a functional procedural fallback. Future art must preserve the board’s composition and readability; no final-art claim should be made until assets are actually produced and integrated. |

---

## 2. The spirit the game must preserve

Pack the Keep should feel like a **small, tactile defensive puzzle with consequences**, not like a conventional tower-defense spreadsheet and not like an inventory screen with combat attached. The player should look at a keep and understand that space, adjacency, routes, floors, rooms, and empty response lanes matter.

The game’s most valuable sensation is: **“I can see the problem, I understand the cost of answering it, and I am choosing which weakness to accept.”** This sensation must survive every future feature.

### Non-negotiable design principles

1. **Packs express doctrines, not rarity.** A pack is a small, coherent answer to a spatial or operational problem. It must alter what the player builds or protects, not merely add a larger number.

2. **Commanders are rule lenses.** Selecting a commander must change what the player notices, values, and sacrifices. A commander is not a portrait attached to a passive percentage bonus.

3. **The keep is the protagonist.** Rooms, walls, floors, gates, support functions, and recovery state must remain visible and mechanically meaningful. Menus must not replace the fort as the primary decision surface.

4. **Every threat teaches a question.** Raiders ask whether the player can concentrate force. Sappers ask whether support dependencies are protected. Climbers ask whether the player left a response lane. Area-pressure threats ask whether recovery was preserved.

5. **Partial loss is information.** A damaged keep should explain what failed and give the player a constrained way to adapt. Avoid death spirals that make recovery performative.

6. **Randomness creates adaptation, not helplessness.** Seeds may vary target priority, pack offers, timing, or pressure, but the player must retain at least one visible counter, reserve, intervention, or recovery option.

7. **Readability beats spectacle.** A simple marker that clearly says `SAPPER → WORKSHOP` is more valuable than a beautiful effect that obscures the route or target.

8. **Solo fairness comes first.** Balance for one player with pause, inspectability, and bounded attention. Do not inherit assumptions from co-op defense games.

9. **Preparation must stay shorter than the interesting battle.** The player should spend time making a meaningful layout, not operating a tedious construction interface.

10. **No hidden authorities.** There must never be one rule in the UI, a second rule in a visual effect, and a third rule in the save system. `KeepState` or its future extracted simulation services own the rule.

### Things the game must not become

Do not add collectible rarity tiers, duplicate pack grinding, monetization, multiplayer balancing, fully destructible physics, a large freeform navigation system, dozens of low-identity units, unexplained percentage soup, forced build orders, long unskippable narrative scenes, or a campaign layer that makes the individual defense disposable. These may be reconsidered only after a compact keep is demonstrably fun and readable.

---

## 3. Long-term product pillars

The roadmap should be organized around five pillars rather than around a raw list of features.

| Pillar | Player-facing question | Systems required | Success signal |
|---|---|---|---|
| Spatial doctrine | What kind of keep am I building? | Grid, floors, zones, adjacency, sightlines, open lanes, pack footprints | Two different layouts can both be viable for different reasons. |
| Adaptive defense | What changes when the forecast is wrong? | Enemy doctrines, focus, pause, commander intervention, recovery | A player can explain why they changed a layout after a breach. |
| Human keep operations | What must be repaired, staffed, or sacrificed? | Rooms, assignments, condition, materials, morale, bounded recovery | Recovery decisions are consequential but not tedious. |
| Authored scenario learning | What is this scenario trying to teach? | Wave plans, event beats, doctrine sequencing, variations, scorecard | New content introduces one new question at a time before combining questions. |
| Replayable mastery | Why play the same keep again? | Commanders, packs, layouts, challenge modifiers, reports, seeded replays | Players compare approaches, not just chase a larger number. |

---

## 4. Roadmap overview

Milestones must be completed in order. An agent may split a milestone into smaller pull requests, but it must not skip the acceptance gate.

| Milestone | Focus | New content policy | Proposed identity |
|---|---|---|---|
| P5 | UX clarity and Greywatch mastery | No large roster; improve existing flow | `v0.11.x-greywatch-mastery` |
| P6 | Data-driven content architecture | Externalize existing content without changing behavior | `v0.12.0-data-contract` |
| P7 | First meaningful content expansion | Add two packs, two units/equipment pairs, and one scenario only after P6 | `v0.13.0-second-doctrines` |
| P8 | Events and scenario authoring framework | Add authored choices with validated effects and deterministic outcomes | `v0.14.0-authored-events` |
| P9 | Campaign/run progression | Add a lightweight map and unlock structure, not grind | `v0.15.0-run-progression` |
| P10 | Presentation and UX polish | Replace high-impact placeholders, accessibility, controller, scaling | `v0.16.0-alpha-ux` |
| P11 | Content breadth and challenge | Add selected commanders, packs, enemy families, and scenario modifiers | `v0.17.x-alpha-content` |
| P12 | Windows alpha and storefront readiness | Offline packaging, crash safety, saves, adapters, human review | `v0.18.0-alpha` |

The numbers are planning identifiers, not permission to release automatically. Every milestone still requires local validation, CI, visual review, and explicit human approval before external distribution.

---

# 5. P5 — Greywatch mastery and UX clarity

P5 should make the existing content easier to understand and more rewarding to replay. It should not introduce a large amount of new content.

## 5.1 Preparation UX

The Preparation screen should answer five questions without requiring the player to scroll through the command table:

1. Which commander am I using, and what does that commander value?
2. Which scenario and doctrine are next?
3. What do my available packs add, and what space or weakness do they create?
4. Where are my current units and what are their valid floors/zones?
5. What is the one most important unresolved layout problem?

Build a compact preparation header containing the scenario name, current wave, commander lens, material total, command points, morale, available pack openings, and a forecast card. The fort remains the main visual body. The command panel should become a contextual inspector rather than a long list of unrelated actions.

The forecast should use plain language and stable structure:

```text
NEXT PRESSURE
Doctrine: Distributed Sabotage
Likely target: Workshop or Supply Room
Question: Can the support chain survive attention splitting?
Your visible answer: Repair Station assigned to Workshop
Your visible weakness: no upper response lane
```

Do not claim that the player’s answer is correct. The forecast identifies a question, not a guaranteed solution.

## 5.2 Placement UX

Placement must remain direct and map-first. Add the following in bounded order:

- A selected-piece inspector with name, role, footprint, preferred floor, preferred zones, cost, and one-sentence trade-off.
- A clear distinction between **arm placement**, **preview**, **confirm**, **cancel**, **remove**, and **reassign**.
- A placement ghost that shows occupied cells, zone, cost, and the reason for rejection.
- A confirmation-free placement flow for valid positions; placement should stay quick.
- Preparation-only removal and re-placement, with no material refund and a visible explanation.
- A lightweight layout summary: ground/upper count, wall/courtyard/keep count, support coverage, open-lane count, and duplicate role warnings.

Do not add arbitrary rotation unless an actual unit requires it. Rotation adds state, test cases, save fields, and visual confusion. Add it only when it creates a real spatial decision.

## 5.3 Battle UX

The Battle screen must communicate the present tactical question before presenting secondary metrics. Order information as follows:

1. Active doctrine and likely target.
2. Focused enemy, route, target, and arrival/contact state.
3. One response preview explaining what the current layout will do.
4. The fort with health, breach, ammo, and placement overlays.
5. Event feed and detailed metrics.
6. Optional commander ability.

Every battle step should generate a causal event chain that can be read in order:

```text
Forecast named Workshop.
Sapper reached the support lane.
Repair Station intercepted with reduced response because it was unassigned.
Workshop took 20 damage.
Partial breach remains recoverable; two recovery actions opened.
```

The player must be able to pause before contact and inspect. Real-time speed is a presentation choice, never a simulation shortcut.

## 5.4 Recovery UX

Recovery is the most important near-term UX area. Replace generic repair language with a short priority puzzle:

- **What happened?** Show the wave outcome and the causal chain.
- **What is next?** Show the next doctrine and likely function under pressure.
- **What can I do?** Show exactly two action slots and legal actions.
- **What am I giving up?** Show the resource, assignment, or future coverage cost.
- **What happens when I finish?** State that the next wave starts paused after explicit closure.

Use an action card pattern:

```text
ACTION 1 OF 2
Repair Workshop
Cost: 8 materials
Benefit: +30 condition; reduces Sapper dependency risk
Trade-off: no specialist assignment this action
[Repair Workshop]
```

For assignment:

```text
ACTION 2 OF 2
Assign Scout Post → North Tower
Cost: one recovery action
Benefit: reveals the Feint and Flank landing target
Trade-off: Scout Post leaves its current response position
[Assign]
```

The advice must remain advisory. It must not disable legal alternatives or silently perform the recommended action.

## 5.5 Results UX

Terminal Results should answer whether the player learned something. Add a structured report with:

- Scenario and commander.
- Three wave rows: doctrine, outcome, principal pressure, defeated enemies, room damage, piece damage, recovery actions.
- Final keep state: morale, breach, materials, surviving pieces, disabled pieces.
- “What worked” and “what failed” derived from state, not guessed from prose.
- The deterministic replay key.
- A replay button and a preparation button, if those become distinct later.
- One suggested experiment, such as “Try the Warden with an open Inner Yard and a Scout Post in North Tower.”

Do not turn the report into a score-only arcade display. The main value is causal understanding.

## 5.6 Settings and accessibility UX

Before alpha, implement a first-class settings layer outside `KeepState`:

- UI scale presets and a user-persistent scale value.
- Fullscreen/windowed mode and resolution handling.
- High-contrast threat cues that do not rely only on color.
- Reduced motion and reduced flash options.
- Text speed and event-feed retention settings.
- Audio mute, effects volume, music volume, and voice volume if voice exists later.
- Keyboard rebinding and controller navigation.
- A visible “pause simulation” rule for accessibility pauses.

Settings must be presentation state. Loading or changing settings must not change a battle seed, combat step, target selection, or outcome.

### P5 acceptance gate

A first-time tester can start the quick playtest, understand the forecast, place or remove a piece, resolve wave one, make a recovery choice, adapt to wave two, inspect a focused threat, complete the scenario, and explain the result using the report. The same run remains deterministic across speed, pause, focus, and display-scale changes.

---

# 6. P6 — Data-driven content architecture

The current prototype keeps definitions in the authoritative script. This is acceptable for the first slice but must not be the long-term content workflow. P6 should externalize definitions **without changing behavior**.

## 6.1 Architecture target

Move authored definitions into validated data resources under a stable project structure. A practical target is:

```text
data/
  commanders/
    castellan.json
    warden.json
  pieces/
    pike_squad.json
    repair_station.json
    fire_team.json
    scout_post.json
    narrow_gate.json
    brace.json
    fire_brazier.json
    signal_beacon.json
  packs/
    pike_line.json
    field_engineers.json
    firekeepers.json
    scouts.json
  enemies/
    raider.json
    sapper.json
    climber.json
    siege_beast.json
  doctrines/
    gate_assault.json
    distributed_sabotage.json
    feint_and_flank.json
    area_pressure.json
  scenarios/
    gatehouse_lock.json
    wrong_wall.json
    open_yard_net.json
  events/
    commander_choice.json
    first_forecast.json
```

Godot `Resource` files are also acceptable, but the source format must remain diffable and easy for an agent to validate. Do not create a single enormous unstructured JSON file as the permanent solution.

The simulation should load a validated `ContentCatalog` or equivalent immutable definitions object at startup. The UI should request display data from the same catalog; it must not duplicate names or roles.

## 6.2 Stable identifier rules

Every content object requires:

```text
id: stable snake_case identifier
content_version: integer or semantic content revision
status: vertical_slice | active | future | deprecated
name: player-facing display name
short_role: one-sentence purpose
question: the player question this content teaches
```

Identifiers must never change because a display name changes. If an identifier must be replaced, add an explicit alias or migration map. Never use array order, localized text, or node names as save identity.

## 6.3 Unit and equipment schema

Units and equipment are both **pieces**, but they need distinct behaviors. The shared schema should include:

```json
{
  "id": "example_piece",
  "kind": "unit",
  "category": "frontline",
  "footprint": [2, 1],
  "allowed_floors": ["ground"],
  "allowed_zones": ["courtyard", "keep"],
  "cost": 8,
  "max_health": 100,
  "placement_question": "Where will pressure be held?",
  "strength_tags": ["gate_assault", "corridor_control"],
  "weakness_tags": ["open_yard", "climber"],
  "attack_profile": {
    "style": "melee",
    "range": 1,
    "cooldown_steps": 1,
    "damage": 12,
    "ammo_capacity": 0
  },
  "support_profile": null,
  "assignment_rules": ["gate"],
  "presentation": {
    "icon": "res://assets/example_piece_icon.png",
    "marker_color_role": "frontline"
  }
}
```

Support pieces should use explicit fields rather than hidden code branches:

```json
{
  "support_profile": {
    "kind": "repair",
    "target_rooms": ["workshop"],
    "condition_restore": 12,
    "response_modifier": "sapper_dependency"
  }
}
```

A new unit is not complete when it can be placed. It is complete when it has a purpose, a footprint, a counter family, a weakness, a visible state, a placement rule, an assignment rule if relevant, a save representation, and deterministic tests.

## 6.4 Pack schema

Every pack must include two or three tightly related pieces, one doctrine, a spatial demand, a strength, a limitation, a choice sentence, and a counter matrix.

```json
{
  "id": "example_pack",
  "name": "Example Pack",
  "family": "support",
  "contents": ["example_unit", "example_equipment"],
  "doctrine": "redundancy",
  "player_question": "What can I afford to lose because I prepared a second chance?",
  "strength": "Makes one failure recoverable.",
  "weakness": "Consumes space and becomes a support target.",
  "spatial_demand": {
    "preferred_floors": ["ground"],
    "preferred_zones": ["keep"],
    "needs_open_lane": false,
    "needs_adjacency": true
  },
  "solves": ["distributed_sabotage", "area_pressure"],
  "asks": ["materials", "support_protection"],
  "commander_affinity": ["castellan", "warden"]
}
```

A pack must not be a disguised upgrade tier. If two packs solve the same problem, they must do so through different spatial or operational choices.

## 6.5 Enemy and doctrine schema

Enemies are authored actors with a declared function. A new enemy requires:

- A stable ID and role.
- A route or route family.
- A target function, not just a nearest building.
- Arrival and contact timing.
- Damage and health profile.
- A readable telegraph.
- At least three plausible counter families.
- A failure mode that does not depend on hidden randomness.
- A report phrase explaining its causal effect.

Doctrines should be separate from enemy definitions. A doctrine chooses a composition, route pattern, target-priority policy, uncertainty, and teaching question. This allows one enemy to appear in more than one authored doctrine without duplicating its base definition.

## 6.6 Commander schema

A commander definition should identify:

- Passive rule lens.
- Once-per-wave or bounded active ability.
- Limitation or opportunity cost.
- Preferred spatial pattern.
- Favored pack families.
- Weakness that another commander handles better.
- UI explanation.
- Tests for both the benefit and the limitation.

New commanders must not be added until the existing commander pair has separate viable layouts and the balance harness demonstrates that neither is a default choice across every scenario.

## 6.7 Scenario schema

A scenario should define:

```json
{
  "id": "example_scenario",
  "name": "Example Scenario",
  "objective": "Hold the support chain while the obvious gate remains a distraction.",
  "lesson": "A clear front line is not enough when the keep depends on one room.",
  "wave_plans": [
    {"doctrine": "gate_assault", "composition": ["raider", "raider"]},
    {"doctrine": "distributed_sabotage", "composition": ["sapper", "raider"]},
    {"doctrine": "feint_and_flank", "composition": ["climber", "raider", "climber"]}
  ],
  "variation_rules": {
    "seeded": true,
    "allowed_changes": ["target_priority", "arrival_offset", "material_pressure"],
    "forbidden_changes": ["remove_all_viable_counters", "change_lesson", "change_wave_count"]
  },
  "completion_report": {
    "success_questions": ["support_chain_preserved", "upper_response_created"],
    "partial_questions": ["what_was_sacrificed", "what_recovered"]
  }
}
```

A scenario should teach one new question in isolation, then combine it with a known question, then test adaptation. Three waves are sufficient for most teaching scenarios. Add more waves only when the pacing and recovery experience justify them.

---

# 7. P7 — First content expansion

Do not begin P7 until the data contract is in place and the content validator can load all existing content from the new format.

The first expansion should be deliberately small:

- One pack that supports open-lane or mobile response.
- One pack that creates a controlled sacrifice or fallback defense.
- One new active unit and one new equipment piece for each pack.
- One new enemy or one new doctrine, but not both at the same time.
- One authored scenario that teaches the new relationship.

A strong candidate direction is to formalize existing design concepts rather than invent unrelated content:

| Content | Purpose | New question |
|---|---|---|
| Runner Network | Mobile response and repair delivery | Where must a reserve be able to arrive before the next failure? |
| Bell Guard | Signal and morale coordination | How does the keep change plans when the first signal is wrong? |
| Ash Slinger | Visibility disruption | Can the player maintain useful information when sightlines are degraded? |
| Counter-Siege | Prepared specialist response | Which large threat is worth reserving space and materials to answer? |

Use only one of these families in the first expansion slice. The design framework already names future concepts; it does not mean they are implemented.

### Content-expansion rule

For each new content item, produce these artifacts before code:

1. A one-page design card explaining purpose, strength, weakness, spatial demand, counter family, failure mode, and visual state.
2. A machine-readable definition with a stable ID.
3. A pack or doctrine relationship entry.
4. A scenario beat that teaches the item.
5. A counter matrix showing at least three responses.
6. A deterministic test plan.
7. An asset brief with silhouette, scale, palette role, and fallback treatment.
8. A balance note describing expected win, partial-breach, and collapse conditions.

The agent must not add a new unit by editing only `keep_state.gd` and a label string.

---

# 8. P8 — Events and authored scenario framework

Events should make the keep feel inhabited and provide decisions that matter without becoming a separate visual-novel game.

## 8.1 Event categories

| Event type | Function | Examples |
|---|---|---|
| Setup | Establish commander, pack, or initial constraint | Two Keys, One Keep |
| Forecast | Add information or uncertainty | The Bell Has a Pattern |
| Recovery | Force a priority choice after damage | The Workshop Can Wait |
| Character | Put a named person or group in tension with the defense | The Warden’s Reserve |
| Trade-off | Exchange materials, morale, space, or future options | Open the Refuge Door |
| Scenario conclusion | Interpret the defense without erasing its cost | The Refuge Bell |

## 8.2 Event implementation contract

Events must be structured data with validated requirements, choices, effects, visible results, and follow-up IDs. UI buttons must call an authoritative event command. Effects must be typed operations, not arbitrary strings evaluated by the UI.

```json
{
  "id": "repair_station_argument",
  "type": "recovery",
  "trigger": {"phase": "recovery", "scenario": "gatehouse_lock", "wave": 2},
  "setup": "The repair crew can stabilize the Workshop or reinforce the upper response lane, but not both.",
  "choices": [
    {
      "id": "stabilize_workshop",
      "requirements": {"materials": {"gte": 8}},
      "effects": [{"op": "repair_room", "room": "workshop", "amount": 30}],
      "visible_result": "The support chain is safer, but the climber lane remains thin."
    },
    {
      "id": "reinforce_upper_lane",
      "requirements": {"piece_available": "scout_post"},
      "effects": [{"op": "assign_piece", "piece": "scout_post", "room": "north_tower"}],
      "visible_result": "The next landing is easier to read, but the Workshop remains damaged."
    }
  ],
  "follow_up": "wave_3_forecast"
}
```

Every event effect must be:

- Validated before mutation.
- Logged in a causal report.
- Deterministic under the same seed and command sequence.
- Saveable if the event is active or resolved.
- Rejected cleanly if requirements are no longer satisfied.

Do not allow events to bypass repair-action budgets, materials, piece availability, scenario completion, or collapse rules.

## 8.3 Narrative tone

Narrative should be short, concrete, and tied to rooms and operations. Characters should have distinct pressures, not only different names. A character beat is valuable when it changes what the player must protect or makes a trade-off emotionally legible.

The game should not moralize every decision. A deliberate sacrifice can be correct. The report should explain consequences without declaring that one style is morally superior.

---

# 9. P9 — Run and campaign progression

Progression should reward learning and completion, not grind. A future campaign layer may use a light regional map, but it must not make Greywatch’s individual defense irrelevant.

## 9.1 Recommended progression layers

1. **Within-wave:** forecast, focus, pause, ability, response.
2. **Between-wave:** repair, assign, reserve, adapt, explicit continuation.
3. **Within-run:** commander, pack offers, room condition, materials, morale, scenario scorecard.
4. **Between-runs:** unlock a new commander, pack, scenario, or modifier through a visible objective.
5. **Campaign:** choose the next keep, route, or political commitment only after the individual defense loop is strong.

## 9.2 Unlock rules

An unlock must add a new decision. It must not simply make all old content obsolete. Every unlock needs:

- A reason it becomes available.
- A teaching scenario or preview.
- A clear limitation.
- A test for first-use comprehension.
- A migration-safe identifier.
- A balance comparison against the current baseline.

Avoid permanent raw power. Prefer new spatial patterns, new recovery options, or new information trade-offs.

## 9.3 Regional map later

A map layer may eventually connect keeps, roads, refugees, supplies, and political choices. It must remain a planning layer over the same core defense loop. A map node should answer “what kind of defense will I be asked to build?” rather than “which menu gives the largest bonus?”

Do not build the regional map before at least two keeps or scenarios have distinct defensive identities. One map node over one keep is mostly decoration.

---

# 10. P10 — Presentation, accessibility, and game feel

The current procedural fort is an honest fallback, not the final art direction. Future presentation work should proceed by impact.

## 10.1 Asset priorities

1. Replace or improve the fort tiles and room silhouettes while preserving grid alignment.
2. Add dedicated commander portraits and readable unit/enemy silhouettes.
3. Add state variants: stable, strained, damaged, breached, disabled, selected, focused.
4. Add only the battle effects that clarify contact, damage, repair, and defeat.
5. Add audio layers for bell, warning, contact, repair, ability, and terminal result.

Every asset must have a small-scale readability check at the normal play distance. An icon that looks good in an asset browser but cannot be distinguished on the board is not finished.

## 10.2 Art rules

Use a 2D illustrated top-down language with bold fort silhouettes, readable room boundaries, restrained palette roles, expressive but compact unit markers, and strong invasion colors. Do not copy external game assets or reproduce another game’s UI. Preserve the square keep, two floors, placement boxes, route lines, and causal overlays as first-class composition elements.

Generated art, if used, must be recorded in `assets/ASSETS.md`, integrated through stable paths, and reviewed for scale, transparency, licensing posture, and readability. If generation is unavailable, use procedural or hand-authored fallback and state that honestly.

## 10.3 Game feel rules

Animation and sound are presentation layers. They may make a deterministic result feel urgent, but they must not change when or whether the result occurs. Pause must freeze presentation and simulation together unless a clearly documented accessibility mode says otherwise.

---

# 11. Deterministic simulation framework

The simulation must remain presentation-independent as content expands.

## 11.1 Command boundary

Every state-changing action should have a command-shaped method with:

```text
ok: bool
reason: stable failure identifier when rejected
message: player-facing explanation
state_changes: compact structured description when practical
```

Examples include:

- `select_commander`
- `select_scenario`
- `open_pack`
- `reserve_pack`
- `place_piece`
- `remove_piece`
- `assign_piece_to_room`
- `clear_piece_assignment`
- `repair_room`
- `repair_piece`
- `start_wave`
- `advance_wave`
- `use_commander_ability`
- `finish_repair_interval`
- `choose_event_option`

UI must not mutate fields directly. Tests may set up controlled state only through explicit test helpers or clearly marked fixture setup.

## 11.2 Seed contract

The seed must control all simulation randomness, including:

- Scenario variation.
- Pack offer order.
- Target-priority tie breaks.
- Arrival offsets if varied.
- Event branch randomization if ever used.
- Any damage variance that is intended to be random.

Use stable random stream names or sub-seeds so adding an unrelated visual random call cannot change combat outcomes. A future refactor should not cause the addition of a decorative particle to alter a battle.

## 11.3 Stable resolution ordering

Document and test a fixed order for each authoritative step. A recommended order is:

1. Advance clock and determine step.
2. Apply queued commander or event interventions.
3. Advance enemy routes.
4. Resolve enemy arrival and target selection.
5. Resolve defender responses in stable piece-instance order.
6. Resolve enemy attacks in stable enemy-instance order.
7. Apply room/piece damage and status changes.
8. Resolve defeats, breaches, morale, and materials.
9. Determine wave outcome.
10. Append causal report and update metrics.

If the ordering changes, update the decision log and golden test fixtures. Never rely on dictionary iteration order for a gameplay decision.

## 11.4 State versus presentation

Authoritative state includes IDs, positions, floors, zones, health, condition, ammo, assignments, wave index, step, doctrine, seed, resources, event state, and history required for save/replay. Presentation state includes focus, hover, selected dropdown item, pause preference, speed, animation phase, audio mute, contrast mode, and camera/layout state.

A presentation-only change must not alter the serialized authoritative payload. This must remain an explicit test target.

## 11.5 Save and migration discipline

The current save schema can grow, but each new field requires:

- A default for older saves.
- Validation for malformed values.
- A migration test.
- A future-version rejection test.
- A note in `docs/decision_log.md` if semantics change.

Prefer additive fields and derived values. Do not persist redundant data if it can be deterministically reconstructed. If a history field becomes too large, persist a bounded form and preserve a replay seed/command log strategy separately.

Never silently reinterpret an old save as a different scenario or commander.

---

# 12. Testing framework

Testing is part of the content pipeline. A new feature is not complete until the appropriate test layers pass.

## 12.1 Test layers

| Layer | Purpose | Examples |
|---|---|---|
| Unit/state | Validate one rule without rendering | Footprints, costs, targeting, damage, ammo, repairs |
| Deterministic replay | Same seed and commands produce identical state | Full three-wave scorecard, save/load continuation |
| Content validation | Validate definitions and references | Stable IDs, pack contents, counter tags, scenario wave plans |
| Scenario matrix | Detect dominant or impossible combinations | Commander × scenario × layout × seed |
| UI smoke | Confirm controls expose the state machine | Title, Preparation, Battle, Recovery, Results |
| Input/accessibility | Confirm alternate paths are equivalent | Mouse, keyboard, controller, scaling, contrast |
| Visual capture | Confirm required information is visible | 1280×720 preparation, battle, recovery, results |
| Packaging | Confirm internal Windows build is usable | Export, launch, save path, offline behavior |
| Review | Critique readability and fairness | Human/AI rubric, no automatic rewriting |

## 12.2 Required deterministic tests for every content addition

For every new unit, pack, enemy, doctrine, commander, scenario, or event, add tests for:

1. Valid definition loading.
2. Stable identifier lookup.
3. Valid placement or activation.
4. At least one invalid or blocked case.
5. Intended interaction with a known counter.
6. Intended weakness or trade-off.
7. Deterministic same-seed replay.
8. Save/load if the content can be active or owned.
9. UI display of purpose and state.
10. Scenario inclusion if the content is not a free-drill-only object.

## 12.3 Balance matrix

The balance harness should eventually cover:

```text
commanders × scenarios × layouts × pack choices × seeds × intervention policies
```

At minimum, maintain:

- A compact adjacency layout.
- A recovery-support layout.
- An open-yard or open-lane layout.
- A deliberately weak but legal layout.
- A no-ability run.
- A timely-ability run.
- A recovery-spend run.
- A recovery-conserve run.

Record outcomes, wave completion, breach counts, recovery success, materials, morale, defeated enemies, disabled defenders, and setup actions. Use the data to find impossible offers, dominant openings, and unexplained collapses. Do not optimize only for a 50/50 win rate; a teaching scenario should have a clear intended learning curve.

## 12.4 Golden replay fixtures

Create small human-readable fixtures containing:

- Seed.
- Commander.
- Scenario.
- Pack/placement commands.
- Recovery commands.
- Ability commands.
- Expected wave doctrines.
- Expected outcome sequence.
- Expected scorecard hash or canonical summary.

When combat math intentionally changes, update fixtures in the same change and explain why. When a visual or UI change causes a fixture to change, treat it as a bug until proven otherwise.

## 12.5 UI test contract

UI tests should assert both state and presentation:

- Correct screen.
- Correct primary action label.
- Correct enabled/disabled state.
- Correct board visibility.
- Correct doctrine/target text.
- Correct recovery action count.
- Correct scorecard rows.
- Correct pause/speed/manual-step semantics.
- Correct focus synchronization.
- No authoritative-state mutation from inspection or display toggles.

Headless UI warnings such as known object leaks should be monitored, but a warning must not be confused with a passing functional test if it masks an actual failure.

## 12.6 Visual verification checklist

At 1280×720, capture at least:

1. Title with Quick Playtest.
2. Preparation with fort, placement boxes, forecast, pack/commander context, and layout lens.
3. Battle wave one paused with visible routes and target.
4. Recovery Results with causal result, next doctrine, action budget, and Continue.
5. Wave two staged and paused.
6. Final Results with three-wave scorecard and replay key.
7. High-contrast presentation.
8. A narrow or scaled window if supported.

If a required fact is not visible in a screenshot or reliably exposed through an accessible UI control, consider the feature unfinished.

## 12.7 Exact local verification baseline

The agent should use the project’s current commands, with the local Godot binary configured as appropriate:

```bash
cd /home/ubuntu/pack_the_keep
export PATH="/tmp/godot-4.4.1:$PATH"
export GODOT_SILENCE_ROOT_WARNING=1
bash scripts/verify.sh
python3 -m json.tool content/content_manifest.json
python3 -m json.tool content/gameplay_framework.json
python3 tools/validate_content.py --manifest content/content_manifest.json
python3 tools/validate_gameplay_framework.py --framework content/gameplay_framework.json
python3 tools/validate_vertical_layers.py --layers content/vertical_layers.json
python3 tools/policy_check.py --repo .
git diff --check
```

After UI changes, run a virtual-display capture at 1280×720. After simulation changes, run the state tests and the relevant balance/replay harness before opening the game to inspect visuals.

---

# 13. Content quality rubric

Before merging any new content, answer the following in the design card and review output.

### Purpose

- What player question does this content ask?
- What existing content does it complement or challenge?
- Does it create a spatial or operational decision?

### Counterplay

- What are at least three ways to answer it?
- Are those answers available through different packs, layouts, or commanders?
- Can the player see the threat before the consequence?

### Trade-off

- What does choosing this content make harder?
- Does it consume space, materials, ammo, command points, floor access, or recovery actions?
- Is the weakness visible before commitment?

### Readability

- Can its role be understood from the board and inspector?
- Are state changes explicit without color alone?
- Does the event feed name its causal effect?

### Fairness

- Does a seeded run retain at least one viable counter?
- Can a partial failure remain informative and recoverable?
- Does the content avoid a mandatory opening build?

### Technical integrity

- Is the definition data-driven or is there a clear reason it is not yet?
- Are all IDs stable?
- Are save, replay, content, UI, and visual tests present?
- Does the content stay out of the presentation authority?

If any answer is vague, the content is not ready for implementation.

---

# 14. Agent operating workflow

The human owner should feed the agent one bounded slice at a time. The agent must not be instructed to “build the whole campaign.”

## 14.1 Required sequence for every task

1. Read `AGENTS.md`, `design/design_prompt.md`, `README.md`, `docs/decision_log.md`, and the smallest relevant source/tests.
2. State the player-facing intent in one paragraph.
3. Define the data shape and authoritative owner.
4. State explicit non-goals.
5. Add or update the decision document before broad refactoring.
6. Implement the smallest reversible slice.
7. Add deterministic tests before visual polish.
8. Run the exact focused tests.
9. Run the full local suite after focused tests pass.
10. Capture the relevant visual states.
11. Inspect the diff for generated files, accidental assets, and UI-only authority leaks.
12. Report risks and one bounded next task.

## 14.2 Recommended agent task prompt

```text
Task: Implement [one observable player-facing behavior] for Pack the Keep.

Read first:
- AGENTS.md
- design/design_prompt.md
- README.md
- docs/decision_log.md
- [smallest relevant design/source/test files]

Current baseline:
- Project: Godot 4.x/GDScript.
- Authoritative simulation: src/core/keep_state.gd or its documented successor.
- Presentation: src/ui/main.gd or its documented successor.
- Preserve deterministic seeded outcomes and the map-first fort board.

Intent:
[What decision or player question should become clearer?]

Authoritative contract:
[Fields, commands, validation, and save behavior.]

Player-facing behavior:
[Preparation/Battle/Recovery/Results changes.]

Acceptance criteria:
1. [visible behavior]
2. [blocked/failure behavior]
3. [deterministic state test]
4. [save/load or replay test]
5. [UI/input/visual check]

Non-goals:
[Explicitly list unrelated systems that must not change.]

Verification:
[Exact focused commands, then bash scripts/verify.sh and visual capture if relevant.]

Response format:
Intent, Plan, Changes, Verification, Risks, Next task.
```

## 14.3 Good task sizes

Good tasks are things such as:

- “Add a deterministic Repair Workshop event to wave-two recovery, with one repair choice and one upper-lane assignment choice.”
- “Externalize the existing four pack definitions without changing any simulation result.”
- “Add an upper-floor mobile responder and one teaching wave that demonstrates why open lanes matter.”
- “Add keyboard/controller navigation to the recovery action cards without changing the repair command contract.”
- “Add a final Results comparison between Castellan and Warden runs using the existing scorecard.”

Bad tasks are things such as:

- “Build the campaign.”
- “Add twenty units.”
- “Make it more fun.”
- “Replace the whole UI.”
- “Add Steam integration and achievements” before offline saves and controller/scaling paths are stable.

---

# 15. Release and private prerelease discipline

The repository is private and should remain internal until the human owner approves broader distribution.

## Local gate

Before commit:

- Focused tests pass.
- Full `scripts/verify.sh` passes.
- Content/framework/policy validators pass.
- JSON parses.
- Godot parser/import passes.
- Visual captures are inspected.
- `git diff --check` passes.
- Generated `.godot`, `.uid`, cache, temporary harnesses, and screenshots are removed unless intentionally documented.
- The diff contains only intended files.

## Main CI gate

Push only after local validation. Wait for the complete CI workflow, including:

- Repository policy.
- Content/framework/vertical-layer validation.
- Ubuntu Godot tests.
- Windows Godot tests.
- AI review if enabled.
- Windows packaging.

A transient job failure may be rerun only after inspecting the log. Do not hide an assertion failure behind a rerun.

## Tag/release gate

Create a new immutable annotated tag only after main CI succeeds. Never move or reuse a previous tag. The release workflow must complete successfully and the private prerelease must contain:

- Windows executable.
- Source archive.
- Release manifest.
- Correct commit/tag identity.

Release notes must state what was actually tested, what remains procedural or placeholder, and whether the build is internal, alpha, or public. Do not make Steam/Epic availability claims merely because a Windows executable exists.

---

# 16. Ordered backlog for the next GPT agent

The following order is recommended.

## Slice A — P5 recovery action cards

Add structured recovery action cards for repair room, repair piece, assignment, and clear assignment. Keep the existing authoritative methods. Add UI assertions for legal/illegal actions, action budget, materials, and explicit Continue.

## Slice B — P5 final report improvements

Expand the existing scorecard into a compact causal report with “what worked,” “what failed,” and one suggested replay experiment derived from state. Add tests that report content changes correctly for Hold, Partial Breach, and Collapse.

## Slice C — P5 layout summary and commander comparison

Add a layout summary and a side-by-side or sequential commander comparison mode that uses the existing fort, not a new dashboard. Ensure comparison is presentation-only and deterministic.

## Slice D — P6 externalize existing definitions

Move the existing commanders, pieces, packs, enemies, doctrines, and scenarios into validated data files. Preserve every existing outcome with golden replay fixtures. Do not add new content in the same change unless required to prove loading.

## Slice E — P6 content validators

Extend validators for stable IDs, missing references, duplicate IDs, invalid footprints, unsupported floors/zones, missing counter families, scenario wave counts, and pack composition rules. Make failures actionable for an agent.

## Slice F — P7 one new pack family

Choose one pack family, write its design card and asset brief, implement its definitions, integrate it into one scenario, add the counter matrix, run the full balance harness, and capture its preparation/battle/results flow.

## Slice G — P8 one event chain

Implement one three-event chain: forecast → recovery choice → consequence report. Effects must be typed commands. Save/load while the event is active and replay the same seed.

## Slice H — P9 lightweight progression prototype

Only after two or more scenarios are distinct, prototype a small between-run unlock screen. Unlocks must add decisions rather than raw power. Keep it offline and outside the core simulation.

## Slice I — P10 controller and scaling

Add controller navigation, input remapping, display scaling, reduced motion, high contrast, and settings persistence. Test all primary actions through mouse, keyboard, and controller paths.

## Slice J — P11 content breadth

Add content in teaching pairs: one new friendly doctrine and one enemy question at a time. Every pair gets a scenario that first isolates and then combines the new question.

## Slice K — P12 alpha hardening

Build Windows smoke tests for launch, offline play, save location, malformed saves, migration, controller, scaling, input remapping, pause, crash-safe close, and clean uninstall/reinstall behavior. Add platform adapters only around the simulation.

---

# 17. Definition of a successful future build

A future Pack the Keep build is successful when a new player can start without a wiki, understand why the current pack and commander matter, see the keep’s spatial language, predict at least one threat response, recover from a partial failure, and finish a scenario with a report that teaches a replay experiment.

A future agent implementation is successful when another agent can inspect the diff, identify the authoritative rule owner, run a focused deterministic test, reproduce the same outcome from a seed, load an older save, and understand what is intentionally out of scope.

A future content expansion is successful when it creates a new decision while preserving the old game’s clarity. More pieces, events, or scenarios are not progress if the player can no longer tell what matters.

> **The long-term standard:** Build fewer systems, make each one legible, and let the player feel clever because the keep’s answer was visible before it worked.
