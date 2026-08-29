# P36 Assault Readiness Visual Verification

- Build: `0.22.2-assault-readiness`
- Local render: Godot 4.7.2, macOS, 1600×900 at 100% scale
- Captures: tick-zero ready state and the immediately released live state
- Scope: presentation inspection only; this is not human playtest evidence

## Ready state

- Entering the first assault creates the authoritative wave at tick zero but pauses before the simulation receives time.
- **Sound the Bell — Begin Phase 1** is the dominant action and the controller-focused command.
- The ready line names Gate Assault and the arriving Raider family while the fortress, routes, targets, timeline, forecast, and response preview remain visible.
- Manual step is disabled until the ready state is acknowledged.

## Live state

- Sounding the bell changes the same screen to **Pause — Inspect** and `LIVE 1.0x` without rebuilding or replacing the wave.
- Enemy positions, health, targets, focus, and timeline remain continuous across the handoff.
- Space and the remapped controller pause action use the same readiness/resume path as the primary button.

## Later phases and state boundary

- A doctrine change or newly introduced enemy family creates another ready state after recovery.
- An unchanged doctrine and enemy-family set continues live after recovery.
- Tick-zero save/load re-derives the same readiness reason from authored scenario data without adding save fields.
- Waiting, changing speed, or attempting manual step during readiness leaves battle step, battle clock, enemies, rooms, pieces, materials, and morale unchanged.

Human pacing preference and whether the ready beat improves first-contact comprehension remain pending structured playtest evidence.

