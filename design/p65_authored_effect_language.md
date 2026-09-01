# P65 — Authored Combat and Recovery Effect Language

## Player-facing purpose

Make attacks, structural damage, and repairs feel like the same Greywatch battle language as the fortress and actor silhouettes. A player should distinguish allied ranged response, allied melee response, hostile ranged impact, hostile melee impact, demolition, damaged atmosphere, breach atmosphere, and repair confirmation without the effect covering health, targets, labels, or consequence.

## Data shape

`BoardVisualRegistry` remains the presentation-only authority for effect profiles. It maps existing resolved event families to eight original, text-free 48×48 SVGs and exposes path, size, status, and provenance. The established renderer cache, timing windows, tint, opacity, reduced-motion branch, and procedural fallback remain unchanged.

No effect state enters `KeepState`, save data, targeting, damage resolution, battle cadence, or replay identity.

## Acceptance criteria

1. Five combat meanings resolve five distinct original effects.
2. Damaged and breached rooms resolve distinct original atmosphere silhouettes; stable rooms remain quiet.
3. Successful repairs resolve one original localized pulse.
4. Effects remain subordinate to health trails, damage labels, target lines, focus, room state, and actor silhouettes.
5. Reduced motion keeps the existing compact static consequence and removes travel/recoil.
6. Missing effect textures leave all procedural combat and recovery feedback intact.
7. No active effect profile depends on the temporary Particle Pack.

## Test cases

- Validate all eight paths, authored provenance, uniqueness by semantic family, and resource loading.
- Re-run the staged K4 exchange through normal and reduced-motion timing.
- Validate stable/damaged/breached room profiles and localized repair profile.
- Compare serialized state before and after snapshot/render inspection.
- Capture a full 1600×900 flow with a staged exchange and localized repair frame.
