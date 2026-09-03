# P75 Board-First Terminal Results Verification

Build `0.63.0-board-first-results` keeps the completed fortress and its final verdict together at the minimum supported review resolution without changing authoritative result state.

At 1280×720 and 100% scale, terminal Results uses a phase-specific two-column composition. The complete two-floor fortress remains visible as evidence while the dedicated debrief presents outcome, scenario/commander identity, the opening causal summary, and the dominant replay action in the initial viewport. Repeated main-column title, subtitle, and status are removed from this composition.

At 1280×720 and 150% scale, terminal Results returns to the stacked composition and restores its main heading. At 1600×900 and 125% scale, the board-first composition remains horizontally bounded. Inter-wave Recovery retains its own responsive composition, focus remains on the dominant replay action, and responsive transitions leave serialized state byte-equivalent.

## Evidence

- Greywatch complete 1280×720 flow: `docs/visual_evidence/v0.63.0-board-first-greywatch-1280x720/`
- Greywatch complete 1600×900 flow: `docs/visual_evidence/v0.63.0-board-first-greywatch-1600x900/`
- Ash Ford complete 1280×720 flow: `docs/visual_evidence/v0.63.0-board-first-ash-ford-1280x720/`
- Ash Ford complete 1600×900 flow: `docs/visual_evidence/v0.63.0-board-first-ash-ford-1600x900/`

The 1280×720 terminal frames show each keep's final geometry, outcome, remaining cost, causal summary, and replay action together. The debrief's longer phase timeline and fortress diagnostics remain available through its independent scroll. All manifests identify automated, debug-free evidence and do not claim human observation.

## Verification

Focused commands:

```text
godot --headless --audio-driver Dummy --path . --script res://tests/test_p32_terminal_debrief.gd
P32 terminal debrief: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p48_responsive_layout.gd
P48 responsive layout: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p31_tutorial_flow.gd
P31 First Watch tutorial flow: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p53_alpha_flow_hardening.gd
P53 alpha flow hardening: PASS
```

Full repository output also passed:

```text
PTK investment vertical: PASS (PTK-I1 through PTK-I6 implemented; human evidence pending; owner distribution approval required)
GPT56 investment packets: PASS (PTK-GPT56-1 through PTK-GPT56-5 implemented; PTK-P16 remains human-owned)
P12 alpha scenario matrix: PASS (228 deterministic viable cases; 456 uninterrupted/resumed simulations)
P12 alpha scenario outcomes: { "held": 216, "partial_breach": 12 }
K8 performance budget: PASS (40 runs in 2286 ms; 120 UI refreshes in 231 ms)
P53 alpha flow hardening: PASS (large text, accessibility, focus, audio, and all phase save boundaries)
PTK-EA-1 Greywatch anchor: PASS (responsive setup, three assaults, two recoveries, terminal replay)
PTK Early Access campaign: PASS
PTK Early Access campaign UI: PASS
PASS: Pack the Keep initial real-time auto-battle tests
```

`env PATH="/tmp/pack-the-keep-bin:/usr/bin:/bin:/usr/sbin:/sbin" bash scripts/verify.sh` exited 0 under Godot 4.7.2. P16 remains human-owned and pending; the tagged Windows workflow remains the final platform package gate.
