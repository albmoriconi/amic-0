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
--! @file memory_interface_tb.vhd
--! @author Alberto Moriconi
--! @date 2019-05-01
--! @brief Testbench for the memory interface
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Empty entity for the testbench
entity memory_interface_tb is
end entity memory_interface_tb;

architecture behavioral of memory_interface_tb is

  -- Constants
  constant high_impedance : std_logic_vector(31 downto 0) :=
    "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";


  -- Clock
  signal clk : std_logic := '1';

  -- Component ports
  signal reset           : std_logic;
  signal mem_read        : std_logic;
  signal mem_write       : std_logic;
  signal mem_fetch       : std_logic;
  signal mar_data_in     : std_logic_vector(31 downto 0);
  signal mar_mem_out     : std_logic_vector(31 downto 0);
  signal mar_write_en    : std_logic;
  signal mdr_data_in     : std_logic_vector(31 downto 0);
  signal mdr_mem_inout   : std_logic_vector(31 downto 0);
  signal mdr_data_out    : std_logic_vector(31 downto 0);
  signal mdr_read_en     : std_logic;
  signal mdr_write_en    : std_logic;
  signal pc_data_in      : std_logic_vector(31 downto 0);
  signal pc_data_out     : std_logic_vector(31 downto 0);
  signal pc_mem_out      : std_logic_vector(31 downto 0);
  signal pc_read_en      : std_logic;
  signal pc_write_en     : std_logic;
  signal mbr_mem_in      : std_logic_vector(7 downto 0);
  signal mbr_8_data_out  : std_logic_vector(31 downto 0);
  signal mbr_32_data_out : std_logic_vector(31 downto 0);
  signal mbr_8_read_en   : std_logic;
  signal mbr_32_read_en  : std_logic;

begin  -- architecture behavioral

  -- Component instantiation
  dut : entity work.memory_interface
    port map (
      clk             => clk,
      reset           => reset,
      mem_read        => mem_read,
      mem_write       => mem_write,
      mem_fetch       => mem_fetch,
      mar_data_in     => mar_data_in,
      mar_mem_out     => mar_mem_out,
      mar_write_en    => mar_write_en,
      mdr_data_in     => mdr_data_in,
      mdr_mem_inout   => mdr_mem_inout,
      mdr_data_out    => mdr_data_out,
      mdr_read_en     => mdr_read_en,
      mdr_write_en    => mdr_write_en,
      pc_data_in      => pc_data_in,
      pc_data_out     => pc_data_out,
      pc_mem_out      => pc_mem_out,
      pc_read_en      => pc_read_en,
      pc_write_en     => pc_write_en,
      mbr_mem_in      => mbr_mem_in,
      mbr_8_data_out  => mbr_8_data_out,
      mbr_32_data_out => mbr_32_data_out,
      mbr_8_read_en   => mbr_8_read_en,
      mbr_32_read_en  => mbr_32_read_en);

  -- Clock generation
  clk <= not clk after 5 ns;

  -- Waveform generation
  wavegen_proc : process
  begin
    wait until clk = '1';
    wait for 2 ns;

    -- Reset
    reset          <= '1';
    mem_read       <= '0';
    mem_write      <= '0';
    mem_fetch      <= '0';
    mar_data_in    <= high_impedance;
    mar_write_en   <= '0';
    mdr_data_in    <= high_impedance;
    mdr_mem_inout  <= high_impedance;
    mdr_read_en    <= '0';
    mdr_write_en   <= '0';
    pc_data_in     <= high_impedance;
    pc_read_en     <= '0';
    pc_write_en    <= '0';
    mbr_mem_in     <= "ZZZZZZZZ";
    mbr_8_read_en  <= '0';
    mbr_32_read_en <= '0';
    wait for 10 ns;

    reset <= '0';
    wait for 10 ns;
    assert mar_mem_out = high_impedance report "Reset - mar_mem_out error" severity error;
    assert mdr_data_out = high_impedance report "Reset - mdr_data_out error" severity error;
    assert pc_data_out = high_impedance report "Reset - pc_data_out error" severity error;
    assert pc_mem_out = high_impedance report "Reset - pc_mem_out error" severity error;
    assert mbr_8_data_out = high_impedance report "Reset - mbr_8_data_out error" severity error;
    assert mbr_32_data_out = high_impedance report "Reset - mbr_32_data_out error" severity error;

    -- Read operation
    mdr_mem_inout <= x"CAFECAFE";
    mar_data_in   <= x"ABCDABCD";
    mar_write_en  <= '1';
    mdr_read_en   <= '1';
    mem_read      <= '1';
    wait for 10 ns;
    assert mar_mem_out = x"ABCDABCD" report "Read - mar_mem_out error" severity error;
    assert mdr_data_out = x"CAFECAFE" report "Reset - mdr_data_out error" severity error;
    assert pc_data_out = high_impedance report "Reset - pc_data_out error" severity error;
    assert pc_mem_out = high_impedance report "Reset - pc_mem_out error" severity error;
    assert mbr_8_data_out = high_impedance report "Reset - mbr_8_data_out error" severity error;
    assert mbr_32_data_out = high_impedance report "Reset - mbr_32_data_out error" severity error;

    -- Read cleanup
    mdr_mem_inout <= high_impedance;
    mar_data_in   <= high_impedance;
    mar_write_en  <= '0';
    mdr_read_en   <= '0';
    mem_read      <= '0';

    -- Write operation
    mdr_data_in  <= x"BAD4BAD4";
    mdr_write_en <= '1';
    mem_write    <= '1';
    wait for 10 ns;
    assert mar_mem_out = x"ABCDABCD" report "Write - mar_mem_out error" severity error;
    assert mdr_data_out = high_impedance report "Write - mdr_data_out error" severity error;
    assert mdr_mem_inout = x"BAD4BAD4" report "Write - mdr_mem_inout error" severity error;
    assert pc_data_out = high_impedance report "Write - pc_data_out error" severity error;
    assert pc_mem_out = high_impedance report "Write - pc_mem_out error" severity error;
    assert mbr_8_data_out = high_impedance report "Write - mbr_8_data_out error" severity error;
    assert mbr_32_data_out = high_impedance report "Write - mbr_32_data_out error" severity error;

    -- Write cleanup
    mdr_data_in  <= high_impedance;
    mdr_write_en <= '0';
    mem_write    <= '0';

    -- Fetch operation
    pc_data_in     <= x"12345678";
    pc_write_en    <= '1';
    mbr_mem_in     <= x"A4";
    mbr_8_read_en  <= '1';
    mbr_32_read_en <= '1';
    mem_fetch      <= '1';
    wait for 10 ns;
    assert mar_mem_out = high_impedance report "Fetch - mar_mem_out error" severity error;
    assert mdr_data_out = high_impedance report "Fetch - mdr_data_out error" severity error;
    assert pc_data_out = high_impedance report "Fetch - pc_data_out error" severity error;
    assert pc_mem_out = x"12345678" report "Fetch - pc_mem_out error" severity error;
    assert mbr_8_data_out = x"000000A4" report "Fetch - mbr_8_data_out error" severity error;
    assert mbr_32_data_out = x"FFFFFFA4" report "Fetch - mbr_32_data_out error" severity error;

    -- Fetch cleanup
    pc_data_in     <= high_impedance;
    pc_write_en    <= '0';
    mbr_mem_in     <= "ZZZZZZZZ";
    mbr_8_read_en  <= '0';
    mbr_32_read_en <= '0';
    mem_fetch      <= '0';

    wait;
  end process WaveGen_Proc;

end architecture behavioral;
