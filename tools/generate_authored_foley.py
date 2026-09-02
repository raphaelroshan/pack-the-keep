#!/usr/bin/env python3
"""Generate Pack the Keep's original semantic one-shot audio palette."""
from __future__ import annotations

import argparse
import hashlib
import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIRECTORY = ROOT / "assets" / "audio" / "semantic"
SAMPLE_RATE = 44_100
PEAK = 0.82

# Layers are (start, length, frequency, sweep_hz_per_second, gain, waveform).
CUES: dict[str, tuple[float, list[tuple[float, float, float, float, float, str]]]] = {
    "warning_bell.wav": (0.42, [(0.00, 0.42, 330, -18, 0.75, "sine"), (0.00, 0.36, 660, -30, 0.28, "sine"), (0.12, 0.28, 440, -20, 0.48, "sine")]),
    "contact_boot.wav": (0.16, [(0.00, 0.16, 92, -120, 0.85, "triangle"), (0.00, 0.09, 0, 0, 0.48, "noise_low")]),
    "defender_volley.wav": (0.18, [(0.00, 0.10, 920, -2600, 0.62, "triangle"), (0.025, 0.15, 1450, -4300, 0.42, "noise_high")]),
    "hostile_impact.wav": (0.22, [(0.00, 0.18, 118, -180, 0.82, "triangle"), (0.00, 0.12, 0, 0, 0.64, "noise_low"), (0.06, 0.15, 178, -240, 0.35, "sine")]),
    "breach_stone.wav": (0.48, [(0.00, 0.34, 78, -70, 0.78, "triangle"), (0.00, 0.45, 0, 0, 0.72, "noise_low"), (0.16, 0.28, 52, -28, 0.55, "sine")]),
    "confirm_latch.wav": (0.14, [(0.00, 0.08, 620, -380, 0.58, "triangle"), (0.045, 0.09, 880, -140, 0.44, "sine")]),
    "repair_hammer.wav": (0.24, [(0.00, 0.11, 210, -120, 0.72, "triangle"), (0.00, 0.08, 0, 0, 0.42, "noise_high"), (0.10, 0.13, 390, -90, 0.46, "sine")]),
    "ability_standard.wav": (0.32, [(0.00, 0.22, 410, 80, 0.48, "sine"), (0.07, 0.24, 540, 110, 0.54, "sine"), (0.14, 0.17, 690, 70, 0.38, "triangle")]),
    "error_dull_knock.wav": (0.18, [(0.00, 0.16, 135, -80, 0.82, "triangle"), (0.00, 0.07, 0, 0, 0.35, "noise_low")]),
    "pause_lock.wav": (0.12, [(0.00, 0.08, 270, -90, 0.64, "triangle"), (0.035, 0.08, 190, -60, 0.50, "triangle")]),
    "resume_release.wav": (0.14, [(0.00, 0.09, 330, 140, 0.50, "triangle"), (0.045, 0.09, 510, 160, 0.58, "sine")]),
    "hold_bell.wav": (0.55, [(0.00, 0.50, 392, -8, 0.52, "sine"), (0.00, 0.46, 588, -12, 0.34, "sine"), (0.13, 0.40, 784, -18, 0.32, "sine")]),
    "partial_breach.wav": (0.42, [(0.00, 0.28, 310, -240, 0.58, "triangle"), (0.10, 0.30, 220, -170, 0.58, "sine"), (0.00, 0.18, 0, 0, 0.26, "noise_low")]),
    "collapse.wav": (0.70, [(0.00, 0.54, 165, -145, 0.62, "triangle"), (0.08, 0.58, 112, -76, 0.65, "sine"), (0.00, 0.64, 0, 0, 0.58, "noise_low")]),
}


def _envelope(local_time: float, length: float) -> float:
    attack = min(1.0, local_time / min(0.006, length * 0.15))
    release = max(0.0, 1.0 - local_time / length)
    return attack * release * release


def _waveform(kind: str, phase: float, noise: float, low_noise: float) -> float:
    if kind == "sine":
        return math.sin(phase)
    if kind == "triangle":
        return 2.0 / math.pi * math.asin(math.sin(phase))
    if kind == "noise_low":
        return low_noise
    if kind == "noise_high":
        return noise - low_noise
    raise ValueError(f"unknown waveform: {kind}")


def render(name: str, duration: float, layers: list[tuple[float, float, float, float, float, str]]) -> bytes:
    frame_count = round(duration * SAMPLE_RATE)
    samples = [0.0] * frame_count
    for layer_index, (start, length, frequency, sweep, gain, kind) in enumerate(layers):
        seed_material = f"pack-the-keep:{name}:{layer_index}".encode("utf-8")
        seed = int.from_bytes(hashlib.sha256(seed_material).digest()[:8], "big")
        rng = random.Random(seed)
        low_noise = 0.0
        start_frame = round(start * SAMPLE_RATE)
        end_frame = min(frame_count, round((start + length) * SAMPLE_RATE))
        for frame in range(start_frame, end_frame):
            local_time = (frame - start_frame) / SAMPLE_RATE
            noise = rng.uniform(-1.0, 1.0)
            low_noise = low_noise * 0.82 + noise * 0.18
            phase = math.tau * (frequency * local_time + 0.5 * sweep * local_time * local_time)
            samples[frame] += _waveform(kind, phase, noise, low_noise) * gain * _envelope(local_time, length)
    peak = max(abs(sample) for sample in samples)
    scale = PEAK / peak if peak > PEAK else 1.0
    return b"".join(struct.pack("<h", round(max(-1.0, min(1.0, sample * scale)) * 32767)) for sample in samples)


def wav_bytes(name: str) -> bytes:
    from io import BytesIO

    duration, layers = CUES[name]
    output = BytesIO()
    with wave.open(output, "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(render(name, duration, layers))
    return output.getvalue()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="verify checked-in files match deterministic output")
    args = parser.parse_args()
    errors: list[str] = []
    if not args.check:
        OUTPUT_DIRECTORY.mkdir(parents=True, exist_ok=True)
    for name in sorted(CUES):
        expected = wav_bytes(name)
        path = OUTPUT_DIRECTORY / name
        if args.check:
            if not path.exists() or path.read_bytes() != expected:
                errors.append(f"authored foley is missing or stale: {path.relative_to(ROOT)}")
        else:
            path.write_bytes(expected)
            print(f"wrote {path.relative_to(ROOT)}")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    if args.check:
        print(f"authored semantic foley: PASS ({len(CUES)} deterministic WAV files)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
