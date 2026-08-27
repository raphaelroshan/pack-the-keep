# P7 — Mobile Response Expansion

## Player purpose

This slice asks one new question: **where must a reserve be able to arrive before the next failure?** It adds two packs from one `mobile_response` family. They reward open paths and planned fallback positions rather than raw damage stacking.

## Pack card: Runner Network

- Contents: Runner Pair and Supply Cache.
- Strength: converts an open route into a fast interception bonus and a bounded material reserve.
- Weakness: both pieces are fragile, occupy useful space, and provide little direct stopping power.
- Spatial demand: keep at least one open adjacent cell around the Runner Pair and protect the Supply Cache from Sappers.
- Failure mode: a packed layout strands the runners; an exposed cache becomes an expensive target.
- Visible state: the Runner Pair's open-lane requirement is stated in its skill, and the cache shows a clear READY/SPENT state.

## Pack card: Fallback Convoy

- Contents: Rear Guard and Breakaway Barricade.
- Strength: becomes useful after a room is strained and can absorb one dangerous contact at a chosen edge.
- Weakness: inefficient before pressure arrives; the barricade damages itself when it protects a room.
- Spatial demand: preserve a second line near a critical room instead of filling the front edge.
- Failure mode: committing both pieces to the first line removes the fallback they were bought to provide.
- Visible state: Rear Guard shows RESERVE/ENGAGED; the barricade shows its remaining condition and each absorbed hit.

## New doctrine: Rolling Breach

Rolling Breach uses existing Raiders, a Sapper, and a Siege Beast. The first contacts test the Gate and support chain; the slow final impact tests whether the player preserved a reserve. It adds no new enemy type.

Forecast:

- Likely target: Gate, then the lowest-condition support room.
- Uncertainty: which damaged room will share the Siege Beast impact.
- Counter families: mobile response, support recovery, control, and commander intervention.

## Teaching scenario: The Relief Road

1. Wave 1 isolates Feint and Flank so an open route and Runner Pair are legible.
2. Wave 2 combines Distributed Sabotage with a recovery decision around the Supply Cache.
3. Wave 3 introduces Rolling Breach and tests the Rear Guard/Breakaway Barricade fallback.

The scenario must remain survivable through existing Scouts plus Field Engineers or timely commander abilities. The new packs are advantageous, not mandatory.

## Counter matrix

| Pressure | Runner Network | Fallback Convoy | Existing response |
| --- | --- | --- | --- |
| Feint and Flank | Intercept a Sapper or Climber while an adjacent lane stays open | Preserve Rear Guard behind the first line | Scouts, Firekeepers, Rally |
| Distributed Sabotage | Deliver a repair response or consume the cache | Let the first line bend while reserve holds support | Field Engineers, Scouts, repair actions |
| Rolling Breach | Keep one response lane open for the Sapper contact | Rear Guard gains value after damage; barricade absorbs one contact | Lockdown, Rally, Firekeepers, controlled room sacrifice |

## Deterministic test plan

- Same seed selects the same Relief Road variation and produces the same report.
- Runner Pair gains its response damage with an open lane and loses it when all adjacent cells are occupied.
- Supply Cache grants its fixed amount once and persists its spent state through save/load.
- Rear Guard bonus occurs only after the fallback condition is visible.
- Breakaway Barricade mitigation and self-damage are deterministic and reported.
- Existing 36-run balance outcomes remain unchanged for existing scenarios.
- A new matrix covers both commanders, three representative layouts, and two seeds on Relief Road.

## Asset brief

- Runner Pair: two compact figures linked by a bright route ribbon; one-cell silhouette; teal mobile-response accent.
- Supply Cache: low square crate with a single high-contrast seal that changes from gold to grey when spent.
- Rear Guard: broad rear-facing shield and short spear; one-cell silhouette distinct from Pike Squad.
- Breakaway Barricade: diagonal timber frame with visible break segments; one-cell footprint and amber sacrifice cue.
- Fallback treatment: procedural glyphs and palette roles in the existing board renderer until authored sprites are available.

## Balance expectations

- Hold: the player preserves an open route, spends the cache at a meaningful recovery point, and keeps a fallback near the final impact.
- Partial breach: one dependency is lost or the barricade is consumed, but the reserve prevents collapse.
- Collapse: the player blocks the response route, spends recovery too early, or commits the fallback to the first line.

The automated matrix covers both commanders, open-response, fallback-line, and layered-response layouts, and seeds 3307/3308. Its 12 bounded runs currently produce eight holds and four partial breaches with no collapses. The separate 36-run pre-expansion matrix remains 20 partial breaches, four holds, and 12 collapses.
