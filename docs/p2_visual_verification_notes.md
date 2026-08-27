# P2 Visual Verification Notes

Captured under `xvfb-run` with Godot 4.4.1 at the configured 1280×720 viewport on the current P2 source.

The preparation capture rendered as a valid 1280×720 RGBA PNG and showed the Greywatch title card, command table, P2 shortcut legend, and scrollable right-side controls without a parser or scene-launch failure. The battle capture rendered as a valid 1280×720 RGBA PNG and showed the paused battle status, explicit forecast and enemy readout, two-floor keep, room state words and condition bars, enemy markers, active invasion progress bar, target/AREA legend, and transient impact/recovery frame.

The capture log contained only the expected virtual-display/ALSA fallback warning: the environment had no real audio device, so Godot used its dummy audio driver. The code-generated feedback path still initialized and the headless P2 UI smoke test passed. The right command panel remains intentionally scrollable; the screenshot shows its scroll thumb and the lower command controls continue below the viewport rather than clipping the whole page.

A second capture pair was taken after explicitly entering Preparation. The preparation screenshot showed the intended `GREYWATCH / Preparation` state, the two-floor map, the selected starter piece, high-contrast state words, and the compact P2 shortcut legend. The paused-battle screenshot showed `GREYWATCH / Battle`, `PAUSED` status, two active Raider markers, explicit doctrine/route/target text, room bars and state words, and the lower map legend. No control-panel geometry was clipped; the lower command content is intentionally available through the visible scroll area.
