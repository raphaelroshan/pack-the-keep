#!/usr/bin/env python3
"""Validate that shipped player-facing copy stays in-world and distinguishable."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


PLAYER_TEXT_KEYS = {
    "ability_name", "ability_text", "choice", "consequence_text", "effect",
    "failure_mode", "fit", "intent", "label", "lesson", "limitation",
    "name", "objective", "opening", "placement_question", "preparation_focus",
    "principal_pressure", "question", "reason", "report_phrase", "risk", "role",
    "setup", "short_role", "skill", "strength", "summary", "telegraph",
    "tradeoff", "visible_result", "weakness",
}
FORBIDDEN_DATA_TERMS = {
    "authored": re.compile(r"\bauthored\b", re.IGNORECASE),
    "deterministic": re.compile(r"\bdeterministic\b", re.IGNORECASE),
    "prototype": re.compile(r"\bprototype\b", re.IGNORECASE),
    "debug": re.compile(r"\bdebug\b", re.IGNORECASE),
    "milestone": re.compile(r"\bP\d+(?:\.\d+)?\b", re.IGNORECASE),
}
META_SCENARIO_OPENERS = re.compile(r"^(teach|test|stress-test)\b", re.IGNORECASE)
FORBIDDEN_UI_PHRASES = (
    "authored defense",
    "authored doctrine",
    "authored opening",
    "authored baseline",
    "authored assault",
    "authored response",
    "deterministic tick",
    "deterministic stepping",
    "automated baseline",
    "quick playtest",
    "quick test",
    "playtest observation",
    "authoritative combat",
    "authoritative report",
)
UI_SOURCES = (
    "src/ui/main.gd",
    "src/ui/battle_beat_presentation.gd",
    "src/ui/phase_header_snapshot.gd",
    "src/ui/preparation_presentation_snapshot.gd",
    "src/ui/recovery_presentation_snapshot.gd",
    "src/ui/results_presentation_snapshot.gd",
    "src/ui/war_council_choice_panel.gd",
    "src/ui/war_council_presentation_snapshot.gd",
    "src/ui/tutorial_director.gd",
)


def _load(path: Path, errors: list[str]) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{path}: cannot read JSON: {exc}")
        return {}
    if not isinstance(value, dict):
        errors.append(f"{path}: root must be an object")
        return {}
    return value


def _walk_player_text(value: Any, path: str = "") -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = []
    if isinstance(value, dict):
        for key, child in value.items():
            child_path = f"{path}.{key}" if path else key
            if key in PLAYER_TEXT_KEYS and isinstance(child, str):
                rows.append((child_path, child))
            else:
                rows.extend(_walk_player_text(child, child_path))
    elif isinstance(value, list):
        for index, child in enumerate(value):
            rows.extend(_walk_player_text(child, f"{path}[{index}]"))
    return rows


def validate_repository(root: Path, errors: list[str]) -> None:
    data_root = root / "data"
    for path in sorted(data_root.rglob("*.json")):
        payload = _load(path, errors)
        for field, text in _walk_player_text(payload):
            for name, pattern in FORBIDDEN_DATA_TERMS.items():
                if pattern.search(text):
                    errors.append(f"{path.relative_to(root)}:{field}: player copy contains development term {name!r}")

    scenario_files = sorted((data_root / "scenarios").glob("*.json"))
    for path in scenario_files:
        summary = str(_load(path, errors).get("short_role", "")).strip()
        if META_SCENARIO_OPENERS.search(summary):
            errors.append(f"{path.relative_to(root)}:short_role: describe the threat, not what the scenario teaches or tests")

    event_titles: dict[str, list[str]] = {}
    for path in sorted((data_root / "events").glob("*.json")):
        payload = _load(path, errors)
        title = str(payload.get("title", "")).strip().casefold()
        if title:
            event_titles.setdefault(title, []).append(path.name)
        setup = str(payload.get("setup", ""))
        if len(setup) > 180:
            errors.append(f"{path.relative_to(root)}:setup: {len(setup)} characters exceeds the compact event-copy budget")
    for title, paths in sorted(event_titles.items()):
        if len(paths) > 1:
            errors.append(f"event title {title!r} is duplicated across {', '.join(paths)}")

    for relative in UI_SOURCES:
        path = root / relative
        try:
            source = path.read_text(encoding="utf-8")
        except OSError as exc:
            errors.append(f"{relative}: cannot read source: {exc}")
            continue
        lowered = source.casefold()
        for phrase in FORBIDDEN_UI_PHRASES:
            if phrase in lowered:
                errors.append(f"{relative}: player-facing source contains development phrase {phrase!r}")
        if "behaviour" in lowered:
            errors.append(f"{relative}: use the project's established American spelling 'behavior'")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    errors: list[str] = []
    validate_repository(args.root.resolve(), errors)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    scenario_count = len(list((args.root / "data" / "scenarios").glob("*.json")))
    event_count = len(list((args.root / "data" / "events").glob("*.json")))
    print(f"Player-facing copy: PASS ({scenario_count} scenarios, {event_count} events, {len(UI_SOURCES)} UI sources)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
