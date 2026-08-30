# K8 — Private-alpha hardening gate

## Purpose

K8 turns the existing accessibility, persistence, controller, audio, package lifecycle, provenance, and failure-recovery checks into one enforceable readiness contract. It adds a bounded performance smoke test and a durable limitations document without changing gameplay or claiming human approval.

## Contract

- `content/k8_private_alpha_gate.json` lists every required automated or documented area and preserves all human gates.
- `tools/validate_k8_private_alpha.py` rejects missing evidence, version drift, release claims, removed human gates, and incomplete packaged lifecycle evidence.
- `tests/test_k8_performance_budget.gd` measures deterministic scenario resolution and repeated 2560×1440 large-text UI refresh against deliberately conservative CI budgets.
- Tagged packages still ship the exact executable, provenance, source, observer brief, and unfilled session templates.

## Non-goals

K8 does not sign an installer, create storefront integration, fabricate human sessions, certify Windows hardware, or set any release-ready flag.
