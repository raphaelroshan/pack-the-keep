# P13 — Event History in Ledger and Results

## Player-facing purpose

The Campaign Ledger and Results screen should answer what the keep has already chosen, not only which run modifier is equipped. Recent authored-event consequences and stable run flags must be visible without opening save data or reconstructing log text.

## Read model

`PackKeepState.event_ledger_snapshot(limit)` is a read-only projection over authoritative `event_history` and `event_flags`.

- Entries are newest-first and capped to five by the UI.
- Each entry exposes its stable event ID, authored title, choice ID, wave, phase, and visible consequence.
- Flags are sorted by stable ID and retain explicit true/false values.
- The projection reports total history count and whether older entries were omitted.
- Calling the projection, refreshing the UI, or toggling presentation preferences must not mutate serialized run state.

## Presentation contract

- The existing Campaign Ledger appends a `RECENT EVENTS` section beneath modifier details.
- The existing Results scorecard uses the same newest-first bounded projection for `EVENT CONSEQUENCES`.
- When more than five events exist, both views state that only the newest five are shown.
- Event and flag labels are readable text derived from stable IDs; no new modal, screen, or campaign map is added.

## Non-goals

- No deletion, pinning, filtering, or editing of history.
- No cross-run archive, relationship simulation, generic journal system, or additional save fields.
- No change to event resolution, event-history persistence, or modifier authority.
