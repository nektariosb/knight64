"""Generate assets/sounds/reject.wav: two descending soft square-ish tones.

Usage: python tool/make_reject_sound.py assets/sounds/reject.wav
"""
import math
import struct
import sys
import wave

RATE = 44100
out = sys.argv[1]

def tone(freq, dur, vol=0.35):
    n = int(RATE * dur)
    samples = []
    for i in range(n):
        t = i / RATE
        # Sum of odd harmonics -> mellow square wave.
        s = sum(math.sin(2 * math.pi * freq * k * t) / k for k in (1, 3, 5, 7))
        # Short attack, exponential-ish release to avoid clicks.
        env = min(1.0, i / (0.005 * RATE)) * min(1.0, (n - i) / (0.03 * RATE))
        samples.append(s * env * vol)
    return samples

data = tone(220, 0.09) + [0.0] * int(RATE * 0.025) + tone(165, 0.13)
with wave.open(out, "wb") as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(RATE)
    w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in data))
