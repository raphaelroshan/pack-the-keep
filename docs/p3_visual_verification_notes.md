# P3 Visual Verification Notes

The P3 capture was run under `xvfb-run` with Godot 4.4.1 at the configured 1280×720 viewport. A deterministic setup placed a starter Pike Squad, staged the area-pressure doctrine, focused the Siege Beast, and enabled high-contrast cues.

The focused battle screenshot rendered as a valid 1280×720 RGBA PNG. It showed the Siege Beast active marker, enlarged area-pressure rings, explicit `AREA` text, the P3 shortcut legend, the two-floor Greywatch map, and the focused marker with double outline and `FOCUSED` label. The command panel remained scrollable and the map stayed inside the target frame.

The scrolled command-panel screenshot rendered as a valid 1280×720 RGBA PNG. It showed the synchronized enemy dropdown, authoritative enemy inspector, `RESPONSE — FOCUSED 1`, `PAUSED PREVIEW — commit when ready`, threat, target/approach state, counter family, and commander ability availability. The recovery panel was visible and correctly explained that its advisory ranking appears after a Hold or Partial Breach; it did not claim a recovery result that had not occurred.

The capture completed without script or parser errors. The P3 smoke test and full local verification gate also passed. The focused area-pressure screenshot is intentionally a functional UI proof rather than final art; dedicated Warden and Siege Beast art remain deferred.
