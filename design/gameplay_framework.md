# Pack the Keep — Gameplay Framework

## 1. Core design decision

**Pack the Keep should be a spatial doctrine game, not a collectible card game with walls.** The player chooses a commander, opens a small number of coherent packs, and arranges a compact keep around a recognizable defensive idea. The fun comes from seeing the idea work, seeing the enemy expose its weakness, and rebuilding without losing the identity of the layout.

The vertical slice should support approximately 30–45 minutes for a first-time player and 15–25 minutes for a replay. It should contain enough interaction to create different defenses, but not so much content that the player spends more time sorting packs than deciding where to place them.

> **Design test:** If a pack can be selected without changing the player’s spatial priorities, it is probably a stat bundle rather than good Pack the Keep content.

## 2. What the player is defending

The keep is a 12-by-8 snapped grid organized around a small room graph. It is not an empty construction sandbox. The existing rooms create strategic priorities before the player places a single piece.

| Space | Gameplay role | Why it matters |
|---|---|---|
| **Gate** | Obvious pressure point | Teaches concentration without making every wave identical. |
| **Outer Wall** | Time-buying boundary | Makes wall-only plans vulnerable to bypass and area damage. |
| **Inner Yard** | Response space | Gives mobile defenders somewhere to move and makes empty space valuable. |
| **Armory** | Pack staging | Connects pack choice to the physical identity of the keep. |
| **Workshop** | Recovery support | Makes repair a spatial decision and a sabotage target. |
| **Barracks** | Assignment and rest | Makes defenders feel like units with availability and limits. |
| **Supply Room** | Resource dependency | Gives sappers a meaningful target and prevents front-line-only play. |
| **North Tower** | Information expansion | Rewards a player who invests in warning rather than raw strength. |
| **Old Chapel** | Refuge and evacuation | Allows a successful outcome that is not identical to holding every wall. |

Rooms should have four visible condition states: **stable**, **strained**, **damaged**, and **breached**. Every state must affect a named function. A damaged workshop reduces repair capacity. A breached gate changes enemy access. A damaged supply room reduces reserve materials. A closed chapel reduces civilian safety but can preserve another defensive lane.

## 3. Unit roster

The unit roster should remain small and asymmetric. The game needs units that answer different spatial questions, not a long list of increasingly efficient soldiers.

### Vertical-slice units

| Unit | Category | Primary job | Strong against | Weak against | Spatial requirement |
|---|---|---|---|---|---|
| **Pike Squad** | Frontline | Holds a narrow corridor. | Raiders and concentrated gate assaults. | Climbers, flankers, open-yard pressure. | Needs a lane and a direction. |
| **Repair Station** | Support | Restores nearby structures. | Attrition, partial breach, area damage recovery. | Sappers and isolated placement. | Needs adjacency or a clear repair radius. |
| **Fire Team** | Control | Creates a temporary denial zone. | Climbers, open approaches, slow targets. | Blocked sightlines and friendly traffic through the zone. | Needs open sightline and deliberate empty space. |
| **Scout Post** | Recon | Reveals threats and improves response time. | Hidden approaches and feints. | Direct attacks and unsupported layouts. | Needs a view of an approach and a response plan. |

### Future units

The future roster should add new verbs rather than bigger numbers. Shield Wardens create adjacency-based anchors. Runner Pairs make movement and evacuation more explicit. Bellkeepers make signal networks and morale visible. Counter-Siege Teams answer slow area-pressure threats but consume significant space.

The future roster should not add a separate damage, armor, range, and speed unit for every tier. A new unit is justified only if it changes a layout decision, creates a counter with a tradeoff, or makes a commander meaningfully different.

### Unit design rules

Every unit needs a clear footprint, role, target preference, range or movement explanation, failure state, and counterplay. Its tooltip should answer four questions: **what does it protect, where does it work, what makes it fail, and what can replace it if it is lost?**

Units should not be permanently assigned to one lane. Even the Pike Squad should be repositionable between waves or through a commander intervention. However, movement should have a cost in time, command points, or exposure so that the player still values pre-wave layout.

## 4. Pack ecosystem

Packs are small doctrines. Each pack contains two or three related pieces, one spatial principle, one limitation, and one preview sentence. The player should understand the pack before opening it.

### Vertical-slice packs

| Pack | Contents | Doctrine | The decision it creates | Main limitation |
|---|---|---|---|---|
| **Pike Line** | Pike Squad, Narrow Gate | Compact corridors | Which approach deserves concentrated strength? | Weak when pressure spreads or bypasses the front. |
| **Field Engineers** | Repair Station, Wall Brace | Redundancy | What can I afford to lose because I prepared a second chance? | Consumes materials and attracts sabotage. |
| **Firekeepers** | Fire Team, Fire Brazier | Denial zones | Which empty space should become expensive to cross? | Can restrict friendly movement and needs sightlines. |
| **Scouts** | Scout Post, Signal Beacon | Early warning | Where will information arrive early enough to matter? | Information is useless without response space. |

