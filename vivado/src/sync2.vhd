-- Two-flip-flop synchronizer: brings an asynchronous input (keyboard clock or keyboard data)
-- into the 100 MHz clock domain and avoids metastability in the rest of the design.
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity sync2 is
  port (
    clk, resetb : in  std_logic;
    din         : in  std_logic;
    dout        : out std_logic
  );
end sync2;

architecture struct of sync2 is
  signal s0 : std_logic;
begin
  u0 : dff port map (clk => clk, resetb => resetb, en => '1', d => din, q => s0);
  u1 : dff port map (clk => clk, resetb => resetb, en => '1', d => s0,  q => dout);
end struct;
