#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 tools/validate_runtime_content.py --keeps data/keeps --regions data/regions --pieces data/pieces --packs data/packs --commanders data/commanders --enemies data/enemies --doctrines data/doctrines --scenarios data/scenarios --events data/events --modifiers data/modifiers --manifest content/content_manifest.json --event-schema content/event_schema.json
python3 tests/test_runtime_content_validator.py
python3 tools/validate_offline_boundary.py
python3 tests/test_packaged_smoke_runner.py
python3 tests/test_release_identity.py
python3 tools/validate_p12_alpha.py
python3 tests/test_p12_alpha_validator.py
python3 tools/validate_p16_playtests.py --protocol content/p16_playtest_protocol.json --sessions playtests/sessions --ci-manifest tools/ci_manifest.json --alpha-checklist content/p12_alpha_checklist.json
python3 tests/test_p16_playtest_protocol.py
python3 tools/summarize_p16_playtests.py --protocol content/p16_playtest_protocol.json --sessions playtests/sessions --ci-manifest tools/ci_manifest.json --alpha-checklist content/p12_alpha_checklist.json
python3 tests/test_p16_playtest_summary.py
python3 tests/test_p16_playtest_build_manifest.py
python3 tests/test_p16_playtest_brief.py
python3 tests/test_p16_playtest_matrix_templates.py

if command -v godot >/dev/null 2>&1; then
  godot --headless --audio-driver Dummy --path . --import
  godot --headless --audio-driver Dummy --path . --script res://tests/test_keep_state.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p1_balance.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p2_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p3_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_v082_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_placement_boxes.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_quick_playtest.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_menu_flow_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_multi_wave.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_multi_wave_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p5_recovery_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_pack_catalog.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p7_mobile_response.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p7_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p8_events.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p8_event_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p9_progression.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p9_progression_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p10_accessibility_preferences.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p10_controller_scaling.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p10_display_audio_settings.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p10_feed_autopause.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p10_game_feel_cues.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p11_crossbow_watch.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p11_crossbow_watch_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p11_bell_guard.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p11_bell_guard_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p11_shieldwall.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p11_shieldwall_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p11_three_bells_challenge.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p11_three_bells_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p11_challenge_modifier.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p11_challenge_modifier_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p12_save_path_isolation.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p12_save_recovery.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p12_packaged_profile.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p12_settings_recovery.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p12_alpha_scenario_matrix.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p13_workshop_event.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p13_workshop_event_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p13_event_history_ledger.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p13_event_history_ledger_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p13_wrong_wall_chain.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p13_wrong_wall_chain_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p13_mara_arc.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p13_mara_arc_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p13_old_drain_occurrence.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p13_old_drain_occurrence_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p14_authored_event_panel.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p14_event_authoring_safety.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p15_ash_ford_identity.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p15_ash_ford_identity_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p15_regional_consequence.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p15_regional_consequence_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p16_playtest_readiness_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p30_last_stand.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p31_tutorial_flow.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p31_tutorial_resilience.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_initial_combat.gd
elif command -v godot4 >/dev/null 2>&1; then
  godot4 --headless --audio-driver Dummy --path . --import
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_keep_state.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p1_balance.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p2_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p3_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_v082_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_placement_boxes.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_quick_playtest.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_menu_flow_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_multi_wave.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_multi_wave_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p5_recovery_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_pack_catalog.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p7_mobile_response.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p7_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p8_events.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p8_event_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p9_progression.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p9_progression_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p10_accessibility_preferences.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p10_controller_scaling.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p10_display_audio_settings.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p10_feed_autopause.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p10_game_feel_cues.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p11_crossbow_watch.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p11_crossbow_watch_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p11_bell_guard.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p11_bell_guard_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p11_shieldwall.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p11_shieldwall_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p11_three_bells_challenge.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p11_three_bells_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p11_challenge_modifier.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p11_challenge_modifier_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p12_save_path_isolation.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p12_save_recovery.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p12_packaged_profile.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p12_settings_recovery.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p12_alpha_scenario_matrix.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p13_workshop_event.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p13_workshop_event_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p13_event_history_ledger.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p13_event_history_ledger_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p13_wrong_wall_chain.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p13_wrong_wall_chain_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p13_mara_arc.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p13_mara_arc_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p13_old_drain_occurrence.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p13_old_drain_occurrence_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p14_authored_event_panel.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p14_event_authoring_safety.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p15_ash_ford_identity.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p15_ash_ford_identity_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p15_regional_consequence.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p15_regional_consequence_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p16_playtest_readiness_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p30_last_stand.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p31_tutorial_flow.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p31_tutorial_resilience.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_initial_combat.gd
else
  echo "Godot 4.x is not installed or not on PATH."
  echo "Run: godot --headless --audio-driver Dummy --path . --script res://tests/test_keep_state.gd"
  exit 2
fi
