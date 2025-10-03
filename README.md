# LNRA-8. LIRA-8/LYRA-8 for norns

LNRA-8 is a little norns interface to Mike Moreno's [LIRA-8](https://github.com/MikeMorenoDSP/LIRA-8), which itself is a Pd emulation of SOMA Lab's famous organismic synthesizer [LYRA-8](https://somasynths.com/lyra-organismic-synthesizer/).

![](lnra-8.gif)

This runs Mike Moreno's Pd patch as the sound engine, so Pd needs to be installed.

## Usage

Encoders <kbd>E2</kbd> and <kbd>E3</kbd> control the hold volume of the two sides (1-4 and 5-8), and with <kbd>K1</kbd> their pitch

The first eight keys from middle-C upward are mapped to the eight sensor plates on a MIDI keyboard and channel selected in the params.

Beyond that, use MIDI mapping to use your MIDI controllers. The LYRA-8 is a complex organism and interfacing with it on the small norns is hard. All the things in the LIRA-8 emulator are set up as norns parameters. The norns on-screen UI shows the oscillator, but not all modulation options, the hyperlfo or the mixer block.

Sounds are randomized at startup, and effects turned down. There will be crunchy audio when timing fails.

## Installation

1. Install with `;install https://github.com/xmacex/lnra-8` in maiden
2. Install pure data with `apt install puredata`

That should be it. Later I hope to use Mike Moreno's LIRA-8 as a git submodule rather than including it directly.
