# P10 — Display and Effects-Audio Settings

## Intent

Complete the first desktop settings pass with explicit window mode, resolution, and effects-volume controls. These values share the versioned presentation settings file and remain outside `PackKeepState`.

## Behavior

- Window mode toggles between windowed and fullscreen.
- Windowed resolution cycles through 1280×720, 1600×900, and 1920×1080; the selected windowed size is retained while fullscreen is active and restored when returning to windowed mode.
- Effects volume cycles through 25%, 50%, 75%, and 100%. The existing mute control remains an independent immediate override.
- Settings schema 3 loads schema-1 and schema-2 files with documented display/audio defaults.
- Unsupported values, malformed JSON, and future schemas fall back safely.
- Headless verification can disable OS-window mutations while still exercising validation and persistence.

## Acceptance criteria

- Every control exposes its current value in text and persists immediately.
- A new UI instance restores window mode, windowed resolution, and effects volume.
- Returning from fullscreen applies the selected windowed resolution.
- Effects volume changes generated feedback amplitude only; it does not affect event timing or simulation commands.
- Display and audio preference changes leave serialized authoritative state byte-for-byte unchanged.
- Existing accessibility, controller, and schema migration tests remain green.

## Non-goals

- No music or voice buses before those audio layers exist.
- No arbitrary resolution entry, monitor selector, HDR, VSync, or platform-specific display API.
