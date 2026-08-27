# Pack the Keep — Events, Occurrences, Meetings, and Developments Bible

**Status:** Proposed content bible for future implementation
**Baseline:** `v0.10.0-greywatch-vertical-slice`
**Primary location:** Greywatch Keep and its immediate valley
**Purpose:** Provide a deep but controlled source of events for preparation, recovery, scenario progression, character development, and future regional play.

> **Event promise:** The keep is not a static board between waves. It is a small, stressed community whose needs, arguments, visitors, weather, rumors, repairs, and discoveries change what the player can protect.

This document is a creative and implementation-oriented library. It is not a mandate to implement every event immediately. Events should enter the game in small authored slices, with stable identifiers, explicit requirements, typed effects, deterministic selection, clear visual consequences, and tests. The event system must deepen the fortification decision rather than distract from it.

---

## 1. The event philosophy

Events in Pack the Keep should make the player feel the pressure behind the walls. A bell rope snaps because someone used it to haul timber. A courier arrives with a warning but needs the only dry room. A family asks for shelter where the player planned to stage a reserve. A mason offers to repair a wall if the Workshop remains protected. These are not disconnected quest cards. They are disturbances in the same spatial and operational system the player is already learning.

The best event asks a question that the keep cannot answer for free:

> **What will you protect, what will you expose, and what will you make harder for the next wave?**

A strong event has four properties:

1. It occurs in a place the player already understands.
2. It offers at least two reasonable choices.
3. Each choice changes a resource, room, assignment, pack, relationship, forecast, or future event condition.
4. The consequence is visible before the next major commitment.

Events should not exist merely to deliver lore, grant arbitrary currency, or interrupt the player with a binary moral test. Flavor is welcome, but it must attach to a build decision, a recovery decision, an information decision, or a human relationship that later affects the keep.

### The emotional register

The tone is practical, intimate, wry, and occasionally eerie. People are tired, inventive, proud, frightened, and often correct about one narrow thing. The keep contains ordinary problems that become strategic under invasion. Humor should emerge from competence and inconvenience rather than parody.

Use physical language: damp rope, cold hinges, ash on a sill, a room that smells of iron, a bell heard through fog, a brace that does not fit, a child counting steps, a cart that cannot turn in the yard. Avoid abstract language such as “gain +10% defense” unless it is accompanied by a concrete description of what changed.

---

## 2. Event taxonomy

Events are organized by where they occur in the player loop and what decision they create.

| Type | Timing | Primary question | Typical effects |
|---|---|---|---|
| **Opening** | Before the first wave | What kind of keep are we trying to make? | Commander framing, starter pack, initial materials, first relationship. |
| **Forecast** | Preparation before a wave | What does the warning tell us, and what remains uncertain? | Information, target reveal, scout opportunity, doctrine confidence. |
| **Meeting** | Preparation or recovery | Who needs the keep, and what can they offer? | Pack fragment, assignment, materials, morale, room occupancy, future flag. |
| **Keep incident** | Preparation or recovery | Which neglected function is now asking for attention? | Room condition, repair cost, path access, assignment, temporary modifier. |
| **Recovery** | After Hold or Partial Breach | What should be repaired, staffed, or sacrificed? | Repair action, assignment, materials, morale, next-wave preparation. |
| **Character development** | After repeated choices or milestones | What does this person believe the keep is for? | Relationship flag, commander ability variant, event branch, ending language. |
| **Trade-off** | Preparation or recovery | What advantage can we accept if it creates a new weakness? | Pack access, refuge capacity, open lane, materials, morale, future threat. |
| **Rare occurrence** | Seeded low-frequency slot | What unexpected possibility changes the plan? | Unusual but bounded opportunity; never removes all counters. |
| **Scenario beat** | Authored wave position | What lesson should this scenario teach now? | Guaranteed event, forecast, room target, choice, or report interpretation. |
| **Regional development** | Between runs or future map | What happens beyond the keep because of our defense? | Settlement state, route, faction posture, next scenario pool. |

### Event importance bands

Not every event should have the same weight. The implementation should distinguish:

- **Atmospheric occurrences:** no mechanical effect or a tiny presentation-only change. Use sparingly and never imply a choice when there is none.
- **Operational events:** change one room, assignment, resource, or forecast. These are the common workhorses.
- **Strategic events:** change a pack offer, scenario condition, commander relationship, or future event pool. These should be less frequent and clearly explained.
- **Anchor events:** define a chapter, character arc, or scenario conclusion. These are authored and never selected as ordinary random filler.

---

## 3. Pacing and selection rules

The event system should add texture without turning every preparation into a reading queue. Event cadence must preserve the central rhythm: inspect the keep, make a plan, watch the doctrine, recover, and learn.

### Recommended cadence

| Phase | Event budget | Guidance |
|---|---:|---|
| Title/opening | 1 anchor event | Establish commander and first spatial question. |
| First Preparation | 1 anchor plus at most 1 small meeting | Do not bury the first forecast under text. |
| Between wave 1 and 2 | 1 recovery event | Tie it to the actual damage or next doctrine. |
| Between wave 2 and 3 | 1 recovery event plus at most 1 optional meeting | Offer a real priority conflict, not a second full menu. |
| Final Results | 1 conclusion event | Interpret the run and expose the next replay question. |
| Later campaign preparation | 1 primary event plus 0–2 occurrences | Let the player opt into optional complications. |

The first implementation should use **one primary event per phase**. Optional events can be added after the player understands the core loop. The game should provide a “continue” or “leave it for now” option when an event is optional; declining is itself a valid choice only if the player understands the cost.

### Eligibility and deterministic selection

Each event has a stable ID, a type, an eligibility predicate, a weight, a cooldown, a repeat policy, and a seed stream. The selector should first filter by hard requirements, then choose from the eligible pool using the run seed and a named stream such as `preparation_occurrence_02`.

The selector must not choose an event that:

- Has no valid choice remaining.
- Requires a room or unit that no longer exists without offering a fallback.
- Removes the player’s only visible counter to the next doctrine.
- Repeats too soon unless repetition is the point of the event.
- Requires hidden knowledge of an unshown flag.
- Creates an impossible save state.

A deterministic event result should be reproducible from:

```text
run seed + event pool version + phase index + scenario ID + prior event IDs + player command sequence
```

Do not use global random calls from UI code. Cosmetic variation must use a separate presentation stream.

### Event state machine

```text
eligible → offered → choice_selected → effects_validated → effects_applied → reported
             │                         │
             └── deferred/declined ───┘
```

An event may be `expired` if the player leaves the relevant phase, but it must state what was lost. An event that has already applied effects must not be applied a second time after save/load.

---

## 4. Stakes and effect vocabulary

Events should use a small vocabulary of understandable stakes. Add a new effect type only when existing effects cannot express the player-facing decision.

