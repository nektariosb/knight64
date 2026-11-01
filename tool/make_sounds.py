"""Generate the game's sound effects into a folder:

  move.wav      a short wooden "chop" for a valid move
  reject.wav    two descending tones for an invalid tap
  complete.wav  a rising "ta-da" when the board is full
  closed.wav    a bigger fanfare for a closed tour

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


def bell(freq, dur):
    # Bright, bell-like note: a few harmonics that fade out, highest first.
    n = int(RATE * dur)
    samples = []
    for i in range(n):
        t = i / RATE
        s = (math.sin(2 * math.pi * freq * t) * math.exp(-t / (dur * 0.45))
             + 0.35 * math.sin(2 * math.pi * freq * 2 * t) * math.exp(-t / (dur * 0.2))
             + 0.12 * math.sin(2 * math.pi * freq * 3 * t) * math.exp(-t / (dur * 0.1)))
        env = min(1.0, i / (0.004 * RATE)) * min(1.0, (n - i) / (0.02 * RATE))
        samples.append(s * env)
    return samples


def mix(parts, dur):
    # parts: (start time, samples) pairs, added together.
    out = [0.0] * int(RATE * dur)
    for start, samples in parts:
        offset = int(RATE * start)
        for i, s in enumerate(samples[:len(out) - offset]):
            out[offset + i] += s
    return out


C5, E5, G5, C6, E6, G6, C7 = 523.25, 659.25, 783.99, 1046.5, 1318.5, 1568.0, 2093.0


def complete():
    # Rising major arpeggio, last note held: "ta-da!"
    parts = [(0.0, bell(C5, 0.3)), (0.1, bell(E5, 0.3)), (0.2, bell(G5, 0.3)), (0.3, bell(C6, 0.9))]
    return normalize(mix(parts, 1.25), 0.8)


def closed():
    # Bigger: a faster, higher arpeggio, a full held chord, then sparkles on top.
    notes = [C5, E5, G5, C6, E6, G6]
    parts = [(i * 0.08, bell(f, 0.3)) for i, f in enumerate(notes)]
    parts += [(0.5, bell(f, 1.6)) for f in (C5, E5, G5, C6)]
    parts += [(0.7 + i * 0.13, [s * 0.4 for s in bell(random.choice((G6, C7, E6)), 0.35)]) for i in range(7)]
    return normalize(mix(parts, 2.2), 0.85)


def write(name, samples):
    with wave.open(os.path.join(out_dir, name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in samples))


write("move.wav", chop())
write("reject.wav", reject())
write("complete.wav", complete())
write("closed.wav", closed())
