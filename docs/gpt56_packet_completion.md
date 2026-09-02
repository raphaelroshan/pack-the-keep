# GPT56 Investment Packet Completion

Build `0.59.0-gpt56-packet-completion` completes PTK-GPT56-1 through PTK-GPT56-5 as implementation gates. It does not record human observation or approve public distribution.

## Changed files

- Runtime content: `data/keeps/greywatch_keep.json`, `data/keeps/ash_ford_redoubt.json`, and `data/keeps/twinwatch_bastion.json` now author the complete 4x3 commander-to-geometry matrix.
- Presentation: `src/ui/war_council_presentation_snapshot.gd` and `src/ui/war_council_choice_panel.gd` expose the selected geometry fit, opening, recommended pack, and accepted risk before entry.
- Evidence and gates: `content/gpt56_progress.json`, `tools/validate_gpt56_progress.py`, `tests/test_gpt56_progress.py`, runtime validator coverage, War Council coverage, balance assertions, and current 1600x900 captures.
- Release identity: the project, CI, gameplay, investment, Early Access, K8, P12, and P16 manifests share the `0.59.0-gpt56-packet-completion` build identity.

## State owners

- Simulation, commands, deterministic outcomes, recovery, and serialization: `src/core/keep_state.gd`.
- Runtime definitions and reference validation: `src/core/content_catalog.gd`, `data/`, and `tools/validate_runtime_content.py`.
- Read-only phase presentation: the War Council, Preparation, Battle, Recovery, and Results snapshot classes under `src/ui/`.
- Save files and settings lifecycle: `src/ui/main.gd`; packaged process-boundary recovery: `src/platform/packaged_smoke.gd` and `tools/run_packaged_smoke.py`.

## Scenario IDs

- Greywatch creative vertical: `gatehouse_lock`, `wrong_wall`, `open_yard_net`.
- Second-keep proof: `flood_mark` teaches Ash Ford's clear causeway; `ash_ford_crossing` combines shifting bank, sabotage, and area pressure.
- Campaign composition and failure: `the_twilight_road`, `millers_debt`, `rimebound_relief`, and `last_stand`.

## Seeded results

- Greywatch opening matrix, seeds `3307` and `3308`: 36 bounded three-wave runs; 16 held and 20 partial breaches. Compact produced 4 held/8 partial, recovery produced 8 held/4 partial, and open-yard produced 4 held/8 partial. Every plan remained viable and every plan exposed a recovery cost.
- Campaign resume matrix, seeds `3307`, `3308`, and `3309`: 228 commander/scenario/seed cases and 456 uninterrupted/save-resumed simulations; 216 held and 12 partial breaches, with byte-equivalent final state for every paired replay.

## Visual evidence

- Greywatch 1600x900: `docs/visual_evidence/v0.59.0-gpt56-greywatch-1600x900/`. Twelve frames cover title, War Council, complete plan and pack offer, live assault, spent intervention, two recoveries, repair feedback, final assault, and causal Results.
- Ash Ford 1600x900: `docs/visual_evidence/v0.59.0-gpt56-ash-ford-1600x900/`. Ten frames show the distinct clear-causeway brief and complete three-wave path.
- Ash Ford 1280x720 regression: `docs/visual_evidence/v0.53.0-investment-ash-ford-1280x720/`.
- Every capture manifest has `human_evidence: false`; these are deterministic implementation artifacts, not observations of a person.

## Assets

All active actor, room, effect, and semantic audio assets are current original assets under `assets/actors`, `assets/rooms`, `assets/effects`, and `assets/audio`. No temporary asset family is active. The earlier licensed kit remains archived with provenance at `assets/temporary/manifest.json` and is not represented as final presentation evidence.

## Failed plans discovered

- Copying Greywatch's packed core into Ash Ford occupies the marked causeway and disables its room-damage reduction.
- Depending on ranged fire against an unrevealed Gloam Knife produces no ranged response until the route is lit.
- Allowing the overwhelming Last Stand to clear every defender invokes its explicit collapse rule and causal defeat report.

## Verification

Recorded focused output:

```text
runtime content catalog: PASS (3 keeps, 1 regions, 29 pieces, 15 packs, 4 commanders, 12 enemies, 14 doctrines, 20 scenarios, 14 events, 2 modifiers)
P38 War Council choice cards: PASS
PASS: Pack the Keep P1 balance harness (36 bounded runs)
P1 outcomes: { "partial_breach": 20, "held": 16 }
P1 opening outcomes: { "compact": { "partial_breach": 8, "held": 4 }, "recovery": { "held": 8, "partial_breach": 4 }, "open_yard": { "partial_breach": 8, "held": 4 } }
P12 alpha scenario matrix: PASS (228 deterministic viable cases; 456 uninterrupted/resumed simulations)
P12 alpha scenario outcomes: { "held": 216, "partial_breach": 12 }
Vertical-slice capture: PASS (12 screens at docs/visual_evidence/v0.59.0-gpt56-greywatch-1600x900)
Vertical-slice capture: PASS (10 screens at docs/visual_evidence/v0.59.0-gpt56-ash-ford-1600x900)
K8 performance budget: PASS (40 runs in 6215 ms; 120 UI refreshes in 266 ms)
P53 alpha flow hardening: PASS (large text, accessibility, focus, audio, and all phase save boundaries)
PTK-EA-1 Greywatch anchor: PASS (responsive setup, three assaults, two recoveries, terminal replay)
PTK Early Access campaign: PASS
PTK Early Access campaign UI: PASS
PASS: Pack the Keep initial real-time auto-battle tests
```

`env PATH="/tmp/pack-the-keep-bin:/usr/bin:/bin:/usr/sbin:/sbin" bash scripts/verify.sh` exited 0 under Godot 4.7.2. The tagged Windows package workflow remains the platform-specific release gate and will publish its own provenance and smoke artifacts.

## Exactly one next packet

`PTK-P16` — owner-scheduled human comprehension, controller, Windows GPU, and listening calibration using the already version-bound protocol. It remains optional calibration and is not an implementation blocker.
