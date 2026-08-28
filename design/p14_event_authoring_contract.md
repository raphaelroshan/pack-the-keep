# P14 Event Authoring Contract

## Intent

Make authored-event scheduling as explicit and reviewable as event effects. A content author should get a precise validation error before Godot loads an event that can repeat forever, drift from the manifest, follow an invalid link, or mutate state through an untyped payload.

## Contract

Every runtime event declares a `selection` object:

```json
{
  "stream": "recovery_event_wave_2",
  "repeat_policy": "once_per_run",
  "cooldown_waves": 0,
  "max_occurrences": 1
}
```

- `stream` is a stable snake-case deterministic stream name. Seed-gated eligibility uses this name rather than display text or file order.
- `once_per_run` requires `cooldown_waves: 0` and `max_occurrences: 1`.
- `repeat_after_cooldown` requires at least one cooldown wave and permits at most three occurrences in the current three-wave scenario model.
- An event can open at most once at the same phase and wave even when repeatable.

Choice records require `id`, `label`, `requirements`, `effects`, and `visible_result`. Requirement operators and effect payload fields are closed sets: unknown operators, operations, missing operands, extra payload keys, and invalid references are rejected.

The canonical active event list lives in `content_manifest.json` under `active_slice.event_ids`. Runtime files, scenario chains, follow-up links, and this manifest list must agree in both directions. Follow-up links must remain in the same scenario and must not form a cycle.

## Verification

Python negative fixtures cover every scheduling, choice, effect, graph, schema-parity, and manifest-parity rule. The Godot catalog mirrors the same contract, and runtime tests prove repeat and cooldown enforcement remains deterministic and save-derived.
