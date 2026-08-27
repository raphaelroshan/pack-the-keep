# Pack the Keep — Vertical Layer Design

## Core decision

Pack the Keep should use **one keep with two functional layers** rather than two independent boards. The upper layer consists of walls and towers. The ground layer consists of the gate, yard, rooms, reserves, repair spaces, and refuge areas.

The upper layer buys **time and information**. The ground layer converts that advantage into **interception, repair, movement, or evacuation**. This creates a clear vertical relationship without requiring the player to track two separate economies or two independent battlefields.

> **Upper defenses do not win by themselves. They create a window. Ground defenses decide what survives inside that window.**

## Layer roles

| Layer | Primary function | Strong at | Vulnerable to |
|---|---|---|---|
| **Walls and towers** | Warning, ranged pressure, route control, and early intervention. | Visibility, delay, directional pressure, signal reach. | Climbers, siege beasts, smoke, isolated access. |
| **Ground floor and yard** | Interception, movement, repair, reserves, supplies, morale, and refuge. | Flexible response, frontline holds, recovery, evacuation. | Raiders, sappers, blocked lanes, morale collapse. |

The two layers share the same 12-by-8 footprint and room graph. The player should not have to mentally switch between two different maps. A tower is an attachment to a wall or room. A ground unit is a response to an upper warning or an interior threat.

## Vertical connections

The first slice uses three connection types.

| Connection | Connects | Purpose | Failure consequence |
|---|---|---|---|
| **East Stair** | North Tower ↔ Inner Yard | Moves defenders and repair runners between tower and response space. | Ground response time increases and the tower becomes isolated. |
| **Gate Stair** | Outer Wall ↔ Gate | Connects wall defense to the primary ground entry. | Wall defenders cannot reinforce the gate quickly. |
| **Signal Relay** | North Tower ↔ Barracks ↔ Workshop | Carries alerts and commander orders across floors. | Forecasts remain visible, but response timing and morale recovery decline. |

Connections should be visible in the map. Stairs show a movement route. Signal relays show a line. Support shows a named room or supply dependency. A damaged connection should change what the player can do rather than merely reduce a hidden percentage.

## Upper-layer units

Upper-layer content should focus on **visibility, delay, and directional pressure** rather than unrestricted damage.

| Unit | Function | Dependency | Main weakness |
|---|---|---|---|
| **Scout Post** | Reveals enemy doctrine and likely landing or approach points. | View of an approach. | Isolated placement, smoke, and tower breach. |
| **Signal Beacon** | Carries alerts to connected ground rooms. | Signal relay and ground connection. | Cut signal chain or isolated tower. |
| **Wall Brace** | Reduces breach damage to an adjacent wall or tower. | Wall segment and repair materials. | Siege-beast area damage and support-room loss. |
| **Wall Archer Post** | Applies steady pressure outside the keep. | Clear sightline and ammunition access. | Smoke, blocked sightlines, and enemies already inside. |
| **Wall Ballista** | Delivers powerful pressure along one declared lane. | Large wall slot, reload team, and clear lane. | Wrong direction, bypasses, and loss of reload support. |
| **Watchfire** | Reveals climbers and burrowers. | Fuel and open tower or wall slot. | Ash wind, smoke, and fuel shortage. |

The first implementation slice should use Scout Post, Signal Beacon, and Wall Brace. Wall Archer Post, Wall Ballista, and Watchfire should be added only after the basic cross-floor relationship is working.

## Ground-layer units

Ground-layer content should make the keep feel inhabited, mobile, and recoverable.

| Unit | Function | Dependency | Main weakness |
|---|---|---|---|
| **Pike Squad** | Holds a gate, corridor, or stair landing. | Lane, assignment, and morale. | Open yard, flank, and morale collapse. |
| **Repair Station** | Restores damaged rooms, stairs, walls, and equipment. | Materials, repair radius, and room access. | Sapper targeting and loss of the supply room. |
| **Fire Team** | Controls open yard space and punishes interior landings. | Sightline and safe firing space. | Friendly-lane blockage, smoke, and heavy targets. |
| **Shield Wardens** | Protect adjacent ground units and stabilize a boundary. | Adjacency and clear retreat. | Sappers, area pressure, and slow rotation. |
| **Runner Pair** | Carries orders, repair kits, and evacuation supplies. | Open lane, destination, signal, and morale. | Blocked lanes and simultaneous alerts. |
| **Bellkeepers** | Coordinates cross-floor alerts and morale. | Bell or relay, room access, and morale. | Signal cut, bell damage, and isolation. |
| **Refuge Ward** | Protects civilians and essential supplies. | Safe room, evacuation route, and morale. | Breach, blocked route, and panic. |

The first implementation slice should use Pike Squad, Repair Station, and Fire Team. Runner Pair, Bellkeepers, and Refuge Ward should follow once access and signal rules are proven.

## The vertical gameplay loop

Every invasion should create a chain of readable decisions.

