-- 4-bit 2-to-1 multiplexer, built from four 1-bit multiplexers
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity mux2_4 is
  port (
    a, b : in  std_logic_vector(3 downto 0);
    s    : in  std_logic;
    y    : out std_logic_vector(3 downto 0)
  );
end mux2_4;

architecture struct of mux2_4 is
begin
  g : for i in 0 to 3 generate
    m : mux2_1 port map (a => a(i), b => b(i), s => s, y => y(i));
  end generate;
end struct;
