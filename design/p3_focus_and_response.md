# Pack the Keep — P3 Focus and Respond Contract

## Purpose

P3 makes the existing Greywatch battle legible as a sequence of deliberate responses. P2 already exposes routes, health, target lines, pause, speed, and manual stepping. P3 adds a map-first focus workflow so the player can select an active enemy, understand its declared pressure, preview an available response while paused, and commit the response without creating a second simulation authority.

## Scope

The slice is intentionally bounded to the current four enemy actors, two commanders, four authored scenarios, and existing repair interval. It adds deterministic map hit-testing for active enemy markers, a selected-enemy outline and inspector state, keyboard focus cycling, and an explicit focus summary in the command table. The existing enemy dropdown remains as a fallback and should synchronize with map selection.

A focused enemy exposes its stable index, name, doctrine, route, current and maximum health, declared target when known, approximate arrival step, and counter family. If the enemy has not acquired a target yet, the UI must say `APPROACHING` rather than invent a destination. Defeated enemies cannot be selected and are removed from the focus cycle.

## Input contract

Mouse click on an active enemy marker selects the enemy. `Tab` cycles forward through active enemies and `Shift+Tab` cycles backward. `F` focuses the causal report as in P2; `E` focuses the currently selected enemy summary. Selection is presentation state and must not alter `PackKeepState`. When the battle is paused, the selected enemy remains stable while the player changes speed or reads the report.

The hitbox is the marker radius plus a small fixed padding, with deterministic overlap resolution: choose the nearest marker center, then the lowest stable enemy index. The same map coordinates and enemy state must always produce the same selected index. No selection is allowed for inactive or defeated enemies.

## Paused response preview

While paused during an active wave, the command table shows the focused enemy’s available response families and the current commander ability state. For an available ability, the preview names the deterministic effect already implemented by the core, such as `Lockdown: next contact halves room damage and restores placed-piece condition` or `Rally: coordinates the next response across floors`. The preview must not mutate state. A commit calls the existing core command exactly once and refreshes the focus/report view.

P3 does not add a new targeting mechanic or direct enemy damage command. It improves the path from observation to existing intervention. If the selected enemy is not a valid target for a commander ability, the UI explains that the ability is timed against the next contact rather than pretending the player can retarget it.

## Recovery priorities

After a held or partial-breach result, the recovery panel ranks existing rooms and pieces by consequence using authoritative condition and criticality data. The ranking is deterministic: breached critical rooms first, then damaged critical rooms, then lowest-condition remaining rooms, with stable room ID as the tie-break. Each row states the current condition, state, and the existing repair action or material requirement. The panel is advisory only; repair commands remain validated by `PackKeepState`.

## Visual language

The focused enemy receives a double outline, a `FOCUSED` tag, and a stronger target line. The focused target room or piece receives an outline but no new color-only semantic. A small response card names `THREAT`, `TARGET`, `COUNTERS`, and `NEXT DECISION`. When a focus changes, the causal report receives a presentation-only acknowledgement; no battle step is advanced.

## Determinism and acceptance

The core state remains authoritative. Identical seeds and identical state-changing command sequences must produce identical outcomes regardless of selection order, focus cycling, preview opening, pause state, speed changes, or accessibility settings. P3 acceptance requires that mouse hit-testing and keyboard cycling select the same stable enemies, dropdown and map selection synchronize, preview calls leave `keep.summary()` and serialized state unchanged, a legal ability commit changes state only through the existing core method, and the recovery ranking is stable across repeated runs.

## Deliberate exclusions

P3 does not add controller remapping, direct enemy retargeting, new enemy types, new commanders, multiplayer, platform SDKs, final animation sheets, a campaign map, or commercial release readiness. Controller support can remain a later milestone unless it can be implemented and tested without broadening this slice.