| Stage | Player sees | Player decides |
|---|---|---|
| **Detection** | A Scout Post or signal relay reveals doctrine and likely approach. | Which alert deserves attention? |
| **Disruption** | An upper piece delays, weakens, or redirects pressure. | Should time be spent protecting the tower or preparing the ground? |
| **Interception** | A Raider, Climber, or Sapper reaches a gate, yard, stair, or room. | Where should the frontline or reserve commit? |
| **Recovery** | A room, wall, or connection is damaged. | Repair, seal, rebuild, evacuate, or accept controlled loss? |

The upper layer should never provide a complete answer. A Scout Post can reveal a Climber but cannot stop it. A tower can weaken a Raider but cannot defend a breached workshop. A ballista can punish a Siege Beast but cannot repair the room it damages.

## Enemy tests by floor

| Enemy | Primary interaction | Upper-layer test | Ground-layer test |
|---|---|---|---|
| **Raiders** | Gate and yard entry. | Can the upper layer buy enough time? | Is there a frontline and reserve? |
| **Sappers** | Support and connection damage. | Can the player protect signal relays and tower access? | Can the player intercept or repair the dependency? |
| **Climbers** | Wall landing and bypass. | Does the player detect and deny the landing? | Is there an interior response space? |
| **Siege Beasts** | Area damage across both layers. | Can the player delay or create a firing window? | Can the player repair, evacuate, or preserve a smaller keep? |
| **Ash Slingers** | Smoke and signal disruption. | Can the player maintain redundant visibility? | Can the keep operate with partial information? |
| **Burrowers** | Interior emergence. | Can warning reach the ground? | Has the player left flexible empty space? |

## Pack identity across floors

The two-floor model should make every pack feel like a doctrine with a relationship between levels.

| Pack | Upper-layer role | Ground-layer role | Resulting doctrine |
|---|---|---|---|
| **Pike Line** | Narrow Gate or Wall Brace. | Pike Squad. | Feed a ground holding lane from a controlled boundary. |
| **Field Engineers** | Wall Brace and upper repair access. | Repair Station. | Keep damage from turning into permanent loss. |
| **Firekeepers** | Watchfire or elevated fire support. | Fire Team and Brazier. | Shape the approach before it becomes an interior fight. |
| **Scouts** | Scout Post and Signal Beacon. | Runner or response coordination. | Convert information into a timely ground action. |
| **Shieldwall** | Reinforced battlement and shutters. | Shield Wardens. | Hold a boundary while preparing controlled retreat. |
| **Runner Network** | Signal relay. | Runner Pair and Supply Cache. | Make movement and recovery the defense. |
| **Bell Guard** | Tower signal. | Bellkeepers. | Make communication and timing the core strength. |
| **Counter-Siege** | Wall Ballista. | Counter-Siege Team and reload support. | Prepare a costly answer to large slow threats. |

A pack should not be a purely upper or purely ground bundle unless the limitation is intentional. The strongest packs should expose a dependency: an upper unit needs a ground crew, or a ground response needs an upper warning.

## Commanders

The Castellan should specialize in **vertical adjacency**. Towers reinforce nearby rooms, wall braces protect connected ground spaces, and Lockdown stabilizes a compact stack. The weakness is over-commitment: a dense vertical layout is efficient but hard to reposition and vulnerable to area pressure.

The Warden should specialize in **cross-floor response**. Ground units move more quickly between stairs, signals travel farther, and Rally coordinates an upper alert with a ground reserve. The weakness is dependence on open lanes, signal continuity, and materials.

This is a stronger distinction than giving one commander more armor and the other more speed. Their abilities change which floor the player values first.

## Spatial and UI rules

The player should always see the following:

| Readout | Why it matters |
|---|---|
| **Upper coverage** | Shows which approaches a tower can observe or pressure. |
| **Ground access** | Shows where a defender or runner can arrive before the next pressure tick. |
| **Support link** | Shows which room, stair, or supply source keeps a piece functional. |
| **Signal path** | Shows which alerts can travel and where the chain can break. |
| **Breach impact** | Shows whether damage affects one floor or both. |
| **Refuge route** | Shows whether civilians can reach the chapel or another safe room. |

The first version should use only three cross-floor rules: **visibility**, **access**, and **support**. Do not initially add ammunition, separate floor morale, complex elevators, or physics destruction. Those systems may be added after the basic model is fun and readable.

## Recommended vertical-slice scope

The vertical slice should contain one wall segment, one tower attachment, one stair, one signal relay, the Gate and Inner Yard, three upper pieces, and three ground pieces. Raiders, Sappers, and Climbers should be the active enemies. Siege Beasts should be introduced only after the player understands the cross-floor relationship.

The slice should prove four things:

1. A Scout Post reveals a threat early enough for a ground response.
2. A Climber can bypass the gate without making walls useless.
3. A Sapper can damage a support connection and create a recovery decision.
4. A player can lose one tower or room while preserving a smaller, playable keep.

## Implementation guidance

The structured source of truth is `content/vertical_layers.json`. Its IDs should align with `content/content_manifest.json` and `content/gameplay_framework.json`. Runtime code should represent upper pieces, ground pieces, and vertical connections explicitly. Do not infer a unit’s floor from its display name.

The first coding pass should add floor metadata and connection state without changing the existing wave loop. The second should add visibility, access, and support queries. The third should connect Climber and Sapper behavior to those queries and add deterministic tests for tower isolation, stair damage, signal loss, and ground response time.
