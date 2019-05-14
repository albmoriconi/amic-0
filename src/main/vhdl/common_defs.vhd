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
--! @file common_defs.vhd
--! @author Alberto Moriconi
--! @date 2019-05-13
--! @brief Common definitions for amic-0 design
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Common definitions for amic-0 design

--! Contains common definitions for the processor design.
package common_defs is

  -- Data widths
  --! Processor register data width
  constant reg_data_width      : positive := 32;
  --! MBR register data width
  constant mbr_data_width      : positive := 8;
  --! ALU control width
  constant alu_ctrl_width      : positive := 8;
  --! C bus control width
  constant c_ctrl_width        : positive := 8;
  --! Memory control width
  constant mem_ctrl_width      : positive := 3;
  --! B bus control width
  constant b_ctrl_width        : positive := 4;
  --! Control store address width
  constant ctrl_str_addr_width : positive := 9;
  --! Control store word width
  constant ctrl_str_word_width : positive := 36;
  --! Control store size
  constant ctrl_str_words      : positive := 512;

  -- Subtypes
  --! Processor register data
  subtype reg_data_type is std_logic_vector(reg_data_width - 1 downto 0);
  --! MBR register data
  subtype mbr_data_type is std_logic_vector(mbr_data_width - 1 downto 0);
  --! ALU control type
  subtype alu_ctrl_type is std_logic_vector(alu_ctrl_width - 1 downto 0);
  --! C bus control type
  subtype c_ctrl_type is std_logic_vector(c_ctrl_width -1 downto 0);
  --! Memory control type
  subtype mem_ctrl_type is std_logic_vector(mem_ctrl_width - 1 downto 0);
  --! B bus control type
  subtype b_ctrl_type is std_logic_vector(b_ctrl_width - 1 downto 0);
  --! Shifter control input
  subtype alu_sh_type is std_logic_vector(7 downto 6);
  --! ALU function field
  subtype alu_fn_type is std_logic_vector(5 downto 4);
  --! Control store address
  subtype ctrl_str_addr_type is std_logic_vector(ctrl_str_addr_width - 1 downto 0);
  --! Control store word
  subtype ctrl_str_word_type is std_logic_vector(ctrl_str_word_width - 1 downto 0);
  --! Control store word next address field
  subtype ctrl_nxt_addr_type is std_logic_vector(35 downto 27);
  --! Control store word next address field without MSB
  subtype ctrl_nxt_addr_no_msb_type is std_logic_vector(34 downto 27);
  --! Control store word ALU field
  subtype ctrl_alu is std_logic_vector(23 downto 16);
  --! Control store word C bus field
  subtype ctrl_c is std_logic_vector(15 downto 7);
  --! Control store word memory field
  subtype ctrl_mem is std_logic_vector(6 downto 4);
  --! Control store word B bus field
  subtype ctrl_b is std_logic_vector(3 downto 0);

  -- Types
  --! Control store content
  type ctrl_str_type is array (ctrl_str_words - 1 downto 0) of ctrl_str_word_type;

  -- Fields
  --! ALU control EN_A bit
  constant alu_ctrl_en_a     : natural := 3;
  --! ALU control EN_B bit
  constant alu_ctrl_en_b     : natural := 2;
  --! ALU control INV_A bit
  constant alu_ctrl_inv_a    : natural := 1;
  --! ALU control INV bit
  constant alu_ctrl_inc      : natural := 0;
  --! Control store word next address MSB
  constant ctrl_nxt_addr_msb : natural := 35;
  --! Control store word JMPC bit
  constant ctrl_jmpc         : natural := 26;
  --! Control store word JAMN bit
  constant ctrl_jamn         : natural := 25;
  --! Control store word JAMZ bit
  constant ctrl_jamz         : natural := 24;

  --! Constants
  --! ALU function logical AND
  constant alu_fn_and   : alu_fn_type := "00";
  --! ALU function logical OR
  constant alu_fn_or    : alu_fn_type := "01";
  --! ALU function logical NOT B
  constant alu_fn_not_b : alu_fn_type := "10";
  --! ALU function arithmetical sum
  constant alu_fn_sum   : alu_fn_type := "11";
  --! Shifter control shift left logical 8 bit
  constant alu_sh_sll8  : alu_sh_type := "10";
  --! Shifter control shift right arithmetical 1 bit
  constant alu_sh_sra1  : alu_sh_type := "01";
  --! Shifter control NOP
  constant alu_sh_nop   : alu_sh_type := "00";
  --! Shifter control invalid
  constant alu_sh_err   : alu_sh_type := "11";

end package common_defs;
