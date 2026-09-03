# P73 Battle-First Assault Verification

Build `0.61.0-battle-first-assault` keeps active combat and its immediate controls together at the minimum supported review resolution without changing authoritative combat.

At 1280×720 and 100% scale, Assault uses a phase-specific two-column composition. The complete two-floor fortress and contact timeline remain visible beside the current phase/tick state, Sound the Bell or pause action, commander intervention, and focused-threat inspection. The normal flow removes the repeated main subtitle, guidance, duplicate pause action, and duplicate pause status from the board column.

At 1280×720 and 150% scale, Assault returns to the stacked composition and restores the main primary action. At 1600×900 and 125% scale, the battle-first composition remains horizontally bounded. First Watch retains its tutorial-owned primary action and focus target at the same board-first breakpoint. Responsive relayout also re-reveals an already-focused terminal replay action after large-text geometry settles.

## Evidence

- Greywatch complete 1280×720 flow: `docs/visual_evidence/v0.61.0-battle-first-greywatch-1280x720/`
- Greywatch complete 1600×900 flow: `docs/visual_evidence/v0.61.0-battle-first-greywatch-1600x900/`
- Ash Ford complete 1280×720 flow: `docs/visual_evidence/v0.61.0-battle-first-ash-ford-1280x720/`
- Ash Ford complete 1600×900 flow: `docs/visual_evidence/v0.61.0-battle-first-ash-ford-1600x900/`

The 1280×720 Assault frames show distinct Greywatch and Ash Ford geometry while preserving the same readable time-control and threat-inspection hierarchy. Greywatch evidence also records the commander intervention and room-repair feedback. All manifests identify automated, debug-free evidence and do not claim human observation.

## Verification

Focused commands:

```text
godot --headless --audio-driver Dummy --path . --script res://tests/test_p48_responsive_layout.gd
P48 responsive layout: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p42_battle_command_hierarchy.gd
P42 battle command hierarchy: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p31_tutorial_flow.gd
P31 First Watch tutorial flow: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p31_tutorial_resilience.gd
P31 tutorial resilience: PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p52_twilight_crossroads_ui.gd
P52 Twilight Crossroads UI: PASS
```

Full repository output also passed:

```text
PTK investment vertical: PASS (PTK-I1 through PTK-I6 implemented; human evidence pending; owner distribution approval required)
GPT56 investment packets: PASS (PTK-GPT56-1 through PTK-GPT56-5 implemented; PTK-P16 remains human-owned)
P12 alpha scenario matrix: PASS (228 deterministic viable cases; 456 uninterrupted/resumed simulations)
P12 alpha scenario outcomes: { "held": 216, "partial_breach": 12 }
K8 performance budget: PASS (40 runs in 4683 ms; 120 UI refreshes in 285 ms)
P53 alpha flow hardening: PASS (large text, accessibility, focus, audio, and all phase save boundaries)
PTK-EA-1 Greywatch anchor: PASS (responsive setup, three assaults, two recoveries, terminal replay)
PTK Early Access campaign: PASS
PTK Early Access campaign UI: PASS
PASS: Pack the Keep initial real-time auto-battle tests
```

`env PATH="/tmp/pack-the-keep-bin:/usr/bin:/bin:/usr/sbin:/sbin" bash scripts/verify.sh` exited 0 under Godot 4.7.2.
