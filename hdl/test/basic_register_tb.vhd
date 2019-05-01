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
--! @file basic_register_tb.vhd
--! @author Alberto Moriconi
--! @date 2019-05-01
--! @brief Testbench for the basic register
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Empty entity for the testbench
entity basic_register_tb is
end entity basic_register_tb;

architecture behavioral of basic_register_tb is

  -- Component ports
  signal reset    : std_logic;
  signal data_in  : std_logic_vector(31 downto 0);
  signal read_en  : std_logic;
  signal write_en : std_logic;
  signal data_out : std_logic_vector(31 downto 0);

  -- Clock
  signal clk : std_logic := '1';

  -- Constants
  constant high_impedance : std_logic_vector(31 downto 0) :=
    "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";

begin  -- architecture behavioral

  -- Component instantiation
  dut : entity work.basic_register
    port map (
      clk      => clk,
      reset    => reset,
      data_in  => data_in,
      read_en  => read_en,
      write_en => write_en,
      data_out => data_out);

  -- Clock generation
  clk <= not clk after 5 ns;

  -- Waveform generation
  wavegen_proc : process
  begin
    wait until clk = '1';
    wait for 2 ns;

    -- Reset
    reset    <= '1';
    data_in  <= (others => '0');
    write_en <= '0';
    read_en  <= '1';
    wait for 10 ns;
    assert data_out = x"00000000" report "Reset - Error" severity error;

    -- Write en = 1
    reset    <= '0';
    data_in  <= x"ABCDABCD";
    write_en <= '1';
    wait for 10 ns;
    assert data_out = x"ABCDABCD" report "Write en = 1 - Error" severity error;

    -- Write en = 0
    data_in  <= x"CAFECAFE";
    write_en <= '0';
    wait for 10 ns;
    assert data_out = x"ABCDABCD" report "Write en = 0 - Error" severity error;

    -- Read en = 0
    read_en <= '0';
    wait for 2 ns;
    assert data_out = high_impedance report "Read en = 0 - Error" severity error;

    wait;
  end process WaveGen_Proc;

end architecture behavioral;
