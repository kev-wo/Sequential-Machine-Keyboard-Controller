-- Top level of the keyboard controller (structural).
-- Reads the 11-bit PS/2 frames (start, 8 data bits LSB first, odd parity, stop) sent by the
-- keyboard and shows the last received byte, in hexadecimal, on BCD1 (high nibble) and BCD2 (low
-- nibble) and on the two right digits of the seven-segment display.
-- ResetG is active low (CPU RESETN). Everything runs on HorlogeG (100 MHz); the keyboard clock is
-- only used as data: synchronized, filtered and turned into the pulse fe (falling edge).
--
--   HorlogeClavier -> sync2 -> filtre_digitale -> detect_front -> fe
--   InfoClavier    -> sync2 -> x
--   fsmControleur (en = fe) -> sh, clr, pk, ld
--   compteur4bit counts the data bits, comp4 gives c = (count = 7)
--   registreDecalage shifts x in when sh.fe; parite checks the parity; a D flip-flop (bit bucket)
--   saves the check; registre8bit loads the code at the stop bit if the frame is valid.
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity controleurClavier is
  generic (DIV_BITS : natural := 14);              -- display refresh divider (small in simulation)
  port (
    HorlogeG       : in  std_logic;
    ResetG         : in  std_logic;                  -- active low
    HorlogeClavier : in  std_logic;
    InfoClavier    : in  std_logic;
    BCD1           : out std_logic_vector(3 downto 0);
    BCD2           : out std_logic_vector(3 downto 0);
    SEG            : out std_logic_vector(6 downto 0);
    DP             : out std_logic;
    AN             : out std_logic_vector(7 downto 0)
  );
end controleurClavier;

architecture struct of controleurClavier is
  signal hc_s, x, clk_f, fe        : std_logic;
  signal sh, clr, pk, ld           : std_logic;
  signal cnt                       : std_logic_vector(3 downto 0);
  signal c                         : std_logic;
  signal sh_en                     : std_logic;
  signal sr, code                  : std_logic_vector(7 downto 0);
  signal p, pk_en, pok, ld_en      : std_logic;
begin
  -- inputs from the keyboard
  u_sync_c : sync2 port map (clk => HorlogeG, resetb => ResetG, din => HorlogeClavier, dout => hc_s);
  u_sync_d : sync2 port map (clk => HorlogeG, resetb => ResetG, din => InfoClavier,    dout => x);
  u_filtre : filtre_digitale port map (clk => HorlogeG, resetb => ResetG, hc => hc_s, clk_filtree => clk_f);
  u_front  : detect_front    port map (clk => HorlogeG, resetb => ResetG, din => clk_f, fe => fe);

  -- controller
  u_fsm : fsmControleur port map (clk => HorlogeG, resetb => ResetG, en => fe, x => x, c => c,
                                  sh => sh, clr => clr, pk => pk, ld => ld);

  -- bit counter and last-bit detector
  u_cnt : compteur4bit port map (clk => HorlogeG, resetb => ResetG, en => fe, clr => clr, inc => sh, q => cnt);
  u_c7  : comp4 port map (a => cnt, b => "0111", eq => c);

  -- shift register and parity
  u_sh_en : and2 port map (a => sh, b => fe, y => sh_en);
  u_sr    : registreDecalage port map (clk => HorlogeG, resetb => ResetG, en => sh_en, din => x, q => sr);
  u_par   : parite port map (d => sr, x => x, p => p);
  u_pk_en : and2 port map (a => pk, b => fe, y => pk_en);
  u_bit   : dff port map (clk => HorlogeG, resetb => ResetG, en => pk_en, d => p, q => pok);   -- bit bucket

  -- output register: load at the stop bit (x = 1) of a frame with correct parity
  u_ld_en : and4 port map (a => ld, b => fe, c => x, d => pok, y => ld_en);
  u_reg   : registre8bit port map (clk => HorlogeG, resetb => ResetG, ld_en => ld_en, d => sr, q => code);

  BCD1 <= code(7 downto 4);
  BCD2 <= code(3 downto 0);

  u_aff : afficheur7seg generic map (DIV_BITS => DIV_BITS)
          port map (clk => HorlogeG, resetb => ResetG, bcd1 => code(7 downto 4), bcd2 => code(3 downto 0),
                    seg => SEG, dp => DP, an => AN);
end struct;
