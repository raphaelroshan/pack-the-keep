# Private-alpha known limitations

This build is an internal, unsigned pre-alpha candidate. Automated checks establish deterministic behavior and package integrity; they do not establish public-alpha or storefront readiness.

- No P16 human playtest session has been completed. Onboarding clarity, replay motivation, and enjoyment remain unverified by observation.
- Windows GPU presentation has not been reviewed across a hardware matrix. Local Metal captures and CI headless runs do not prove frame pacing on supported Windows systems.
- Physical controller coverage is pending. Automated bindings, navigation, remapping, and packaged input checks do not replace device testing.
- Procedural semantic audio has automated mute, volume, cue, and reduced-motion coverage but no completed human listening review.
- The Windows executable is unsigned and has no installer, updater, crash reporter, cloud save, or storefront integration.
- Saves are local. Automated Windows packaging now kills a prepared process with malformed primaries and proves backup recovery plus clean rewrites; human timing around real save operations, antivirus interaction, power loss, and storage failure remains pending.
- The K8 performance budget covers deterministic scenario resolution and repeated 2560×1440 large-text UI refresh in headless automation. It is not a claim about frame pacing on every target GPU.
- The repository and tagged prereleases are public for development transparency; distribution approval, public-alpha messaging, Steam readiness, and Epic readiness remain false until the owner explicitly changes them.
