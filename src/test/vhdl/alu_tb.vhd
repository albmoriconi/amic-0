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

use work.common_defs.all;

--! Empty entity for the ALU testbench
entity alu_tb is
end entity alu_tb;

architecture behavioral of alu_tb is

  -- Component ports
  signal control       : alu_ctrl_type;
  signal operand_a     : reg_data_type;
  signal operand_b     : reg_data_type;
  signal sh_result     : reg_data_type;
  signal negative_flag : std_logic;
  signal zero_flag     : std_logic;

begin  -- architecture behavioral

  -- Component instantiation
  dut : entity work.alu
    port map (
      control       => control,
      operand_a     => operand_a,
      operand_b     => operand_b,
      sh_result     => sh_result,
      negative_flag => negative_flag,
      zero_flag     => zero_flag);

  -- Waveform generation
  wavegen_proc : process
  begin
    -- ALU test
    -- AND function
    control   <= "00001100";
    operand_a <= x"CAFECAFE";
    operand_b <= x"BAE07EE7";
    wait for 10 ns;
    assert sh_result = x"8AE04AE6" report "Logical AND - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Logical AND - Bad N flag" severity failure;
    assert zero_flag = '0' report "Logical AND - Bad Z flag" severity failure;

    -- OR function
    control <= "00011100";
    wait for 10 ns;
    assert sh_result = x"FAFEFEFF" report "Logical OR - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Logical OR - Bad N flag" severity failure;
    assert zero_flag = '0' report "Logical OR - Bad Z flag" severity failure;

    control <= "00011000";
    wait for 10 ns;
    assert sh_result = x"CAFECAFE" report "Operand A - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Operand A - Bad N flag" severity failure;
    assert zero_flag = '0' report "Operand A - Bad Z flag" severity failure;

    control <= "00010100";
    wait for 10 ns;
    assert sh_result = x"BAE07EE7" report "Operand B - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Operand B - Bad N flag" severity failure;
    assert zero_flag = '0' report "Operand B - Bad Z flag" severity failure;

    control <= "00011010";
    wait for 10 ns;
    assert sh_result = x"35013501" report "Logical NOT A - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Logical NOT A - Bad N flag" severity failure;
    assert zero_flag = '0' report "Logical NOT A - Bad Z flag" severity failure;

    -- NOT B function
    control <= "00101100";
    wait for 10 ns;
    assert sh_result = x"451F8118" report "Logical NOT B - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Logical NOT B - Bad N flag" severity failure;
    assert zero_flag = '0' report "Logical NOT B - Bad Z flag" severity failure;

    -- Sum function
    operand_a <= x"0AFECAFE";
    operand_b <= x"0AE07EE7";
    control   <= "00111100";
    wait for 10 ns;
    assert sh_result = x"15DF49E5" report "Arithmetic sum 1 - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Arithmetic sum 1 - Bad N flag" severity failure;
    assert zero_flag = '0' report "Arithmetic sum  1- Bad Z flag" severity failure;
    operand_a <= x"CAFECAFE";
    wait for 10 ns;
    assert sh_result = x"D5DF49E5" report "Arithmetic sum 2 - Bad sh_result" severity failure;
    assert negative_flag = '1' report "Arithmetic sum 2 - Bad N flag" severity failure;
    assert zero_flag = '0' report "Arithmetic sum 2 - Bad Z flag" severity failure;

    control <= "00111101";
    wait for 10 ns;
    assert sh_result = x"D5DF49E6" report "Arithmetic sum + 1 - Bad sh_result" severity failure;
    assert negative_flag = '1' report "Arithmetic sum + 1  - Bad N flag" severity failure;
    assert zero_flag = '0' report "Arithmetic sum + 1 - Bad Z flag" severity failure;

    control <= "00111001";
    wait for 10 ns;
    assert sh_result = x"CAFECAFF" report "Operand A + 1 - Bad sh_result" severity failure;
    assert negative_flag = '1' report "Operand A + 1 - Bad N flag" severity failure;
    assert zero_flag = '0' report "Operand A + 1 - Bad Z flag" severity failure;

    control <= "00110101";
    wait for 10 ns;
    assert sh_result = x"0AE07EE8" report "Operand B + 1 - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Operand B + 1 - Bad N flag" severity failure;
    assert zero_flag = '0' report "Operand B + 1 - Bad Z flag" severity failure;

    operand_a <= x"0AFECAFE";
    control   <= "00111111";
    wait for 10 ns;
    assert sh_result = x"FFE1B3E9" report "Aritmhetic difference 1 - Bad sh_result" severity failure;
    assert negative_flag = '1' report "Arithmetic difference 1 - Bad N flag" severity failure;
    assert zero_flag = '0' report "Arithmetic difference 1 - Bad Z flag" severity failure;
    operand_b <= x"0AFECAFE";
    wait for 10 ns;
    assert sh_result = x"00000000" report "Aritmhetic difference 2 - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Arithmetic difference 2 - Bad N flag" severity failure;
    assert zero_flag = '1' report "Arithmetic difference 2 - Bad Z flag" severity failure;
    operand_a <= x"0AE07EE7";
    wait for 10 ns;
    assert sh_result = x"001E4C17" report "Aritmhetic difference 3 - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Arithmetic difference 3 - Bad N flag" severity failure;
    assert zero_flag = '0' report "Arithmetic difference 3 - Bad Z flag" severity failure;

    control <= "00110110";
    wait for 10 ns;
    assert sh_result = x"0AFECAFD" report "Operand B - 1 - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Operand B - 1 - Bad N flag" severity failure;
    assert zero_flag = '0' report "Operand B - 1 - Bad Z flag" severity failure;

    -- Other
    control <= "00010000";
    wait for 10 ns;
    assert sh_result = x"00000000" report "Zero - Bad sh_result" severity failure;
    assert negative_flag = '0' report "Zero - Bad N flag" severity failure;
    assert zero_flag = '1' report "Zero - Bad Z flag" severity failure;

    control <= "00110001";
    wait for 10 ns;
    assert sh_result = x"00000001" report "One - Bad sh_result" severity failure;
    assert negative_flag = '0' report "One - Bad N flag" severity failure;
    assert zero_flag = '0' report "One - Bad Z flag" severity failure;

    control <= "00110010";
    wait for 10 ns;
    assert sh_result = x"FFFFFFFF" report "Negative one - Bad sh_result" severity failure;
    assert negative_flag = '1' report "Negative one - Bad N flag" severity failure;
    assert zero_flag = '0' report "Negative one - Bad Z flag" severity failure;

    -- Shifter test
    -- NO OP IN(31) = 0
    control <= "00011000";
    operand_a  <= x"7BCD7BCD";
    wait for 10 ns;
    assert sh_result = x"7BCD7BCD" report "No op in(31) = 0 - Bas sh_result" severity failure;

    -- SLL8 IN(31) = 0
    control <= "10011000";
    wait for 10 ns;
    assert sh_result = x"CD7BCD00" report "Shift left in(31) = 0 - Bad sh_result" severity failure;

    -- SRA1 IN(31) = 0
    control <= "01011000";
    wait for 10 ns;
    assert sh_result = x"3DE6BDE6" report "Shift right in(31) = 0 - Bad sh_result" severity failure;

    -- NO OP IN(31) = 1
    operand_a  <= x"ABCDABCD";
    control <= "00011000";
    wait for 10 ns;
    assert sh_result = x"ABCDABCD" report "No op in(31) = 1 - Bad sh_result" severity failure;

    -- SLL8 IN(31) = 1
    control <= "10011000";
    wait for 10 ns;
    assert sh_result = x"CDABCD00" report "Shift left in(31) = 1 - Bad sh_result" severity failure;

    -- SRA1 IN(31) = 1
    control <= "01011000";
    wait for 10 ns;
    assert sh_result = x"D5E6D5E6" report "Shift right in(31) = 1 - Bad sh_result" severity failure;

    wait;
  end process wavegen_proc;

end architecture behavioral;
