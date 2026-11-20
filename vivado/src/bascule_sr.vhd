-- Asynchronous SR latch (structural): two cross-coupled NOR gates, no clock.
--   q  = NOR(r, qn)        qn = NOR(s, q)
--   s = 1, r = 0 : q = 1 (set)        s = 0, r = 1 : q = 0 (reset)
--   s = 0, r = 0 : q holds its value  s = 1, r = 1 : not allowed (never happens in the filter)
-- The outputs change as soon as s or r changes (asynchronous): it is an intentional
-- combinational loop, waived with ALLOW_COMBINATORIAL_LOOPS (XDC and attribute below).
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity bascule_sr is
  port (s, r : in std_logic; q, qn : out std_logic);
end bascule_sr;

architecture struct of bascule_sr is
  signal qi, qni : std_logic;
  attribute KEEP : string;
  attribute KEEP of qi, qni : signal is "TRUE";
  attribute DONT_TOUCH : string;
  attribute DONT_TOUCH of qi, qni : signal is "TRUE";
  attribute ALLOW_COMBINATORIAL_LOOPS : string;
  attribute ALLOW_COMBINATORIAL_LOOPS of qi, qni : signal is "TRUE";
begin
  u_nq  : nor2 port map (a => r, b => qni, y => qi);
  u_nqn : nor2 port map (a => s, b => qi,  y => qni);
  q  <= qi;
  qn <= qni;
end struct;
