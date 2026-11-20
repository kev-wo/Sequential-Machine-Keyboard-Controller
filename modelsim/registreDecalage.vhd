-- 8-bit shift register (structural): eight D flip-flops chained, shifting RIGHT.
-- On each enabled clock edge the serial input din enters at q(7) and every bit moves one place
-- towards q(0). The keyboard sends the LSB first, so after 8 shifts the first bit received (d0)
-- is in q(0) and the last one (d7) is in q(7): q holds the scan code.
--   en : shift enable (state B of the FSM AND the falling-edge pulse of the keyboard clock)
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity registreDecalage is
  port (
    clk, resetb : in  std_logic;
    en, din     : in  std_logic;
    q           : out std_logic_vector(7 downto 0)
  );
end registreDecalage;

architecture struct of registreDecalage is
  signal qi : std_logic_vector(7 downto 0);
begin
  u7 : dff port map (clk => clk, resetb => resetb, en => en, d => din, q => qi(7));
  g  : for i in 0 to 6 generate
    u : dff port map (clk => clk, resetb => resetb, en => en, d => qi(i + 1), q => qi(i));
  end generate;
  q <= qi;
end struct;
