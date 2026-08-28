# P12 Human Alpha Checklist

Automated status is a release-candidate signal only. A human owner must record evidence for every gate below before changing the P12 checklist from `candidate`.

| Gate | Required evidence | Status |
| --- | --- | --- |
| Windows GPU presentation | Launch at 1280×720, 1600×900, 1920×1080, and fullscreen on supported Windows hardware; inspect Preparation, Battle, Results, overlays, and scrolling. | Pending |
| Physical controllers | Test Xbox-compatible and one additional controller through navigation, placement, pause, manual step, ability, focus, remap, conflict resolution, and reset. | Pending |
| Procedural audio | Hear each semantic cue at multiple volume presets; verify mute, restore, and no clipping or stuck playback. | Pending |
| Forced-close recovery | Terminate during active play and around save operations; confirm primary/backup recovery and unchanged current state after invalid candidates. | Pending |
| Signed installer | Install, upgrade, uninstall, and reinstall from a signed Windows package; verify shortcuts, save retention policy, and no executable-relative data. | Pending |
| Storefront launch | Launch offline through protected Steam and Epic test environments after adapters exist; verify no platform dependency enters `PackKeepState`. | Pending |
| Human playtest | Complete the four-session commander/modifier matrix and all nine observations in [`p16_human_playtest_protocol.md`](p16_human_playtest_protocol.md); record comprehension, readability, recovery, trust, and close findings. | Pending |

Do not publish, sign, upload to a storefront, or mark `release_ready` true from automated evidence alone.
