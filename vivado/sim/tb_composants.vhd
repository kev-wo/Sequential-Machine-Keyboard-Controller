-- Component-level functional testbench of the keyboard controller blocks:
-- decodeurBCD, parite, compteur4bit, registreDecalage, registre8bit, sync2, detect_front,
-- filtre_digitale and fsmControleur. Each test prints a line; the last line reports PASSED.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_composants is end tb_composants;

architecture sim of tb_composants is
  signal clk, resetb : std_logic := '0';
  -- decoder and parity
  signal dec_d : std_logic_vector(3 downto 0) := (others => '0');
  signal dec_y : std_logic_vector(6 downto 0);
  signal par_d : std_logic_vector(7 downto 0) := (others => '0');
  signal par_x, par_p : std_logic := '0';
  -- counter
  signal cn_en, cn_clr, cn_inc : std_logic := '0';
  signal cn_q : std_logic_vector(3 downto 0);
  -- shift register and output register
  signal sr_en, sr_din : std_logic := '0';
  signal sr_q : std_logic_vector(7 downto 0);
  signal rg_ld : std_logic := '0';
  signal rg_q : std_logic_vector(7 downto 0);
  -- synchronizer, edge detector, filter
  signal sy_in, sy_out : std_logic := '0';
  signal fr_in, fr_fe : std_logic := '1';
  signal fl_in : std_logic := '1';
  signal fl_out : std_logic;
  -- FSM
  signal fsm_en, fsm_x, fsm_c : std_logic := '0';
  signal fsm_sh, fsm_clr, fsm_pk, fsm_ld : std_logic;

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
  clk <= not clk after 5 ns;

  u_dec : entity work.decodeurBCD     port map (d => dec_d, y => dec_y);
  u_par : entity work.parite          port map (d => par_d, x => par_x, p => par_p);
  u_cnt : entity work.compteur4bit    port map (clk => clk, resetb => resetb, en => cn_en, clr => cn_clr, inc => cn_inc, q => cn_q);
  u_sr  : entity work.registreDecalage port map (clk => clk, resetb => resetb, en => sr_en, din => sr_din, q => sr_q);
  u_rg  : entity work.registre8bit    port map (clk => clk, resetb => resetb, ld_en => rg_ld, d => sr_q, q => rg_q);
  u_syn : entity work.sync2           port map (clk => clk, resetb => resetb, din => sy_in, dout => sy_out);
  u_fr  : entity work.detect_front    port map (clk => clk, resetb => resetb, din => fr_in, fe => fr_fe);
  u_fil : entity work.filtre_digitale port map (clk => clk, resetb => resetb, hc => fl_in, clk_filtree => fl_out);
  u_fsm : entity work.fsmControleur   port map (clk => clk, resetb => resetb, en => fsm_en, x => fsm_x, c => fsm_c,
                                                sh => fsm_sh, clr => fsm_clr, pk => fsm_pk, ld => fsm_ld);

  process
    variable e : integer := 0;
    variable cnt, pcount : integer;
    constant BYTE : std_logic_vector(7 downto 0) := x"A5";
    procedure chk(c : boolean; msg : string) is begin
      if not c then e := e + 1; report "FAIL: " & msg severity error; end if;
    end procedure;
    procedure tick(n : integer) is begin
      for i in 1 to n loop wait until falling_edge(clk); end loop;
    end procedure;
    procedure fsm_step(x, c : std_logic) is
    begin
      fsm_x <= x; fsm_c <= c; fsm_en <= '1'; tick(1); fsm_en <= '0'; tick(1);
    end procedure;
    procedure fsm_outs(sh, clr, pk, ld : std_logic; msg : string) is
    begin
      chk(fsm_sh = sh and fsm_clr = clr and fsm_pk = pk and fsm_ld = ld, msg);
    end procedure;
  begin
    -- 1. decoder: all 16 hexadecimal digits
    for v in 0 to 15 loop
      dec_d <= std_logic_vector(to_unsigned(v, 4)); wait for 10 ns;
      chk(dec_y = seg_pat(v), "decodeurBCD digit " & integer'image(v));
    end loop;
    report "decodeurBCD: 16 of 16 digits correct";
    -- 2. parity checker: all 512 combinations
    for v in 0 to 255 loop for xb in 0 to 1 loop
      par_d <= std_logic_vector(to_unsigned(v, 8)); par_x <= '0'; if xb = 1 then par_x <= '1'; end if;
      wait for 10 ns;
      pcount := xb; for i in 0 to 7 loop if par_d(i) = '1' then pcount := pcount + 1; end if; end loop;
      chk((par_p = '1') = (pcount mod 2 = 1), "parite " & integer'image(v));
    end loop; end loop;
    report "parite: 512 of 512 combinations correct";

    -- reset
    resetb <= '0'; tick(2); resetb <= '1'; tick(2);

    -- 3. counter (clear, count with wrap-around, hold, freeze)
    cn_en <= '1'; cn_clr <= '1'; tick(2); chk(cn_q = "0000", "compteur4bit clear");
    cn_clr <= '0'; cn_inc <= '1'; cnt := 0;
    for i in 1 to 18 loop
      tick(1); cnt := (cnt + 1) mod 16; chk(to_integer(unsigned(cn_q)) = cnt, "compteur4bit step " & integer'image(i));
      if i = 6 then cn_inc <= '0'; tick(2); chk(to_integer(unsigned(cn_q)) = cnt, "compteur4bit hold"); cn_inc <= '1'; end if;
      if i = 9 then cn_en <= '0'; tick(2); chk(to_integer(unsigned(cn_q)) = cnt, "compteur4bit freeze"); cn_en <= '1'; end if;
    end loop;
    cn_inc <= '0'; cn_clr <= '1'; tick(2); chk(cn_q = "0000", "compteur4bit clear 2"); cn_clr <= '0'; cn_en <= '0';
    report "compteur4bit: clear, count 0-15 with wrap, hold and freeze correct";

    -- 4. shift register: shift A5 in LSB first, then hold; output register loads on ld_en only
    sr_en <= '1';
    for i in 0 to 7 loop sr_din <= BYTE(i); tick(1); end loop;
    sr_en <= '0'; tick(2);
    chk(sr_q = BYTE, "registreDecalage holds the shifted byte");
    sr_din <= '1'; tick(3); chk(sr_q = BYTE, "registreDecalage holds when en = 0");
    chk(rg_q = x"00", "registre8bit still empty");
    rg_ld <= '1'; tick(1); rg_ld <= '0'; tick(2); chk(rg_q = BYTE, "registre8bit loads the byte");
    sr_en <= '1'; sr_din <= '0'; tick(2); sr_en <= '0'; tick(1);
    chk(rg_q = BYTE, "registre8bit keeps the byte while a new frame is shifted");
    report "registreDecalage and registre8bit: shift order, hold and load correct";

    -- 5. synchronizer: output follows the input two clock cycles later
    sy_in <= '1'; tick(1); chk(sy_out = '0', "sync2 after 1 clock");
    tick(1); chk(sy_out = '1', "sync2 after 2 clocks");
    sy_in <= '0'; tick(2); chk(sy_out = '0', "sync2 falls after 2 clocks");
    report "sync2: 2-clock delay correct";

    -- 6. falling-edge detector: one pulse per falling edge, none for a rising edge
    fr_in <= '1'; tick(3); pcount := 0;
    -- fe is sampled at the rising clock edges, where the flip-flops of the design use it
    fr_in <= '0'; for i in 1 to 4 loop wait until rising_edge(clk); if fr_fe = '1' then pcount := pcount + 1; end if; end loop;
    tick(1);
    chk(pcount = 1, "detect_front: exactly one pulse for a falling edge");
    pcount := 0; fr_in <= '1'; for i in 1 to 4 loop wait until rising_edge(clk); if fr_fe = '1' then pcount := pcount + 1; end if; end loop;
    tick(1);
    chk(pcount = 0, "detect_front: no pulse for a rising edge");
    report "detect_front: one pulse per falling edge";

    -- 7. digital filter: spikes shorter than 8 clock cycles are rejected, real edges pass
    fl_in <= '1'; tick(12); chk(fl_out = '1', "filtre idles high");
    fl_in <= '0'; tick(3); fl_in <= '1'; tick(12);                 -- 3-cycle low spike
    chk(fl_out = '1', "filtre rejects a 3-cycle spike low");
    fl_in <= '0'; tick(9); chk(fl_out = '0', "filtre follows a real low level");
    fl_in <= '1'; tick(3); fl_in <= '0'; tick(12);                 -- 3-cycle high spike
    chk(fl_out = '0', "filtre rejects a 3-cycle spike high");
    fl_in <= '1'; tick(9); chk(fl_out = '1', "filtre follows a real high level");
    report "filtre_digitale: spikes rejected, steady levels passed";

    -- 8. FSM: A -> B (x = 0), 8 data bits (c = 0 ... c = 1), C, D, back to A
    resetb <= '0'; tick(2); resetb <= '1'; tick(2);
    fsm_outs('0', '1', '0', '0', "fsm state A outputs");
    fsm_step('1', '0'); fsm_outs('0', '1', '0', '0', "fsm stays in A while x = 1");
    fsm_step('0', '0'); fsm_outs('1', '0', '0', '0', "fsm goes to B on the start bit");
    fsm_step('1', '0'); fsm_outs('1', '0', '0', '0', "fsm stays in B while c = 0");
    fsm_step('0', '1'); fsm_outs('0', '1', '1', '0', "fsm goes to C when c = 1");
    fsm_step('1', '0'); fsm_outs('0', '1', '0', '1', "fsm goes to D");
    fsm_step('1', '0'); fsm_outs('0', '1', '0', '0', "fsm returns to A");
    report "fsmControleur: A - B - C - D - A with the right outputs";

    if e = 0 then report "*** COMPONENT TESTS PASSED ***";
    else report "*** COMPONENT TESTS FAILED: " & integer'image(e) & " errors ***" severity failure; end if;
    wait;
  end process;
end sim;
