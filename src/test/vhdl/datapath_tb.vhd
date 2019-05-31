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
--! @file datapath_tb.vhd
--! @author Alberto Moriconi
--! @date 2019-05-15
--! @brief Testbench for the processor datapath
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common_defs.all;

entity datapath_tb is
end entity datapath_tb;

architecture behavioral of datapath_tb is

  -- Component ports
  signal reset            : std_logic;
  signal alu_control      : alu_ctrl_type;
  signal c_to_reg_control : c_ctrl_type;
  signal mem_control      : mem_ctrl_type;
  signal reg_to_b_control : b_ctrl_type;
  signal mbr_reg_out      : mbr_data_type;
  signal alu_n_flag       : std_logic;
  signal alu_z_flag       : std_logic;
  signal mem_data_we      : std_logic;
  signal mem_data_in      : reg_data_type;
  signal mem_data_out     : reg_data_type;
  signal mem_data_addr    : reg_data_type;
  signal mem_instr_in     : mbr_data_type;
  signal mem_instr_addr   : reg_data_type;

  -- Clock
  signal clk : std_logic := '1';

  -- Variables
  shared variable end_run : boolean := false;

begin  -- architecture behavioral

  -- Component instantiation
  dut : entity work.datapath
    port map (
      clk              => clk,
      reset            => reset,
      alu_control      => alu_control,
      c_to_reg_control => c_to_reg_control,
      mem_control      => mem_control,
      reg_to_b_control => reg_to_b_control,
      mbr_reg_out      => mbr_reg_out,
      alu_n_flag       => alu_n_flag,
      alu_z_flag       => alu_z_flag,
      mem_data_we      => mem_data_we,
      mem_data_in      => mem_data_in,
      mem_data_out     => mem_data_out,
      mem_data_addr    => mem_data_addr,
      mem_instr_in     => mem_instr_in,
      mem_instr_addr   => mem_instr_addr);

  -- Clock generation
  clk_proc : process
  begin
    while end_run = false loop
      clk <= not clk;
      wait for 5 ns;
    end loop;

    wait;
  end process clk_proc;

  -- Waveform generation
  wavegen_proc: process
  begin
    wait until clk = '1';
    wait for 2 ns;

    reset <= '1';
    wait for 10 ns;

    -- Data read 1 + instruction fetch
    reset <= '0';
    mem_control <= "011";
    wait for 10 ns;

    -- Data read 2
    mem_control <= "010";
    mem_instr_in <= x"CA";
    mem_data_in <= x"0AFECAFE";
    wait for 10 ns;

    -- Take first operand from MDR to H
    mem_data_in <= x"0AE07EE7";
    mem_control <= "000";
    c_to_reg_control <= "100000000";
    reg_to_b_control <= "000000001";
    alu_control <= "00010100";
    wait for 10 ns;

    -- Take arithmetical sum to MAR and MDR
    mem_data_in <= x"00000000";
    c_to_reg_control <= "000000011";
    alu_control <= "00111100";
    wait for 10 ns;
    -- Check MAR and MDR out
    assert mem_data_out = x"15DF49E5" report "MDR out - Bad value" severity failure;
    assert mem_data_addr = x"15DF49E5" report "MAR out - Bad value" severity failure;

    -- Take MBR (sign extended) to PC
    c_to_reg_control <= "000000100";
    reg_to_b_control <= "000000100";
    alu_control <= "00010100";
    wait for 10 ns;
    -- Check PC out
    assert mem_instr_addr = x"FFFFFFCA" report "PC out - Bad value" severity failure;

    end_run := true;
    wait;
  end process wavegen_proc;

end architecture behavioral;
