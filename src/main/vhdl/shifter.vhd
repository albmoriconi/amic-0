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
--! @file shifter.vhd
--! @author Alberto Moriconi
--! @date 2019-04-30
--! @brief Shifter unit for the ALU output
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Shifter unit for the ALU output

--! # Inputs
--! The operation of the shifter is controlled by the 2 bits shifter_ctrl:
--!
--! SLL8 | SRA1
--!   ^      ^
--!  MSB    LSB
--!
--! When SLL8 is high, the input is shifted left 8 bits and the 8 LSBs are zero
--! filled; when SRA1 is high, the input is shifter right 1 bit and the MSB is
--! sign extended.
--!
--! # Outputs
--! When both SLL8 and SRA1 are low, the input is presented unmodified to the
--! output; the result is unspecified if both SLL8 and SRA1 are high at the
--! same time and it should not be considered valid.
entity shifter is
  port (
    --! Input to the shifter
    shifter_in   : in  std_logic_vector(31 downto 0);
    --! Controls the shifter operation
    shifter_ctrl : in  std_logic_vector(1 downto 0);
    --! Output from the shifter
    shifter_out  : out std_logic_vector(31 downto 0)
    );
end entity shifter;

--! Dataflow architecture for the shifter
architecture dataflow of shifter is

  -- Subtypes
  subtype shifter_ctrl_type is std_logic_vector(1 downto 0);

  -- Constants
  constant shifter_sll8 : shifter_ctrl_type := "10";
  constant shifter_sra1 : shifter_ctrl_type := "01";
  constant shifter_nop  : shifter_ctrl_type := "00";
  constant shifter_inv  : shifter_ctrl_type := "11";

begin -- architecture dataflow

  with shifter_ctrl select shifter_out <=
    shifter_in(23 downto 0) & x"00"          when shifter_sll8,
    shifter_in(31) & shifter_in(31 downto 1) when shifter_sra1,
    shifter_in                               when others;

end architecture dataflow;
