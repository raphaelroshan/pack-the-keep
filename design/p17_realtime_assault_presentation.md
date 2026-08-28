# P17 Real-Time Assault Presentation and 1440p Support

## Player-facing purpose

Combat should feel like an assault unfolding across the keep rather than a sequence of turns waiting for the player to press an advance button. Starting combat should immediately put enemies in motion, while pause, speed controls, and manual stepping remain available as tactical accessibility tools. At 2560×1440, the fort and command rail should remain readable instead of occupying a small corner of the window.

## Authoritative boundary

`PackKeepState` keeps its deterministic one-second resolution steps, authored scenario phases, recovery intervals, and save schema. The UI owns continuous interpolation between those steps, transient engagement traces, default playback state, presentation wording, window presets, and responsive scaling. Changing display size, pausing, or rendering motion must not change the serialized simulation.

## Player-facing behavior

- Starting an assault enters Battle in running 1× time instead of waiting at step zero.
- The primary Battle action pauses or resumes real-time play; manual step remains available through its existing input/control path while paused.
- Enemy markers move continuously toward their authored contact points using the fractional simulation clock.
- Each resolved combat tick briefly draws defender-to-target engagement traces and impact rings.
- Authored groups are presented as assault phases rather than arcade-style waves. Recovery remains a deliberate lull between phases.
- Windowed presets include 1280×720, 1600×900, 1920×1080, and 2560×1440. New installs default to 1600×900, and 2560×1440 uses the existing scalable layout rather than changing simulation state.

## Acceptance criteria

1. A newly started battle is running and advances through `_process()` without a manual-step click.
2. Pause freezes authoritative progress; resume continues it; manual stepping remains deterministic.
3. Enemy marker position changes during a fractional second before the next authoritative combat tick.
4. A resolved tick produces a bounded presentation-only engagement trace unless reduced motion is enabled.
5. The UI names assault phases and recovery lulls while internal scenario compatibility remains intact.
6. 2560×1440 is selectable, persisted, restored, and visually readable; 1280×720 remains supported.
7. Presentation timing and display changes do not alter deterministic outcomes or serialized state.

## Tests

- UI timing coverage for running start, fractional motion, pause/resume, and manual step.
- Display settings coverage for the 2560×1440 preset and migration defaults.
- Packaged smoke coverage for real-time start followed by pause/freeze/manual-step verification.
- 1280×720 and 2560×1440 renderer captures.
- Full deterministic and scenario-matrix regression suite.

## Non-goals

- Removing authored scenario phases, recovery decisions, or deterministic combat steps.
- Projectile physics, navigation agents, free movement, or frame-rate-dependent damage.
- Increasing enemy/content count.
- Making pause or manual step less accessible.