| Stake | Player-facing meaning | Example |
|---|---|---|
| Materials | What can be built or repaired now | Pay 8 materials to reinforce the Workshop. |
| Room condition | Whether a keep function can withstand pressure | The Supply Room is damp and starts strained. |
| Piece condition | Whether a defender remains reliable | The Fire Team’s gear is damaged. |
| Ammo | How many ranged responses remain | Firekeepers arrive with fewer rounds. |
| Assignment | Who is committed to which room | Scout Post covers North Tower. |
| Morale | Whether the keep remains coordinated | Refusing shelter lowers morale but preserves stores. |
| Command points | How many bounded interventions remain | Spend one point to issue a warning. |
| Information | How clearly the next threat is known | Reveal the likely target but not arrival timing. |
| Space | What can be placed or moved | Refugees occupy part of the Inner Yard. |
| Refuge capacity | Who can remain safe inside the keep | Open Chapel blankets increase capacity but consume materials. |
| Pack access | Which coherent doctrine can be built | Accept the salvaged Scout pack. |
| Relationship flags | Which future conversations and endings appear | The Bellkeeper trusts the Warden after being heard. |
| Scenario posture | What the final report values | Fortress, refuge, or delay. |

### Effect design rule

Every effect must have a corresponding visible result. If an event changes morale, show the new morale and explain why. If it changes a room, mark the room. If it changes an available pack, explain the doctrine it enables. Avoid hidden reputation meters until there is a clear player-facing reason to track them.

---

# 5. Opening and early-keep events

These events establish the keep, commander, first pack, and emotional language of the season. They should be authored rather than randomly selected.

## 5.1 Two Keys, One Keep

**ID:** `two_keys_one_keep`
**Timing:** Opening
**Participants:** Castellan, Warden
**Purpose:** Make commander choice a spatial doctrine choice.

The player finds two iron keys in the old command room. One opens the armory, the other the signal cabinet. The Castellan wants the armory opened first; the Warden wants the cabinet and the roofline inspected.

| Choice | Mechanical consequence | Future hook |
|---|---|---|
| Open the armory | Unlock the first pack preview and place one starter piece. | More pack-focused opening language. |
| Open the signal cabinet | Reveal the first doctrine more clearly and gain a forecast token. | The Bell Has a Pattern becomes more precise. |
| Ask both commanders to compromise | Start with fewer materials but reveal two pack limitations. | Commander relationship begins as cooperative but tense. |

This event should not make one option objectively better. The purpose is to teach that information and construction are competing advantages.

## 5.2 The Name on the Wall

**ID:** `name_on_the_wall`
**Timing:** First Preparation
**Location:** Old Chapel or outer wall
**Purpose:** Introduce the keep’s past without adding a lore-only objective.

A mason’s name is carved into a wall beneath a newer brace. The Castellan recognizes the work; the Warden recognizes the date as the year the road changed.

| Choice | Consequence |
|---|---|
| Preserve the old brace | One wall segment begins in better condition, but consumes a placement slot. |
| Remove it for material | Gain materials, but the next wall-damage report is more severe. |
| Mark it for later study | Gain information about a future wall route; no immediate resource change. |

## 5.3 The Empty Granary

**ID:** `empty_granary`
**Timing:** First Preparation
**Location:** Supply Room
**Purpose:** Teach that the Supply Room is a dependency, not a generic resource counter.

The granary is empty except for three sacks of grain that have been relabeled as sand. The quartermaster insists they can be used for firebreaks. A resident says they are the last food in the keep.

| Choice | Consequence |
|---|---|
| Keep the grain | Preserve morale and refuge capacity; no combat bonus. |
| Use the grain as firebreak material | Gain temporary area-pressure protection; lose morale if the Chapel is occupied. |
| Divide the sacks | Smaller immediate benefit to both; unlocks a later ration event. |

## 5.4 The Bell Has a Pattern

**ID:** `bell_has_a_pattern`
**Timing:** Forecast before Gate Assault
**Purpose:** Teach that information is useful only when the layout can act on it.

The Bellkeeper has heard three false alarms from the southern road and one real movement under the eastern trees. The player can ask for certainty, speed, or a second listener.

| Choice | Consequence |
|---|---|
| Ring the warning now | Reveal the likely gate target; consume one command point. |
| Wait for a second signal | Improve timing confidence, but the first approach step becomes less predictable. |
| Send the Scout Post | Reveal a route marker and move the Scout assignment toward North Tower if legal. |

This event should be the first place where the player understands that “more information” may cost time or attention.

## 5.5 Cold Iron in the Rain

**ID:** `cold_iron_in_the_rain`
**Timing:** First Preparation, seed-eligible
**Location:** Armory
**Purpose:** Give a small pack choice with a spatial cost.

A cart arrives with iron fittings from a collapsed bridge. They can become a Narrow Gate extension or braces for the Outer Wall.

| Choice | Consequence |
|---|---|
| Reinforce the gate | Improve Gate Assault response; reduce open-yard flexibility. |
| Reinforce the wall | Improve upper-floor condition; consume materials that could open a second pack. |
| Store the fittings | Preserve the option for a later event; occupy Supply Room capacity. |

## 5.6 The Tinker’s Measure

**ID:** `tinkers_measure`
**Timing:** First or second Preparation
**Visitor:** Traveling repairer
**Purpose:** Introduce a neutral character who sees the keep as a machine.

The Tinker measures every doorway and says the fort was built around a cart that no longer exists. They offer a folding brace, a signal mirror, or a promise to return.

| Choice | Consequence |
|---|---|
| Take the folding brace | Add a limited equipment piece with a large footprint and strong breach prevention. |
| Take the signal mirror | Improve forecast clarity for Climbers but require an upper placement slot. |
| Pay for both | Spend materials; the Tinker becomes a recurring repair contact. |
| Send them away | Preserve resources; a later incident becomes harder to repair. |

## 5.7 Three Lanterns at Dusk

**ID:** `three_lanterns_at_dusk`
**Timing:** Before the first battle
**Purpose:** Introduce uncertainty without hiding the doctrine.

Three lanterns appear beyond the road: one at the gate approach, one in the orchard, and one high on the ridge. The player knows a Gate Assault is likely but not whether it is a feint.

| Choice | Consequence |
|---|---|
| Watch the gate | Improve Gate target confidence. |
| Watch the ridge | Reveal a possible Climber marker in a later wave. |
| Split the watchers | Gain broad but weak information and reduce Scout response strength. |

---

# 6. Visitors, meetings, and human pressure

Meetings should make the keep feel connected to nearby lives. They are not a separate diplomacy simulator. Most meetings should occupy a room, request a resource, offer a skill, or change how the next defense is interpreted.

## 6.1 The Charcoal Burner

