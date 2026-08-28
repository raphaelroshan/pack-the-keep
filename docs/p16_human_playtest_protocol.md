# P16 Human Playtest Protocol

This protocol prepares controlled alpha evidence without treating automation as a human result. Do not distribute a build, invite external testers, or change release status without the owner explicitly approving that action.

## Session matrix

Complete at least four sessions covering each combination of:

- Castellan baseline
- Castellan with Hardened Vanguard
- Warden baseline
- Warden with Hardened Vanguard

Use the current packaged Windows release candidate where possible. Additional sessions should vary controller, UI scale, scenario, prior experience, and whether the run includes a partial breach.

## Start a session record

Generate a record before play begins:

```bash
python3 tools/new_playtest_session.py \
  --session-id session_001 \
  --tester-alias tester_a \
  --commander castellan \
  --run-type baseline \
  --scenario gatehouse_lock \
  --output playtests/sessions/session_001.json
```

The generated record contains only `not_tested` observations. A human observer updates it after the session. Use a non-identifying alias; do not include names, contact details, recordings, or unrelated device identifiers.

## Required observations

Every completed record must cover onboarding, first successful hold, partial-breach recovery, event comprehension, replay motivation, controller/scaling use, pause trust, save recovery, and packaged close. Mark an item `not_tested` when the session genuinely did not exercise it; never infer success from automated checks.

Findings should be concrete and reproducible. Every `friction` or `blocked` observation must link to a finding. Each finding records a unique snake-case `id`, a stable snake-case `issue_key` shared by the same problem across sessions, one required `observation_id`, severity, summary, reproduction steps, and a small `suggested_action`. Use `critical` only for data loss, unsafe distribution, unrecoverable progression, or an inability to complete the required flow. Preserve the original JSON evidence.

Only the human observer may set `completed` to `true`, after all nine observations have been exercised and `observer_summary` has been written. Automation must leave generated records unfilled.

## Validate evidence

```bash
python3 tools/validate_p16_playtests.py \
  --protocol content/p16_playtest_protocol.json \
  --sessions playtests/sessions \
  --ci-manifest tools/ci_manifest.json \
  --alpha-checklist content/p12_alpha_checklist.json
```

With no completed sessions, validation reports readiness and leaves the human gate pending. A complete matrix is coverage evidence only: the human gate remains pending until the owner reviews the records and explicitly changes the release boundary.

## Summarize and triage

```bash
python3 tools/summarize_p16_playtests.py \
  --protocol content/p16_playtest_protocol.json \
  --sessions playtests/sessions \
  --ci-manifest tools/ci_manifest.json \
  --alpha-checklist content/p12_alpha_checklist.json
```

The deterministic summary reports matrix coverage, observation-status counts, all finding keys, and task candidates only when the same `issue_key` appears in at least two session records. Suggested actions remain human-authored and should be implemented as small reversible changes. The summary does not approve a release.
