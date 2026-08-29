# P32 Dedicated Terminal Debrief

## Player-facing intent

A finished defense must look finished. Terminal Results should acknowledge the outcome, keep the damaged fortress visible as evidence, explain the three-phase causal arc, and offer one concrete replay experiment before presenting secondary persistence or exit actions.

## Authoritative boundary

- `PackKeepState.scenario_report()` and existing room/piece state remain the only sources for outcome, wave history, damage, resources, and replay advice.
- `TerminalDebriefPanel` is presentation-only. It receives a copied view model, emits button signals, and never mutates simulation state.
- Existing `_on_playtest_primary_action()`, `_on_save()`, and screen navigation handlers remain the command boundary.
- Run-save schema remains 4. A loaded terminal state derives the same debrief again; no debrief fields are serialized.

## Composition

At terminal Results, the ordinary command rail is replaced by a dedicated debrief panel while the keep board remains visible beside it.

1. Outcome banner and scenario/commander identity.
2. Compact resource and fortress-condition chips.
3. Three-phase timeline with doctrine, outcome, pressure, damage, and recovery use.
4. Key causal chain: what held and what failed.
5. Persistent damage: damaged rooms and disabled or strained defenders.
6. One concrete replay experiment.
7. One dominant primary action plus secondary save and return-to-menu actions.

Inter-wave Results retain the existing recovery panel and action budget. An unresolved terminal event also retains its event/recovery presentation until the event is resolved.

## Input and layout

- The primary debrief action receives focus when terminal Results opens.
- Controller/keyboard activation uses ordinary Godot button focus and the existing handlers.
- At 100% and 125% UI scaling, the debrief may stack below the keep, but it remains a single bounded panel.
- Reduced motion does not change the debrief because it has no required animation.

## Acceptance criteria

1. Terminal Results is visually distinct from inter-wave Recovery.
2. The keep board remains visible as evidence of persistent damage.
3. All authored phases, outcome, resource state, causal explanation, persistent damage, and replay experiment are visible in the debrief read model.
4. Review Setup is the only high-emphasis action; Save Result and Return to Main Menu are secondary.
5. First Watch completion and retry continue through their existing tutorial commands.
6. Saving and loading a terminal state reproduces the same debrief without new save fields.
7. Existing deterministic, input, scaling, accessibility, event, and packaged checks remain green.

## Non-goals

- No new combat math, scenario, enemy, pack, campaign layer, or animation system.
- No broad rewrite of `main.gd`.
- No fabricated human comprehension claim.
