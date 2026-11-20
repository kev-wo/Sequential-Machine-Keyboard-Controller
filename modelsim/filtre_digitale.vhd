-- Digital filter for the keyboard clock (structural), as in the lab figure 13.
-- An 8-bit shift register samples the (synchronized) keyboard clock with the 100 MHz clock.
-- The filtered clock goes to '1' only after 8 successive '1' samples (80 ns) and to '0' only
-- after 8 successive '0' samples, so noise and reflections on the cable are removed.
--   set = all 8 samples are '1'      reset = all 8 samples are '0'
--   the output stage is an asynchronous SR latch made of two cross-coupled NOR gates (figure 13):
--        q = NOR(rst, qn)      qn = NOR(set, q)
--   The latch (bascule_sr) is an intentional combinational loop: ALLOW_COMBINATORIAL_LOOPS is set
--   on its nets in the XDC file. set and rst are never '1' together (all ones / all zeros).
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity filtre_digitale is
  port (
    clk, resetb : in  std_logic;
    hc          : in  std_logic;     -- keyboard clock (synchronized)
    clk_filtree : out std_logic
  );
end filtre_digitale;

architecture struct of filtre_digitale is
  signal s, ns            : std_logic_vector(7 downto 0);   -- samples and their complements
  signal h1, h2, l1, l2   : std_logic;
  signal set, rst         : std_logic;
  signal q, qn            : std_logic;
  attribute KEEP : string;
  attribute KEEP of set, rst : signal is "TRUE";
begin
  u_s0 : dff port map (clk => clk, resetb => resetb, en => '1', d => hc, q => s(0));
  g : for i in 1 to 7 generate
    u : dff port map (clk => clk, resetb => resetb, en => '1', d => s(i - 1), q => s(i));
  end generate;
  gn : for i in 0 to 7 generate
    u : inv port map (a => s(i), y => ns(i));
  end generate;

  -- all ones / all zeros detectors (combinational circuit of figure 13)
  u_h1  : and4 port map (a => s(0),  b => s(1),  c => s(2),  d => s(3),  y => h1);
  u_h2  : and4 port map (a => s(4),  b => s(5),  c => s(6),  d => s(7),  y => h2);
  u_set : and2 port map (a => h1, b => h2, y => set);
  u_l1  : and4 port map (a => ns(0), b => ns(1), c => ns(2), d => ns(3), y => l1);
  u_l2  : and4 port map (a => ns(4), b => ns(5), c => ns(6), d => ns(7), y => l2);
  u_rst : and2 port map (a => l1, b => l2, y => rst);

  -- asynchronous SR latch (two cross-coupled NOR gates, see bascule_sr.vhd)
  u_latch : bascule_sr port map (s => set, r => rst, q => q, qn => qn);
  clk_filtree <= q;
end struct;
