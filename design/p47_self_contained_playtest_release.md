# P47 — Self-contained playtest release

## Player-facing purpose

Give every human observer one immutable download cohort containing the Windows build, exact provenance, instructions, and one unfilled record template for each required commander/modifier session. An observer should not need to find a separate expiring CI artifact or reconstruct the evidence format before testing.

## Data and ownership

- The tagged release workflow owns packaging only; it does not create gameplay state or human evidence.
- `tools/write_playtest_build_manifest.py` remains authoritative for executable provenance.
- `tools/write_playtest_brief.py` remains authoritative for observer instructions.
- `tools/write_playtest_matrix_templates.py` remains authoritative for blank matrix records.
- Generated templates must retain blank human-owned fields and `not_tested` observations.
- `content/p16_playtest_protocol.json` remains `release_ready: false`; automation cannot approve distribution.

## Acceptance criteria

1. A tagged release regenerates `playtest-build.json` from the exact exported executable and tag commit.
2. It generates `PLAYTEST_README.md` and all four required unfilled matrix templates after validating that provenance.
3. The GitHub prerelease exposes the executable, release manifest, playtest manifest, observer brief, templates, and source archive as durable assets.
4. A repository test fails if the release workflow drops any required generator or published asset.
5. Existing deterministic, packaged smoke, offline, and human-evidence boundaries remain unchanged.

## Test cases

- Inspect the workflow contract for all three P16 generation commands and their exact inputs.
- Assert the release publication command includes every generated playtest asset.
- Run the existing P16 manifest, brief, template, protocol, and release-identity tests.
- Run `bash scripts/verify.sh` and `git diff --check`.
- On the tag, require the release workflow and inspect the published prerelease asset list.

## Non-goals

- Do not fabricate, pre-fill, or mark a human session complete.
- Do not change the playtest matrix, game simulation, save schema, or UI.
- Do not auto-approve the private alpha or change `release_ready`.
