# P12 — Clean Reinstall Profile Continuity

## Intent

Prove that the single-file Windows build can move to a fresh install directory without coupling saves or settings to the executable location, while a fresh profile remains isolated.

## Acceptance criteria

- Initial packaged smoke creates its run and settings beneath the CI profile, not beside the executable.
- CI copies the exported executable to a new install directory and launches that copy.
- The relocated executable restores saved battle step one, 125% scale, and the remapped pause binding from the same profile.
- Both initial and reinstall reports retain the same build identity and user-data root.
- The combined smoke artifact records both phases.

**Trade-off:** Copying the embedded executable models portable uninstall/reinstall behavior, not a signed installer, registry entries, shortcuts, or storefront launchers.
