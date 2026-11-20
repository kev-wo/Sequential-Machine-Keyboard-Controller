-- FSM controller of the keyboard interface (structural, Moore).
-- Four states, Gray assignment y1y0:  A = 00 (idle, waiting for the start bit),
-- B = 01 (reading the 8 data bits), C = 11 (parity bit), D = 10 (stop bit).
-- The state flip-flops are enabled by en = fe, so the state changes once per keyboard clock pulse.
--   next state:  Y1 = y1.y0 + y0.c        Y0 = y1'.y0 + y1'.x'
--   outputs:     sh = y1'.y0   (state B: shift the data bit in and count it)
--                clr = sh'     (counter held at 0 outside state B)
--                pk = y1.y0    (state C: save the parity check in the bit bucket)
--                ld = y1.y0'   (state D: load the scan code if the frame is valid)
--   x = data bit, c = bit counter equals 7 (the bit being read is the last data bit).
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity fsmControleur is
  port (
    clk, resetb : in  std_logic;
    en          : in  std_logic;     -- falling-edge pulse of the filtered keyboard clock
    x, c        : in  std_logic;
    sh, clr, pk, ld : out std_logic
  );
end fsmControleur;

architecture struct of fsmControleur is
  signal y1, y0, ny1, ny0, nx          : std_logic;
  signal t11, t12, t01, t02            : std_logic;     -- product terms
  signal d1, d0, shi                   : std_logic;
begin
  u_ny1 : inv port map (a => y1, y => ny1);
  u_ny0 : inv port map (a => y0, y => ny0);
  u_nx  : inv port map (a => x,  y => nx);

  -- next-state logic
  u_t11 : and2 port map (a => y1,  b => y0, y => t11);       -- y1.y0
  u_t12 : and2 port map (a => y0,  b => c,  y => t12);       -- y0.c
  u_d1  : or2  port map (a => t11, b => t12, y => d1);
  u_t01 : and2 port map (a => ny1, b => y0, y => t01);       -- y1'.y0
  u_t02 : and2 port map (a => ny1, b => nx, y => t02);       -- y1'.x'
  u_d0  : or2  port map (a => t01, b => t02, y => d0);

  -- state flip-flops (asynchronous reset to state A = 00)
  u_ff1 : dff port map (clk => clk, resetb => resetb, en => en, d => d1, q => y1);
  u_ff0 : dff port map (clk => clk, resetb => resetb, en => en, d => d0, q => y0);

  -- Moore output decode
  u_sh  : and2 port map (a => ny1, b => y0,  y => shi);
  u_clr : inv  port map (a => shi, y => clr);
  u_pk  : and2 port map (a => y1,  b => y0,  y => pk);
  u_ld  : and2 port map (a => y1,  b => ny0, y => ld);
  sh <= shi;
end struct;
