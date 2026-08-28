# P12 — Malformed Save Recovery

## Intent

Protect the current run from malformed, truncated, future-version, or crash-interrupted save files. Loading must validate a candidate away from live state and fall back to the last backup when one is usable.

## Rules

1. Parse and fully validate each candidate into a fresh `PackKeepState`; rejected data never touches the current run.
2. Try the primary save first, then the backup when the primary is missing or invalid.
3. Name backup recovery explicitly in the event feed.
4. If neither candidate is valid, retain the current run and report both failure reasons compactly.
5. Existing schema migration remains owned by `PackKeepState.load_serialized()`.
6. Validate nested piece, room, enemy, history, assignment, and catalog-ID shapes before assigning any field on the candidate.

## Acceptance criteria

- Valid primary saves load normally.
- Malformed JSON, malformed state, and future schemas fall back to a valid backup.
- Non-object piece/enemy/room entries, unknown catalog IDs, incomplete room maps, broken assignments, and invalid nested field types are rejected without partially mutating the target state.
- A missing primary can recover a crash-stranded backup.
- Two invalid candidates leave the live run byte-for-byte unchanged.
- Legacy primary or backup payloads still report migration.

**Trade-off:** Recovery does not silently rewrite the primary file. The next explicit save replaces it atomically after the player confirms the recovered run is usable.
