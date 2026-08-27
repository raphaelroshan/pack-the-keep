# Pack the Keep — First Keep Battle Slice

## Scope

The first playable battle is a compact, deterministic defense of one keep. It implements **The Castellan** as the only active commander, four basic defensive units, three basic enemy types, the existing two-floor keep vocabulary, three waves, one repair interval, and one partial-breach recovery path. The Warden, Siege Beast, additional packs, and larger keep scenarios remain future content.

The player’s main question is:

> **Do I build one strong front, or do I leave enough interior response space to survive the enemy that bypasses it?**

The answer must be visible in the keep layout and in the battle report. A player should never need to infer that a piece was ineffective from a hidden modifier.

## Single keep layout

The first keep is **Greywatch Keep**, represented on a 12×8 snapped grid with a ground floor and an upper wall/tower layer. The layers share a footprint but have separate room functions and connections.

| Area | Floor | Function | Enemy relevance |
|---|---|---|---|
| Gate | Ground | Main entrance and shortest raider route | Raider target |
| Outer Wall | Upper | Time-buying perimeter | Climber route |
| Inner Yard | Ground | Response space and cross-lane movement | Valuable empty space |
| Armory | Ground | Pack staging and materials | Sapper dependency target |
| Workshop | Ground | Repair and recovery | Sapper target |
| Barracks | Ground | Defender assignment and morale | Climber or sapper consequence |
| Supply Room | Ground | Repair materials and ammunition reserve | Sapper target |
| North Tower | Upper | Forecast and signal coverage | Climber target |
| Old Chapel | Upper | Refuge and controlled evacuation | Failure is survivable but changes the outcome |

The first map uses three approach markers: **Gate Road**, **East Wall**, and **North Tower Line**. Each marker shows a direction, estimated arrival, doctrine, and likely target before the wave begins.

## Active commander: The Castellan

The Castellan is the commander for the first implementation. Their passive is **Layered Masonry**: a placed piece receives a small stability bonus when adjacent to a keep room or a Wall Brace, but isolated pieces do not. This teaches the player to connect the defense without making adjacency a mandatory puzzle.

Their ability is **Lockdown**. Once per wave, the player spends one command point to seal the keep’s internal doors for one battle step. During that step, room damage is reduced and all placed pieces gain a small condition recovery. The cost is that mobile response is disabled for the step, so the ability is strongest when used to survive a known impact rather than pressed on cooldown.

The Castellan’s weakness is over-commitment. A dense gate block is efficient against Raiders but becomes vulnerable to Sappers and Climbers if the player leaves no response space or upper coverage.

## Basic defensive units

| Unit | Floor | Role | Baseline behavior | Strong against | Weak against |
|---|---|---|---|---|---|
| **Pike Squad** | Ground | Frontline | Attacks enemies in the Gate Road lane and stops a Raider’s progress when adjacent to the Gate | Raiders and narrow gate assaults | Climbers and threats that bypass the gate |
| **Repair Station** | Ground | Recovery support | Repairs the most damaged adjacent room or piece after defenders act | Sapper damage and attrition | Direct attack and isolated placement |
| **Fire Team** | Ground or upper | Control | Projects a visible denial zone across one approach; deals extra damage to Climbers | Climbers and open approaches | Blocked sightlines and Siege Beasts, which are not in the slice |
| **Scout Post** | Upper | Recon | Reveals the precise first target and gives one extra preparation step before a wave | Sappers, feints, and unknown targets | Direct attack and unsupported placement |

Units have a condition value from **1.0 ready** to **0.0 destroyed**. At 0.5 condition, the unit becomes strained and its player-facing panel explains the reduced behavior. At 0.0 it is disabled and can be repaired between waves if the Workshop or Repair Station remains available.

## Enemy mechanics

Enemies are doctrine-driven actors, not generic health bars. Each enemy has a route, target rule, arrival time, attack value, and counter tags. The forecast reveals the doctrine, primary approach, likely target, and one uncertainty. The exact secondary target can remain hidden until the Scout Post or a related commander effect reveals it.

