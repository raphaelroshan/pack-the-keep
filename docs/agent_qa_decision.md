# Agent QA Decision Record

## Decision

Adopt a shared repository-owned agent QA layer across Market of Ash, Pack the Keep, and The Long March. The layer consists of `docs/qa_playbook.md`, `tools/agent_qa_runner.py`, `tools/agent_qa_capture.gd`, `scripts/agent_qa.sh`, scenario manifests under `qa/scenarios/`, and CI evidence artifacts.

## Why this design

The repositories already contain valuable game-specific acceptance suites. Replacing them with a generic framework would risk losing domain knowledge and would delay work on the investment vertical. The shared layer therefore wraps the existing verifier, adds explicit result classification, captures stdout/stderr, measures duration, records the environment, and performs a readiness-aware Godot viewport capture.

## Pack the Keep adapter

Pack the Keep's Greywatch manifest is executable. The runner first invokes the repository's authoritative verifier, then runs `tests/test_ea1_greywatch_anchor.gd` as the semantic logic journey and `tools/capture_vertical_slice.gd` as its visual witness. The adapter binds every declared command to an existing UI or `KeepState` boundary, records the observed phase sequence, and requires named 1280×720 screenshots before it may return `PASS`.

## Trade-offs

The adapter reuses established game-specific fixtures instead of adding a second automation API. This keeps command authority and assertions close to the shipped flow, but means each repository still needs its own explicit binding table. A manifest marked `planned` remains a contract only and must never be reported as an executed journey.

The capture script rejects empty, wrong-size, and visually uniform frames. This can expose renderer or startup problems earlier, but it may require per-game readiness signals for scenes whose first frame is intentionally sparse. Such exceptions must be explicit in the manifest rather than weakening the global check.

Third-party frameworks remain optional. If a framework is adopted, pin a Godot 4.4.1-compatible version and pilot it in one repository. The custom verifier remains authoritative for simulation, content, release, save, and campaign acceptance.

## Status vocabulary

`PASS` means the requested verifier completed successfully and the required evidence was produced. `FAIL` means an assertion, command, or capture failed. `TIMEOUT_PARTIAL` means the verifier exceeded its budget and partial logs are available; it is never equivalent to pass. `BLOCKED_ENVIRONMENT` means a required tool or binary was unavailable. `INVALID_EVIDENCE` means a screenshot or manifest could not prove the claimed state.

## Next decisions

1. Wire the Market of Ash and The Long March manifests to their game-specific semantic command adapters.
2. Add per-suite timing records to the existing long wrappers.
3. Add state-specific visual baselines only after review establishes which hashes should be stable across renderers.
4. Pilot one compatible Godot test framework only if it reduces maintenance.
