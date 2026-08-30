# Pack the Keep — Latest Visual Review

**Build:** `v0.30.0-private-alpha-gate`

**Branch:** `origin/main`

**Engine:** Godot 4.4.1

**Capture:** 1280×720 Xvfb display; title and War Council flow captured from a real launch.

## Verification

The full repository verification suite passed, including policy and content checks, P13–P47 progression coverage, event and persistence tests, controller and scaling checks, accessibility checks, auto-battle coverage, release packaging, and the initial real-time battle tests. The project launches successfully and advances from Main Menu into War Council.

## Evidence

- [Title](visual_evidence/v0.30.0-private-alpha-gate-review-2026-08-30/pack_01_title.png)
- [War Council](visual_evidence/v0.30.0-private-alpha-gate-review-2026-08-30/pack_02_first_action.png)
- [Follow-up](visual_evidence/v0.30.0-private-alpha-gate-review-2026-08-30/pack_03_followup.png)

## Findings

The title screen is substantially more authored than the earlier prototype and communicates CHOOSE, BUILD, and HOLD clearly. The War Council flow reaches a real commitment surface and exposes commander, scenario pressure, risk, variation, and the Enter Keep action.

The remaining visible issue at 1280×720 is density and vertical overflow. The page continues below the viewport, the top navigation is busy, and the commander/defense panels are pushed into a scroll-heavy composition. The primary commit action appears before all choice context is comfortably visible. This makes the preparation decision harder to understand even though the underlying systems and automated checks pass.

## Next roadmap sequence

1. Repair responsive War Council and Preparation layouts for 1280×720, 1600×900, large text, high contrast, and controller focus. Use a deliberate single-column fallback rather than simply shrinking the existing split pane.
2. Keep the fort visible as the primary decision surface while selecting commander, scenario, pack, placement, and commit. One selected subject must have one clear identity, purpose, condition, and next action.
3. Extract War Council, Preparation, Battle, Recovery, and Results presentation boundaries from the monolithic UI without changing `KeepState` or command semantics.
4. Finish battle beat readability: forecast, approach, target lock, wind-up, response, impact, dependency consequence, and settle. Pause, speed, and manual-step must remain authoritative-tick aligned.
5. Make Recovery and terminal Results distinct, causal, and replay-oriented.
6. Add one controlled commander, keep, pack, or enemy teaching slice only after the responsive and preparation contracts pass. Do not add broad content to avoid fixing the current hierarchy problem.
7. Harden the private-alpha artifact across save migration, controller, audio, clean install, packaging, and deterministic replay.

Human testing is optional follow-up calibration and is not a prerequisite for these implementation steps. Automated tests, normal-flow launches, layout assertions, and screenshot evidence are the active gates.
