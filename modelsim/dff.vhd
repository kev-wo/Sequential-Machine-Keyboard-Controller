-- D flip-flop with asynchronous active-low reset and synchronous enable (atomic module)
library ieee;
use ieee.std_logic_1164.all;

entity dff is
  port (
    clk    : in  std_logic;
    resetb : in  std_logic;   -- asynchronous, active low
    en     : in  std_logic;   -- clock enable
    d      : in  std_logic;
    q      : out std_logic
  );
end dff;

architecture rtl of dff is
begin
  process (clk, resetb)
  begin
    if resetb = '0' then
      q <= '0';
    elsif rising_edge(clk) then
      if en = '1' then
        q <= d;
      end if;
    end if;
  end process;
end rtl;
