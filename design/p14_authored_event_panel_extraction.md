# P14 — Authored Event Panel Extraction

Extract the authored-event card from `src/ui/main.gd` into one presentation-only component. The component owns label/button construction and rendering, emits a stable choice ID, and never reads or mutates `PackKeepState`.

`main.gd` remains the controller: it asks `KeepState.current_event()` for a read model, passes that dictionary to the panel, and handles `choice_requested` by calling `KeepState.choose_event_option()`.

Existing public test handles (`authored_event_panel`, title/setup labels, choice buttons/details) remain available during the refactor. Visual styling, two-choice capacity, focus behavior, blocked reasons, and all existing event states must remain unchanged.
