# Pack the Keep — Development Environment Setup

## Local environment

Use a Windows development machine as the primary target because the commercial release is intended for Steam and Epic Games Store. Keep the project in Git and bind the project folder to the coding agent before asking it to edit files. Install Godot 4.x, Git, and a code editor with GDScript diagnostics.

The sandbox used to generate this package does not have Godot installed. The project has been scaffolded and statically reviewed but not executed here. Install and pin a stable Godot 4.x version locally before feature development.

## First commands

From the project root:

```powershell
godot --editor project.godot
godot --headless --path . --script res://tests/test_keep_state.gd
git status
git add .
git commit -m "Initialize Pack the Keep agent-first prototype"
```

Press **F5** to run the project or **F6** to run the current scene. The verification script reports the missing command if Godot is not on PATH.

## Agent access

Bind the local project folder to the coding agent. Feed the persistent context prompt in `docs/agent_feeding_guide.md`, then give one narrow commander, pack, piece, invasion, or interface task. Do not share Steamworks or Epic credentials in prompts or repository files.

## Platform integration staging

Keep the first milestone completely offline. After save versioning and deterministic defense simulation are stable, add a platform abstraction with no-op behavior. Add Steam achievements and Steam Cloud through a thin adapter, then add Epic Online Services through a separate adapter. Neither platform service should be imported by `src/core/keep_state.gd`.

## Build channels

| Channel | Purpose |
| --- | --- |
| Local debug | Fast grid and invasion iteration with verbose logs, deterministic seeds, and developer controls. |
| Demo/review | Clean vertical slice with safe saves, no debug shortcuts, readable onboarding, and resettable profile. |
| Release candidate | Windows storefront build with platform adapters, crash reporting, controller/scaling checks, and locked content. |

Tag release candidates from a clean committed tree. Record the Godot version, seed set used for regression, test result, and exact build artifact.

## Art pipeline

Start with a limited 2D top-down kit: keep floor, walls, rooms, pack icons, commander portraits, defender silhouettes, enemy markers, construction states, and breach effects. Use stable filenames and data references. Art should make pack identity, defense role, condition, and threat direction visible at normal zoom. Replace placeholders incrementally rather than discovering at the end that decoration has obscured the keep.

## Environment checklist

Before feature work, confirm that the folder is bound, Git is initialized, Godot opens `project.godot`, the main scene launches, the headless test command is known, and the agent has read `AGENTS.md`. If any item fails, fix the environment first.
