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
    word    : out mbr_data_type
    );
end entity program_store;

--! Dataflow architecture for the control store
architecture dataflow of program_store is

  -- Constants
  constant words : prog_str_type := (
--BEGIN_WORDS_ENTRY
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

begin  -- architecture dataflow

  word <= words(to_integer(unsigned(address)));

end architecture dataflow;
