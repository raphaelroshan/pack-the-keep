# v0.8.2 Testability Slice

## Goal

Make the first Greywatch battle understandable without an external explanation. A new tester should see a sensible opening layout, understand the next action, read why an event occurred, and connect the wave result to the placement decision.

## Scope

The slice adds a compact first-battle guide, a deterministic recommended starter layout, a chronological combat event feed, and a causal result explanation. It does not add new authoritative combat rules, units, enemies, progression systems, or platform integrations.

## Presentation boundary

The guide and explanations read existing authoritative state: available pieces, placed pieces, forecast, battle report, combat metrics, breach level, morale, outcome, and recovery interval. They must never write to `KeepState` or change the serialized result. The recommended layout is the one intentional command: it calls the existing `place_piece` API with fixed valid origins and reports the authoritative result.

## Guided first battle

Preparation displays a short numbered sequence. Before placement it recommends placing Pike Squad in the ground courtyard and keeping Narrow Gate near the gate. After a piece is placed it points to opening a pack or starting the invasion. Once an invasion begins it tells the tester that the battle is paused, explains Space and N, and points to the event feed. After resolution it points to the causal result panel and recovery actions. The guide should remain visible but concise, and it should disappear from the title screen.

## Recommended starter layout

The command table receives a `Use recommended starter layout` action. It attempts only missing starter pieces at fixed origins: Pike Squad at ground cell `(4, 5)` and Narrow Gate at ground cell `(2, 5)`. If a piece is already present, it is skipped. Each placement still passes through `place_piece`, so material cost, overlap, footprint, zone classification, and rejection behavior remain authoritative. The button reports how many pieces were added and invites the tester to modify the layout.

## Event feed

The existing battle report is presented as a compact newest-first feed with a visible heading and the latest four causal lines. No duplicate event system is introduced. The feed must update after manual steps, automatic steps, ability use, and wave resolution.

## Causal result explanation

The result panel names the outcome, breach level, morale, the number of defeated enemies, room damage, piece damage, and recovery state. It adds one plain-language interpretation based only on the outcome and existing metrics. Examples include: `HELD — no room breach was recorded; try a more exposed placement if you want to test the counter.`; `PARTIAL BREACH — the keep survived, but at least one function was damaged; repair the most critical room first.`; and `COLLAPSE — critical functions or morale failed; compare the forecast with the placement and response lane.`

## Acceptance tests

The UI smoke test must verify that the recommended-layout command places both starter pieces, the guide changes across preparation and battle, the event feed contains the forecast after starting a wave, the feed changes after a manual step, the result explanation identifies a resolved outcome, and the authoritative serialized state is unchanged by merely refreshing guidance or explanations. A fresh 1280×720 capture must show the fort and readable guidance/event/result text without replacing the board.

## Trade-offs

The guide intentionally favors concise text over a tutorial overlay that could obscure the fort. The recommended layout uses fixed origins rather than an optimizer so it is explainable and replay-stable. The event feed reuses the existing report rather than adding structured event objects, avoiding a schema change in this release; richer typed combat events can be considered after tester feedback.

## Final layout decision

The causal result panel is placed in the primary left reading column beside the fort. On the Results screen, battle-only forecast, enemy, placement, event, and combat-explanation blocks are hidden so the outcome and recovery explanation remain visible in the initial 1280x720 view.
