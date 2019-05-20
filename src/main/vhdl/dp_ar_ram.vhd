--------------------------------------------------------------------------VHDL--
-- Copyright (C) 2019 Alberto Moriconi
--
-- This program is free software: you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, either version 3 of the License, or (at your option) any later
-- version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
-- details.
--
-- You should have received a copy of the GNU General Public License along with
-- this program. If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------
--! @file dp_ar_ram.vhd
--! @author Alberto Moriconi
--! @date 2019-05-20
--! @brief Dual port, asynchronous read RAM for amic-0 based systems.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_defs.all;

--! Data memory for amic-0 based systems

--! Dual port, asynchronous read RAM for amic-0 based systems.
entity dp_ar_ram is
  port (
    --! Clock
    clk        : in  std_logic;
    --! Write enable 1
    we_1       : in  std_logic;
    --! Port for memory write 1
    data_in_1  : in  reg_data_type;
    --! Port for memory read 1
    data_out_1 : out reg_data_type;
    --! Address for memory operations 1
    address_1  : in  reg_data_type;
    --! Write enable 2
    we_2       : in  std_logic;
    --! Port for memory write 2
    data_in_2  : in  reg_data_type;
    --! Port for memory read 2
    data_out_2 : out reg_data_type;
    --! Address for memory operations 2
    address_2  : in  reg_data_type
    );
end entity dp_ar_ram;

--! Dataflow architecture for the control store
architecture behavioral of dp_ar_ram is

  -- Signals
  signal t_address_1 : integer := 0;
  signal t_address_2 : integer := 0;

  -- RAM content
  signal mem : dp_ar_ram_type := (
--BEGIN_WORDS_ENTRY
512 => "00000000",
513 => "00000000",
514 => "00000000",
515 => "00000000",
516 => "00000000",
517 => "00000000",
518 => "00000000",
519 => "01010110",
520 => "00000000",
521 => "00000000",
522 => "00000000",
523 => "00000011",
524 => "00000000",
525 => "00000000",
526 => "00000000",
527 => "00100010",
0 => "00000000",
1 => "00000001",
2 => "00000000",
3 => "00000010",
4 => "00010000",
5 => "01010110",
6 => "00110110",
7 => "00000001",
8 => "00100000",
9 => "00000000",
10 => "00000001",
11 => "00010101",
12 => "00000001",
13 => "10100001",
14 => "00000000",
15 => "00000110",
16 => "10100111",
17 => "00000000",
18 => "00001111",
19 => "00010000",
20 => "00000000",
21 => "00010101",
22 => "00000001",
23 => "00100000",
24 => "00000000",
25 => "00000010",
26 => "10111001",
27 => "00000000",
28 => "00000011",
29 => "00110110",
30 => "00000010",
31 => "10100111",
32 => "00000000",
33 => "00000000",
34 => "00000000",
35 => "00000011",
36 => "00000000",
37 => "00000000",
38 => "00010101",
39 => "00000001",
40 => "00010101",
41 => "00000010",
42 => "00010000",
43 => "00001111",
44 => "01100101",
45 => "01100101",
46 => "10101101",
others => (others => '0')
--END_WORDS_ENTRY
);

begin  -- architecture behavioral

  t_address_1 <= to_integer(unsigned(address_1));
  t_address_2 <= to_integer(unsigned(address_2));

  mem_proc : process(clk) is
  begin
    if (rising_edge(clk)) then
      if (we_1 = '1') then
        mem(t_address_1) <= data_in_1(31 downto 24);
        mem(t_address_1 + 1) <= data_in_1(23 downto 16);
        mem(t_address_1 + 2) <= data_in_1(15 downto 8);
        mem(t_address_1 + 3) <= data_in_1(7 downto 0);
      end if;
      if (we_2 = '1') then
        mem(t_address_2) <= data_in_2(31 downto 24);
        mem(t_address_2 + 1) <= data_in_2(23 downto 16);
        mem(t_address_2 + 2) <= data_in_2(15 downto 8);
        mem(t_address_2 + 3) <= data_in_2(7 downto 0);
      end if;
    end if;
  end process;

  data_out_1(31 downto 24) <= mem(t_address_1);
  data_out_1(23 downto 16) <= mem(t_address_1 + 1);
  data_out_1(15 downto 8) <= mem(t_address_1 + 2);
  data_out_1(7 downto 0) <= mem(t_address_1 + 3);

  data_out_2(31 downto 24) <= mem(t_address_2);
  data_out_2(23 downto 16) <= mem(t_address_2 + 1);
  data_out_2(15 downto 8) <= mem(t_address_2 + 2);
  data_out_2(7 downto 0) <= mem(t_address_2 + 3);

end architecture behavioral;
