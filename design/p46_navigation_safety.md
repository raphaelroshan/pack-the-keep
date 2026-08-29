# P46 Navigation Safety

## Intent

Give every screen a predictable Escape/controller-back response and prevent accidental loss of an unsaved defense.

## Navigation contract

- Settings returns to the screen that opened it.
- War Council returns to the Main Menu.
- Preparation, Battle, Recovery, and terminal Results request confirmation before abandoning a changed run.
- The confirmation states exactly whether progress differs from the last successful save.
- **Stay with defense** closes the confirmation without changing state.
- **Discard and return to War Council** resets the in-memory run through the existing setup reset path; an existing save file is not deleted.
- Escape first cancels active placement or input rebinding, then acts as Back.

## Authority boundary

- Dirty state is derived by comparing the current serialized `PackKeepState` with the signature captured after a successful save or load.
- Confirmation UI is presentation-only.
- No save schema, combat rule, tutorial objective, or persistence format changes.

## Acceptance evidence

- A UI test covers Settings, War Council, active-run confirmation, Stay, discard, saved-state wording, and placement-cancel priority.
- Confirmation visibility and cancellation do not mutate the run.
- Existing input, save/load, tutorial, and full deterministic suites remain green.
