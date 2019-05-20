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
--! @file processor.vhd
--! @author Alberto Moriconi
--! @date 2019-05-11
--! @brief The amic-0 processor
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common_defs.all;

--! The amic-0 processor

--! The processor exposes the memory interface defined in the datapath.
entity processor is
  port (
    --! Clock
    clk            : in  std_logic;
    --! Synchronous active-high reset
    reset          : in  std_logic;
    --! Memory data write enable
    mem_data_we    : out std_logic;
    --! Port for memory data read
    mem_data_in    : in  reg_data_type;
    --! Port for memory data write
    mem_data_out   : out reg_data_type;
    --! Memory address for memory data operations
    mem_data_addr  : out reg_data_type;
    --! Port for memory instruction read
    mem_instr_in   : in  mbr_data_type;
    --! Memory address for memory instruction fetch
    mem_instr_addr : out reg_data_type
    );
end entity processor;

-- Structural architecture for the processor
architecture structural of processor is

  -- Signals
  signal alu_control_t      : alu_ctrl_type;
  signal c_to_reg_control_t : c_ctrl_type;
  signal reg_to_b_control_t : b_ctrl_type;
  signal mem_control_t      : mem_ctrl_type;
  signal mbr_reg_t          : mbr_data_type;
  signal alu_n_flag_t       : std_logic;
  signal alu_z_flag_t       : std_logic;

begin  -- architecture structural

  -- Control unit instantiation
  control_unit : entity work.control_unit
    port map (
      clk              => clk,
      reset            => reset,
      mbr_reg_in       => mbr_reg_t,
      alu_n_flag       => alu_n_flag_t,
      alu_z_flag       => alu_z_flag_t,
      alu_control      => alu_control_t,
      c_to_reg_control => c_to_reg_control_t,
      mem_control      => mem_control_t,
      reg_to_b_control => reg_to_b_control_t);

  -- Datapath instantiation
  datapath : entity work.datapath
    port map (
      clk              => clk,
      reset            => reset,
      alu_control      => alu_control_t,
      c_to_reg_control => c_to_reg_control_t,
      mem_control      => mem_control_t,
      reg_to_b_control => reg_to_b_control_t,
      mbr_reg_out      => mbr_reg_t,
      alu_n_flag       => alu_n_flag_t,
      alu_z_flag       => alu_z_flag_t,
      mem_data_we      => mem_data_we,
      mem_data_in      => mem_data_in,
      mem_data_out     => mem_data_out,
      mem_data_addr    => mem_data_addr,
      mem_instr_in     => mem_instr_in,
      mem_instr_addr   => mem_instr_addr);

end architecture structural;