### Future packs

**Shieldwall** adds Shield Wardens and Emergency Shutters. It supports anchored gates and controlled retreat, but rotates slowly and is vulnerable to distributed sabotage.

**Runner Network** adds Runner Pairs and Supply Caches. It supports open, adaptive layouts, but requires clear lanes and command attention.

**Bell Guard** adds Bellkeepers and a Signal Beacon. It supports coordinated responses, pause warnings, and morale recovery, but loses value when the signal chain is isolated.

**Counter-Siege** adds a Counter-Siege Team and Supply Cache. It answers slow siege beasts and area threats, but occupies large space and is weak against fast bypassing enemies.

### Pack offer rules

The game should offer a choice of three packs at key moments, with one reserve slot or a limited redraw. It should never produce an opening in which every offered pack is irrelevant to the forecast. Randomness should create a different problem, not remove the player’s ability to make a plan.

A pack may be powerful in one scenario and awkward in another. The game should communicate that through the forecast. For example, Firekeepers are attractive when the approach crosses open yard, while Field Engineers are attractive when the enemy is expected to target support rooms.

Do not use rarity tiers, duplicate cards, collectible monetization, endless inventories, or percentage-heavy pack upgrades. The commercial progression should unlock new decisions and scenarios, not grind away the need to understand the current keep.

## 5. Commanders

The vertical slice needs two commanders with different strategic verbs.

### The Castellan

The Castellan favors compact layered defense. Adjacent rooms reinforce each other, Lockdown temporarily restores condition across placed pieces, and the starting materials reserve is stable. The drawback is slow repositioning. The Castellan is strongest when the player predicts the main approach and builds a connected interior.

The Castellan should not simply be the “easy” commander. Their weakness is over-commitment. A player can build an elegant box that fails when climbers bypass the gate or when a support room is cut off.

### The Warden

The Warden favors mobile defenders and counterattacks. Defenders reposition more quickly, Rally restores morale and coordinates a response, and the opening has more movement potential. The drawback is a smaller starting materials reserve and a greater need for open lanes and signal coverage.

The Warden should not simply be the “advanced” commander. Their weakness is under-construction. A player who leaves too much open space without enough information or support will create a fast but fragile defense.

### Future commanders

A **Quartermaster** could trade immediate materials for stronger reserves and repair economics. A **Beacon Keeper** could make information and signal relays the center of the keep. An **Artificer** could create powerful one-use devices with significant setup costs. A **Refuge Keeper** could turn rooms and civilian safety into a primary victory condition.

Each future commander should alter one passive, one active ability, one favored pack family, and one drawback. If two commanders produce the same opening layout and priority list, one of them needs redesign.

## 6. Enemy roster and doctrines

The enemy roster should be small while the doctrines provide changing pressure. Every new enemy must be introduced in isolation before it is combined with another doctrine.

### Vertical-slice enemies

| Enemy | Doctrine | Readable behavior | Counterplay |
|---|---|---|---|
| **Raider** | Gate assault | Takes the shortest declared route toward a gate or exposed entrance. | Pike Line, controlled gates, Rally, concentrated frontline. |
| **Sapper** | Distributed sabotage | Targets a marked support dependency instead of chasing defenders. | Field Engineers, Scouts, mobile interception, post-hit repair. |
| **Climber** | Feint and flank | Uses a visible wall route to enter a less-defended interior position. | Open response space, Scouts, Firekeepers, mobile repositioning. |
| **Siege Beast** | Area pressure | Advances slowly and damages several nearby structures on impact. | Firekeepers, Field Engineers, reserved specialist, evacuation plan. |

### Future enemies

**Ash Slingers** create Smoke and Signal pressure by reducing visibility and interrupting signal links. **Skirmishers** create Attrition Screen pressure by draining morale and condition without becoming the main target. **Shieldbreakers** disrupt the strongest frontline piece and create a short vulnerability window. **Burrowers** surface at forecasted interior markers and punish layouts that rely only on the outer wall.

### Enemy design rules

The forecast must reveal doctrine, likely target, approximate timing, and one uncertainty source. It does not need to reveal every detail. A player should know whether the threat is testing the gate, a support room, the wall, or an area of the keep.

No enemy should have exactly one required counter. Every doctrine should be answerable through at least three of the following: pack choice, room layout, commander ability, scouting, timing, controlled sacrifice, or evacuation.

## 7. Wave pacing

The campaign should use three major waves with explicit teaching and recovery phases.