**ID:** `charcoal_burner_at_the_gate`
A charcoal burner asks to leave two carts inside the gate before the invasion. The carts can become fuel, cover, or an obstruction.

- **Shelter the carts:** gain materials after the next wave, but reduce Gate Road space.
- **Send them to the ravine:** preserve the gate, but lose the future fuel reward.
- **Use the carts as barricades:** temporary Gate Assault strength, followed by a repair cost.

The visible lesson is that an object can be both a future resource and a present spatial liability.

## 6.2 The Family with the Blue Blanket

**ID:** `family_blue_blanket`
A family asks for refuge in the Old Chapel. They need space, but one of them knows the southern service path.

- **Admit them:** reduce refuge capacity and gain a route hint.
- **Turn them away:** preserve capacity but lower morale.
- **Admit the scout child only:** gain the hint with a smaller space cost, but trigger a later family event.

Do not frame the first option as automatically virtuous. Each choice must be mechanically valid and explained.

## 6.3 The Deserter’s Map

**ID:** `deserters_map`
A former Ashen Host runner arrives with a map of old drainage routes. They may be a liar, frightened, or both.

- **Trust the map:** reveal a possible Climber route; leave a temporary uncertainty marker on the map.
- **Question the deserter:** spend time and gain a more reliable target, but lose one preparation action.
- **Lock them up:** gain a prisoner for a later event; morale changes depending on commander.
- **Send them onward:** no immediate benefit; future Ashen Host composition shifts slightly.

## 6.4 The Shepherd and the Missing Bell

**ID:** `shepherd_missing_bell`
A shepherd’s bell is found near the wall. It can be returned, mounted to a warning line, or kept as a decoy.

- **Return it:** gain local trust and a future livestock supply event.
- **Mount it:** improve early warning but create a predictable signal the enemy can learn.
- **Use it as a decoy:** reveal a false route once; later doctrines become more uncertain.

## 6.5 The Roadside Preacher

**ID:** `roadside_preacher`
A preacher asks to speak in the Chapel. The Warden sees morale value; the Castellan sees a crowd in a room that needs to remain clear.

- **Allow the sermon:** morale rises, Chapel becomes occupied for one phase.
- **Ask for a short blessing:** smaller morale rise, no room occupation.
- **Refuse the gathering:** retain space, but the next refuge event is colder in tone.

## 6.6 The Miller’s Two Keys

**ID:** `millers_two_keys`
A miller offers a key to the old mill storage room if the keep protects their grain route.

- **Promise protection:** gain future materials but create a scenario objective outside the keep.
- **Take the key only:** gain a pack fragment; no promise is made.
- **Refuse:** preserve the keep’s focus and lose a possible regional connection.

## 6.7 The Wounded Courier

**ID:** `wounded_courier`
A courier arrives with a sealed message and a damaged leg. The message could improve the forecast, but the courier needs the Workshop’s attention.

- **Treat the courier:** spend a recovery action or materials; gain information.
- **Read the message first:** gain information immediately, but lower morale if treatment is delayed.
- **Send them to the Chapel:** preserve Workshop capacity, but the message becomes partially unreadable.

## 6.8 The Old Mason’s Apprentice

**ID:** `old_masons_apprentice`
An apprentice knows how to make old wall braces fit, but only if the player leaves a clear route through the Yard.

- **Give them the Yard:** gain a temporary wall repair bonus; lose one open placement position.
- **Send them to the Workshop:** improve future repairs but leave the current wall unchanged.
- **Ask them to teach a defender:** spend one action; unlock a later brace interaction.

## 6.9 The Child Who Counts Steps

**ID:** `child_counts_steps`
A child has been counting the time between bell and movement. Their rhythm is better than the adults’ notes.

- **Listen:** reveal approximate arrival timing for one doctrine.
- **Put them in the Chapel:** increase refuge trust; no forecast benefit.
- **Ask them to teach the Scout Post:** improve information but occupy the Scout assignment for one wave.

## 6.10 The Silent Cartographer

**ID:** `silent_cartographer`
A mapmaker sketches the keep without speaking. They ask for an empty table in the Armory.

- **Give them the table:** improve layout advice in the next Preparation; consume an Armory surface slot.
- **Ask for the map now:** gain a partial floor overlay; future mapmaker events become unavailable.
- **Burn the sketch:** no immediate gain, but the commander relationship changes.

---

# 7. Keep incidents and operational problems

Keep incidents should turn neglected details into spatial questions. They must be concise, easy to resolve, and visibly connected to the room graph.

| ID | Incident | Location | Choices and consequences |
|---|---|---|---|
| `gate_hinge_screams` | The Gate hinge announces every movement. | Gate | Oil it for materials; brace it for condition; leave it loud to gain an early-warning cue but lose stealth. |
| `roof_leak_in_chapel` | Rain occupies the refuge space. | Old Chapel | Spend materials to patch; move blankets to Supply; accept reduced refuge capacity for one phase. |
| `stairwell_blocked` | A fallen beam closes the vertical connection. | Vertical connection | Clear it with a recovery action; route around it and weaken upper response; use it as a temporary barricade. |
| `well_rope_frayed` | The well cannot safely supply the Workshop. | Courtyard | Replace rope; ration water and save materials; move the Workshop assignment temporarily. |
| `missing_bolts` | A brace has no matching bolts. | Workshop | Salvage from another room; ask the Tinker; install a weaker temporary brace. |
| `rat_nest_in_supply` | Rats have reached the labels and grain. | Supply Room | Clear them with Fire Team support; spend food; leave the room and lose reserve clarity. |
| `bell_rope_snapped` | The warning bell cannot be rung from below. | North Tower | Replace rope; create a hand-signal protocol; move the bell to the Yard and lose upper coverage. |
| `ash_in_the_lamp_oil` | Lamps burn with a red, smoky flame. | Armory | Filter the oil; use it as an enemy marker; accept reduced visibility in the next battle. |
| `old_drain_opens` | A drain reveals a route beneath the wall. | Outer Wall | Seal it; scout it; leave it as an emergency escape route with a future Climber risk. |
| `cold_room_barracks` | Defenders cannot rest in the Barracks. | Barracks | Spend fuel; move rest into Chapel; reduce morale but preserve materials. |
| `wrong_labels` | Pack labels were swapped years ago. | Armory | Verify them with time; trust the labels and risk a misleading preview; discard one unknown item. |
| `stuck_shutter` | A wall shutter cannot close. | Outer Wall | Repair it; remove it and create an open lane; use it as a lookout with condition risk. |
| `collapsed_shelf` | A shelf blocks one placement box. | Armory | Clear it for space; leave it as cover; salvage its wood for a Brace. |
| `mud_in_the_yard` | Rain makes the open lane slow. | Inner Yard | Lay boards; accept slower movement; close the Yard to refuge traffic. |
| `cracked_chapel_step` | People trip while moving into refuge. | Old Chapel | Repair it; mark a one-way route; reduce refuge capacity until fixed. |
| `frozen_latch` | A support room cannot be opened quickly. | Workshop or Supply | Warm it with fuel; break it and pay condition; leave it closed and lose access for one phase. |
| `moth_eaten_banners` | Old banners obscure a sightline. | Upper Wall | Remove them for visibility; keep them for morale; cut them into temporary wraps. |
| `broken_measuring_line` | The old grid guide is inaccurate. | Preparation | Re-measure and delay the wave start; trust the old grid and risk a placement error; give it to the Cartographer. |
| `loose_stone_in_the_wall` | A small stonefall reveals a hollow. | Outer Wall | Fill it; inspect it for a hidden cache; mark it as a deliberate firing slit. |
| `smoke_in_the_workshop` | Damp timber smolders without flame. | Workshop | Put it out and lose materials; ventilate and gain a temporary open lane; ignore it and begin the next wave strained. |

