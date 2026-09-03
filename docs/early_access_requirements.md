# Pack the Keep — Early Access Requirements

**Status:** Active, machine-checked contract for a skeletal but commercially credible Early Access build
**Current baseline:** `0.60.0-board-first-preparation`; GPT56, investment, and Early Access gates are machine-checked, all twelve commander/keep geometry fits are authored, Preparation is board-first at 1280×720, each phase has truthful decision framing, and all active presentation assets are original. The progress ledgers record exact evidence, automated candidate status, and the owner-controlled distribution boundary.

## Product decision

Pack the Keep should enter Early Access as a **small keep-defense campaign**, not as Greywatch repeated with cosmetic variations. The first keep remains the quality anchor. Beyond it, the game needs thinner but complete keeps, commanders, invasion doctrines, and recovery decisions that make placement and pack selection meaningful across different spatial problems.

A skeletal keep may reuse the same renderer, UI, temporary asset kit, and effect vocabulary. It may not be a reskinned scenario with identical routes and counters. Every new keep must ask a different defensive question and provide at least two viable answers.

## Early Access breadth floor

| System | Early Access floor | Quality expectation |
|---|---:|---|
| Playable keeps | 3 | Greywatch plus two mechanically distinct layouts; all have preparation, battle, recovery, and Results. |
| Commanders | 4 | Each has a visible strength, limitation, intervention, and doctrine question. |
| Packs | 15–18 | Enough for meaningful opening choices; packs must solve different spatial or threat problems. |
| Defensive pieces | 24–30 | At least two viable roles for each major threat family; no unit is only a stat upgrade. |
| Enemy families | 12–14 | Distinct movement, targeting, pressure, or counter requirements with readable telegraphs. |
| Doctrines/scenarios | 20–24 | At least six repeatable scenarios per keep, including bounded seed variation. |
| Events | 14–18 | Events change preparation, resources, relationships, or recovery and have deterministic branches. |
| Commanders/keep combinations | 12+ viable starts | The player should be able to form more than one sensible opening doctrine. |
| Playable session | 30–75 minutes | A player can learn one keep, complete several assaults, recover, and see a meaningful result. |
| Replay value | 3+ materially different plans per keep | Variation must alter decisions, not only enemy colors or numeric pressure. |

These are minimum breadth targets. They do not require bespoke art for every piece, but they do require distinct silhouettes, counter language, timing, and player-facing purpose.

## Required player paths

The Early Access build must support four practical play styles:

1. **Compact specialist defense:** use a small number of assigned pieces and strong room relationships.
2. **Flexible response:** reserve packs or interventions to react to changing enemy doctrines.
3. **Prepared doctrine:** choose a forecast-informed plan that is strong against the known pressure but has a clear weakness.
4. **Recovery mastery:** survive a partial breach, sacrifice one benefit, repair intelligently, and continue without a forced optimal sequence.

No single commander, pack, or placement order should be mandatory for ordinary completion. The game can present teaching questions and recommended counters, but it must not reduce the player to following a script.

## Keep contract

Each new keep is accepted only when it has:

- A distinct floor/wall/door or room-graph problem.
- At least three named rooms or zones with different defensive value.
- Two enemy approach patterns that produce different placement questions.
- One support or recovery rule that changes the value of a damaged room.
- At least two viable seeded opening plans.
- A complete First Watch or contextual briefing path.
- Presentation snapshots for War Council, Preparation, Battle, Recovery, and Results.
- Controller, large-text, reduced-motion, pause, save, and deterministic replay coverage.

A skeletal keep can use Tiny Dungeon or Tiny Battle assets as temporary layout and silhouette support, but the evidence must label those assets as provisional. Greywatch’s authored visual language remains the quality reference.

## Quality gates before Early Access

The current Greywatch flow must remain stable while breadth is added. The Early Access candidate must additionally pass:

- Fresh-save completion of at least one scenario on every keep.
- At least two seeded plans per keep that produce distinct but valid outcomes.
- Deterministic replay with identical commands, seed, pause/speed changes, and save/resume boundaries.
- No hidden dependency on a specific commander, pack, or enemy order.
- No soft-lock after Hold, Partial Breach, Collapse, failed intervention, or depleted ammunition.
- Readable forecast, target, response, impact, recovery, and terminal-result explanations.
- 1280×720, 1600×900, large-text, reduced-motion, keyboard, and controller coverage.
- Clean Windows package launch, save migration, backup recovery, provenance, and rollback evidence.
- A known-limitations document distinguishing skeletal breadth from final art and animation.

Human P16 sessions remain useful later, but they are not a prerequisite for agents to implement and verify the Early Access floor.

## Content production rule

Every new commander, keep, pack, piece, enemy, doctrine, or event is a vertical slice. It must include data, a player-facing explanation, visual identity, audio/feedback mapping, deterministic tests, save coverage, and a capture or evidence manifest. New content must use stable IDs and the existing command boundary. Do not add a large roster until the current selected-state, primary-action, combat, recovery, and Results surfaces remain readable.

## Recommended order

**PTK-EA-1 — Complete:** Greywatch is the CI-enforced quality anchor, including responsive preparation, the complete multi-wave journey, authored board visuals, bounded semantic foley, deterministic/save evidence, and a versioned capture.

**PTK-EA-2 — Complete:** Ash Ford has six scenarios, its clear-causeway and shallow-repair identity, two opening plans, and full-flow evidence.

**PTK-EA-3 — Complete:** Twinwatch has six scenarios and the Marshal adds an assignment-led fourth commander lens with two viable plans.

**PTK-EA-4 — Complete:** Battering Rams and Harriers add armored demolition and ammunition-aware specialist pressure with explicit counters and authored silhouettes.

**PTK-EA-5 — Complete:** Four additional events, disclosed bounded variations, mastery comparisons, and replay goals bring the catalog to its approved floors.

**PTK-EA-6 — Complete:** accessibility, controller focus, save/replay, performance, packaging, limitations, and the owner-only distribution boundary are enforced as candidate gates.

## Non-negotiable boundaries

`PackKeepState` remains authoritative for simulation, while panels, animation, sound, focus, and effects remain presentation layers. Combat animations may stage resolved events but may not decide damage or timing. New content must be understandable from the preparation and forecast surfaces, and skeletal art must never be mistaken for final commercial art.
