-- Self-checking testbench of the keyboard controller.
-- A PS/2 keyboard model sends complete 11-bit frames (start, 8 data bits LSB first, odd parity,
-- stop) with a keyboard clock period of 4 us (the real period is 60 to 100 us; shortened to keep
-- the simulation small, it is still thousands of times slower than the 10 ns system clock).
-- Cases: make and break codes of several keys, extended keys (E0), a repeated (held) key,
-- noise pulses on the keyboard clock, a frame with wrong parity, a frame with a wrong stop bit,
-- and a global reset in the middle of a frame. After every byte BCD1 and BCD2 are compared with
-- the byte, and the seven-segment outputs are compared with the expected patterns.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_controleurClavier is end tb_controleurClavier;

architecture sim of tb_controleurClavier is
  constant T_SYS : time := 10 ns;
  constant T_KB  : time := 4 us;
  signal clk      : std_logic := '0';
  signal resetg   : std_logic := '0';
  signal kb_clk   : std_logic := '1';
  signal kb_dat   : std_logic := '1';
  signal bcd1, bcd2 : std_logic_vector(3 downto 0);
  signal seg      : std_logic_vector(6 downto 0);
  signal dp       : std_logic;
  signal an       : std_logic_vector(7 downto 0);
  signal errors   : integer := 0;
  signal done     : boolean := false;

  -- expected pattern, written in the order SEG(0)=CA ... SEG(6)=CG ('0' = segment lit)
  function seg_pat(v : integer) return std_logic_vector is
    variable r : std_logic_vector(6 downto 0);
    variable t : string(1 to 7);
  begin
    case v is
      when 0  => t := "0000001"; when 1  => t := "1001111"; when 2  => t := "0010010";
      when 3  => t := "0000110"; when 4  => t := "1001100"; when 5  => t := "0100100";
      when 6  => t := "0100000"; when 7  => t := "0001111"; when 8  => t := "0000000";
      when 9  => t := "0000100"; when 10 => t := "0001000"; when 11 => t := "1100000";
      when 12 => t := "0110001"; when 13 => t := "1000010"; when 14 => t := "0110000";
      when others => t := "0111000";
    end case;
    for i in 0 to 6 loop
      if t(i + 1) = '1' then r(i) := '1'; else r(i) := '0'; end if;
    end loop;
    return r;
  end function;