Incidents should use the same room condition language as combat: **stable, strained, damaged, breached, stabilized**. They should not invent a separate status vocabulary.

---

# 8. Forecast and scouting occurrences

These occurrences are valuable because they turn the player’s attention toward the next doctrine without removing uncertainty entirely.

## 8.1 Smoke on the Southern Ridge

**ID:** `smoke_southern_ridge`
A column of smoke may be a cooking fire, a signal, or an attempt to pull attention away from the gate.

- Watch the ridge: improve Climber confidence in a later wave.
- Watch the gate: improve Gate Assault timing.
- Send a runner: spend command points to identify the smoke as friendly or hostile.

## 8.2 The Ash Footprints

**ID:** `ash_footprints`
Small footprints appear in the ash outside the lower wall. They end at a drain.

- Seal the drain: reduce future bypass risk, consume materials.
- Follow the trail: reveal the Old Drain event chain, delay preparation.
- Paint the footprints: preserve evidence and gain a report clue without changing the route.

## 8.3 A Crow on the Bell

**ID:** `crow_on_the_bell`
A crow lands on the bell and does not move when the keep stirs.

- Watch its direction: reveal an approach lane.
- Drive it away: gain no information but improve bell reliability.
- Leave it: gain a weak warning cue that can be wrong.

## 8.4 The Ladder in the Orchard

**ID:** `ladder_in_the_orchard`
An old ladder is found outside the wall. It is too short for a direct climb but long enough to reach a broken ledge.

- Burn it: remove a possible Climber tool.
- Bring it inside: gain materials but occupy Yard space.
- Leave it and watch: improve timing against Climbers but preserve the object as an enemy prop.

## 8.5 The Empty Lantern

**ID:** `empty_lantern`
A lantern is found burning without oil. Its wick is cold when touched.

- Treat it as an enemy signal: reveal a feint marker.
- Use it as a keep signal: improve friendly coordination but make the signal predictable.
- Extinguish it: preserve secrecy and lose information.

## 8.6 The Road Goes Quiet

**ID:** `road_goes_quiet`
Birds, carts, and distant hammering stop at once.

- Lock down the Gate: improve immediate defense and consume the Castellan’s ability if selected.
- Open the Yard for movement: improve Warden response and leave the Gate less concentrated.
- Do nothing: preserve intervention for contact and accept uncertainty.

## 8.7 The Captured Hook

**ID:** `captured_climber_hook`
A hooked tool is found in a ditch. It tells the player Climbers are possible but not when.

- Mount it as a warning: reveal a future bypass marker.
- Study it in the Workshop: improve Climber counter advice.
- Throw it away: reduce anxiety in the report but gain no information.

## 8.8 The False Muster

**ID:** `false_muster`
A distant horn calls defenders to a road that is not under attack.

- Answer the horn: reveal a possible Sapper route but reduce morale.
- Ignore it: preserve placement, but the next target selection is less certain.
- Send the Warden or Scout: spend a response unit and gain route clarity.

---

# 9. Recovery events

Recovery events are the heart of the game’s human and strategic drama. They should arise from actual damage where possible. A damaged Workshop should create Workshop problems; a breached Gate should create movement and refuge decisions; a disabled unit should create a staffing choice.

## 9.1 The Workshop Can Wait

**ID:** `workshop_can_wait`
**Trigger:** Workshop strained or damaged after a wave
**Question:** Repair the support chain or prepare the next response?

- Repair Workshop: spend materials and restore condition.
- Assign Repair Station: spend one recovery action and improve future repair reach.
- Move the crew to the wall: gain immediate wall condition but leave Workshop vulnerable.

## 9.2 The Bellkeeper’s Hands

**ID:** `bellkeepers_hands`
**Trigger:** North Tower damaged or Scout Post disabled
The Bellkeeper’s hands are blistered from pulling the rope. They can teach a replacement, rest in the Chapel, or keep ringing.

- Rest them: morale improves, information is weaker next wave.
- Teach a replacement: spend one action, preserve forecast coverage.
- Keep them on the bell: improve the next warning, risk a later disability.

## 9.3 The Gate Is Not the Keep

**ID:** `gate_is_not_the_keep`
**Trigger:** Gate held while support room is breached
The defenders celebrate the gate, but the Workshop has gone dark.

- Celebrate the hold: morale rises, but no repair priority is set.
- Tell the truth: morale holds steady and reveals the support-room risk clearly.
- Move celebration into the Chapel: improve refuge identity, occupy the Chapel.

## 9.4 One More Brace

**ID:** `one_more_brace`
**Trigger:** Wall condition below stable, materials at least 6
A brace can be fitted now, but its placement will close a response lane.

- Fit it to the wall: reduce wall risk, reduce open-lane count.
- Fit it as a courtyard barrier: improve Gate Assault response, reduce movement.
- Save it: preserve a future equipment option.

## 9.5 The Quiet Disabled Unit

**ID:** `quiet_disabled_unit`
**Trigger:** Defender disabled during a wave
A disabled defender is not dead, but their absence changes the room’s meaning.

- Repair the piece: spend materials and one action.
- Reassign another piece: preserve the room but expose the old assignment.
- Leave the position empty: gain an open lane and accept weaker direct response.

## 9.6 The Last Dry Blanket

**ID:** `last_dry_blanket`
**Trigger:** Chapel or refuge capacity is under pressure
A crate of dry blankets can warm the Chapel or wrap damaged equipment.

- Use them for refuge: increase capacity and morale.
- Use them for equipment: restore one piece condition but lower refuge capacity.
- Divide them: small benefit to both and unlock a later scarcity event.

## 9.7 The Supply Ledger

