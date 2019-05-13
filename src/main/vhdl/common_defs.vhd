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
--! @file alu.vhd
--! @author Alberto Moriconi
--! @date 2019-04-26
--! @brief Arithmetic logic unit based on MIC-1 ALU
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Common definitions for amic-0 design

--! Contains common definitions for the processor design.
package common_defs is

  -- Data width onstants
  --! ALU control input width
  constant alu_ctrl_width : positive := 6;
  --! ALU function field width
  constant alu_fn_width   : positive := 2;
  --! Processor register data width
  constant reg_data_width : positive := 32;

  -- Subtypes
  --! ALU control input
  subtype alu_ctrl_type is std_logic_vector(alu_ctrl_width - 1 downto 0);
  --! ALU function field
  subtype alu_fn_type is std_logic_vector(alu_fn_width - 1 downto 0);
  --! Processor register data
  subtype reg_data_type is std_logic_vector(reg_data_width - 1 downto 0);

  -- Other constants
  --! ALU control EN_A bit
  constant alu_ctrl_en_a  : natural    := 3;
  --! ALU control EN_B bit
  constant alu_ctrl_en_b  : natural    := 2;
  --! ALU control INV_A bit
  constant alu_ctrl_inv_a : natural    := 1;
  --! ALU control INV bit
  constant alu_ctrl_inc   : natural    := 0;
  --! ALU function logical AND
  constant alu_fn_and     : alu_fn_type := "00";
  --! ALU function logical OR
  constant alu_fn_or      : alu_fn_type := "01";
  --! ALU function logical NOT B
  constant alu_fn_not_b   : alu_fn_type := "10";
  --! ALU function arithmetical sum
  constant alu_fn_sum     : alu_fn_type := "11";

end package common_defs;
