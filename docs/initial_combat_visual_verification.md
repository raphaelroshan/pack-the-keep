# Initial Real-Time Auto-Battle Visual Verification

The initial-combat capture was run under `xvfb-run` with Godot 4.4.1 at the configured 1280×720 viewport. The deterministic setup opened the Firekeepers pack, placed Fire Team on the upper floor, staged area pressure, focused the Siege Beast, resolved one battle step, and enabled high-contrast cues.

The battle screenshot rendered as a valid 1280×720 RGBA PNG. It showed the real-time auto-battle explanation, the named-route and behavior-target wording, the active approach phase, one spent ammunition round in the combat metrics, the upper-floor Fire Team, the focused Siege Beast, and the existing area-pressure presentation. The explanatory copy wrapped across two lines without clipping and the two-floor map remained within the target frame.

The scrolled command-panel screenshot rendered as a valid 1280×720 RGBA PNG. It showed the paused battle control, speed control, enemy dropdown, authoritative Siege Beast inspector, focused response preview, counter family, commander ability availability, and recovery guidance. The piece ammo counter is visible in the map piece label and the combat metrics expose `ammo spent`.

The capture completed without parser or runtime errors. The visual proof is intentionally functional rather than final art: the current project still uses procedural combat markers and optional code-generated feedback tones, while dedicated Warden/Siege Beast art, projectile animation, and authored sound remain deferred.
