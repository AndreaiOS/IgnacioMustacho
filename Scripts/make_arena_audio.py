"""Original procedural arena bed, organ countdown, shoe squeak and closing cadence.
No recordings, external dependencies or copyrighted melody. Deterministic output.
"""
import math
import random
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parents[1] / 'Sources' / 'Audio'
OUT.mkdir(exist_ok=True)

def save(name, samples):
    import array
    data = array.array('h', (int(max(-1, min(1, v)) * 32760) for v in samples))
    with wave.open(str(OUT / (name + '.wav')), 'wb') as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes(data.tobytes())

def organ(t, frequency, duration):
    if t < 0 or t >= duration:
        return 0
    envelope = min(1, t / 0.012) * min(1, (duration - t) / 0.09) * math.exp(-t * 2)
    return envelope * sum(math.sin(2 * math.pi * frequency * harmonic * t) * gain
                          for harmonic, gain in [(1, .45), (2, .16), (3, .09), (4, .04)])

rng = random.Random(1984)
for index, frequency in enumerate([261.63, 329.63, 392.0, 523.25]):
    samples = []
    for n in range(int(RATE * .32)):
        t = n / RATE
        clap = rng.uniform(-1, 1) * math.exp(-t * 55) * (.14 if index == 3 else .045)
        samples.append(organ(t, frequency, .32) * .65 + clap)
    save('countdown' + str(index), samples)
# Periodic, band-limited crowd-like room wash. Loop endpoints match exactly.
frequencies = [(rng.randint(180, 3400) / 6, rng.random() * math.tau) for _ in range(64)]
save('arena', (sum(math.sin(math.tau * f * n / RATE + p) for f, p in frequencies) / 90
               * (.7 + .15 * math.sin(math.tau * n / RATE / 6)) for n in range(RATE * 6)))
save('squeak', (math.sin(math.tau * (1200 * (n / RATE) + 1300 * (n / RATE) ** 2))
                * math.sin(math.pi * n / (RATE * .12)) ** 2 * .12 for n in range(int(RATE * .12))))
notes = [(0, 523.25), (.22, 392), (.44, 329.63), (.7, 261.63), (.7, 329.63), (.7, 392)]
save('finish', (sum(organ(n / RATE - start, frequency, .85 if start == .7 else .24)
                    * (.25 if start == .7 else .45) for start, frequency in notes)
                for n in range(int(RATE * 1.65))))

# Historical instrumental review of the original 100–167 BPM curve. Not used by the app.
import array

def read(name):
    with wave.open(str(OUT / (name + '.wav')), 'rb') as wav:
        return [v / 32768 for v in array.array('h', wav.readframes(wav.getnframes()))]

notes_audio = [read('countdown' + str(i)) for i in range(4)]
ending = read('finish')
room = read('arena')
events = []
target = 0.0
for command in range(17):
    beat = max(.36, .6 - (command // 4) * .06)
    target += beat * 4
    for i in range(4):
        events.append((target - (3 - i) * beat, notes_audio[i]))
end_time = target + .5
events.append((end_time, ending))
mix = [room[n % len(room)] * .18 if n / RATE < end_time else 0
       for n in range(int(RATE * (end_time + 1.8)))]
for when, sound in events:
    first = int(when * RATE)
    for offset, sample in enumerate(sound):
        if first + offset < len(mix):
            mix[first + offset] += sample * .65
preview = OUT.parents[1] / 'Documentation' / 'Arena-Audio-Preview.wav'
with wave.open(str(preview), 'wb') as wav:
    wav.setnchannels(1)
    wav.setsampwidth(2)
    wav.setframerate(RATE)
    wav.writeframes(array.array('h', (int(max(-1, min(1, sample)) * 32760) for sample in mix)).tobytes())
print(f'Preview: {len(mix) / RATE:.2f}s; peak {max(abs(v) for v in mix):.3f}')

# Six short original award stings; no sampled athlete voice or borrowed tune.
award_notes = {
    10: [329.63, 392, 523.25],
    23: [392, 369.99, 523.25],
    33: [261.63, 196, 329.63],
    50: [392, 523.25, 659.25],
    81: [523.25, 659.25, 783.99],
    100: [523.25, 659.25, 783.99, 1046.5],
}
for threshold, frequencies in award_notes.items():
    save('award' + str(threshold), (sum(organ(n / RATE - index * .13, frequency, .25) * .5
         for index, frequency in enumerate(frequencies)) for n in range(int(RATE * .8))))
