# P74 Board-First Recovery Verification

Build `0.62.0-board-first-recovery` keeps the damaged fortress, causal outcome, and first useful recovery command together at the minimum supported review resolution without changing authoritative recovery state.

At 1280×720 and 100% scale, an ordinary inter-wave Recovery uses a phase-specific two-column composition. The compact outcome and priority brief remains above the complete two-floor fortress while the command rail opens on the highest damaged priority and sorts a legal repair or assignment first. Repeated main-column instructions, status, and the duplicate End Lull action are removed from this composition.

At 1280×720 and 150% scale, Recovery returns to the stacked composition and restores its main continuation action. At 1600×900 and 125% scale, the board-first composition remains horizontally bounded. Blocking authored events retain their deliberate choice layout, and First Watch retains its tutorial-owned action and focus route. Responsive relayout and presentation selection leave authoritative state byte-equivalent.

## Evidence

- Greywatch complete 1280×720 flow: `docs/visual_evidence/v0.62.0-board-first-greywatch-1280x720/`
- Greywatch complete 1600×900 flow: `docs/visual_evidence/v0.62.0-board-first-greywatch-1600x900/`
- Ash Ford complete 1280×720 flow: `docs/visual_evidence/v0.62.0-board-first-ash-ford-1280x720/`
- Ash Ford complete 1600×900 flow: `docs/visual_evidence/v0.62.0-board-first-ash-ford-1600x900/`

The Greywatch evidence opens ordinary Recovery on a damaged Narrow Gate and later Armory, with the matching legal repair and exact cost visible beside the board. The undamaged Ash Ford evidence opens on a legal specialist assignment instead of leading with blocked repair diagnostics. All manifests identify automated, debug-free evidence and do not claim human observation.

## Verification

Focused commands:

```text
godot --headless --audio-driver Dummy --path . --script res://tests/test_p37_recovery_hierarchy.gd
P37 Recovery hierarchy: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p5_recovery_action_cards.gd
P5 recovery action cards: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p52_twilight_crossroads_ui.gd
P52 Twilight Crossroads UI: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p31_tutorial_flow.gd
P31 First Watch tutorial flow: PASS

python3 tools/validate_investment_progress.py
PTK investment vertical: PASS

python3 tools/validate_gpt56_progress.py
GPT56 investment packets: PASS
```

The full repository verifier passed under Godot 4.7.2. Its durable gates include:

```text
PTK investment vertical: PASS (PTK-I1 through PTK-I6 implemented; human evidence pending; owner distribution approval required)
GPT56 investment packets: PASS (PTK-GPT56-1 through PTK-GPT56-5 implemented; PTK-P16 remains human-owned)
P12 alpha scenario matrix: PASS (228 deterministic viable cases; 456 uninterrupted/resumed simulations)
P12 alpha scenario outcomes: { "held": 216, "partial_breach": 12 }
P53 alpha flow hardening: PASS (large text, accessibility, focus, audio, and all phase save boundaries)
PTK-EA-1 Greywatch anchor: PASS (responsive setup, three assaults, two recoveries, terminal replay)
PTK Early Access campaign: PASS
PTK Early Access campaign UI: PASS
PASS: Pack the Keep initial real-time auto-battle tests
```

`env PATH="/tmp/pack-the-keep-bin:/usr/bin:/bin:/usr/sbin:/sbin" bash scripts/verify.sh` exited 0. The tagged Windows workflow remains the final platform package gate.
