-- Component declarations for the whole design (compile this file first).
library ieee;
use ieee.std_logic_1164.all;

package components is
  -- primitive gates
  component inv   port (a : in std_logic; y : out std_logic); end component;
  component and2  port (a, b : in std_logic; y : out std_logic); end component;
  component and3  port (a, b, c : in std_logic; y : out std_logic); end component;
  component and4  port (a, b, c, d : in std_logic; y : out std_logic); end component;
  component or2   port (a, b : in std_logic; y : out std_logic); end component;
  component or3   port (a, b, c : in std_logic; y : out std_logic); end component;
  component xor2  port (a, b : in std_logic; y : out std_logic); end component;
  component xnor2 port (a, b : in std_logic; y : out std_logic); end component;
  component nor2  port (a, b : in std_logic; y : out std_logic); end component;
  component bascule_sr port (s, r : in std_logic; q, qn : out std_logic); end component;

  -- storage
  component dff port (clk, resetb, en, d : in std_logic; q : out std_logic); end component;

  -- small modules
  component half_adder port (a, b : in std_logic; s, co : out std_logic); end component;
  component mux2_1 port (a, b, s : in std_logic; y : out std_logic); end component;
  component mux2_4
    port (a, b : in std_logic_vector(3 downto 0); s : in std_logic; y : out std_logic_vector(3 downto 0));
  end component;
  component comp1 port (a, b : in std_logic; eq, gt : out std_logic); end component;
  component comp4 port (a, b : in std_logic_vector(3 downto 0); eq : out std_logic); end component;
  component compteur4bit
    port (clk, resetb, en, clr, inc : in std_logic; q : out std_logic_vector(3 downto 0));
  end component;

  -- keyboard interface
  component sync2 port (clk, resetb, din : in std_logic; dout : out std_logic); end component;
  component filtre_digitale port (clk, resetb, hc : in std_logic; clk_filtree : out std_logic); end component;
  component detect_front port (clk, resetb, din : in std_logic; fe : out std_logic); end component;
  component fsmControleur
    port (clk, resetb, en, x, c : in std_logic; sh, clr, pk, ld : out std_logic);
  end component;
  component registreDecalage
    port (clk, resetb, en, din : in std_logic; q : out std_logic_vector(7 downto 0));
  end component;
  component registre8bit
    port (clk, resetb, ld_en : in std_logic; d : in std_logic_vector(7 downto 0); q : out std_logic_vector(7 downto 0));
  end component;
  component parite port (d : in std_logic_vector(7 downto 0); x : in std_logic; p : out std_logic); end component;

  -- display
  component decodeurBCD port (d : in std_logic_vector(3 downto 0); y : out std_logic_vector(6 downto 0)); end component;
  component afficheur7seg
    generic (DIV_BITS : natural := 14);
    port (clk, resetb : in std_logic; bcd1, bcd2 : in std_logic_vector(3 downto 0);
          seg : out std_logic_vector(6 downto 0); dp : out std_logic; an : out std_logic_vector(7 downto 0));
  end component;
end package components;