begin
  clk <= not clk after T_SYS / 2;

  dut : entity work.controleurClavier
    generic map (DIV_BITS => 4)                      -- fast display scan for the simulation
    port map (HorlogeG => clk, ResetG => resetg, HorlogeClavier => kb_clk, InfoClavier => kb_dat,
              BCD1 => bcd1, BCD2 => bcd2, SEG => seg, DP => dp, AN => an);

  -- keyboard model and checks
  stim : process
    variable errs : integer := 0;

    procedure check(expected : std_logic_vector(7 downto 0); msg : string) is
    begin
      wait for 3 us;                                  -- let the controller finish
      if bcd1 /= expected(7 downto 4) or bcd2 /= expected(3 downto 0) then
        errs := errs + 1;
        report "FAIL " & msg & ": expected " & integer'image(to_integer(unsigned(expected))) &
               " got " & integer'image(to_integer(unsigned(bcd1 & bcd2))) severity error;
      else
        report "ok   " & msg & "  -> " & integer'image(to_integer(unsigned(expected)));
      end if;
    end procedure;

    -- one keyboard clock pulse carrying one bit; noise injects 30 ns spikes (too short to pass the filter)
    procedure send_bit(b : std_logic; noise : boolean) is
    begin
      kb_dat <= b;
      wait for T_KB / 4;
      if noise then                                   -- spike on the clock while it is high
        kb_clk <= '0'; wait for 30 ns; kb_clk <= '1'; wait for 100 ns;
      end if;
      kb_clk <= '0';
      wait for T_KB / 4;
      if noise then                                   -- spike on the clock while it is low
        kb_clk <= '1'; wait for 30 ns; kb_clk <= '0';
      end if;
      wait for T_KB / 4;
      kb_clk <= '1';
      wait for T_KB / 4;
    end procedure;

    procedure send_frame(data : std_logic_vector(7 downto 0);
                         bad_par : boolean; bad_stop : boolean; noise : boolean) is
      variable par : std_logic := '1';                -- odd parity: 1 xor all data bits
    begin
      for i in 0 to 7 loop par := par xor data(i); end loop;
      if bad_par then par := not par; end if;
      send_bit('0', noise);
      for i in 0 to 7 loop send_bit(data(i), noise); end loop;
      send_bit(par, noise);
      if bad_stop then send_bit('0', noise); else send_bit('1', noise); end if;
      kb_dat <= '1';
      wait for 2 * T_KB;                              -- idle gap between bytes
    end procedure;

    procedure byte(data : std_logic_vector(7 downto 0); msg : string) is
    begin
      send_frame(data, false, false, false);
      check(data, msg);
    end procedure;
  begin
    resetg <= '0'; wait for 200 ns; resetg <= '1'; wait for 1 us;
    check(x"00", "after reset");

    -- press and release A (make 1C, break F0 1C)
    byte(x"1C", "A make");
    byte(x"F0", "break prefix F0");
    byte(x"1C", "A break (last byte)");
    -- ENTER (5A) and the digit 0 (45)
    byte(x"5A", "ENTER make"); byte(x"F0", "F0"); byte(x"5A", "ENTER break");
    byte(x"45", "0 make");     byte(x"F0", "F0"); byte(x"45", "0 break");
    -- extended key: right arrow (E0 74, break E0 F0 74)
    byte(x"E0", "E0 prefix"); byte(x"74", "R ARROW make");
    byte(x"E0", "E0 prefix"); byte(x"F0", "F0"); byte(x"74", "R ARROW break");
    -- key held: the make code repeats
    byte(x"23", "D held 1"); byte(x"23", "D held 2"); byte(x"23", "D held 3");
    byte(x"F0", "F0"); byte(x"23", "D break");
    -- all bits set / cleared
    byte(x"FF", "FF (all ones)"); byte(x"00", "00 (all zeros)"); byte(x"A5", "A5"); byte(x"5A", "5A");

    -- noise on the keyboard clock must not change the result
    send_frame(x"2B", false, false, true);  check(x"2B", "F make with noise on the clock");

    -- invalid frames must be ignored: the display keeps 2B
    send_frame(x"33", true,  false, false); check(x"2B", "wrong parity ignored");
    send_frame(x"34", false, true,  false); check(x"2B", "wrong stop bit ignored");
    -- and the next valid frame is received correctly
    byte(x"34", "G make after the invalid frames");

    -- global reset in the middle of a frame
    send_bit('0', false); send_bit('1', false); send_bit('0', false); send_bit('1', false);
    resetg <= '0'; wait for 100 ns; resetg <= '1'; kb_dat <= '1';
    wait for 3 * T_KB;
    check(x"00", "reset in the middle of a frame");
    byte(x"1B", "S make after the reset");
    byte(x"F0", "F0"); byte(x"1B", "S break");

    done <= true;
    wait for 1 us;
    if errs = 0 and errors = 0 then
      report "*** SIMULATION PASSED: all keyboard frames and display outputs are correct ***" severity note;
    else
      report "*** SIMULATION FAILED: " & integer'image(errs + errors) & " errors ***" severity failure;
    end if;
    wait;
  end process;

  -- display check: each active anode must show the matching digit of the scan code
  disp : process (clk)
    variable lo, hi : integer;
  begin
    if rising_edge(clk) and resetg = '1' then
      lo := to_integer(unsigned(bcd2)); hi := to_integer(unsigned(bcd1));
      if an(0) = '0' and an(1) = '1' and seg /= seg_pat(lo) and not done then
        -- ignore the one cycle after a digit switch (the scan flip-flop and segments settle together)
        errors <= errors + 1;
      end if;
      if an(1) = '0' and an(0) = '1' and seg /= seg_pat(hi) and not done then
        errors <= errors + 1;
      end if;
    end if;
  end process;
end sim;
