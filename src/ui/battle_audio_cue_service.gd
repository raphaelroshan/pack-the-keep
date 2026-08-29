class_name BattleAudioCueService
extends Node

const MIX_RATE := 44100.0
const BASE_AMPLITUDE := 0.08

const CUE_PROFILES := {
	"warning": {"frequencies": [330.0, 440.0], "duration": 0.055, "gain": 0.9, "beat": "assault_start"},
	"contact": {"frequencies": [160.0], "duration": 0.085, "gain": 1.0, "beat": "contact"},
	"volley": {"frequencies": [610.0, 780.0], "duration": 0.04, "gain": 0.7, "beat": "defender_response"},
	"impact": {"frequencies": [135.0, 190.0], "duration": 0.065, "gain": 0.9, "beat": "hostile_impact"},
	"breach": {"frequencies": [280.0, 205.0, 145.0], "duration": 0.07, "gain": 0.95, "beat": "breach"},
	"confirm": {"frequencies": [480.0], "duration": 0.07, "gain": 0.75, "beat": "confirm"},
	"repair": {"frequencies": [390.0, 520.0], "duration": 0.06, "gain": 0.8, "beat": "recovery"},
	"ability": {"frequencies": [520.0, 660.0], "duration": 0.065, "gain": 0.9, "beat": "ability"},
	"error": {"frequencies": [140.0], "duration": 0.1, "gain": 1.0, "beat": "error"},
	"pause": {"frequencies": [300.0], "duration": 0.055, "gain": 0.65, "beat": "pause"},
	"resume": {"frequencies": [500.0], "duration": 0.055, "gain": 0.65, "beat": "resume"},
	"hold": {"frequencies": [520.0, 660.0, 780.0], "duration": 0.055, "gain": 0.85, "beat": "terminal_hold"},
	"partial_breach": {"frequencies": [360.0, 250.0], "duration": 0.075, "gain": 0.9, "beat": "terminal_partial_breach"},
	"collapse": {"frequencies": [220.0, 150.0], "duration": 0.09, "gain": 1.0, "beat": "terminal_collapse"}
}

const BATTLE_BEAT_CUES := {
	"assault_start": "warning",
	"contact": "contact",
	"defender_response": "volley",
	"hostile_impact": "impact",
	"breach": "breach",
	"recovery": "repair",
	"terminal_hold": "hold",
	"terminal_partial_breach": "partial_breach",
	"terminal_collapse": "collapse"
}

var audio_player: AudioStreamPlayer
var audio_stream: AudioStreamGenerator
var last_cue_id: String = "none"
var last_beat_id: String = "none"
var last_request: Dictionary = {}

func setup_output(enabled: bool) -> void:
	if not enabled or audio_player != null:
		return
	audio_player = AudioStreamPlayer.new()
	audio_stream = AudioStreamGenerator.new()
	audio_stream.mix_rate = MIX_RATE
	audio_stream.buffer_length = 0.35
	audio_player.stream = audio_stream
	add_child(audio_player)
	audio_player.play()

func profile(cue_id: String) -> Dictionary:
	return Dictionary(CUE_PROFILES.get(cue_id, {})).duplicate(true)

func cue_for_beat(beat_id: String) -> String:
	return String(BATTLE_BEAT_CUES.get(beat_id, ""))

func play_beat(beat_id: String, muted: bool, effects_gain: float, reduced_motion: bool = false) -> Dictionary:
	var cue_id: String = cue_for_beat(beat_id)
	if cue_id.is_empty():
		return {"played": false, "reason": "unknown_beat", "beat_id": beat_id, "cue_id": ""}
	last_beat_id = beat_id
	return play_cue(cue_id, muted, effects_gain, reduced_motion)

func play_cue(cue_id: String, muted: bool, effects_gain: float, reduced_motion: bool = false) -> Dictionary:
	var cue_profile: Dictionary = profile(cue_id)
	if cue_profile.is_empty():
		return {"played": false, "reason": "unknown_cue", "beat_id": "", "cue_id": cue_id}
	last_cue_id = cue_id
	last_beat_id = String(cue_profile.get("beat", cue_id))
	var gain: float = clampf(effects_gain, 0.0, 1.0)
	last_request = {"cue_id": cue_id, "beat_id": last_beat_id, "muted": muted, "effects_gain": gain, "reduced_motion": reduced_motion}
	if muted:
		last_request["played"] = false
		last_request["reason"] = "muted"
		return last_request.duplicate(true)
	if gain <= 0.0:
		last_request["played"] = false
		last_request["reason"] = "zero_volume"
		return last_request.duplicate(true)
	if audio_player == null or audio_stream == null:
		last_request["played"] = false
		last_request["reason"] = "no_audio_device"
		return last_request.duplicate(true)
	var frequencies: Array = cue_profile.get("frequencies", [])
	if reduced_motion and frequencies.size() > 1:
		frequencies = [frequencies[0]]
	for frequency in frequencies:
		_play_tone(float(frequency), float(cue_profile.duration), float(cue_profile.gain) * gain)
	last_request["played"] = true
	last_request["reason"] = "played"
	return last_request.duplicate(true)

func _play_tone(frequency: float, duration: float, output_gain: float) -> void:
	if audio_player == null or audio_stream == null:
		return
	var playback: AudioStreamGeneratorPlayback = audio_player.get_stream_playback()
	if playback == null:
		return
	var frame_count: int = int(audio_stream.mix_rate * duration)
	for frame in range(frame_count):
		var envelope: float = 1.0 - float(frame) / float(frame_count)
		var sample: float = sin(TAU * frequency * float(frame) / audio_stream.mix_rate) * BASE_AMPLITUDE * output_gain * envelope
		playback.push_frame(Vector2(sample, sample))

func semantic_snapshot() -> Dictionary:
	return {
		"battle_beats": BATTLE_BEAT_CUES.duplicate(true),
		"last_cue_id": last_cue_id,
		"last_beat_id": last_beat_id,
		"last_request": last_request.duplicate(true),
		"output_ready": audio_player != null and audio_stream != null
	}
