-- Two-digit hexadecimal display driver for the Nexys A7 seven-segment display.
-- The refresh divider is a free-running DIV_BITS-bit binary counter (flip-flops, half adders):
-- strobe = '1' when all bits are '1', i.e. once every 2**DIV_BITS clock cycles (14 bits: 16384
-- cycles = 6.1 kHz, about 3 kHz per digit at 100 MHz).
-- The strobe toggles the scan flip-flop s; a multiplexer selects the low nibble (s = 0) or the
-- high nibble (s = 1), which goes to the segment decoder. Anodes and segments are active low.
--   AN0 = right digit (low nibble, BCD2), AN1 = left digit (high nibble, BCD1), AN2..AN7 off.
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity afficheur7seg is
  generic (DIV_BITS : natural := 14);
  port (
    clk, resetb : in  std_logic;
    bcd1, bcd2  : in  std_logic_vector(3 downto 0);   -- high and low digit
    seg         : out std_logic_vector(6 downto 0);   -- CA..CG, active low
    dp          : out std_logic;                      -- decimal point, off
    an          : out std_logic_vector(7 downto 0)    -- active low
  );
end afficheur7seg;

architecture struct of afficheur7seg is
  signal strobe   : std_logic;
  signal s, ns    : std_logic;
  signal dig      : std_logic_vector(3 downto 0);
  signal q, d     : std_logic_vector(DIV_BITS - 1 downto 0);   -- divider counter
  signal cy       : std_logic_vector(DIV_BITS downto 0);       -- carry chain
begin
  -- structural refresh divider: q <= q + 1 every clock cycle
  cy(0) <= '1';
  g_div : for i in 0 to DIV_BITS - 1 generate
    u_ha : half_adder port map (a => q(i), b => cy(i), s => d(i), co => cy(i + 1));
    u_ff : dff port map (clk => clk, resetb => resetb, en => '1', d => d(i), q => q(i));
  end generate;
  strobe <= cy(DIV_BITS);                                     -- all bits '1'

  u_ns  : inv  port map (a => s, y => ns);
  u_s   : dff  port map (clk => clk, resetb => resetb, en => strobe, d => ns, q => s);
  u_mux : mux2_4 port map (a => bcd2, b => bcd1, s => s, y => dig);
  u_dec : decodeurBCD port map (d => dig, y => seg);

  an(0) <= s;                        -- low (on) while s = 0
  an(1) <= ns;                       -- low (on) while s = 1
  an(7 downto 2) <= "111111";
  dp <= '1';
end struct;
