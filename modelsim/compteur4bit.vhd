-- 4-bit up counter with synchronous clear, count-enable and global slow enable (structural).
-- Four enabled D flip-flops, a half-adder incrementer and a few gates.
--   en  : global slow enable (1 Hz tick AND LOAD_FSM)
--   clr : clear to 0 at the next enabled edge
--   inc : count up at the next enabled edge (ignored while clr = '1'; holds when both are '0')
--   d(i) = sum(i).clr'        ce = en.(clr + inc)
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity compteur4bit is
  port (
    clk, resetb  : in  std_logic;
    en, clr, inc : in  std_logic;
    q            : out std_logic_vector(3 downto 0)
  );
end compteur4bit;

architecture struct of compteur4bit is
  signal qi, sum, cy, d : std_logic_vector(3 downto 0);
  signal nclr, ci, ce   : std_logic;
begin
  -- incrementer: qi + 1  (first half adder adds the constant '1')
  ha0 : half_adder port map (a => qi(0), b => '1',   s => sum(0), co => cy(0));
  ha1 : half_adder port map (a => qi(1), b => cy(0), s => sum(1), co => cy(1));
  ha2 : half_adder port map (a => qi(2), b => cy(1), s => sum(2), co => cy(2));
  ha3 : half_adder port map (a => qi(3), b => cy(2), s => sum(3), co => cy(3));

  u_nclr : inv port map (a => clr, y => nclr);

  g : for i in 0 to 3 generate
    u_d  : and2   port map (a => sum(i), b => nclr, y => d(i));      -- clear forces 0
    u_ff : dff port map (clk => clk, resetb => resetb, en => ce, d => d(i), q => qi(i));
  end generate;

  u_ci : or2  port map (a => clr, b => inc, y => ci);
  u_ce : and2 port map (a => en,  b => ci,  y => ce);                 -- load only when clearing or counting
  q <= qi;
end struct;
