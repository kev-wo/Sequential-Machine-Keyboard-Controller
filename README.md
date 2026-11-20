# CEG3155 Lab 4: PS/2 Keyboard Controller

Structural VHDL controller for the Nexys A7-100T. It reads 11-bit PS/2 frames from a USB keyboard (plugged into J5) and shows the last byte received in hex on BCD1 (high digit) and BCD2 (low digit), on the two rightmost 7-segment digits and on LEDs LD15–12 and LD7–4. Pressing A shows `1C`.
## Design
- 4-state Moore FSM (Gray code A=00, B=01, C=11, D=10) reduced from 5 states
- Keyboard clock: 2-flip-flop synchronizer, 8-sample digital filter, asynchronous SR latch (two NOR gates, `bascule_sr.vhd`)
- Shift register (LSB first), odd-parity check, bit-bucket flip-flop, output register loaded on a valid stop bit
- Single 100 MHz clock with enable pulses; global active-low reset


