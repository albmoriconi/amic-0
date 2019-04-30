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
--! @file shifter_tb.vhd
--! @author Alberto Moriconi
--! @date 2019-04-30
--! @brief Testbench for the shifter unit
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Empty entity for the shifter testbench
entity shifter_tb is
end entity shifter_tb;

architecture behavioral of shifter_tb is

  -- Component ports
  signal shifter_in   : std_logic_vector(31 downto 0);
  signal shifter_ctrl : std_logic_vector(1 downto 0);
  signal shifter_out  : std_logic_vector(31 downto 0);

begin  -- architecture behavioral

  -- Component instantiation
  dut : entity work.shifter
    port map (
      shifter_in   => shifter_in,
      shifter_ctrl => shifter_ctrl,
      shifter_out  => shifter_out);

  -- Waveform generation
  wavegen_proc : process
  begin
    -- NO OP IN(31) = 0
    shifter_in   <= x"7BCD7BCD";
    shifter_ctrl <= "00";
    wait for 10 ns;
    assert shifter_out = x"7BCD7BCD" report "No op in(31) = 0 - Error" severity error;

    -- SLL8 IN(31) = 0
    shifter_ctrl <= "10";
    wait for 10 ns;
    assert shifter_out = x"CD7BCD00" report "Shift left in(31) = 0 - Error" severity error;

    -- SRA1 IN(31) = 0
    shifter_ctrl <= "01";
    wait for 10 ns;
    assert shifter_out = x"3DE6BDE6" report "Shift right in(31) = 0 - Error" severity error;

    -- NO OP IN(31) = 1
    shifter_in   <= x"ABCDABCD";
    shifter_ctrl <= "00";
    wait for 10 ns;
    assert shifter_out = x"ABCDABCD" report "No op in(31) = 1 - Error" severity error;

    -- SLL8 IN(31) = 1
    shifter_ctrl <= "10";
    wait for 10 ns;
    assert shifter_out = x"CDABCD00" report "Shift left in(31) = 1 - Error" severity error;

    -- SRA1 IN(31) = 1
    shifter_ctrl <= "01";
    wait for 10 ns;
    assert shifter_out = x"D5E6D5E6" report "Shift right in(31) = 1 - Error" severity error;

    wait;
  end process WaveGen_Proc;

end architecture behavioral;
