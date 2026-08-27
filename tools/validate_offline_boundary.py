#!/usr/bin/env python3
"""Reject direct network clients from the offline core and UI boundary."""
from __future__ import annotations

import re
from pathlib import Path


NETWORK_APIS = (
    "HTTPRequest",
    "HTTPClient",
    "WebSocketPeer",
    "WebSocketMultiplayerPeer",
    "ENetMultiplayerPeer",
    "StreamPeerTCP",
    "PacketPeerUDP",
    "TCPServer",
)


def main() -> int:
    roots = (Path("src/core"), Path("src/ui"))
    errors: list[str] = []
    scanned = 0
    pattern = re.compile(r"\b(?:" + "|".join(re.escape(api) for api in NETWORK_APIS) + r")\b")
    for root in roots:
        for path in sorted(root.rglob("*.gd")):
            scanned += 1
            for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
                code = line.split("#", 1)[0]
                match = pattern.search(code)
                if match:
                    errors.append(f"{path}:{line_number}: direct network API {match.group(0)} is outside a platform adapter")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"offline boundary: PASS ({scanned} gameplay scripts, no direct network clients)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
