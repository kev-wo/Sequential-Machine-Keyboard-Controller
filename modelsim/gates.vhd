-- Primitive logic gates (leaf cells). Every other block in the design is built only by
-- instantiating these gates, the D flip-flop (dff) and, for the display refresh, a small divider.
library ieee;
use ieee.std_logic_1164.all;

entity inv is port (a : in std_logic; y : out std_logic); end inv;
architecture dataflow of inv is begin y <= not a; end dataflow;

library ieee;
use ieee.std_logic_1164.all;
entity and2 is port (a, b : in std_logic; y : out std_logic); end and2;
architecture dataflow of and2 is begin y <= a and b; end dataflow;

library ieee;
use ieee.std_logic_1164.all;
entity and3 is port (a, b, c : in std_logic; y : out std_logic); end and3;
architecture dataflow of and3 is begin y <= a and b and c; end dataflow;

library ieee;
use ieee.std_logic_1164.all;
entity and4 is port (a, b, c, d : in std_logic; y : out std_logic); end and4;
architecture dataflow of and4 is begin y <= a and b and c and d; end dataflow;

library ieee;
use ieee.std_logic_1164.all;
entity or2 is port (a, b : in std_logic; y : out std_logic); end or2;
architecture dataflow of or2 is begin y <= a or b; end dataflow;

library ieee;
use ieee.std_logic_1164.all;
entity or3 is port (a, b, c : in std_logic; y : out std_logic); end or3;
architecture dataflow of or3 is begin y <= a or b or c; end dataflow;

library ieee;
use ieee.std_logic_1164.all;
entity xor2 is port (a, b : in std_logic; y : out std_logic); end xor2;
architecture dataflow of xor2 is begin y <= a xor b; end dataflow;

library ieee;
use ieee.std_logic_1164.all;
entity xnor2 is port (a, b : in std_logic; y : out std_logic); end xnor2;
architecture dataflow of xnor2 is begin y <= a xnor b; end dataflow;

library ieee; use ieee.std_logic_1164.all;
entity nor2 is port (a, b : in std_logic; y : out std_logic); end nor2;
architecture dataflow of nor2 is begin y <= a nor b; end dataflow;
