-- 4-bit equality comparator: four 1-bit cells and a 4-input AND
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity comp4 is
  port (
    a, b : in  std_logic_vector(3 downto 0);
    eq   : out std_logic
  );
end comp4;

architecture struct of comp4 is
  signal e : std_logic_vector(3 downto 0);
begin
  g : for i in 0 to 3 generate
    c : comp1 port map (a => a(i), b => b(i), eq => e(i), gt => open);
  end generate;
  g_all : and4 port map (a => e(3), b => e(2), c => e(1), d => e(0), y => eq);
end struct;
