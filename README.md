# DATO-808

An 808-style drum kit in the browser for the **Dato DRUM** sequencer.

Plug the Dato DRUM in over USB, and every step it plays is sent as MIDI to this page, which plays
synthesized 808-style sounds instead of the Dato's onboard kit. No samples: every sound is built
live with the Web Audio API.

## Sounds

Bass drum, snare drum, low tom, hi tom, hand clap, cowbell, closed hi-hat and open hi-hat.
The closed hat chokes a ringing open hat. Each sound has Level, Tune and Decay knobs.

## Run it

Web MIDI needs Chrome (or another Chromium browser) and a secure origin such as `localhost`:

```bash
python3 -m http.server 8808
```

Then open <http://localhost:8808/808-kit.html>.

1. Turn the Dato's own volume all the way down.
2. Press **Start** and allow MIDI access.
3. Hit play on the Dato.

## Features

- **Auto-assign:** MIDI notes the kit hasn't seen yet go to the next free sound. Defaults follow the
  General MIDI drum map (36 kick, 38 snare, 42 closed hat, and so on).
- **Learn:** click Learn on a sound, then hit a pad on the Dato to tie them together.
- **Step lights and tempo:** the 16 step LEDs and the tempo readout follow the Dato's MIDI clock.
- **Accent:** note velocity sets the hit's loudness (can be switched off).
- Click the coloured keys or press `1`–`8` to play sounds without the Dato.
- Knobs: drag up and down, scroll, or use the arrow keys; double-click resets. Settings are saved in the browser.

Not affiliated with Dato or Roland.
