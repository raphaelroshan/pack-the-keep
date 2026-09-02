from __future__ import annotations

import hashlib
import importlib.util
import json
import math
import struct
import unittest
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("generate_authored_foley", ROOT / "tools" / "generate_authored_foley.py")
assert SPEC and SPEC.loader
generator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(generator)


class AuthoredFoleyTests(unittest.TestCase):
    def test_palette_is_complete_reproducible_and_distinct(self) -> None:
        self.assertEqual(len(generator.CUES), 14)
        digests: set[str] = set()
        for name in generator.CUES:
            path = generator.OUTPUT_DIRECTORY / name
            actual = path.read_bytes()
            self.assertEqual(actual, generator.wav_bytes(name), name)
            digests.add(hashlib.sha256(actual).hexdigest())
        self.assertEqual(len(digests), len(generator.CUES))

    def test_wav_contract_is_bounded_and_audible(self) -> None:
        for name in generator.CUES:
            path = generator.OUTPUT_DIRECTORY / name
            with wave.open(str(path), "rb") as wav:
                self.assertEqual(wav.getnchannels(), 1, name)
                self.assertEqual(wav.getsampwidth(), 2, name)
                self.assertEqual(wav.getframerate(), 44_100, name)
                duration = wav.getnframes() / wav.getframerate()
                self.assertGreaterEqual(duration, 0.1, name)
                self.assertLessEqual(duration, 0.7, name)
                frames = wav.readframes(wav.getnframes())
                samples = struct.unpack(f"<{len(frames) // 2}h", frames)
                peak = max(abs(sample) for sample in samples) / 32767.0
                rms = math.sqrt(sum(sample * sample for sample in samples) / len(samples)) / 32767.0
                self.assertLessEqual(peak, 0.83, name)
                self.assertGreater(rms, 0.01, name)

    def test_runtime_profiles_reference_only_authored_audio(self) -> None:
        service = (ROOT / "src" / "ui" / "battle_audio_cue_service.gd").read_text(encoding="utf-8")
        self.assertNotIn("assets/temporary/", service)
        for name in generator.CUES:
            self.assertIn(f"res://assets/audio/semantic/{name}", service)
        manifest = json.loads((ROOT / "content" / "content_manifest.json").read_text(encoding="utf-8"))
        contract = manifest["p66_authored_semantic_foley"]
        self.assertEqual(contract["status"], "implemented")
        self.assertEqual(contract["cue_count"], len(generator.CUES))
        self.assertEqual(contract["temporary_runtime_dependencies"], [])


if __name__ == "__main__":
    unittest.main()