**ID:** `supply_ledger`
**Trigger:** Supply Room damaged or reserve materials low
The ledger reveals that some “missing” materials were given to households before the invasion.

- Reclaim the materials: gain resources, reduce morale.
- Honor the entries: preserve morale, lose resources.
- Audit only the next wave’s supplies: reveal ammunition and repair limits without immediate cost.

## 9.8 The Prisoner at the Wall

**ID:** `prisoner_at_the_wall`
**Trigger:** A Sapper is stopped or captured
A captured Sapper knows what the enemy expected the keep to neglect.

- Question them: reveal the next target family.
- Trade them for supplies: gain materials, lose future information.
- Release them with a false report: alter a later doctrine variation within bounded rules.
- Keep them in the Chapel: preserve information, consume refuge space.

## 9.9 The Argument in the Yard

**ID:** `argument_in_the_yard`
**Trigger:** Warden selected, morale below 6, or two assignments conflict
The defenders argue over whether the Yard is a reserve or a work space.

- Choose the reserve: improve Warden response, delay a repair.
- Choose the Workshop: improve repairs, reduce open movement.
- Let them argue: gain a temporary morale loss but reveal a genuine layout conflict in the report.

## 9.10 The Castellan’s Old Plan

**ID:** `castellan_old_plan`
**Trigger:** Castellan selected, compact layout, second recovery
The Castellan produces a plan that would make the keep stronger if the player closes the only interior lane.

- Follow the plan: improve adjacency, reduce movement.
- Tear out the central line: preserve an open lane, lose the Castellan’s passive benefit in one area.
- Annotate the plan: reveal a new compact-but-open layout hint.

## 9.11 The Warden’s Reserve

**ID:** `warden_reserve`
**Trigger:** Warden selected, open lane preserved, partial breach
The Warden wants to hold one unit back instead of assigning every room.

- Keep a reserve: reduce current room coverage, improve response to the next revealed threat.
- Assign everyone: improve immediate coverage, lose reserve flexibility.
- Split the reserve: weaker benefits to two lanes, more resilient layout.

---

# 10. Character development arcs

Named characters should emerge from practical roles. They should not become a collection of dialogue portraits disconnected from the board.

## 10.1 Mara Venn, Workshop master

**Role:** Repair Station keeper and practical engineer.
**Core belief:** Every failure has a material cause.
**Blind spot:** She treats people like replaceable components when tired.

### Arc beats

1. **The Wrong Tool** — Mara admits the Workshop has no proper brace. The player chooses salvage, pack access, or delay.
2. **The Workshop Can Wait** — She asks for protection before the next Sapper wave.
3. **A Second Door** — She proposes opening a service route that improves repairs but creates a Climber path.
4. **The Measure of a Brace** — She learns that a repair is not successful if it traps the people meant to use it.
5. **Ending variants** — In a fortress ending, Mara leaves a maintainable system. In a refuge ending, she builds portable repair kits. In an evacuation ending, she teaches others rather than staying behind.

## 10.2 Jory Pike, Bellkeeper

**Role:** Warning, signal, and local memory.
**Core belief:** A warning is only useful if someone trusts it.
**Blind spot:** Jory mistakes familiar sounds for reliable truth.

### Arc beats

1. **The Bell Has a Pattern** — Jory offers the first forecast.
2. **False Muster** — Jory sends defenders to the wrong place and must decide whether to admit it.
3. **The Bellkeeper’s Hands** — Jory needs rest or replacement.
4. **Three Knocks** — Jory creates a new signal language with the Warden.
5. **Ending variants** — Jory either leaves a functioning bell network, carries the bell to the refuge route, or rings a final warning during evacuation.

## 10.3 Elian Rusk, quartermaster

**Role:** Supply Room, rationing, and pack inventory.
**Core belief:** Every resource has already been promised to someone.
**Blind spot:** Elian counts supplies more easily than consequences.

Elian’s events should make materials and refuge capacity concrete. He is the source of `empty_granary`, `supply_ledger`, `last_dry_blanket`, and later `the_missing_label`. If the player repeatedly honors household claims, Elian becomes a regional supply contact. If the player repeatedly reclaims everything for the keep, Elian improves short-term material access but becomes less trusted.

## 10.4 Tessa Vale, road runner

**Role:** Courier, Scout Post trainee, and future regional link.
**Core belief:** Movement is safety when the route is known.
**Blind spot:** Tessa underestimates how quickly a safe route becomes a target.

Tessa appears through `wounded_courier`, `child_counts_steps`, `road_goes_quiet`, and `the_long_lantern`. Her arc should help the player understand open lanes, upper/lower connections, and the cost of keeping someone mobile instead of assigned.

## 10.5 Rook, the deserter

**Role:** Captured or voluntary informant from the Ashen Host.
**Core belief:** The enemy is also made of frightened people following a doctrine.
**Blind spot:** Rook believes information can erase responsibility.

Rook should never provide perfect intelligence. Rook offers route families, target habits, and evidence of internal Ashen Host disagreement. Trusting Rook may reveal a better counter but should create a new obligation or uncertainty.

## 10.6 The Castellan and the Warden

Commander arcs should not be linear morality stories. They are arguments about what a keep is for.

| Commander | Early belief | Pressure point | Mature belief |
|---|---|---|---|
| Castellan | A keep survives through adjacency and layered structure. | Compactness can trap defenders and residents. | A fortress needs a deliberate empty lane. |
| Warden | A keep survives through movement and timely response. | Movement without signal becomes panic. | A reserve is useful only when someone knows where it can go. |

Commander development should alter advice text, event choices, ability framing, and endings before it alters combat math.

---

# 11. Pack-related occurrences

Packs should generate events that make their doctrine feel physical. These occurrences are not advertisements. They are moments when a pack’s advantage and limitation become visible.

## 11.1 Pike Line — compact corridors

- **`pike_handles_the_stair`** — Pike Squad can hold a narrow connection, but only if the lane remains open.
- **`old_training_post`** — Add a practice dummy to the Yard, improving Pike response but consuming space.
- **`the_long_pike`** — Choose a stronger gate counter or a more flexible interior unit.
- **`pike_and_refuge`** — Move Pike Squad near the Chapel for safety, weakening the Gate.

## 11.2 Field Engineers — redundancy

- **`brace_without_a_home`** — The Repair Station can stabilize a wall, but the Workshop loses one repair action.
- **`two_small_repairs`** — Repair two strained rooms lightly or one room fully.
- **`the_engineers_argument`** — Choose portable tools or a fixed repair bench.
- **`salvage_after_sabotage`** — A Sapper’s tools reveal an enemy route but contaminate the Workshop.

## 11.3 Firekeepers — denial zones

