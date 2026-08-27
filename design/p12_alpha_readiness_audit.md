# P12 — Alpha Readiness Audit

## Intent

Turn the P12 checklist into a machine-readable release boundary. Every required alpha-hardening item must name durable repository evidence, and the package job must validate the combined initial/reinstall artifact report before accepting a candidate.

## Rules

- `content/p12_alpha_checklist.json` contains every required P12 check exactly once.
- Checklist evidence paths must exist and remain reviewable.
- Build identity must match the project, framework, CI manifest, and checklist.
- Source jobs validate checklist structure; package/release jobs additionally validate dynamic Windows evidence.
- The combined artifact must independently prove release-template execution, clean-profile setup, executable relocation, stable user-data paths, current schemas, complete content, and both runtime phases.
- Interrupted-save tests require valid run and settings primaries to outrank stranded temporary files, missing primaries to recover from backups, and temporary files alone to leave gameplay unchanged or restore documented presentation defaults.
- Status remains `candidate`; commercial or human alpha approval is never inferred from CI.
- The CI manifest must keep `release_ready` false until a human explicitly changes the release boundary.
- Required human gates remain explicitly `pending` with one manual evidence guide.

**Trade-off:** The audit proves automated evidence coverage, not subjective playtest quality or storefront approval.
