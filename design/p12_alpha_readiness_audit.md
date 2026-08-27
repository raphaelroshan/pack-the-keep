# P12 — Alpha Readiness Audit

## Intent

Turn the P12 checklist into a machine-readable release boundary. Every required alpha-hardening item must name durable repository evidence, and the package job must validate the combined initial/reinstall artifact report before accepting a candidate.

## Rules

- `content/p12_alpha_checklist.json` contains every required P12 check exactly once.
- Checklist evidence paths must exist and remain reviewable.
- Build identity must match the project, framework, CI manifest, and checklist.
- Source jobs validate checklist structure; package/release jobs additionally validate dynamic Windows evidence.
- The combined artifact must independently prove release-template execution, clean-profile setup, executable relocation, stable user-data paths, current schemas, complete content, and both runtime phases.
- Interrupted-save tests require a valid primary to outrank a stranded temporary file, a missing primary to recover from backup, and a temporary file alone to leave the live run unchanged.
- Status remains `candidate`; commercial or human alpha approval is never inferred from CI.
- Required human gates remain explicitly `pending` with one manual evidence guide.

**Trade-off:** The audit proves automated evidence coverage, not subjective playtest quality or storefront approval.
