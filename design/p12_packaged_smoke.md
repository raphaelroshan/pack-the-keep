# P12 — Packaged Build Smoke Contract

## Intent

Begin alpha hardening at the distribution boundary. A Windows artifact is not ready merely because export succeeded: CI must launch the packaged main scene, exercise a short offline gameplay path, prove that save/settings files stay inside an isolated user-data root, and observe a clean process exit.

## Smoke sequence

1. Export the release executable with the repository's Windows preset.
2. Launch the packaged main scene headlessly with network proxies pointed at an unreachable local endpoint and require exit code zero within a fixed timeout.
3. Relaunch the real main scene with both a dedicated user argument and environment guard, then use the normal command and persistence implementations with smoke-specific filenames.
4. Place a starter defender, start Gatehouse Lock, advance one deterministic step, save the run, and save presentation preferences.
5. Verify the save, settings, and structured smoke report were written below the CI-owned profile root.
6. Free the main scene, observe clean teardown, and require the packaged process to exit successfully.

## Acceptance criteria

- The smoke runner has a bounded timeout and prints captured output on failure.
- The report proves a non-editor packaged build loaded the complete runtime catalog.
- Gameplay reaches battle step one through the real main scene and authoritative keep state.
- The run save contains the expected game ID and current save schema.
- The settings file contains the current settings schema.
- User data resolves beneath the isolated profile root supplied by CI.
- Main-scene launch and scripted teardown both return zero with unreachable proxy settings.
- Pull-request and tagged release packaging use the same smoke runner.

## Non-goals

- No storefront SDK, signing, installer, updater, telemetry, or network service.
- No GUI automation or pixel comparison in the Windows runner yet.
- Malformed-save recovery, controller input, scaling, and reinstall persistence remain subsequent P12 slices.

**Trade-off:** The smoke path runs headlessly and proves package/runtime boundaries rather than graphics-driver behavior. Visual and hardware coverage remain separate release checks.
