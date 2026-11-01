"""Generate the game's sound effects into a folder:

  move.wav    a short wooden "chop" for a valid move
  reject.wav  two descending tones for an invalid tap

Usage: python tool/make_sounds.py assets/sounds
"""
import math
import os
import random
import struct
import sys
import wave

RATE = 44100
out_dir = sys.argv[1]
random.seed(64)  # Same noise every run, so the files only change when the code does.


def normalize(samples, peak):
    top = max(abs(s) for s in samples)
    return [s / top * peak for s in samples]


def lowpass(samples, cutoff):
    # One-pole low-pass filter.
    a = 1 - math.exp(-2 * math.pi * cutoff / RATE)
    y = 0.0
    out = []
    for s in samples:
        y += a * (s - y)
        out.append(y)
    return out


def chop(dur=0.3):
    n = int(RATE * dur)
    noise = [random.uniform(-1, 1) for _ in range(n)]
    crack_noise = lowpass(noise, 2500)
    body_noise = lowpass(lowpass(noise, 600), 600)
    samples = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        # Deep thump whose pitch drops from 130 Hz to 45 Hz, like a heavy blow.
        # tanh adds harmonics so small phone speakers still "feel" the bass.
        phase += 2 * math.pi * (45 + 85 * math.exp(-t / 0.025)) / RATE
        thump = math.tanh(2.5 * math.sin(phase)) * math.exp(-t / 0.11)
        # The impact: a very short, dull click.
        crack = crack_noise[i] * math.exp(-t / 0.004) * 1.0
        # Splintering wood: dull noise, no clean ringing tones (those sound like metal).
        thud = body_noise[i] * math.exp(-t / 0.04) * 3.0
        # Short attack so the start doesn't click.
        env = min(1.0, i / (0.001 * RATE))
        samples.append((thump + crack + thud) * env)
    return normalize(samples, 0.95)


def tone(freq, dur):
    n = int(RATE * dur)
    samples = []
    for i in range(n):
        t = i / RATE
        # Sum of odd harmonics -> mellow square wave.
        s = sum(math.sin(2 * math.pi * freq * k * t) / k for k in (1, 3, 5, 7))
        # Short attack, exponential-ish release to avoid clicks.
        env = min(1.0, i / (0.005 * RATE)) * min(1.0, (n - i) / (0.03 * RATE))
        samples.append(s * env)
    return samples


def reject():
    # Two descending tones: "uh-oh".
    samples = tone(220, 0.09) + [0.0] * int(RATE * 0.025) + tone(165, 0.13)
    return normalize(samples, 0.8)


def write(name, samples):
    with wave.open(os.path.join(out_dir, name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in samples))


write("move.wav", chop())
write("reject.wav", reject())
