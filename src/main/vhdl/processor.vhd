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

--! The amic-0 processor

--! # Inputs
--!
--! The external clock is provided to datapath and control unit registers.
--! Reset is asynchronous, high low.
--!
--! # Bidirectional ports
--! The datapath has a 32 bit bidirectional port for memory data read/write
--! (including fetch).
--!
--! # Outputs
--! The datapath provides the memory address for memory operations.
entity processor is
  port (
    --! Clock
    clk         : in    std_logic;
    --! Asynchronous active-high reset
    reset       : in    std_logic;
    --! Bidirectional port for memory data read/write
    mem_data    : inout std_logic_vector(31 downto 0);
    --! Memory address for memory operations
    mem_address : out   std_logic_vector(31 downto 0)
    );
end entity processor;

-- Structural architecture for the processor
architecture structural of processor is

  -- Signals
  signal alu_control_t      : std_logic_vector(7 downto 0);
  signal c_to_reg_control_t : std_logic_vector(8 downto 0);
  signal reg_to_b_control_t : std_logic_vector(8 downto 0);
  signal mem_control_t      : std_logic_vector(2 downto 0);
  signal mbr_reg_out_t      : std_logic_vector(7 downto 0);
  signal alu_n_flag_t       : std_logic;
  signal alu_z_flag_t       : std_logic;

begin  -- architecture structural

  -- Control unit instantiation
  control_unit : entity work.control_unit
    port map (
      clk              => clk,
      reset            => reset,
      mbr_reg_out      => mbr_reg_out_t,
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
      mbr_reg_out      => mbr_reg_out_t,
      mem_data         => mem_data,
      mem_address      => mem_address,
      alu_n_flag       => alu_n_flag_t,
      alu_z_flag       => alu_z_flag_t);

end architecture structural;
