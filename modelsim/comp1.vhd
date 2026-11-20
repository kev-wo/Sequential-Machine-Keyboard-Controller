-- 1-bit comparator cell, structural:  eq = a xnor b   gt = a.b'
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity comp1 is
  port (a, b : in std_logic; eq, gt : out std_logic);
end comp1;

architecture struct of comp1 is
  signal nb : std_logic;
begin
  g_eq  : xnor2 port map (a => a, b => b, y => eq);
  g_inv : inv   port map (a => b, y => nb);
  g_gt  : and2  port map (a => a, b => nb, y => gt);
end struct;
