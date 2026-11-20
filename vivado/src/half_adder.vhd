-- 1-bit half adder, structural: s = a xor b, co = a and b
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity half_adder is
  port (a, b : in std_logic; s, co : out std_logic);
end half_adder;

architecture struct of half_adder is
begin
  g_s  : xor2 port map (a => a, b => b, y => s);
  g_co : and2 port map (a => a, b => b, y => co);
end struct;
