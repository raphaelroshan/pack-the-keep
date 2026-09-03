# Pack the Keep — AI Game-Quality Execution Plan

**Applies to:** `v0.60.0-board-first-preparation` and later

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
| **P51.3 — Complete** | Add the first teaching pack | Road Wardens and Outriders create a visible prepared-delay versus concentrated-damage tempo question with two proven full-run answers. |
| **P51.4 — Complete** | Add the second teaching pack | Lantern Watch reveals Gloam Knives for ranged response while Road Wardens preserve a distinct melee answer across deterministic full runs. |
| **P51.5 — Complete** | Combine the proven questions | The Twilight Road teaches tempo and visibility separately, then combines them with prepared-route and flexible-response plans and no new combat subsystem. |
| **P52.1 — Complete** | Add bounded replay variation | Twilight Crossroads trades one recovery action for final-wave road delay or stair visibility and supports two mixed-pack answers. |
| **P52.2 — Complete** | Make the branch legible at Results | Terminal mastery names the selected route, forgone preparation, complementary/redundant build fit, and opposite-branch replay experiment. |
| **P52.3 — Complete** | Add meaningful seeded adaptation | Three fixed seed variants disclose balanced, visibility-heavy, or tempo-heavy final pressure and retain the same preparation emphasis at Results. |
| **P53.1 — Complete** | Audit the completed alpha flow | One end-to-end UI journey composes accessibility, controller focus, two file-backed save boundaries, semantic audio state, seeded pressure, and responsive terminal Results; the existing package and performance gates remain green. |
| **P55 — Complete** | Replace abstract actor interiors with temporary licensed sprites | Active defenders and enemies read as melee, ranged, heavy, or siege actors while role silhouettes, color, health, cadence, targets, focus, and specialist overlays remain authoritative and visible. |
| **P56 — Complete** | Give semantic battle beats tactile temporary foley | A bounded four-player sample pool differentiates warning, contact, response, impact, breach, recovery, control, and terminal cues while preserving mute, volume, visible labels, and synthesized fallback. |
| **P57 — Complete** | Add restrained combat effect textures | Defender response and hostile melee, ranged, and demolition impacts gain distinct temporary CC0 effects without obscuring health, damage, target, or focus information. |
| **P58 — Complete** | Make damage and recovery physically legible | Damaged/breached rooms gain restrained state-driven atmosphere and successful room/defender repairs gain one localized restored-value pulse. |
| **P59 — Complete** | Add temporary room-function recognition | Seven Greywatch functional rooms use restrained Tiny Dungeon prop accents beneath all tactical information; unaccented movement and structural spaces remain quiet. |
| **P61 — Complete** | Keep room functions readable at board scale | Every room uses a stable fully fitted board label; purposeful short labels replace accidental ellipses while inspection retains complete names. |
| **P62 — Complete** | Replace core actor placeholders at board scale | Four defender-role and four signature-enemy silhouettes use original text-free 32×32 vector art while tactical overlays and procedural fallback remain intact. |
| **P63 — Complete** | Complete the authored enemy set | Shield Guard, Ash Slinger, Shieldbreaker, Standard Cutter, Outrider, and Gloam Knife gain distinct original silhouettes; current actor profiles no longer use Tiny Battle. |
| **P64 — Complete** | Replace Greywatch room props | Seven original 32×32 functional silhouettes replace current Tiny Dungeon room props without adding density to the open yard or structural wall. |
| **P65 — Complete** | Replace temporary board effects | Eight original 48×48 marks replace active combat, room-damage, breach, and repair textures while preserving established timing and fallbacks. |
| **P66 — Complete** | Replace temporary semantic foley | Fourteen reproducible original WAV cues replace the active CC0 samples while preserving semantic IDs, bounded playback, mute/volume, headless behavior, and generated-tone fallback. |

## Acceptance tests for every AI task

The agent must run the complete verification wrapper and the relevant focused tests. Tests must enter affected screens through the normal flow, assert layout bounds and focus reachability, and compare the same seed under normal, large-text, high-contrast, reduced-motion, keyboard, and controller paths. Screenshot evidence must record version, viewport, state, and capture method.

A task is incomplete if it hides the fort behind a menu, adds a unit before its teaching question is visible, changes combat behavior through animation timing, removes a useful action at narrow widths, or relies on human playtest results that do not yet exist. Automated evidence must be treated as evidence of behavior, not proof of enjoyment.

## Recommended next prompt

> The automated GPT56, investment, and Early Access roadmaps are complete at `0.60.0-board-first-preparation`. Preserve PTK-GPT56-1 through PTK-GPT56-5, PTK-I1 through PTK-I6, PTK-EA-1 through PTK-EA-6, P67–P72, K1–K8, P51–P66, P54, responsive-decision, room-label, authored-actor, authored-room, authored-audio, combat-effect, and repair-feedback gates. The Kenney kit is archived and no active presentation profile references it. Do not invent human findings or distribution approval.

## Definition of game-quality readiness

Pack the Keep is ready for private alpha when a new run clearly communicates choose → build → hold, the fortress remains the protagonist, each battle explains what happened and why, recovery offers a meaningful next decision, at least two defensive solutions work for each teaching scenario, and the complete First Watch path can be replayed without debug actions. Human testing is an optional confidence and calibration layer after these deterministic and presentation gates are satisfied.

## Historical evidence

The latest baseline is recorded in [`latest_visual_review_2026-09-01.md`](latest_visual_review_2026-09-01.md) and [`latest_test_report_2026-09-01.md`](latest_test_report_2026-09-01.md), and the versioned captures are in `docs/visual_evidence/`. The broader roadmap remains [`agent_handoff_roadmap.md`](agent_handoff_roadmap.md).