| Enemy | Route behavior | Target rule | Attack effect | Counter logic |
|---|---|---|---|---|
| **Raider** | Takes the shortest route to Gate Road | Gate, then the first ground defender blocking the gate | Deals 2 room damage or 1 piece damage per contact step | Pike Squad stops progress; Fire Team can soften but not hold alone |
| **Sapper** | Avoids the strongest front and takes a marked support route | Workshop, Supply Room, or Repair Station | Deals 3 support damage and disables one dependency for a step | Scout Post reveals target; Pike or Fire Team can intercept; Repair Station recovers afterward |
| **Climber** | Uses East Wall or North Tower Line to bypass the Gate | Upper wall, Scout Post, or Old Chapel | Ignores gate control and creates an interior breach marker | Fire Team denial zone, upper coverage, or a reserved response lane |

Enemy health is intentionally small. The difficulty comes from **arrival timing, target choice, and route interaction**, not inflated hit points. A wave can be dangerous because it reaches a support room before a repair unit can respond.

## Battle phases

### 1. Forecast

The player sees the wave composition, doctrine, approach marker, estimated arrival, likely target, and counter families. The player may place or reposition units, open a pack, spend materials, or use one preparation action. Starting a wave locks placement until the next repair interval.

### 2. Approach

Each battle step advances enemy progress along its declared route. Scout Post improves forecast confidence and can reveal a Sapper’s exact target. Fire Team denial zones and Pike Squad control apply before contact. The player can pause between steps and spend a command point on Lockdown.

### 3. Contact

Defenders act in a stable order: Scout Post information, Fire Team control damage, Pike Squad lane control, then Repair Station recovery. Enemies that survive their route check attack their target. The timeline records each cause, such as **“Sapper reached Supply Room; Repair Station was two rooms away; Supply Room strained.”**

### 4. Adaptation window

After the first contact step, the player may use Lockdown if it remains available. No piece can be freely rebuilt during contact. The player’s meaningful choice is whether to protect the current keep, accept a partial breach, or preserve command points for the final wave.

### 5. Outcome

A wave ends in one of three states:

| Outcome | Condition | Consequence |
|---|---|---|
| **Held** | All enemies defeated or turned back before a critical room breaches | Gain materials and morale; keep the current layout |
| **Partial breach** | A critical room reaches breached state while the keep remains connected | Lose one function, gain a repair opportunity, and continue to the next wave |
| **Collapse** | Gate and two critical support rooms are breached, or morale reaches zero | End the run quickly with a causal report and a shorter retry |

The first slice should make Held and Partial Breach common enough to teach adaptation. Collapse should require a clearly visible chain of ignored problems.

## Targeting and room damage

Rooms have condition and function. The Gate controls the Raider route. The Workshop enables repair. The Supply Room enables materials and ammunition. The North Tower enables forecast. The Old Chapel enables controlled evacuation. A room’s condition is shown as stable, strained, damaged, or breached.

When several legal targets exist, the enemy chooses deterministically using the following priority: declared doctrine target, lowest condition among valid targets, then stable room ID order. This means two runs with the same seed and layout produce the same target and report.

## Resources

The first battle uses **materials**, **command points**, and **morale**. Materials pay for pieces and between-wave repair. Command points pay for Lockdown. Morale increases after a hold, decreases after a breached critical room, and is restored by the Castellan’s layered layout or a successful repair interval. There is no hidden resource or rarity tier in the first slice.

## Basic battle schedule

| Wave | Composition | Teaching purpose |
|---|---|---|
| **First Bell** | 2 Raiders | Concentrate enough strength at the Gate without overbuilding the front |
| **The Wrong Wall** | 1 Raider + 1 Sapper | Protect Workshop and Supply Room; learn support targeting |
| **The High Route** | 1 Raider + 1 Climber | Leave response space and upper coverage instead of trusting the Gate |

Between waves, the player receives a short repair interval. The Repair Station can restore one damaged room or piece; the player receives a small materials award after a Hold and a smaller award after a Partial Breach.

## Readability requirements

Every active enemy displays its doctrine and route. Every unit displays its role, effective approach, current condition, and failure reason if inactive. The battle timeline must explain target selection, denial, damage, repair, Lockdown, breach, and outcome. The player must be able to pause and understand the state without relying on reaction speed.

## Deliberate exclusions

Do not add Siege Beast, Ash Slinger, full procedural keep generation, independent defender pathfinding, collectible rarity, duplicate packs, multiplayer balancing, or a second commander to this slice. Those features can follow once Greywatch Keep produces clear, replayable choices with the three basic enemy doctrines.
