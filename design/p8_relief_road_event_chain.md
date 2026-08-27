# P8 — Relief Road Event Chain

## Player-facing intent

The Relief Road should feel inhabited without interrupting its defensive lesson. A short forecast, recovery, and conclusion chain asks the player to commit a real resource, see the consequence in battle or recovery, and read the result in the final report.

## Event chain

1. **The Bell Has a Pattern** (`relief_road_warning`, Preparation, wave 0)
   - Mark the support lane: spend one command point; the first Sapper contact deals one less damage.
   - Keep command ready: preserve the command point and accept the normal Sapper contact.
2. **The Workshop Can Wait** (`relief_road_recovery`, Recovery, wave 1)
   - Release field stores: spend one recovery action and gain five materials.
   - Steady the refuge: spend one recovery action and gain one morale, capped at ten.
3. **The Refuge Bell** (`relief_road_report`, Results, wave 3)
   - Record the outcome: store the final outcome and keep-state snapshot in event history so the consequence is saveable and reportable.

Each event blocks progression until one valid choice is made. A rejected choice leaves all authoritative state unchanged.

## Data shape

Each event is a JSON object under `data/events/` with a stable ID, type, scenario, trigger, setup, choices, and optional follow-up ID. Choices contain an ID, label, structured requirements, typed effects, and visible result.

Supported requirements in this slice:

- `command_points: {gte: int}`
- `recovery_actions: {gte: int}`
- `morale: {lt: int}`

Supported effects in this slice:

- `spend_command_points`
- `spend_recovery_action`
- `add_materials`
- `add_morale`
- `set_flag`
- `record_outcome`

The event catalog validates operation names and payloads. `PackKeepState.choose_event_option()` preflights every requirement and effect before applying any mutation.

## Authoritative state

`PackKeepState` owns `active_event_id`, `resolved_event_ids`, `event_flags`, and `event_history`. These fields serialize in save schema 3. Older saves default to empty event state and deterministically activate the event appropriate to their current Relief Road phase.

The `support_lane_marked` flag is consumed on the first Sapper attack and reduces that attack by one damage. Event UI reads `current_event()` and `event_choice_preview()` and never mutates resources, flags, or history directly.

## Acceptance criteria

- All three definitions load through the runtime catalog and reject unknown effects, malformed triggers, invalid follow-ups, and duplicate choice IDs.
- Selecting Relief Road activates the forecast event; an unresolved event blocks wave start.
- Event choices validate atomically and return `ok`, a stable `reason`, `message`, and `state_changes`.
- The marked-lane choice spends one command point and reduces exactly one Sapper contact.
- The recovery event consumes exactly one of the two recovery actions and grants only its selected resource.
- The conclusion records a deterministic snapshot and appears in the scenario report.
- Active and resolved event state survives save/load; schema-2 saves migrate with safe defaults; malformed event state is rejected.
- Same seed and commands reproduce event history and the scenario scorecard.
- Preparation, Recovery, and Results expose the active event and legal choice buttons.

## Test cases

- Positive catalog load and stable event ordering.
- Negative catalog coverage for unsupported effect, bad trigger, unknown follow-up, and duplicate choice ID.
- Invalid event ID, invalid choice ID, insufficient command points, wrong phase, and exhausted recovery budget do not mutate state.
- Marked and unmarked Sapper contacts differ by exactly one damage; the flag is consumed once.
- Both recovery branches consume one action and apply their bounded resource change.
- Save/load while the forecast or recovery event is active preserves the available choices.
- Legacy schema-2 Relief Road saves derive the correct active event.
- UI smoke chooses one option in each phase and reaches a final event consequence report.

## Non-goals

- No arbitrary expression evaluator or script strings in content.
- No random event selection, branching scenario graph, character inventory, dialogue history, or campaign consequences.
- No event effect may place pieces, bypass pack availability, exceed resource bounds, or skip the normal wave/recovery gates.