- **`oil_on_the_stones`** — Create a denial zone in the Yard or protect a room from area pressure.
- **`smoke_and_sightlines`** — Improve damage at the cost of information clarity.
- **`the_firebreak_question`** — Burn a cart to protect the keep or preserve it for supplies.
- **`embers_in_the_chapel`** — Warm the refuge or risk smoke and reduced capacity.

## 11.4 Scouts — early warning

- **`the_second_roofline`** — Move Scout Post to the upper wall or keep a ground-level route.
- **`signal_in_the_fog`** — Reveal target family but not exact timing.
- **`a_map_with_no_legend`** — Translate information into a layout hint or a route marker.
- **`the_scouts_empty_lane`** — The best Scout position is intentionally empty of other pieces.

Future packs should receive the same treatment. If a pack cannot generate at least two useful occurrences and one limitation event, its identity is probably not strong enough.

---

# 12. Rare and memorable occurrences

Rare events should feel surprising but not arbitrary. They should be available only under visible or explainable conditions, and they must not invalidate a run.

## 12.1 The Bell Rings Underwater

**ID:** `bell_rings_underwater`
**Eligibility:** Old drain discovered, heavy rain, seed-eligible.
The flooded drain carries a vibration that sounds like a bell beneath the keep.

- Investigate: reveal an escape route with a future Climber risk.
- Seal the drain: improve wall integrity and lose the route.
- Listen only: gain a forecast clue with no structural change.

## 12.2 The White Fox

**ID:** `white_fox`
**Eligibility:** Chapel refuge active, morale at least 6.
A fox enters the Yard and sleeps beneath the least protected wall.

- Follow its path: reveal a weak wall segment.
- Leave it: gain a small morale effect and a visual marker.
- Drive it out: preserve order and lose the clue.

## 12.3 The Enemy’s Empty Camp

**ID:** `enemys_empty_camp`
**Eligibility:** Scouting success, no active prisoner.
The player finds a camp with warm coals and no soldiers.

- Search it: gain materials and a false route clue.
- Mark it: improve regional information later.
- Burn it: reduce a future enemy resource but create smoke visible to the enemy.

## 12.4 The Stone That Remembers Heat

**ID:** `stone_remembers_heat`
**Eligibility:** Area Pressure survived, wall room damaged.
A wall stone remains warm long after the Siege Beast leaves.

- Study it in the Workshop: unlock a future anti-area pack clue.
- Use it in the Chapel: improve warmth, reduce Workshop materials.
- Remove it: gain rare material and weaken the wall temporarily.

## 12.5 The Door in the Chapel Floor

**ID:** `door_chapel_floor`
**Eligibility:** Old Chapel inspected twice, refuge capacity above zero.
A hidden door leads to a narrow passage that could save people or expose the keep.

- Open it as an evacuation route: increase refuge/evacuation options and expose a bypass risk.
- Seal it: improve Chapel stability and lose a future ending branch.
- Send Rook through it: reveal a regional path with uncertain loyalty.

## 12.6 The Same Stranger Twice

**ID:** `same_stranger_twice`
**Eligibility:** The player declined or delayed two prior meetings.
The same stranger appears with a different coat and a better story.

- Ask about the first visit: expose a deception.
- Offer shelter: create a future informant relationship.
- Refuse again: preserve space, but the stranger may appear elsewhere.

## 12.7 The Unclaimed Banner

**ID:** `unclaimed_banner`
A banner from a forgotten garrison is found in a sealed room.

- Raise it: improve morale but attract attention.
- Cut it into bandages: restore piece condition and lose the symbol.
- Store it: unlock a future faction recognition event.

## 12.8 Rain at the Wrong Time

**ID:** `rain_at_the_wrong_time`
A storm arrives during a preparation window and changes the value of lanes, fire, and the wall.

- Cover the Workshop: preserve repairs, reduce Yard movement.
- Cover the Chapel: preserve refuge, expose tools.
- Leave the keep open: improve visibility after rain, damage one random eligible room within a bounded table.

The last option may use seeded variation, but it must list the possible affected functions before selection.

---

# 13. Regional and future campaign developments

The first playable game can keep these developments as future hooks or short between-run reports. They should not become a full economy or map layer until multiple keeps or scenarios exist.

## 13.1 The Road Moves Again

The old road begins to shift toward Greywatch because the southern bridge is unsafe. If the player preserved the Gate and supply chain, Greywatch becomes a trade refuge. If the player preserved the Chapel and open lanes, it becomes a civilian corridor. If the player used the keep as a delay mechanism, the road moves around the ruins.

## 13.2 The Ashen Host Splits

Repeatedly stopping Sappers but losing to Climbers may cause the Ashen Host to adapt its doctrine emphasis in future scenarios. This should alter composition within bounded authored alternatives, not create an invisible difficulty increase.

## 13.3 The Three Settlements

Future regional reports can track three nearby settlements:

| Settlement | Need | What Greywatch can offer | What it offers back |
|---|---|---|---|
| **Low Mill** | Grain and water | Protection, route access | Materials and ration events |
| **Ridge Camp** | Warning and shelter | Scout coverage, refuge | Climber information and signal tools |
| **Ash Ford** | Evacuation route | Delay defense, bridge protection | Movement options and difficult choices |

A settlement should not be a shop menu. Its state should emerge from previous defense choices and create a new spatial or operational question.

## 13.4 The Refuge Bell

If the player repeatedly protects refuge capacity, a bell network forms between Greywatch, Old Chapel, and the road. The final campaign question becomes whether the keep should remain a fortress or become the first node of a moving refuge.

## 13.5 The Empty Keep

If the player repeatedly sacrifices rooms to preserve people and routes, a future scenario begins with a keep that is physically damaged but socially prepared. This is not a “bad ending.” It is a different starting doctrine.

## 13.6 The Mason’s Road

If Mara’s arc is completed and the Tinker is trusted, the Workshop can create portable braces. This unlocks a scenario where the player defends a moving repair convoy rather than a fixed wall, but only after the fixed-keep loop is proven stable.

---

# 14. Authored scenario chains

Events become most memorable when they form short chains with changing context. The chains below are candidates for future implementation.

## Chain A — The Wrong Wall

**Lesson:** A gate defense can fail if the support chain is exposed.

1. **`the_bell_has_a_pattern`** — forecast a Gate Assault.
2. **`the_gate_is_not_the_keep`** — after the gate holds, reveal Workshop damage.
3. **`the_workshop_can_wait`** — choose repair, assignment, or wall support.
4. **`supply_ledger`** — after a second support-room pressure, decide who bears scarcity.
5. **`a_second_door`** — offer a service route that helps repairs but changes the Climber question.

The chain should end with a scorecard sentence such as: “The Gate held because the Pike Squad had a lane. The Workshop failed because it had no second reach.”

## Chain B — The Refuge Bell

**Lesson:** A keep can succeed by preserving movement and people rather than every wall.