## References

[1]: agent_handoff_roadmap.md "Pack the Keep Agent Handoff Roadmap"
[2]: game_quality_transformation_plan.md "Pack the Keep Game-Quality Transformation Plan"
[3]: latest_test_report_2026-08-30.md "Pack the Keep Latest Main Test Report"


## Latest verification update — 2026-08-31

The current `main` build `0.38.0-alpha-hardened` passes `scripts/verify.sh`, including P52 Twilight Crossroads, P53 accessibility and persistence hardening, controller focus, muted audio, save boundaries, and real-time auto-battle coverage. A fresh 1280×720 launch shows a strong authored title screen, while the War Council remains vertically dense: the defense brief, commit summary, primary action, commander card, and defense card compete within the first viewport.

**Next mandatory task: K1 — Responsive War Council and Preparation layout.** Preserve the visible primary action, condense the decision summary, make the selected commander/defense relationship explicit, and keep the next useful context reachable at 1280×720, 1600×900, Large Text, keyboard, and controller focus. Do not add another commander or broad content slice until this preparation decision surface passes layout and screenshot gates. Human testing remains optional and non-blocking.

## Responsive decision update — 2026-08-31

`0.39.0-responsive-decisions` completes the mandatory K1 follow-up. Stacked War Council layouts remove the repeated defense brief and lead with a compact run frame, explicit commander/defense/keep pairing, deterministic seed pressure, preparation focus, and visible Enter Keep action. Both choice navigation rows remain in the 1280×720 / 125% first viewport; 1600×900 / 100% retains the full overview and two-column rail; 1280×720 / 150% uses the deliberate single-column fallback with focused-primary visibility. Preparation carries the pairing forward, replaces the repeated lesson paragraph with the authored strategic question, compacts the Large Text brief, and keeps Ready Defense plus the fort reachable. Focused tests, complete verification, and renderer captures cover the update without simulation mutation.

No further autonomous implementation milestone is selected. P16 human observation remains the next evidence layer and must begin only when the owner schedules real testers.

## Temporary actor readability update — 2026-08-31

`0.40.0-actor-readability` uses a bounded CC0 Tiny Battle subset to replace the abstract centers of active defender and enemy markers. Formation and ranged defenders now have distinct allied actors; hostile melee, ranged, demolition, fast, concealed, and siege roles resolve appropriate temporary sprites. The existing shape/color backing, health and cadence bars, target lines, focus rings, armor, smoke, breach, and command-hunter labels remain unchanged, and compact timeline markers keep the procedural grammar. Missing assets fall back to the prior glyphs. This is a presentation-only test layer and not a final-art claim.

## Tactile audio update — 2026-08-31

`0.41.0-tactile-audio` maps the established semantic cue vocabulary to a restrained CC0 Interface Sounds/RPG Audio subset. Playback uses four reusable players, follows mute and effects-volume settings, keeps visible cue labels, and falls back to the existing generated tones when a sample is missing. Audio remains presentation-only and does not enter save state, combat resolution, or replay keys.

## Combat effect readability update — 2026-08-31

`0.42.0-combat-vfx` adds compact tinted Particle Pack textures at the existing defender-response and hostile-impact beats. Melee, ranged, and demolition profiles remain distinct, reduced motion uses a static compact treatment, and the procedural projectile, slash, ring, health-trail, damage-label, and focus grammar stays authoritative and visible.

## Room damage and repair update — 2026-08-31

`0.43.0-room-feedback` gives damaged and breached rooms restrained state-driven smoke/scorch treatment, then anchors a short restored-value spark to successful room and defender repairs. Stable rooms stay quiet, blocked actions create no success pulse, reduced motion shortens the treatment, and authoritative repair costs and amounts remain unchanged.

## Temporary room-function accent update — 2026-08-31

`0.44.0-room-accents` gives seven Greywatch functional rooms a small, low-opacity Tiny Dungeon prop silhouette beneath labels, health, units, damage, focus, and selection. The inner yard and outer wall remain quiet, other keeps retain their established rendering, and all room identity remains presentation-only with procedural fallback.

## Room-label legibility update — 2026-09-01

`0.45.0-readable-rooms` fits every stable room label between 10px and 8px before drawing. Workshop and Barracks remain complete, Supply Room and North Tower use purposeful board shorthand, and inspection retains the complete authored names and roles without changing room identity or simulation state.

## Authored core actor update — 2026-09-01

`0.46.0-authored-core-actors` replaces temporary tiles for all active defender roles plus Raider, Sapper, Climber, and Siege Beast with original text-free 32×32 SVG silhouettes designed for the actual board-marker scale. The remaining extended enemies retain their declared CC0 fallback until the next bounded art pass.

## Complete authored actor update — 2026-09-01

`0.47.0-authored-actors` adds distinct original silhouettes for Shield Guard, Ash Slinger, Shieldbreaker, Standard Cutter, Outrider, and Gloam Knife. All ten enemy profiles and every active defender role now use the text-free 32×32 actor language, with procedural shapes retained as the no-texture fallback.

## Authored room-function update — 2026-09-01

`0.48.0-authored-room-accents` replaces the seven active Greywatch Tiny Dungeon props with original portcullis, armory, workshop, barracks, supply, tower, and chapel silhouettes. Their established low-density placement and opacity remain unchanged, the inner yard and outer wall stay quiet, and labels plus tactical overlays remain dominant.

## Authored battle-effect update — 2026-09-01

`0.49.0-authored-effects` replaces the active Particle Pack dependency with original allied melee/ranged response, hostile melee/ranged impact, demolition, damaged-room, breached-room, and repair marks. The existing beat timing, tint, opacity, reduced-motion path, procedural marks, and simulation boundary remain unchanged.
