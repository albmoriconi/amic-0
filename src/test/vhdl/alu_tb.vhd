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
--! @file alu_tb.vhd
--! @author Alberto Moriconi
--! @date 2019-04-27
--! @brief Testbench for the arithmetic logic unit
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Empty entity for the ALU testbench
entity alu_tb is
end entity alu_tb;


architecture behavioral of alu_tb is

  -- Component ports
  signal control       : std_logic_vector(5 downto 0);
  signal operand_a     : std_logic_vector(31 downto 0);
  signal operand_b     : std_logic_vector(31 downto 0);
  signal result        : std_logic_vector(31 downto 0);
  signal negative_flag : std_logic;
  signal zero_flag     : std_logic;

begin  -- architecture behavioral

  -- Component instantiation
  dut : entity work.alu
    port map (
      control       => control,
      operand_a     => operand_a,
      operand_b     => operand_b,
      result        => result,
      negative_flag => negative_flag,
      zero_flag     => zero_flag
      );

  -- Waveform generation
  wavegen_proc : process
  begin
    -- AND
    control   <= "001100";
    operand_a <= x"CAFECAFE";
    operand_b <= x"BAE07EE7";
    wait for 10 ns;
    assert result = x"8AE04AE6" report "Logical and - Bad result" severity error;
    assert negative_flag = '0' report "Logical and - Bad N flag" severity error;
    assert zero_flag = '0' report "Logical and - Bad Z flag" severity error;

    -- OR
    control <= "011100";
    wait for 10 ns;
    assert result = x"FAFEFEFF" report "Logical or - Bad result" severity error;
    assert negative_flag = '0' report "Logical or - Bad N flag" severity error;
    assert zero_flag = '0' report "Logical or - Bad Z flag" severity error;

    control <= "011000";
    wait for 10 ns;
    assert result = x"CAFECAFE" report "Operand A - Bad result" severity error;
    assert negative_flag = '0' report "Operand A - Bad N flag" severity error;
    assert zero_flag = '0' report "Operand A - Bad Z flag" severity error;

    control <= "010100";
    wait for 10 ns;
    assert result = x"BAE07EE7" report "Operand B - Bad result" severity error;
    assert negative_flag = '0' report "Operand B - Bad N flag" severity error;
    assert zero_flag = '0' report "Operand B - Bad Z flag" severity error;

    control <= "011010";
    wait for 10 ns;
    assert result = x"35013501" report "Logical not A - Bad result" severity error;
    assert negative_flag = '0' report "Logical not A - Bad N flag" severity error;
    assert zero_flag = '0' report "Logical not A - Bad Z flag" severity error;

    -- NOT B
    control <= "101100";
    wait for 10 ns;
    assert result = x"451F8118" report "Logical not B - Bad result" severity error;
    assert negative_flag = '0' report "Logical not B - Bad N flag" severity error;
    assert zero_flag = '0' report "Logical not B - Bad Z flag" severity error;

    -- SUM
    operand_a <= x"0AFECAFE";
    operand_b <= x"0AE07EE7";
    control   <= "111100";
    wait for 10 ns;
    assert result = x"15DF49E5" report "Arithmetic sum 1 - Bad result" severity error;
    assert negative_flag = '0' report "Arithmetic sum 1 - Bad N flag" severity error;
    assert zero_flag = '0' report "Arithmetic sum  1- Bad Z flag" severity error;
    operand_a <= x"CAFECAFE";
    wait for 10 ns;
    assert result = x"D5DF49E5" report "Arithmetic sum 2 - Bad result" severity error;
    assert negative_flag = '1' report "Arithmetic sum 2 - Bad N flag" severity error;
    assert zero_flag = '0' report "Arithmetic sum 2 - Bad Z flag" severity error;

    control <= "111101";
    wait for 10 ns;
    assert result = x"D5DF49E6" report "Arithmetic sum + 1 - Bad result" severity error;
    assert negative_flag = '1' report "Arithmetic sum + 1  - Bad N flag" severity error;
    assert zero_flag = '0' report "Arithmetic sum + 1 - Bad Z flag" severity error;

    control <= "111001";
    wait for 10 ns;
    assert result = x"CAFECAFF" report "Operand A + 1 - Bad result" severity error;
    assert negative_flag = '1' report "Operand A + 1 - Bad N flag" severity error;
    assert zero_flag = '0' report "Operand A + 1 - Bad Z flag" severity error;

    control <= "110101";
    wait for 10 ns;
    assert result = x"0AE07EE8" report "Operand B + 1 - Bad result" severity error;
    assert negative_flag = '0' report "Operand B + 1 - Bad N flag" severity error;
    assert zero_flag = '0' report "Operand B + 1 - Bad Z flag" severity error;

    operand_a <= x"0AFECAFE";
    control   <= "111111";
    wait for 10 ns;
    assert result = x"FFE1B3E9" report "Aritmhetic difference 1 - Bad result" severity error;
    assert negative_flag = '1' report "Arithmetic difference 1 - Bad N flag" severity error;
    assert zero_flag = '0' report "Arithmetic difference 1 - Bad Z flag" severity error;
    operand_b <= x"0AFECAFE";
    wait for 10 ns;
    assert result = x"00000000" report "Aritmhetic difference 2 - Bad result" severity error;
    assert negative_flag = '0' report "Arithmetic difference 2 - Bad N flag" severity error;
    assert zero_flag = '1' report "Arithmetic difference 2 - Bad Z flag" severity error;
    operand_a <= x"0AE07EE7";
    wait for 10 ns;
    assert result = x"001E4C17" report "Aritmhetic difference 3 - Bad result" severity error;
    assert negative_flag = '0' report "Arithmetic difference 3 - Bad N flag" severity error;
    assert zero_flag = '0' report "Arithmetic difference 3 - Bad Z flag" severity error;


    control <= "110110";
    wait for 10 ns;
    assert result = x"0AFECAFD" report "Operand B - 1 - Bad result" severity error;
    assert negative_flag = '0' report "Operand B - 1 - Bad N flag" severity error;
    assert zero_flag = '0' report "Operand B - 1 - Bad Z flag" severity error;

    -- Other
    control <= "010000";
    wait for 10 ns;
    assert result = x"00000000" report "Zero - Bad result" severity error;
    assert negative_flag = '0' report "Zero - Bad N flag" severity error;
    assert zero_flag = '1' report "Zero - Bad Z flag" severity error;

    control <= "110001";
    wait for 10 ns;
    assert result = x"00000001" report "One - Bad result" severity error;
    assert negative_flag = '0' report "One - Bad N flag" severity error;
    assert zero_flag = '0' report "One - Bad Z flag" severity error;

    control <= "110010";
    wait for 10 ns;
    assert result = x"FFFFFFFF" report "Negative one - Bad result" severity error;
    assert negative_flag = '1' report "Negative one - Bad N flag" severity error;
    assert zero_flag = '0' report "Negative one - Bad Z flag" severity error;

    wait;
  end process wavegen_proc;

end architecture behavioral;
