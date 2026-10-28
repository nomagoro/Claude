"""Synthesize a bright, light BGM (original, royalty-free) and a 'pop' sound effect."""
import wave
import numpy as np

BPM = 112
# I - vi - IV - V in C major (MIDI note numbers)
CHORDS = [[60, 64, 67], [57, 60, 64], [53, 57, 60], [55, 59, 62]]
BASS = [36, 33, 29, 31]
ARP = [0, 1, 2, 1, 2, 1, 0, 2]  # chord-tone index per 8th note
MELODY = [  # (8th-note step, chord-tone index, octave up) per bar
    [(0, 2, 1), (2, 1, 1), (3, 2, 1), (4, 0, 2), (6, 2, 1)],
    [(0, 1, 1), (2, 2, 1), (4, 1, 1), (5, 0, 1)],
    [(0, 2, 1), (1, 1, 1), (2, 2, 1), (4, 0, 2), (6, 2, 1)],
    [(0, 1, 1), (2, 2, 1), (3, 1, 1), (4, 0, 1), (6, 2, 0)],
]


def hz(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def tone(f, dur, sr, partials=((1, 1.0),), decay=6.0, attack=0.004):
    t = np.arange(int(dur * sr)) / sr
    y = sum(a * np.sin(2 * np.pi * f * k * t) for k, a in partials)
    env = np.exp(-decay * t) * np.clip(t / attack, 0, 1)
    return y * env


def add(buf, sig, start, sr, gain, pan=0.0):
    i = int(start * sr)
    if i >= len(buf):
        return
    sig = sig[: len(buf) - i] * gain
    buf[i:i + len(sig), 0] += sig * (1 - pan) ** 0.5
    buf[i:i + len(sig), 1] += sig * (1 + pan) ** 0.5


def make_bgm(dur, sr=48000):
    rng = np.random.RandomState(7)
    buf = np.zeros((int(dur * sr) + sr, 2))
    beat = 60.0 / BPM
    bar = beat * 4
    nbars = int(np.ceil(dur / bar))
    for b in range(nbars):
        ch, bs, t0 = CHORDS[b % 4], BASS[b % 4], b * bar
        intro = b < 2
        # pad
        for m in ch:
            p = tone(hz(m), bar, sr, ((1, 1), (2, 0.25)), decay=0.6, attack=0.25)
            add(buf, p, t0, sr, 0.035)
        # marimba-ish arpeggio
        for s, idx in enumerate(ARP):
            m = ch[idx] + 12
            add(buf, tone(hz(m), 0.5, sr, ((1, 1), (4, 0.25)), decay=9), t0 + s * beat / 2, sr, 0.09,
                pan=-0.3 if s % 2 else 0.3)
        # bell melody
        if not intro:
            for step, idx, octv in MELODY[b % 4]:
                m = ch[idx] + 12 * (octv + 1)
                add(buf, tone(hz(m), 0.9, sr, ((1, 1), (2, 0.3), (3, 0.12)), decay=4.5), t0 + step * beat / 2, sr, 0.075)
        # bass
        for k in (0, 2, 2.5):
            add(buf, tone(hz(bs), beat * 0.9, sr, ((1, 1), (2, 0.3)), decay=3.5, attack=0.01), t0 + k * beat, sr, 0.22)
        if intro and b == 0:
            continue
        # drums: soft kick 1 & 3, clap 2 & 4, shaker on 8ths
        for k in range(4):
            tt = np.arange(int(0.18 * sr)) / sr
            if k % 2 == 0:
                kick = np.sin(2 * np.pi * (55 * tt + 60 * (1 - np.exp(-tt * 30)) / 30)) * np.exp(-tt * 22)
                add(buf, kick, t0 + k * beat, sr, 0.35)
            else:
                n = rng.randn(len(tt))
                clap = np.diff(n, prepend=0) * np.exp(-tt * 28)
                add(buf, clap, t0 + k * beat, sr, 0.06)
        for s in range(8):
            tt = np.arange(int(0.06 * sr)) / sr
            hh = np.diff(rng.randn(len(tt)), prepend=0) * np.exp(-tt * 70)
            add(buf, hh, t0 + s * beat / 2, sr, 0.03 if s % 2 else 0.015, pan=0.4)
    buf = buf[: int(dur * sr)]
    # gentle fade in/out
    n = len(buf)
    env = np.ones(n)
    fi, fo = int(0.05 * sr), int(1.8 * sr)
    env[:fi] = np.linspace(0, 1, fi)
    env[-fo:] = np.linspace(1, 0, fo) ** 1.5
    buf *= env[:, None]
    return buf / np.abs(buf).max() * 0.6


def make_pop(sr=48000):
    t = np.arange(int(0.12 * sr)) / sr
    f = 500 + 900 * np.exp(-t * 40)
    y = np.sin(2 * np.pi * np.cumsum(f) / sr) * np.exp(-t * 35)
    y = np.stack([y, y], 1)
    return y * 0.8


def write_wav(path, data, sr=48000):
    d = np.clip(data, -1, 1)
    pcm = (d * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm.tobytes())
