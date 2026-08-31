# Pack the Keep — AI Game-Quality Execution Plan

**Applies to:** `v0.32.0-twinwatch` and later

**Purpose:** Turn the First Watch prototype into a readable, tactile, game-quality keep-defense vertical slice. Automated verification, deterministic simulation checks, scripted flow coverage, and screenshot review are the active gates. Human testing remains useful for later confidence and tuning, but it is not a prerequisite for execution.

## Non-negotiable contract

`KeepState` and the content catalog remain authoritative. Presentation can stage, summarize, animate, and inspect state, but it cannot invent damage, targeting, timing, ammunition, placement legality, or recovery outcomes. Every task must preserve pause, speed, manual-step, controller, large-text, high-contrast, reduced-motion, save/load, and deterministic replay behavior.

The game is a spatial defensive puzzle, not a rarity treadmill or a command spreadsheet. Packs express coherent doctrines, commanders change the questions the player asks, and every enemy introduces a readable problem with at least one visible counter. Do not add content to avoid fixing a confusing screen.

## Execution order

| Step | Objective | Required outcome |
|---|---|---|
| **K1 — Complete** | Repair responsive War Council and Preparation | At 1280×720, 1600×900, large text, and controller focus, commander, keep, pack, forecast, placement, and commit information remain reachable without clipping. Narrow layouts use a deliberate single-column fallback. |
| **K2 — Complete** | Make the keep the primary decision surface | The board remains the visual anchor through placement, inspection, and commitment. Greywatch has authored material surfaces, and one selected room or defender has one clear identity, purpose, condition, and next action on the board. |
| **K3 — Complete** | Extract presentation panels | War Council, Preparation, Battle, Recovery, and Results render from deterministic read-only snapshots without moving simulation ownership or changing command semantics. |
| **K4 — Complete** | Finish the battle readability pass | Forecast, approach, target lock, wind-up, response, impact, consequence, and settle now form a coherent speed-scaled beat grammar over each authoritative tick. |
| **K5 — Complete** | Make recovery and Results distinct | Recovery exposes the first priority and sacrificed alternative; terminal Results leads with the decisive pattern, remaining cost, and a specific replay experiment. |
| **K6 — Complete** | Add a controlled content slice | Standard Cutters hunt assigned specialists first; The Cut Standard teaches precision interception and mobile reserve as two deterministic viable answers. |
| **K7 — Complete** | Build composition and replay mastery | War Council previews fixed seeded pressure; Results compares doctrine fit, recovery commitment, pack plan, and the first useful uncovered-pressure experiment. |
| **K8 — Complete** | Harden the private alpha | Ten automated/documented areas, conservative performance budgets, packaged lifecycle and forced-close recovery evidence, exact provenance, and known limitations are enforced while all release claims and seven human gates remain pending. |
| **P51.1 — Complete** | Add one commander lens | The Quartermaster makes reserve timing visible through discounted first-pack access, stronger surviving stores, and bounded Resupply without changing combat authority. |
| **P51.2 — Complete** | Add one defensive identity | Twinwatch Bastion makes two staffed posts a visible spatial rule and preserves anchored and mobile answers in The Divided Bell. |
| **P51.3 — Next** | Add the first teaching pack | Introduce one pack and enemy family as a complete question/counter/weakness slice before combining it with later content. |

## Acceptance tests for every AI task

The agent must run the complete verification wrapper and the relevant focused tests. Tests must enter affected screens through the normal flow, assert layout bounds and focus reachability, and compare the same seed under normal, large-text, high-contrast, reduced-motion, keyboard, and controller paths. Screenshot evidence must record version, viewport, state, and capture method.

A task is incomplete if it hides the fort behind a menu, adds a unit before its teaching question is visible, changes combat behavior through animation timing, removes a useful action at narrow widths, or relies on human playtest results that do not yet exist. Automated evidence must be treated as evidence of behavior, not proof of enjoyment.

## Recommended next prompt

> P51.1–P51.2 are complete at `0.32.0-twinwatch`. Implement P51.3 as one teaching pack paired with one isolated enemy question. Preserve the K1–K8 and P54 gates, keep at least two viable answers, and never fabricate human observations or infer public-alpha/storefront approval.

## Definition of game-quality readiness

Pack the Keep is ready for private alpha when a new run clearly communicates choose → build → hold, the fortress remains the protagonist, each battle explains what happened and why, recovery offers a meaningful next decision, at least two defensive solutions work for each teaching scenario, and the complete First Watch path can be replayed without debug actions. Human testing is an optional confidence and calibration layer after these deterministic and presentation gates are satisfied.

## Historical evidence

The latest baseline is recorded in [`latest_visual_review_2026-08-31.md`](latest_visual_review_2026-08-31.md) and [`latest_test_report_2026-08-31.md`](latest_test_report_2026-08-31.md), and the versioned captures are in `docs/visual_evidence/`. The broader roadmap remains [`agent_handoff_roadmap.md`](agent_handoff_roadmap.md).

## References

[1]: agent_handoff_roadmap.md "Pack the Keep Agent Handoff Roadmap"
[2]: game_quality_transformation_plan.md "Pack the Keep Game-Quality Transformation Plan"
[3]: latest_test_report_2026-08-30.md "Pack the Keep Latest Main Test Report"
