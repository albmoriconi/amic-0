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
--! @file program_store.vhd
--! @author Alberto Moriconi
--! @date 2019-05-16
--! @brief Program store for amic-0 based system
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_defs.all;

--! Program store for amic-0 based system

--! The program store is a ROM used to store a program.
entity program_store is
  port (
    --! Address of the desired word
    address : in  reg_data_type;
    --! Content of the addressed word
    word    : out reg_data_type
    );
end entity program_store;

--! Dataflow architecture for the control store
architecture dataflow of program_store is

  -- Constants
  constant words : prog_str_type := (
--BEGIN_WORDS_ENTRY
    others => (others => '0')
--END_WORDS_ENTRY
    );

begin  -- architecture dataflow

  word <= words(to_integer(unsigned(address)));

end architecture dataflow;
