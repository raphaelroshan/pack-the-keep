# P13 — The Workshop Can Wait

## Player-facing purpose

Gatehouse Lock should react when sabotage leaves the Workshop strained after wave two. The recovery event asks whether the player spends scarce materials repairing the room now or commits an already-placed Repair Station to protect the support chain before Feint and Flank.

## Data contract

- Stable event ID: `workshop_can_wait`.
- Scenario: `gatehouse_lock`.
- Trigger: recovery after wave two.
- Eligibility: Workshop condition is at most 70 and the next authored doctrine is `feint_and_flank`.
- The event is listed directly in Gatehouse Lock's authored event chain; this slice does not add a random scheduler.

Choice one, `repair_workshop`, requires eight materials and one recovery action. Its typed `repair_room` effect uses the same authoritative room-repair mutation as the normal recovery command.

Choice two, `assign_repair_station`, requires one recovery action and a placed Repair Station. Its typed `assign_piece` effect selects the first stable eligible Repair Station instance and uses the same authoritative assignment mutation as the normal recovery command.

## Acceptance criteria

- A stable Workshop does not open the event.
- A strained or damaged Workshop opens it only during Gatehouse Lock recovery after wave two with Feint and Flank next.
- Both choices are previewed before mutation and reject atomically when resources, placement, adjacency, or assignment rules are not satisfied.
- Repair Workshop spends eight materials and one action, restores 30 condition up to 100, and updates the visible room state.
- Assign Repair Station spends one action and creates the normal Workshop assignment without duplicating assignment rules.
- The unresolved event blocks ordinary recovery actions and continuation.
- Active and resolved event state survives save/load, and replaying the same choice produces identical serialized state.
- The generic authored-event panel exposes both choices at 1280×720; the selected consequence appears in the existing Results event history.

## Non-goals

- No random event scheduler, event weights, cooldown system, new character relationship system, new room-capacity simulation, or scenario-specific UI.
- No automatic placement of a Repair Station and no bypass of normal recovery costs or assignment geometry.
