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
--! @file datapath.vhd
--! @author Alberto Moriconi
--! @date 2019-05-01
--! @brief Processor datapath
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Processor datapath

--! # Inputs
--!
--! The external clock is provided to the internal registers (register file and
--! memory interface); reset is asynchronous, active high.
--!
--! The control signals for ALU, C and B bus and memory operations are provided
--! from the control unit; refer to the control_unit documentation for detailed
--! microinstruction breakdown.
--!
--! # Bidirectional ports
--!
--! The datapath has a 32 bit bidirectional port for memory data read/write
--! (including fetch).
--!
--! # Outputs
--!
--! The datapath provides the content of the MBR register and the N/Z ALU flags
--! to the control unit, the memory address to the outer world.
entity datapath is
  port (
    --! Clock
    clk              : in    std_logic;
    --! Asynchronous active-high reset
    reset            : in    std_logic;
    --! Control signals for the ALU
    alu_control      : in    std_logic_vector(7 downto 0);
    --! Control signals for the C bus
    c_to_reg_control : in    std_logic_vector(8 downto 0);
    --! Control signals for memory operations
    mem_control      : in    std_logic_vector(2 downto 0);
    --! Control signals for the B bus
    reg_to_b_control : in    std_logic_vector(8 downto 0);
    --! Content of the MBR register
    mbr_reg_out      : out   std_logic_vector(7 downto 0);
    --! Bidirectional port for memory data read/write
    mem_data         : inout std_logic_vector(31 downto 0);
    --! Memory address for memory operations
    mem_address      : out   std_logic_vector(31 downto 0);
    --! ALU negative flag
    alu_n_flag       : out   std_logic;
    --! ALU zero flag
    alu_z_flag       : out   std_logic
    );
end entity datapath;

--! Structural architecture for the datapath
architecture structural of datapath is

  -- Signals
  signal alu_to_shifter : std_logic_vector(31 downto 0);
  signal a_bus          : std_logic_vector(31 downto 0);
  signal b_bus          : std_logic_vector(31 downto 0);
  signal c_bus          : std_logic_vector(31 downto 0);

begin  -- architecture structural

  -- ALU instantiation
  alu : entity work.alu
    port map (
      control       => alu_control(5 downto 0),
      operand_a     => a_bus,
      operand_b     => b_bus,
      result        => alu_to_shifter,
      negative_flag => alu_n_flag,
      zero_flag     => alu_z_flag);

  -- Shifter instantiation
  shifter : entity work.shifter
    port map (
      shifter_in   => alu_to_shifter,
      shifter_ctrl => alu_control(7 downto 6),
      shifter_out  => c_bus);

  -- Memory interface instantiation
  memory_interface : entity work.memory_interface
    port map (
      clk             => clk,
      reset           => reset,
      mem_read        => mem_control(1),
      mem_write       => mem_control(2),
      mem_fetch       => mem_control(0),
      mar_data_in     => c_bus,
      mar_mem_out     => mem_address,
      mar_write_en    => c_to_reg_control(0),
      mdr_data_in     => c_bus,
      mdr_mem_inout   => mem_data,
      mdr_data_out    => b_bus,
      mdr_read_en     => reg_to_b_control(0),
      mdr_write_en    => c_to_reg_control(1),
      pc_data_in      => c_bus,
      pc_data_out     => b_bus,
      pc_mem_out      => mem_address,
      pc_read_en      => reg_to_b_control(1),
      pc_write_en     => c_to_reg_control(2),
      mbr_mem_in      => mem_data(7 downto 0),
      mbr_reg_out     => mbr_reg_out,
      mbr_8_data_out  => b_bus,
      mbr_32_data_out => b_bus,
      mbr_8_read_en   => reg_to_b_control(3),
      mbr_32_read_en  => reg_to_b_control(2));

  -- Register file instantiation
  gen_reg : for i in 0 to 4 generate
    register_i : entity work.basic_register
      port map (
        clk      => clk,
        reset    => reset,
        data_in  => c_bus,
        read_en  => reg_to_b_control(i + 4),
        write_en => c_to_reg_control(i + 3),
        data_out => b_bus);
  end generate gen_reg;

  -- H register instantiation
  register_h : entity work.basic_register
    port map (
      clk      => clk,
      reset    => reset,
      data_in  => c_bus,
      read_en  => '1',
      write_en => c_to_reg_control(8),
      data_out => a_bus);

end architecture structural;
