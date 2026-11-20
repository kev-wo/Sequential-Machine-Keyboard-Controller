-- 1-bit 2-to-1 multiplexer, structural: y = a.s' + b.s   (y = a when s = '0', b when s = '1')
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity mux2_1 is
  port (a, b, s : in std_logic; y : out std_logic);
end mux2_1;

architecture struct of mux2_1 is
  signal ns, pa, pb : std_logic;
begin
  g_inv : inv  port map (a => s,  y => ns);
  g_pa  : and2 port map (a => a,  b => ns, y => pa);
  g_pb  : and2 port map (a => b,  b => s,  y => pb);
  g_or  : or2  port map (a => pa, b => pb, y => y);
end struct;
