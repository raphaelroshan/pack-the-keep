# Pack the Keep — settings and tutorial visual review

**Build:** `0.67.0-settings-first-watch-hierarchy`

**Branch:** `codex/p79-settings-tutorial-hierarchy`

**Engine:** Godot 4.7.2

**Viewports:** 1280×720 and 1600×900

## Automated result

The P79 viewport contract, menu flow, display/audio settings, controller scaling, full First Watch flow, and tutorial resilience tests pass. Full verification is recorded in `docs/p79_settings_tutorial_hierarchy_verification.md`.

## Visual result

Settings now reads as a deliberate game screen. Five named groups separate readability, display and sound, battle pace, local session notes, and input; all controls and Back fit the first 1280×720 viewport. The wide layout uses the same balanced surface instead of leaving an empty main column beside a narrow scrolling rail.

First Watch now begins as a staged briefing over the authored keep image. Each opening lesson shows its speaker, briefing progress, concrete objective, and the three-part keep/pressure/recovery scope. Continue and Skip Tutorial remain dominant; interactive steps replace the redundant Show Objective label with Refocus Objective.

## Next gate

No automated investment or GPT56 implementation gate remains open. The next bounded task is a fresh pause/inspection affordance audit during live Assault; P16 remains a real-human observation gate and must not be fabricated.

## Evidence

- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-settings-1280x720/02_settings.png`
- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-settings-1600x900/02_settings.png`
- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-tutorial-1280x720/02_tutorial_keep.png`
- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-tutorial-1600x900/02_tutorial_keep.png`
