-- Odd-parity checker: p = d0 xor d1 ... xor d7 xor x. The frame has odd parity, so the
-- 8 data bits plus the parity bit x must contain an odd number of ones, i.e. p = '1' is correct.
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity parite is
  port (
    d : in  std_logic_vector(7 downto 0);
    x : in  std_logic;
    p : out std_logic
  );
end parite;

architecture struct of parite is
  signal a0, a1, a2, a3, b0, b1, e : std_logic;
begin
  u_a0 : xor2 port map (a => d(0), b => d(1), y => a0);
  u_a1 : xor2 port map (a => d(2), b => d(3), y => a1);
  u_a2 : xor2 port map (a => d(4), b => d(5), y => a2);
  u_a3 : xor2 port map (a => d(6), b => d(7), y => a3);
  u_b0 : xor2 port map (a => a0,   b => a1,   y => b0);
  u_b1 : xor2 port map (a => a2,   b => a3,   y => b1);
  u_c  : xor2 port map (a => b0,   b => b1,   y => e);
  u_p  : xor2 port map (a => e,    b => x,    y => p);
end struct;
