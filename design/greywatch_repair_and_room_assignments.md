# Pack the Keep — Greywatch Repair Interval and Room Assignments

## Purpose

The repair interval is the short, authored breath between invasions. It should make damage matter without turning recovery into a full construction phase. The player gets a small number of deliberate actions, sees the next pressure, and decides which room receives a specialist. The keep should feel repaired because the player made a priority decision, not because the game silently reset condition.

## Authored Greywatch interval

After each non-collapse wave at Greywatch, the battle report opens a **two-action repair interval**. The interval has a named prompt based on the result:

| Previous outcome | Authored prompt | Mechanical emphasis |
|---|---|---|
| **Held** | “The bells stop. Assign the crew before the next warning.” | Create a strong assignment or repair a strained room |
| **Partial breach** | “The breach is quiet for now. Stabilize one function, then choose who takes the next post.” | Restore a damaged room and accept that another remains exposed |
| **Collapse** | “Greywatch is lost.” | No interval; the retry begins from preparation |

The player can take at most two interval actions. They may end early, but the UI names the unused recovery opportunity. The next wave cannot begin until the interval is ended.

## Room assignment

A placed defensive piece may be assigned to one room on the same floor. Assignment requires the piece to be inside or adjacent to the room and consumes one interval action. A room accepts only one assigned piece. Reassigning requires the old assignment to be cleared during an interval, so the player cannot freely teleport responsibilities during a battle.

Assignments are role commitments rather than permanent stat bonuses:

| Assignment | Effect | Cost or vulnerability |
|---|---|---|
| Pike Squad → Gate | Adds a clear hold bonus to Gate Road | The squad is committed to the gate and less useful elsewhere |
| Repair Station → Workshop | Increases repair amount and prioritizes Workshop | Sapper pressure becomes more consequential if the station is hit |
| Fire Team → Inner Yard | Extends denial into the response space | Friendly movement lanes become more restricted |
| Scout Post → North Tower | Reveals exact secondary target and adds one preparation step | The tower becomes a valuable Climber target |

An unassigned unit still performs its baseline behavior, so a new player is not punished for missing the system. Assignment creates stronger identity and better efficiency, not mandatory activation.

## Repair actions

The interval offers three repair commands:

1. **Repair Room:** spend materials and one action to restore a named room by 30 condition, changing breached to damaged or damaged to strained.
2. **Repair Piece:** spend materials and one action to restore a named unit by 30% condition.
3. **Assign Unit:** spend one action to connect a unit to a room and activate its specialist behavior.

The Repair Station can also perform a smaller automatic repair during contact if it remains operational. This means the player chooses between immediate battle support and interval specialization rather than receiving two independent repair economies.

## Battle interaction

Assignments alter the next battle’s causal report. Examples include:

> “Pike Squad assigned to Gate: Gate Road hold bonus +2.”

> “Sapper marked Workshop. Repair Station was assigned there, so the hit disabled repair capacity for this step.”

> “Scout Post assigned to North Tower: secondary target revealed before contact.”

The assignment must never silently change enemy doctrine. It changes the fortress’s answer to that doctrine. A good report should name the room, unit, assignment, and result.

## Recovery philosophy

The interval is not a perfect reset. It repairs one part of the keep while leaving another decision unresolved. A player who repairs the Gate may enter the next wave with a damaged Supply Room. A player who assigns the Scout Post may give up the action needed to repair a room. This creates a compact, solo-friendly recovery puzzle.

## First implementation boundaries

The first slice implements only the existing Greywatch rooms and four basic units. It does not add freeform worker movement, individual crew hunger, a second inventory, or a continuous repair mini-game. The simulation exposes explicit commands, action counts, assignment state, authored interval text, and deterministic serialization. The UI displays these directly.
