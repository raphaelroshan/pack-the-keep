# P72 Board-First Preparation Verification

Build `0.60.0-board-first-preparation` closes the preparation-density finding from PR #117 without changing simulation authority.

At 1280×720 and 100% scale, War Council retains its focused stacked briefing. Entering Preparation now uses a phase-specific two-column composition: the left surface contains the current question, visible answer, compact live plan/risk, Ready Defense action, and complete two-floor fortress; the right rail contains the selected doctrine pack and placement commands. The redundant readiness sentence is removed only in this composition.

At 1280×720 and 150% scale, Preparation returns to the existing stacked large-text layout and restores the full per-placement rationale. At 1600×900 and 125% scale, the board-first composition remains within horizontal bounds. Controller focus still begins on Ready Defense, the page opens at scroll position zero, and responsive changes leave serialized state byte-equivalent.

## Evidence

- Greywatch 1280×720: `docs/visual_evidence/v0.60.0-board-first-greywatch-1280x720/`
- Greywatch complete 1600×900 flow: `docs/visual_evidence/v0.60.0-board-first-greywatch-1600x900/`
- Ash Ford 1280×720: `docs/visual_evidence/v0.60.0-board-first-ash-ford-1280x720/`
- Ash Ford complete 1600×900 flow: `docs/visual_evidence/v0.60.0-board-first-ash-ford-1600x900/`

The Greywatch and Ash Ford 1280×720 Preparation frames visibly differ in room topology, starter plan, selected pack, spatial-rule cue, response pattern, and accepted weakness. This re-proves PTK-I2 on the same composition that closes PTK-I1.

## Verification

Focused commands:

```text
godot --headless --audio-driver Dummy --path . --script res://tests/test_p48_responsive_layout.gd
P48 responsive layout: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p33_preparation_answer_quality.gd
P33 preparation answer quality: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p40_preparation_command_hierarchy.gd
P40 preparation command hierarchy: PASS
```

Full repository output also passed:

```text
PTK investment vertical: PASS (PTK-I1 through PTK-I6 implemented; human evidence pending; owner distribution approval required)
GPT56 investment packets: PASS (PTK-GPT56-1 through PTK-GPT56-5 implemented; PTK-P16 remains human-owned)
P12 alpha scenario matrix: PASS (228 deterministic viable cases; 456 uninterrupted/resumed simulations)
P12 alpha scenario outcomes: { "held": 216, "partial_breach": 12 }
K8 performance budget: PASS (40 runs in 3156 ms; 120 UI refreshes in 963 ms)
P53 alpha flow hardening: PASS (large text, accessibility, focus, audio, and all phase save boundaries)
PTK-EA-1 Greywatch anchor: PASS (responsive setup, three assaults, two recoveries, terminal replay)
PTK Early Access campaign: PASS
PTK Early Access campaign UI: PASS
PASS: Pack the Keep initial real-time auto-battle tests
```

`env PATH="/tmp/pack-the-keep-bin:/usr/bin:/bin:/usr/sbin:/sbin" bash scripts/verify.sh` exited 0 under Godot 4.7.2. The tagged Windows workflow remains the final platform package gate.
