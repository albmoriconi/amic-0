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
--! @file processor_tb.vhd
--! @author Alberto Moriconi
--! @date 2019-05-19
--! @brief Testbench for the processor
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common_defs.all;

--! Empty entity for the testbench
entity processor_tb is
end entity processor_tb;

--! Behavioral architecture for the testbench
architecture behavioral of processor_tb is

  -- Component ports
  signal reset          : std_logic;
  signal mem_data_we    : std_logic;
  signal mem_data_in    : reg_data_type;
  signal mem_data_out   : reg_data_type;
  signal mem_data_addr  : reg_data_type;
  signal mem_instr_in   : mbr_data_type;
  signal mem_instr_addr : reg_data_type;

  -- Clock
  signal clk : std_logic := '1';

  -- Variables
  shared variable end_run : boolean := false;

begin  -- architecture behavioral

  -- Component instantiation
  dut : entity work.processor
    port map (
      clk            => clk,
      reset          => reset,
      mem_data_we    => mem_data_we,
      mem_data_in    => mem_data_in,
      mem_data_out   => mem_data_out,
      mem_data_addr  => mem_data_addr,
      mem_instr_in   => mem_instr_in,
      mem_instr_addr => mem_instr_addr);

  dp_ar_ram : entity work.dp_ar_ram
    port map (
      clk        => clk,
      we_1       => mem_data_we,
      data_in_1  => mem_data_out,
      data_out_1 => mem_data_in,
      address_1  => mem_data_addr,
      we_2       => '0',
      data_in_2  => (others => '0'),
      data_out_2 => mem_instr_in,
      address_2  => mem_instr_addr);

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
    reset <= '0';

    wait until mem_instr_addr = x"0000000A" and mem_data_we = '1';
    assert mem_data_out = x"00000018" report "Bad calculated value" severity failure;

    wait until mem_instr_addr = x"0000000B";
    end_run := true;
    wait;
  end process wavegen_proc;

end architecture behavioral;
