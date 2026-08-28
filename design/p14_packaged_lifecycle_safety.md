# P14 Packaged Lifecycle Safety

## Intent

Extend the Windows release-candidate smoke from a two-launch relocation check into a bounded profile lifecycle matrix. The executable must remain portable while user data remains isolated, recoverable, and independent of presentation settings.

## Automated phases

1. `clean_install` starts with no run, settings, temporary, or backup files and creates a schema-4 battle-step-one profile.
2. `reinstall` launches the same build from a directory containing only a copied executable and restores the clean-install profile.
3. `stale_backup` places valid but older run/settings backups beside valid primary files and proves the primaries win.
4. `missing_profile` launches against a profile root that did not exist before process start, retains documented defaults, and leaves authoritative state unchanged when Load finds no candidate.
5. `upgrade` launches from another clean install directory against schema-3 run/settings fixtures, reports migration, preserves supported values, defaults newly introduced settings, and rewrites both primaries as schema 4.

The Python runner owns Windows paths, isolated profile roots, executable relocation, and fixture preparation. The Godot smoke adapter owns only observable application behavior. Every phase keeps unreachable proxy guards in place, loads the runtime catalog, and frees the main scene before exit.

## Non-goals

This remains a portable embedded-executable test. Signed installers, registry entries, shortcuts, storefront launchers, and forced operating-system termination remain human or later release gates.
