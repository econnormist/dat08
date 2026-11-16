# DAT08

An 808-style sound expander in the browser for the **Dato DRUM** sequencer.

Plug the Dato DRUM in over USB and every step it plays is sent as MIDI to this page, which plays
synthesized 808-style sounds instead of the Dato's onboard kit. No samples: every sound is built
live with the Web Audio API. The page keeps the Dato's own octagon layout, built from 808 parts:
the four pads are red/orange/yellow/cream 808 keys with variant LEDs, the effects are round 808
buttons, the sliders are 808 faders, and the center is a tempo dial with 16 step LEDs that chase
the Dato's clock.

## Play it

**Live:** <https://econnormist.github.io/dato-808/>. Open it in Chrome (or another Chromium browser,
since Safari has no Web MIDI) and plug in the Dato DRUM.

1. Turn the Dato's own volume all the way down.
2. Press **Start** and allow MIDI access.
3. Play. Pick variants with the ◀ ▶ arrows on the Dato as usual.

No Dato at hand? Click the pads (or press `1`–`4`), use the on-screen arrows, and hold Crush or Filter.

## Sounds: 4 pads × 8 variants

| Pad | Notes | Variants |
|---|---|---|
| Top | 38–45 | Snare, Snare Tight, Snare Fat, Rim Shot, Clap, Clap Big, Snare Clap, Snap |
| Right | 46–53 | Closed Hat, Tick Hat, Open Hat, Open Long, Maracas, Cymbal, Ride, Low Hat |
| Bottom | 54–61 | Low Tom, Mid Tom, Hi Tom, Low Conga, Hi Conga, Cowbell, Claves, 808 Bass |
| Left | 30–37 | Kick Tight, Kick Punch, Kick 808, Kick Boom, Kick Sub, Kick Drive, Kick High, Kick Dive |

Closed hats and maracas choke a ringing open hat.

## Dato DRUM MIDI map

Measured from the device over USB. Everything is on MIDI channel 10.

| Control | MIDI | Handled by |
|---|---|---|
| Pads + variants | notes 30–61 (see above); tap = velocity 127, sequencer = 100 | this page |
| Sliders (left, top, right, bottom) | CC 21, 22, 23, 24 | this page: ±7 semitones pitch for that pad |
| Crush (green) | CC 12, pressure-like 0–127 | this page: bit-crusher + sample-rate reduction |
| Filter (blue) | CC 74 (CC 75 is its inverse) | this page: resonant low-pass sweep |
| Repeat (red) | CC 17 | the Dato: it re-sends the notes |
| Random (yellow) | CC 16 | the Dato: it sends extra notes |
| Swing switch | CC 9 (1 / 64 / 127) | the Dato: it shifts note timing; shown here |
| Tempo knob | CC 15; MIDI clock follows | shown here, from the clock |
| Volume knob | CC 7 | shown here; optionally follows |

The Dato sends MIDI clock continuously, even when stopped, and never sends start/stop.

`tools/midimon.swift` is the macOS MIDI monitor used to work this out:

```bash
swift tools/midimon.swift dato
```

## Run it locally

Web MIDI needs a secure origin such as `localhost`:

```bash
python3 -m http.server 8808
```

Then open <http://localhost:8808/>.

Not affiliated with Dato or Roland.
