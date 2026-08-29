# P42 Battle Command Hierarchy

## Intent

Make the Assault command rail read like a live command post instead of a debug control stack. The default view must answer: what is happening, can time move, which commander intervention remains, and how do I inspect the current threat?

## Player-facing hierarchy

1. **Battle state** — phase, tick, live/paused state, speed, and the most useful immediate instruction.
2. **Primary time command** — sound the bell, pause, or resume.
3. **Commander intervention** — the authored once-per-phase ability and its current availability.
4. **Threat inspection** — map/timeline-first focus with one visible action for the currently focused threat.
5. **Tactical controls disclosure** — deterministic single-step, speed cycling, and the fallback threat selector begin collapsed.

## Interaction contract

- Opening or closing tactical controls is presentation-only and cannot mutate run or combat state.
- Existing shortcuts, deterministic stepping, speed settings, auto-pause, commander ability rules, focus cycling, and tutorial gates remain authoritative and unchanged.
- Tutorial enemy-inspection focus must land on a visible control while fallback selectors are collapsed.
- The hierarchy must remain usable in the stacked 125% scale layout.

## Acceptance evidence

- A deterministic UI test verifies the visible hierarchy and collapsed fallback controls.
- The same test verifies disclosure state does not mutate serialized keep state.
- Tutorial focus reaches the visible threat inspection action.
- Existing combat, tutorial, input, scaling, and full verification suites remain green.
