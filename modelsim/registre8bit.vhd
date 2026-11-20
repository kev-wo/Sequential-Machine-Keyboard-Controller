-- 8-bit parallel-load register (structural): holds the last valid scan code while the next
-- frame is being shifted in. The eight flip-flops load d when ld_en = '1'.
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity registre8bit is
  port (
    clk, resetb : in  std_logic;
    ld_en       : in  std_logic;
    d           : in  std_logic_vector(7 downto 0);
    q           : out std_logic_vector(7 downto 0)
  );
end registre8bit;

architecture struct of registre8bit is
begin
  g : for i in 0 to 7 generate
    u : dff port map (clk => clk, resetb => resetb, en => ld_en, d => d(i), q => q(i));
  end generate;
end struct;
