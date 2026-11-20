-- Falling-edge detector: fe is '1' for exactly one clock cycle when the filtered keyboard
-- clock goes from '1' to '0'. The PS/2 data bit is valid at that moment. All flip-flops of the
-- design use GClock and are enabled by this pulse, so there is only one clock domain.
--   fe = prev . (not now)       prev = now delayed by one clock cycle
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity detect_front is
  port (
    clk, resetb : in  std_logic;
    din         : in  std_logic;
    fe          : out std_logic
  );
end detect_front;

architecture struct of detect_front is
  signal prev, nnow : std_logic;
begin
  u_prev : dff port map (clk => clk, resetb => resetb, en => '1', d => din, q => prev);
  u_inv  : inv  port map (a => din, y => nnow);
  u_and  : and2 port map (a => prev, b => nnow, y => fe);
end struct;