1. **`family_blue_blanket`** — decide whether the Chapel becomes refuge.
2. **`last_dry_blanket`** — allocate scarce warmth after damage.
3. **`child_counts_steps`** — reveal the value of movement and timing.
4. **`door_chapel_floor`** — choose evacuation route or structural safety.
5. **`the_road_moves_again`** — determine whether Greywatch becomes a corridor.

## Chain C — A Keep That Listens

**Lesson:** Information is a resource only when the keep has space to respond.

1. **`silent_cartographer`** — choose map access or immediate certainty.
2. **`signal_in_the_fog`** — reveal a target family but not timing.
3. **`the_scouts_empty_lane`** — preserve a response space.
4. **`false_muster`** — decide whether to trust a signal.
5. **`three_knocks`** — complete a commander/Scout relationship beat.

## Chain D — The Mason’s Debt

**Lesson:** Repair expertise creates both resilience and dependency.

1. **`old_masons_apprentice`** — grant space or send the apprentice to Workshop.
2. **`one_more_brace`** — choose where the brace belongs.
3. **`missing_bolts`** — decide what other room loses material.
4. **`mara_second_door`** — open a service route or remain compact.
5. **`masons_road`** — unlock portable repairs for a future scenario.

## Chain E — The Deserter’s Truth

**Lesson:** Information can be useful without being clean.

1. **`deserters_map`** — trust, question, imprison, or release.
2. **`prisoner_at_the_wall`** — extract a doctrine clue.
3. **`same_stranger_twice`** — discover that another messenger knows Rook.
4. **`enemys_empty_camp`** — find evidence that neither side has the full story.
5. **`ashen_host_splits`** — alter a future scenario’s bounded composition.

---

# 15. Event authoring template

Every new event should begin as a design card before code is written.

```text
ID:
Name:
Type:
Chapter or scenario:
Timing:
Location or room:
Participants:
Player question:
Setup text:
Eligibility:
Weight/cooldown:
Repeat policy:
Choices:
  - ID:
    label:
    requirements:
    effects:
    visible_result:
    future_hooks:
    failure_message:
What changes on the board:
What changes in the report:
What does this make harder:
What are the visible counters:
Save behavior:
Deterministic seed stream:
Tests:
Asset/audio needs:
Non-goals:
```

### Machine-readable shape

```json
{
  "id": "workshop_can_wait",
  "content_version": 1,
  "status": "future",
  "type": "recovery",
  "chapter": "the_wrong_wall",
  "timing": "recovery",
  "location": "workshop",
  "eligibility": {
    "room_condition": {"room": "workshop", "lte": "strained"},
    "next_doctrine": ["distributed_sabotage", "feint_and_flank"]
  },
  "player_question": "Do we repair the support chain or prepare the next response?",
  "choices": [
    {
      "id": "repair_workshop",
      "label": "Repair Workshop",
      "requirements": {"materials": {"gte": 8}, "recovery_actions": {"gte": 1}},
      "effects": [{"op": "repair_room", "room": "workshop", "amount": 30}],
      "visible_result": "The Workshop can support the next defense again.",
      "future_hooks": ["mara_second_door"]
    },
    {
      "id": "assign_repair_station",
      "label": "Assign Repair Station → Workshop",
      "requirements": {"piece_available": "repair_station", "recovery_actions": {"gte": 1}},
      "effects": [{"op": "assign_piece", "piece": "repair_station", "room": "workshop"}],
      "visible_result": "Repair reach improves, but the unit is committed to the Workshop."
    }
  ],
  "selection": {"stream": "recovery_event_wave_2", "repeat_policy": "once_per_run"}
}
```

Narrative prose is for display. It must never be parsed as a scripting language.

---

# 16. Typed effect catalog

The first implementation should support a small effect catalog:

| Effect operation | Required fields | Validation |
|---|---|---|
| `repair_room` | room, amount | Room exists; amount bounded; recovery/material rules apply. |
| `repair_piece` | piece, amount | Piece exists; not active combat; material/action rules apply. |
| `assign_piece` | piece, room | Floor, role, and assignment rules pass. |
| `clear_assignment` | piece | Piece is assigned; phase allows clearing. |
| `adjust_materials` | amount, reason | Cannot silently create negative or unbounded resources. |
| `adjust_morale` | amount, reason | Clamp and report the change. |
| `adjust_room_condition` | room, amount, reason | Use the same condition model as combat. |
| `adjust_piece_condition` | piece, amount, reason | Use the same condition model as combat. |
| `grant_pack_access` | pack | Pack exists; availability rules pass. |
| `reserve_pack` | pack | Reserve slot and timing rules pass. |
| `reveal_doctrine` | doctrine or target family | Reveal only information the event promises. |
| `set_flag` | flag, value | Stable namespace; save and migration support. |
| `add_capacity` | capacity_kind, amount | Bound to a known refuge or spatial capacity. |
| `occupy_space` | location, footprint, duration | Placement and future release are explicit. |
| `schedule_event` | event_id, phase | Event exists and cannot create an invalid loop. |
| `modify_wave_variant` | scenario, wave, bounded key | Must remain within authored variation rules. |

Effects should be applied transactionally: validate all choice effects, then apply them, then append one event result to the causal history. If any effect fails, apply none and return a structured rejection.

---

# 17. Event-to-UX presentation rules

The event interface should feel like a dispatch from the keep, not a separate card game.

## Preparation event card

Show the location and the spatial consequence first:

```text
WORKSHOP — MARA VENN
The repair bench can serve the wall or restore the support chain.

QUESTION
Which function can the keep afford to leave exposed?

CHOICE A: Repair Workshop
Cost: 8 materials, 1 action
Visible result: Workshop stabilized
Trade-off: no new wall brace

CHOICE B: Fit a wall brace
Cost: 6 materials, 1 action
Visible result: Outer Wall strengthened
Trade-off: Workshop remains strained
```

## Meeting card

Show who is present, where they need to stand, and whether they occupy space:

```text
A FAMILY AT THE CHAPEL
They need shelter. One of them knows the southern service path.

ADMIT THEM
Refuge capacity −1; reveal service path.

SEND THEM ON
Morale −1; preserve Chapel space.
```

## Occurrence banner

Small occurrences can use a compact banner with an optional inspection detail. Never interrupt a paused battle with a large event window unless the event is explicitly a pre-contact decision.

## Report integration

Every meaningful event result should add a compact causal line:

```text
Recovery choice: Repair Station assigned to Workshop.
Effect: Workshop repair reach improved for wave 3.
Trade-off: Repair Station was not available as a free response piece.
```

The player should be able to inspect the event history from Results, but the history must not become a wall of prose.

---

# 18. Event testing framework

Events require more than text snapshots. They must be tested as state transitions.

## Required tests for every event