| Stage | Purpose | Enemy pressure | Player decision |
|---|---|---|---|
| **Preparation** | Choose commander, open first pack, inspect rooms, place pieces. | No active attack. | Declare a spatial doctrine. |
| **Wave 1: The First Bell** | Teach one doctrine cleanly. | Gate assault by Raiders. | Concentrate, reserve, or delay for information. |
| **Repair 1** | Explain damage and recovery. | No new enemy type. | Repair, rebuild, or preserve materials. |
| **Wave 2: The Wrong Wall** | Test whether the player protected support and response space. | Sappers combined with Raiders or Climbers. | Repair support, counterattack, seal a room, or accept a smaller keep. |
| **Repair 2** | Offer a second pack and expose the final threat. | Forecast and resource pressure. | Choose a complementary doctrine rather than more of the same. |
| **Wave 3: The Refuge Bell** | Test the purpose of the keep. | Siege Beast or combined area-pressure doctrine. | Hold, preserve refuge, or execute controlled withdrawal. |

Waves should not become passive once the player reaches stability. The second wave should change the target priority. The third should damage space, movement, or recovery rather than simply increase enemy health.

Pause and speed controls are part of the game’s intended strategy, not accessibility concessions. A player should be able to pause after a new threat appears, inspect its target, and issue one meaningful command without needing high-APM execution.

## 8. Resources and economy

The vertical slice should use four visible resources.

| Resource | Function | Design rule |
|---|---|---|
| **Materials** | Build and repair pieces. | Every cost previews before placement; no hidden construction currency. |
| **Command Points** | Pay for interventions and commander abilities. | The player has at least one meaningful first-wave intervention. |
| **Morale** | Measures coordination and recovery willingness. | Every change has a named cause and recovery route. |
| **Pack Slots** | Limits simultaneous doctrines. | Small, named slots prevent clutter and force identity. |

Materials should create opportunity cost. Spending everything on the first wall should make a later repair harder, but not impossible. Command points should encourage timing, not constant button pressing. Morale should be a readable state with strong visual feedback rather than an unexplained percentage.

## 9. Progression

Progression should happen at three scales.

**Within a wave**, the player gains information and spends command points. This is the tactical layer.

**Within a run**, the player gains doctrine coherence, recovery tools, and a second pack. This is the adaptation layer. The player should feel that the keep learned something, even after a breach.

**Across the campaign**, the player unlocks commanders, packs, rooms, and scenario modifiers. This is the strategic layer. Unlocks should broaden the decision space, not invalidate the first four packs.

The recommended campaign progression is:

| Unlock stage | Content | Purpose |
|---|---|---|
| **Start** | Castellan, Warden, Pike Line, Field Engineers, Firekeepers, Scouts | Establish the complete vertical-slice vocabulary. |
| **After first successful run** | One new commander or one new pack family | Give the player a different strategic verb. |
| **After partial-breach recovery** | Repair Protocol and Reserve Materials | Reward learning from failure. |
| **After two distinct doctrines** | Reserve Slots or Controlled Gates | Make mixed-pack layouts strategically useful. |
| **After campaign completion** | New keep scenario and one future pack | Extend the game horizontally rather than inflating numbers. |

A completed scenario should unlock a new possibility, not a permanent damage multiplier. The player’s knowledge of the enemy and the keep should remain the most important progression.

## 10. Solo balance and failure philosophy

Pack the Keep must be balanced for one player making decisions under pause, not for co-op coverage. Every important threat needs a response that can be understood and executed by one person.

The game should support at least three outcomes: full hold, partial breach with recovery, and controlled evacuation. Collapse may exist, but it should be relatively fast, clearly explained, and followed by a shorter retry. A player should never lose after a long preparation phase because the first pack draw silently removed the only counter.

The main anti-failure tests are:

| Test | Desired result |
|---|---|
| Either starting commander versus the first wave | Both can survive with different layouts. |
| Each vertical-slice pack versus at least one doctrine | Every pack has a clear viable scenario. |
| Gate loss | The keep remains playable if an interior route exists. |
| Support-room loss | The player can repair, seal, or change doctrine. |
| New enemy introduction | The doctrine is forecast and taught before combination. |
| Pause intervention | A thoughtful player can respond without frantic input. |
| Partial breach | The next setup is shorter and more informative, not a total reset. |

## 11. What not to support yet

Do not add multiplayer balancing, collectible rarity, duplicate packs, freeform physics destruction, a sprawling hero progression system, dozens of rooms, procedural endless waves, mobile-first touch controls, or a conventional tower-defense lane system. These features would obscure the central question before the compact keep is proven.

The first commercial-quality milestone is not “many units.” It is a small roster in which a player can choose a commander, understand a pack, build a recognizable defense, read a threat, intervene, recover from a breach, and explain why the keep survived or failed.
