-- Testbench of the digital filter (filtre_digitale) with a bouncing keyboard clock.
-- hc goes high (steady), then bounces (pulses of 15 to 30 ns, shorter than 80 ns) before
-- settling low, then bounces again before settling high. clk_filtree must change only after
-- 8 equal samples, and it changes at the same clock edge as the 8th sample: the SR latch reacts
-- to set / reset at once instead of waiting one more clock cycle (asynchronous output stage).
--   clock: rising edges at 5, 15, 25 ... ns     reset until 22 ns
library ieee;
use ieee.std_logic_1164.all;

entity tb_filtre_digitale is end tb_filtre_digitale;

architecture sim of tb_filtre_digitale is
  signal clk, resetb : std_logic := '0';
  signal hc          : std_logic := '1';
  signal clk_filtree : std_logic;
  signal done        : boolean := false;
  signal errors      : integer := 0;

  procedure chk(cond : boolean; msg : string; signal e : inout integer) is
  begin
    if cond then report "ok   " & msg;
    else report "FAIL " & msg severity error; e <= e + 1;
    end if;
  end procedure;
begin
  clk <= not clk after 5 ns when not done else '0';
  dut : entity work.filtre_digitale port map (clk => clk, resetb => resetb, hc => hc, clk_filtree => clk_filtree);

  stim : process
  begin
    hc <= '1';
    wait for 22 ns;  resetb <= '1';                 -- reset released, samples start at 25 ns
    -- steady high: 8th '1' sample at 95 ns
    wait for 94 ns - now; chk(clk_filtree = '0', "94 ns: only 7 high samples, output still 0", errors);
    wait for 96 ns - now; chk(clk_filtree = '1', "96 ns: 8th high sample at 95 ns, output 1", errors);
    -- bounces before going low
    wait for 202 ns - now; hc <= '0';              -- 20 ns low
    wait for 222 ns - now; hc <= '1';              -- 15 ns high
    wait for 237 ns - now; hc <= '0';              -- 30 ns low
    wait for 267 ns - now; hc <= '1';              -- 15 ns high
    wait for 282 ns - now; hc <= '0';              -- steady low: 8th '0' sample at 355 ns
    wait for 300 ns - now; chk(clk_filtree = '1', "bounces (15-30 ns) ignored, output still 1", errors);
    wait for 354 ns - now; chk(clk_filtree = '1', "354 ns: only 7 low samples, output still 1", errors);
    wait for 356 ns - now; chk(clk_filtree = '0', "356 ns: 8th low sample at 355 ns, output 0", errors);
    -- bounce before going high
    wait for 502 ns - now; hc <= '1';              -- 30 ns high
    wait for 532 ns - now; hc <= '0';              -- 20 ns low
    wait for 552 ns - now; hc <= '1';              -- steady high: 8th '1' sample at 625 ns
    wait for 560 ns - now; chk(clk_filtree = '0', "bounce ignored, output still 0", errors);
    wait for 624 ns - now; chk(clk_filtree = '0', "624 ns: only 7 high samples, output still 0", errors);
    wait for 626 ns - now; chk(clk_filtree = '1', "626 ns: 8th high sample at 625 ns, output 1", errors);
    wait for 700 ns - now;
    if errors = 0 then report "*** FILTRE DIGITALE TESTS PASSED ***";
    else report "*** FILTRE DIGITALE TESTS FAILED ***" severity error; end if;
    done <= true;
    wait;
  end process;
end sim;
