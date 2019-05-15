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
--! @file control_unit_tb.vhd
--! @author Alberto Moriconi
--! @date 2019-05-15
--! @brief Testbench for the processor control unit
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common_defs.all;

--! Empty entity for the testbench
entity control_unit_tb is
end entity control_unit_tb;

architecture behavioral of control_unit_tb is

  -- Component ports
  signal reset            : std_logic;
  signal mbr_reg_in       : mbr_data_type;
  signal alu_n_flag       : std_logic;
  signal alu_z_flag       : std_logic;
  signal alu_control      : alu_ctrl_type;
  signal c_to_reg_control : c_ctrl_type;
  signal mem_control      : mem_ctrl_type;
  signal reg_to_b_control : b_ctrl_type;

  -- Clock
  signal clk : std_logic := '1';

  -- Variables
  shared variable end_run : boolean := false;

begin  -- architecture behavioral

  -- Component instantiation
  dut : entity work.control_unit
    port map (
      clk              => clk,
      reset            => reset,
      mbr_reg_in       => mbr_reg_in,
      alu_n_flag       => alu_n_flag,
      alu_z_flag       => alu_z_flag,
      alu_control      => alu_control,
      c_to_reg_control => c_to_reg_control,
      mem_control      => mem_control,
      reg_to_b_control => reg_to_b_control);

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
  wavegen_Proc: process
  begin
    wait until clk = '1';
    wait for 2 ns;

    -- This test depends on the content of the control store.
    -- It may fail if microprogram is modified.
    reset <= '1';
    wait for 10 ns;

    -- Program entry point
    reset <= '0';
    wait for 10 ns;
    assert alu_control = "00000000" report "Entry point - Bad ALU control" severity failure;
    assert c_to_reg_control = "000000000" report "Entry point - Bad C bus control" severity failure;
    assert mem_control = "000" report "Entry point - Bad memory control" severity failure;
    assert reg_to_b_control = "000000000" report "Entry point - Bad B bus control" severity failure;

    -- MIC-1 entry
    wait for 10 ns;
    assert alu_control = "00111100" report "mic1_entry - Bad ALU control" severity failure;
    assert c_to_reg_control = "000000001" report "mic1_entry - Bad C bus control" severity failure;
    assert mem_control = "010" report "mic1_entry - Bad memory control" severity failure;
    assert reg_to_b_control = "001000000" report "mic1_entry - Bad B bus control" severity failure;

    wait for 40 ns;
    assert alu_control = "10010100" report "mic1_entry + 4 - Bad ALU control" severity failure;
    assert c_to_reg_control = "100000000" report "mic1_entry + 4 - Bad C bus control" severity failure;
    assert mem_control = "000" report "mic1_entry + 4 - Bad memory control" severity failure;
    assert reg_to_b_control = "000001000" report "mic1_entry + 4 - Bad B bus control" severity failure;

    wait for 190 ns;
    assert alu_control = "00110101" report "main - Bad ALU control" severity failure;
    assert c_to_reg_control = "000000100" report "main - Bad C bus control" severity failure;
    assert mem_control = "001" report "main - Bad memory control" severity failure;
    assert reg_to_b_control = "000000010" report "main - Bad B bus control" severity failure;

    wait for 10 ns;
    mbr_reg_in <= x"9D"; -- Go to iflt
    assert alu_control = "00000000" report "nop - Bad ALU control" severity failure;
    assert c_to_reg_control = "000000000" report "nop - Bad C bus control" severity failure;
    assert mem_control = "000" report "nop - Bad memory control" severity failure;
    assert reg_to_b_control = "000000000" report "nop - Bad B bus control" severity failure;

    wait for 10 ns;
    assert alu_control = "00110101" report "main  - Bad ALU control" severity failure;
    assert c_to_reg_control = "000000100" report "main - Bad C bus control" severity failure;
    assert mem_control = "001" report "main - Bad memory control" severity failure;
    assert reg_to_b_control = "000000010" report "main - Bad B bus control" severity failure;

    wait for 40 ns;
    alu_n_flag <= '1';
    assert alu_control = "00010100" report "iflt + 1 - Bad ALU control" severity failure;
    assert c_to_reg_control = "000000000" report "iflt + 3 - Bad C bus control" severity failure;
    assert mem_control = "000" report "iflt + 3 - Bad memory control" severity failure;
    assert reg_to_b_control = "100000000" report "iflt + 3 - Bad B bus control" severity failure;

    wait for 10 ns;
    assert alu_control = "00110110" report "T - Bad ALU control" severity failure;
    assert c_to_reg_control = "010000000" report "T - Bad C bus control" severity failure;
    assert mem_control = "001" report "T - Bad memory control" severity failure;
    assert reg_to_b_control = "000000010" report "T - Bad B bus control" severity failure;

    end_run := true;
    wait;
  end process wavegen_Proc;

end architecture behavioral;
