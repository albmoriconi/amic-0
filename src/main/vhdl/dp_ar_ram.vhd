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
    data_out_2 : out mbr_data_type;
    --! Address for memory operations 2
    address_2  : in  reg_data_type
    );
end entity dp_ar_ram;

--! Dataflow architecture for the control store
architecture behavioral of dp_ar_ram is

  -- Signals
  signal t_address_1  : integer := 0;
  signal t_address_2  : integer := 0;
  signal wa_address_2 : reg_data_type;
  signal t_data_out_2 : reg_data_type;

  -- RAM content
  signal mem : dp_ar_ram_type := (
--BEGIN_WORDS_ENTRY
128 => "00000000000000000000000000000000",
0 => "00000001000000000000000100000000",
1 => "00001110000100000000101000010000",
2 => "10100111000000010011011001100101",
3 => "00000000000000000000000000000000",
others => (others => '0')
--END_WORDS_ENTRY
    );

begin  -- architecture behavioral

  wa_address_2 <= "00" & address_2(reg_data_type'high downto 2);
  t_address_1 <= to_integer(unsigned(address_1));
  t_address_2 <= to_integer(unsigned(wa_address_2));

  mem_proc : process(clk) is
  begin
    if (rising_edge(clk)) then
      if (we_1 = '1') then
        mem(t_address_1) <= data_in_1;
      elsif (we_2 = '1') then
        mem(t_address_2) <= data_in_2;
      end if;
    end if;
  end process;

  data_out_1   <= mem(t_address_1);
  t_data_out_2 <= mem(t_address_2);

  with address_2(1 downto 0) select data_out_2 <=
    t_data_out_2(7 downto 0)   when "00",
    t_data_out_2(15 downto 8)  when "01",
    t_data_out_2(23 downto 16) when "10",
    t_data_out_2(31 downto 24) when "11",
    (others => '0')            when others;

end architecture behavioral;
