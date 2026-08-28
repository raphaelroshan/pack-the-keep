#!/usr/bin/env python3
"""Render deterministic P16 human-playtest coverage and repeated-finding triage."""
from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

import validate_p16_playtests as validator


SEVERITY_RANK = {"critical": 0, "high": 1, "medium": 2, "low": 3}


def render_summary(evidence: dict[str, Any]) -> str:
    protocol = evidence["protocol"]
    sessions = [record["session"] for record in evidence["sessions"]]
    completed_matrix = evidence["completed_matrix"]
    lines = [
        "# P16 Human Playtest Summary",
        "",
        f"Build: `{protocol['build_version']}`",
        "",
        f"Records: {len(sessions)} total; {evidence['completed_count']} completed.",
        "Human playtest gate: **PENDING**. This report never grants release approval.",
        "",
        "## Required matrix",
        "",
        "| Commander | Run type | Completed |",
        "| --- | --- | --- |",
    ]
    for commander in sorted(validator.COMMANDERS):
        for run_type in sorted(validator.RUN_TYPES):
            completed = "yes" if (commander, run_type) in completed_matrix else "no"
            lines.append(f"| {commander} | {run_type} | {completed} |")

    observation_counts: dict[str, Counter[str]] = {
        observation_id: Counter() for observation_id in validator.REQUIRED_OBSERVATIONS
    }
    findings_by_key: dict[str, list[tuple[str, dict[str, Any]]]] = defaultdict(list)
    for session in sessions:
        session_id = str(session.get("session_id", "unknown"))
        for observation in session.get("observations", []):
            observation_counts[str(observation["id"])][str(observation["status"])] += 1
        for finding in session.get("findings", []):
            findings_by_key[str(finding["issue_key"])].append((session_id, finding))

    lines.extend([
        "",
        "## Observation signals",
        "",
        "| Observation | Pass | Friction | Blocked | Not tested |",
        "| --- | ---: | ---: | ---: | ---: |",
    ])
    for observation_id in sorted(validator.REQUIRED_OBSERVATIONS):
        counts = observation_counts[observation_id]
        lines.append(
            f"| {observation_id} | {counts['pass']} | {counts['friction']} | "
            f"{counts['blocked']} | {counts['not_tested']} |"
        )

    repeat_threshold = int(protocol["repeat_threshold"])
    repeated = [
        (key, values)
        for key, values in findings_by_key.items()
        if len({entry[0] for entry in values}) >= repeat_threshold
    ]
    repeated.sort(key=lambda item: (
        min(SEVERITY_RANK[entry[1]["severity"]] for entry in item[1]),
        -len(item[1]),
        item[0],
    ))
    lines.extend(["", "## Repeated task candidates", ""])
    if not repeated:
        lines.append(f"No finding key has appeared in {repeat_threshold} or more session records.")
        lines.append("")
    for issue_key, entries in repeated:
        severity = min((entry[1]["severity"] for entry in entries), key=lambda value: SEVERITY_RANK[value])
        session_ids = sorted({entry[0] for entry in entries})
        observation_ids = sorted({str(entry[1]["observation_id"]) for entry in entries})
        summaries = sorted({str(entry[1]["summary"]) for entry in entries})
        actions = sorted({str(entry[1]["suggested_action"]) for entry in entries})
        lines.extend([
            f"### `{issue_key}` — {severity} — {len(session_ids)} sessions",
            "",
            f"Observations: {', '.join(observation_ids)}",
            f"Sessions: {', '.join(session_ids)}",
            "",
            "Observed summaries:",
            *[f"- {summary}" for summary in summaries],
            "",
            "Suggested reversible actions:",
            *[f"- {action}" for action in actions],
            "",
        ])

    lines.extend(["## All finding keys", ""])
    if not findings_by_key:
        lines.append("No human findings recorded.")
    else:
        for issue_key in sorted(findings_by_key):
            lines.append(f"- `{issue_key}`: {len(findings_by_key[issue_key])} record(s)")
    lines.extend(["", "Owner review and explicit approval remain required.", ""])
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--protocol", required=True)
    parser.add_argument("--sessions", required=True)
    parser.add_argument("--ci-manifest", required=True)
    parser.add_argument("--alpha-checklist", required=True)
    parser.add_argument("--output")
    args = parser.parse_args()
    evidence = validator.load_and_validate_evidence(
        Path(args.protocol), Path(args.sessions), Path(args.ci_manifest), Path(args.alpha_checklist)
    )
    if evidence["errors"]:
        print(f"P16 playtest summary: BLOCK ({len(evidence['errors'])} errors)")
        for error in evidence["errors"]:
            print(f"ERROR: {error}")
        return 1
    rendered = render_summary(evidence)
    if args.output:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(rendered, encoding="utf-8")
        print(f"P16 playtest summary: WROTE {output_path}")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
