-- Decoder from a 4-bit value (one hexadecimal digit 0-F of the scan code) to the seven
-- segments, gate-level structural (generated from the Karnaugh-map equations in gen_seg7_hex.py).
-- Outputs are ACTIVE LOW, ordered y(0)=CA(a) ... y(6)=CG(g), as on the Nexys A7 cathode bus.
library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity decodeurBCD is
  port (
    d : in  std_logic_vector(3 downto 0);
    y : out std_logic_vector(6 downto 0)
  );
end decodeurBCD;

architecture struct of decodeurBCD is
  signal d3, d2, d1, d0, nd3, nd2, nd1, nd0 : std_logic;
  signal o11 : std_logic;
  signal o12 : std_logic;
  signal o16 : std_logic;
  signal o21 : std_logic;
  signal o22 : std_logic;
  signal o26 : std_logic;
  signal o31 : std_logic;
  signal o32 : std_logic;
  signal o36 : std_logic;
  signal o5 : std_logic;
  signal o6 : std_logic;
  signal t1 : std_logic;
  signal t10 : std_logic;
  signal t13 : std_logic;
  signal t14 : std_logic;
  signal t15 : std_logic;
  signal t17 : std_logic;
  signal t18 : std_logic;
  signal t19 : std_logic;
  signal t2 : std_logic;
  signal t20 : std_logic;
  signal t23 : std_logic;
  signal t24 : std_logic;
  signal t25 : std_logic;
  signal t27 : std_logic;
  signal t28 : std_logic;
  signal t29 : std_logic;
  signal t3 : std_logic;
  signal t30 : std_logic;
  signal t33 : std_logic;
  signal t34 : std_logic;
  signal t35 : std_logic;
  signal t4 : std_logic;
  signal t7 : std_logic;
  signal t8 : std_logic;
  signal t9 : std_logic;
begin
  d3 <= d(3);  d2 <= d(2);  d1 <= d(1);  d0 <= d(0);   -- wiring
  u_nd3 : inv port map (a => d3, y => nd3);
  u_nd2 : inv port map (a => d2, y => nd2);
  u_nd1 : inv port map (a => d1, y => nd1);
  u_nd0 : inv port map (a => d0, y => nd0);
  u4 : and4 port map (a => d0, b => d1, c => d3, d => nd2, y => t1);
  u5 : and4 port map (a => d0, b => d2, c => d3, d => nd1, y => t2);
  u6 : and4 port map (a => d0, b => nd1, c => nd2, d => nd3, y => t3);
  u7 : and4 port map (a => d2, b => nd0, c => nd1, d => nd3, y => t4);
  u8 : or2 port map (a => t1, b => t2, y => o5);
  u9 : or2 port map (a => o5, b => t3, y => o6);
  u10 : or2 port map (a => o6, b => t4, y => y(0));
  u11 : and3 port map (a => d0, b => d1, c => d3, y => t7);
  u12 : and3 port map (a => d1, b => d2, c => nd0, y => t8);
  u13 : and3 port map (a => d2, b => d3, c => nd0, y => t9);
  u14 : and4 port map (a => d0, b => d2, c => nd1, d => nd3, y => t10);
  u15 : or2 port map (a => t7, b => t8, y => o11);
  u16 : or2 port map (a => o11, b => t9, y => o12);
  u17 : or2 port map (a => o12, b => t10, y => y(1));
  u18 : and3 port map (a => d1, b => d2, c => d3, y => t13);
  u19 : and3 port map (a => d2, b => d3, c => nd0, y => t14);
  u20 : and4 port map (a => d1, b => nd0, c => nd2, d => nd3, y => t15);
  u21 : or2 port map (a => t13, b => t14, y => o16);
  u22 : or2 port map (a => o16, b => t15, y => y(2));
  u23 : and3 port map (a => d0, b => d1, c => d2, y => t17);
  u24 : and4 port map (a => d1, b => d3, c => nd0, d => nd2, y => t18);
  u25 : and4 port map (a => d0, b => nd1, c => nd2, d => nd3, y => t19);
  u26 : and4 port map (a => d2, b => nd0, c => nd1, d => nd3, y => t20);
  u27 : or2 port map (a => t17, b => t18, y => o21);
  u28 : or2 port map (a => o21, b => t19, y => o22);
  u29 : or2 port map (a => o22, b => t20, y => y(3));
  u30 : and2 port map (a => d0, b => nd3, y => t23);
  u31 : and3 port map (a => d0, b => nd1, c => nd2, y => t24);
  u32 : and3 port map (a => d2, b => nd1, c => nd3, y => t25);
  u33 : or2 port map (a => t23, b => t24, y => o26);
  u34 : or2 port map (a => o26, b => t25, y => y(4));
  u35 : and3 port map (a => d0, b => d1, c => nd3, y => t27);
  u36 : and3 port map (a => d0, b => nd2, c => nd3, y => t28);
  u37 : and3 port map (a => d1, b => nd2, c => nd3, y => t29);
  u38 : and4 port map (a => d0, b => d2, c => d3, d => nd1, y => t30);
  u39 : or2 port map (a => t27, b => t28, y => o31);
  u40 : or2 port map (a => o31, b => t29, y => o32);
  u41 : or2 port map (a => o32, b => t30, y => y(5));
  u42 : and4 port map (a => d0, b => d1, c => d2, d => nd3, y => t33);
  u43 : and3 port map (a => nd1, b => nd2, c => nd3, y => t34);
  u44 : and4 port map (a => d2, b => d3, c => nd0, d => nd1, y => t35);
  u45 : or2 port map (a => t33, b => t34, y => o36);
  u46 : or2 port map (a => o36, b => t35, y => y(6));
end struct;
