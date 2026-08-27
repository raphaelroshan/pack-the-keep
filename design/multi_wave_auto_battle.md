# Pack the Keep — Multi-Wave Auto-Battle

## Goal

Turn the current single-invasion test into a readable three-wave authored scenario run. A tester starts one invasion sequence, watches each wave resolve automatically, receives a real recovery interval between waves, and sees the next doctrine begin without returning to the title or manually selecting Start Invasion.

## Sequence contract

The selected scenario remains authoritative. Its `wave_plans` and `doctrines` define the wave count, enemy composition, and escalation. Gatehouse Lock currently has three waves: Gate Assault, Distributed Sabotage, and Feint and Flank. Other scenarios retain their authored three-wave plans.

The player still gets recovery agency between waves. When a wave resolves, the core opens the existing two-action repair interval. The next wave does not begin until the player finishes that interval. Finishing the interval automatically starts the next authored wave, using the scenario doctrine and composition already defined by `start_wave`. No new hidden economy or combat rules are introduced.

The final authored wave ends in Results as before. A collapse ends the sequence immediately and does not auto-start another wave. If a player manually uses the existing Finish repair interval command on an earlier wave, the UI starts the next wave exactly once.

## Timing and presentation

The UI keeps the battle paused at the start of every wave. A tester may inspect the new forecast, route, and enemy composition before pressing Space for real-time presentation or N for deterministic manual steps. When a wave resolves, Results presents a short inter-wave recovery state rather than claiming the whole scenario is complete. The event feed names the completed wave and the next doctrine.

The real-time loop automatically advances an active wave only. It never silently consumes repair actions. Automatic sequencing means automatic transition after explicit recovery completion, not an unattended chain that removes placement and repair decisions.

## Persistence and determinism

Wave index, active wave, repair interval, battle clock, current enemies, and event history remain serialized. A save loaded during an active wave resumes that wave; a save loaded during recovery resumes the recovery interval. The same seed, scenario, placement, recovery commands, and speed-independent manual steps produce the same multi-wave reports.

The core exposes the authored wave count and whether another wave is available as read-only queries. The UI uses those queries rather than reimplementing scenario length rules.

## Acceptance criteria

A Gatehouse Lock run can start at wave 1, resolve, open recovery, accept two repair/assignment actions, and after Finish repair interval automatically enter wave 2 with its Sapper composition. Repeating recovery enters wave 3 with its Climber composition. Finishing wave 3 enters Results and does not start a fourth wave. Manual `start_wave` remains blocked during recovery and after the authored scenario ends. Existing single-wave, save/load, ammo/reload, pause/speed, placement, focus, and quick-playtest behavior remain deterministic and covered.
