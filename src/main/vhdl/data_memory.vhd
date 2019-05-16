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
--! @file data_memory.vhd
--! @author Alberto Moriconi
--! @date 2019-05-16
--! @brief Data memory for amic-0 based systems.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_defs.all;

--! Data memory for amic-0 based systems

--! The data memory is a RAM used to store program data.
--! The interface is described in Xilinx WP231 (transparent mode).
entity data_memory is
  port (
    --! Clock
    clk      : in  std_logic;
    --! Write enable
    we       : in  std_logic;
    --! Port for memory write
    data_in  : in  reg_data_type;
    --! Port for memory read
    data_out : out reg_data_type;
    --! Address for memory operations
    address  : out reg_data_type
    );
end entity data_memory;

--! Dataflow architecture for the control store
architecture behavioral of data_memory is

  signal mem : mem_data_type;

begin  -- architecture dataflow

  mem_proc : process(clk) is
  begin
    if (rising_edge(clk)) then
      if (we = '1') then
        mem(to_integer(unsigned(address))) <= data_in;
        data_out                           <= data_in;
      else
        data_out <= mem(to_integer(unsigned(address)));
      end if;
    end if;
  end process;

end architecture behavioral;