1. The event becomes eligible under the intended state.
2. The event remains ineligible when a hard requirement is absent.
3. Every choice is displayed with its requirements and visible result.
4. Valid choices apply exactly the declared effects.
5. Invalid choices apply no partial effects.
6. The event cannot be applied twice after save/load.
7. The event result appears in the causal report.
8. The same seed and command sequence select and resolve the same event.
9. A different eligible seed may vary selection without changing the event’s lesson or removing all counters.
10. The event does not bypass repair budgets, materials, collapse, wave order, or scenario completion.
11. Older saves load with the event state defaulted safely.
12. UI inspection does not mutate authoritative state.

## Scenario-level event tests

Each scenario should have fixtures for:

| Fixture | Purpose |
|---|---|
| Intended chain | Prove the authored event sequence teaches the scenario lesson. |
| Decline path | Ensure refusing optional help remains playable. |
| Scarcity path | Exercise low-material or low-morale choices. |
| Damage path | Ensure event eligibility follows actual room/piece state. |
| Commander variant | Ensure both commander lenses receive viable event choices. |
| Seed replay | Prove deterministic selection and effects. |
| Save during event | Prove active event persistence and no double application. |
| Collapse path | Prove collapse terminates event scheduling safely. |
| Final report | Prove event consequences appear in scenario Results. |

## Content validator rules

Extend the content validator when the event system is implemented. It should reject:

- Duplicate IDs.
- Unknown rooms, pieces, packs, commanders, doctrines, flags, or effect operations.
- Events with fewer than two meaningful choices unless explicitly marked atmospheric.
- Choices with no requirements, effects, or visible results.
- Effects that reference prose instead of typed operations.
- Events with no timing or invalid phase.
- Repeatable events with no cooldown or bound.
- Scenario chains that can schedule themselves forever.
- Events that change combat state without a deterministic seed or explicit authored rule.
- Events that can remove every viable counter to the next authored doctrine.

## Balance checks

Add event-aware cases to the existing matrix:

```text
commander × scenario × layout × pack choice × seed × event branch × recovery policy
```

Track whether event branches create:

- An unwinnable opening.
- A dominant choice selected in nearly every run.
- A hidden mandatory event.
- A morale death spiral.
- A repair loop that makes damage irrelevant.
- A spatial blockage that removes all legal placement.
- A report that cannot explain the outcome.

The target is not equal outcomes. The target is that each reasonable choice creates a different, understandable defense problem.

---

# 19. Recommended implementation sequence

The event library is intentionally larger than the first implementation. Build it in risk slices.

## Event Slice 1 — One recovery event

Implement `workshop_can_wait` for Gatehouse Lock after wave one or two. Use existing repair and assignment commands. Add state, UI, save/load, deterministic, and causal-report tests. Do not add a new event scheduler yet if one direct authored event can prove the command boundary.

## Event Slice 2 — One preparation meeting

Implement `family_blue_blanket` or `wounded_courier`. Prove that a meeting can occupy a room or alter refuge capacity without becoming a separate simulation. Add a visible preparation card and one Results line.

## Event Slice 3 — Event catalog and validator

Externalize the first events into data. Validate references and effect operations. Preserve existing authored events and add stable IDs to all future entries.

## Event Slice 4 — One three-event chain

Implement Chain A, **The Wrong Wall**, with a deterministic decline path and save during an active event. Do not build a general campaign map yet.

## Event Slice 5 — Character relationship flags

Add only the flags needed for one character arc, preferably Mara or Jory. Keep flags namespaced, visible in the report, and bounded. Do not build a generic reputation system.

## Event Slice 6 — Rare occurrence slot

Add one rare event such as `old_drain_opens` with clear eligibility and a bounded future hook. Test several seeds and ensure it cannot remove all viable counters.

## Event Slice 7 — Regional report

Show one between-run consequence, such as Low Mill becoming more or less connected to Greywatch. Keep it as a report and a next-scenario modifier before building a full regional map.

---

# 20. Content review rubric

Before an agent implements an event, the reviewer should ask:

### Is the event about the keep?

Can the player point to the room, lane, floor, unit, or resource affected? If not, it is probably flavor rather than gameplay content.

### Is the decision real?

Do both choices preserve a viable run while creating different costs? If one choice is always correct, rewrite the trade-off.

### Is the consequence legible?

Does the player see the cost before choosing and the result after choosing? Does the next forecast or report make the consequence concrete?

### Is it appropriately timed?

Does the event arrive when the player can act on it? Do not show a repair opportunity after the repair interval has already closed.

### Does it preserve the game’s rhythm?

Can the player read and resolve it quickly? Does it leave the fort visible? Does it respect pause and manual-step expectations?

### Is it replayable?

Would a player choose differently on a second run because the event exposes a different doctrine or weakness, rather than because the reward is random?

### Is it honest?

Does the text avoid promising certainty when the simulation only provides a clue? Does it reveal a bounded uncertainty rather than hiding a random penalty?

### Is it implementable?

Are requirements and effects explicit? Is the save behavior known? Are tests defined? Is the event free of UI-owned game rules?

---

# 21. Design boundaries and future possibilities

The following possibilities are intentionally deferred but compatible with this bible:

- A small regional map connecting multiple keeps.
- Faction relationships among Ashen Host groups and valley settlements.
- Multi-run character arcs that unlock new pack families.
- Evacuation scenarios where the keep becomes a delay mechanism.
- Portable fortifications and temporary camps.
- A second keep with a different room graph.
- Scenario modifiers such as winter, flood, smoke, or road blockade.
- Community requests and settlement supply routes.

These should be added only after the Greywatch event loop is readable. A large event catalog cannot compensate for weak room identity or unclear combat feedback.

Do not add:

- A dialogue-only quest hub detached from the keep.
- A reputation bar with no visible decisions.
- Random events that erase a run without counterplay.
- Events that force a single correct moral answer.
- Events that silently alter wave composition.
- Events that give raw permanent power without a new decision.
- Event text so long that the player forgets the next doctrine.

---

# 22. The intended feeling

At its best, an event should make the player pause over the fort and say:

> “If I let them use the Chapel, I can learn the service route, but I lose the room I wanted for refuge. If I refuse them, the keep stays cleaner and the next wave is easier to stage, but I may never know what is coming from the south.”

That is the standard. The event is successful when it makes the existing spatial decision more human, more specific, and more difficult to answer cheaply.

Pack the Keep should gradually become a story about a place that people are trying to keep useful under pressure. Some players will build a dense fortress. Some will leave an empty yard and move people through it. Some will preserve the Chapel and abandon a wall. Some will trust the deserter, some will lock them away, and some will use their map while admitting it may be wrong.

The game should remember those choices through rooms, reports, relationships, and future opportunities—not through a pile of opaque variables.
