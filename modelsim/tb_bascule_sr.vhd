-- Testbench of the asynchronous SR latch (bascule_sr). There is NO clock in this testbench:
-- s and r change at irregular times and the outputs must follow immediately (same time step),
-- which shows the asynchronous behaviour. Cases: reset, hold, set, hold, a set pulse while q = 1
-- (no change), short reset pulse, short set pulse.
library ieee;
use ieee.std_logic_1164.all;

entity tb_bascule_sr is end tb_bascule_sr;

architecture sim of tb_bascule_sr is
  signal s, r  : std_logic := '0';
  signal q, qn : std_logic;
  signal errors : integer := 0;

  procedure chk(cond : boolean; msg : string; signal e : inout integer) is
  begin
    if cond then report "ok   " & msg;
    else report "FAIL " & msg severity error; e <= e + 1;
    end if;
  end procedure;
begin
  dut : entity work.bascule_sr port map (s => s, r => r, q => q, qn => qn);

  process
  begin
    wait for 5 ns;  r <= '1';  wait for 1 ns;  chk(q = '0' and qn = '1', "reset at 5 ns: q = 0", errors);
    wait for 11 ns; r <= '0';  wait for 1 ns;  chk(q = '0', "r released at 17 ns: q holds 0", errors);
    wait for 5 ns;  s <= '1';  wait for 1 ps;                       -- 1 ps later: q has already changed
                                                chk(q = '1' and qn = '0', "set at 23 ns: q = 1 within 1 ps (no clock)", errors);
    wait for 8 ns;  s <= '0';  wait for 1 ns;  chk(q = '1', "s released at 31 ns: q holds 1", errors);
    wait for 12 ns; s <= '1';  wait for 2 ns;  s <= '0';
                               wait for 1 ns;  chk(q = '1', "set pulse at 44 ns while q = 1: no change", errors);
    wait for 4 ns;  r <= '1';  wait for 3 ns;  r <= '0';
                               wait for 1 ns;  chk(q = '0' and qn = '1', "3 ns reset pulse at 52 ns: q = 0 and holds", errors);
    wait for 15 ns; s <= '1';  wait for 2 ns;  s <= '0';
                               wait for 1 ns;  chk(q = '1' and qn = '0', "2 ns set pulse at 71 ns: q = 1 and holds", errors);
    wait for 20 ns;
    if errors = 0 then report "*** BASCULE SR TESTS PASSED ***";
    else report "*** BASCULE SR TESTS FAILED ***" severity error; end if;
    wait;
  end process;
end sim;
