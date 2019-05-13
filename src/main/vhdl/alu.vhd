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
--! @file alu.vhd
--! @author Alberto Moriconi
--! @date 2019-04-26
--! @brief Arithmetic logic unit based on MIC-1 ALU
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Arithmetic logic unit based on MIC-1 ALU

--! # Inputs
--!
--! The ALU operates on 2 operands (A, B); its operation is controlled by the 6
--! control bits:
--!
--! F_0 | F_1 | EN_A | EN_B | INV_A | INC
--!  ^                                 ^
--! MSB                               LSB
--!
--! The arithmetical/logical operation is selected by the 2 MSBs (F_0, F_1):
--!
--!  - 00 : Logical AND (A AND B)
--!  - 01 : Logical OR (A OR B)
--!  - 10 : Logical negation (NOT B)
--!  - 11 : Arithmetical sum (A + B)
--!
--! The ALU also provides separate enables for A and B and an invert signal for
--! A. The INC bit is used only by the arithmetical sum and has the effect of
--! adding an LSB to the sum.
--!
--! # Outputs
--!
--! The ALU result is selected by the (F_0, F_1) bits; the zero flag (Z) is
--! high when all bits of the result are 0; the negative flag (N) is high when
--! the operation is the arithmetical sum and the MSB of the result is 1.
entity alu is
  port (
    --! ALU control
    control       : in  std_logic_vector(5 downto 0);
    --! ALU operand A
    operand_a     : in  std_logic_vector(31 downto 0);
    --! ALU operand B
    operand_b     : in  std_logic_vector(31 downto 0);
    --! ALU result
    result        : out std_logic_vector(31 downto 0);
    --! Negative flag
    negative_flag : out std_logic;
    --! Zero flag
    zero_flag     : out std_logic
    );
end entity alu;

--! Behavioral architecture for the ALU
architecture behavioral of alu is

  -- Subtypes
  subtype alu_data_type is std_logic_vector(31 downto 0);
  subtype alu_function_type is std_logic_vector(1 downto 0);

  -- Aliases
  alias f     : alu_function_type is control(5 downto 4);
  alias en_a  : std_logic is control(3);
  alias en_b  : std_logic is control(2);
  alias inv_a : std_logic is control(1);
  alias inc   : std_logic is control(0);

  -- Constants
  constant f_and   : alu_function_type := "00";
  constant f_or    : alu_function_type := "01";
  constant f_not_b : alu_function_type := "10";
  constant f_sum   : alu_function_type := "11";

  -- Signals
  signal t_operand_a     : alu_data_type;
  signal t_operand_a_inv : alu_data_type;
  signal t_operand_b     : alu_data_type;
  signal t_and           : alu_data_type;
  signal t_or            : alu_data_type;
  signal t_not_b         : alu_data_type;
  signal t_sum           : alu_data_type;
  signal t_result        : alu_data_type;
  signal t_inc           : std_logic_vector(0 downto 0);

begin  -- architecture behavioral

  t_operand_a     <= operand_a       when en_a = '1'  else (others => '0');
  t_operand_a_inv <= not t_operand_a when inv_a = '1' else t_operand_a;
  t_operand_b     <= operand_b       when en_b = '1'  else (others => '0');
  t_inc(0)        <= inc;

  t_and   <= t_operand_a_inv and t_operand_b when f = f_and   else (others => '0');
  t_or    <= t_operand_a_inv or t_operand_b  when f = f_or    else (others => '0');
  t_not_b <= not t_operand_b                 when f = f_not_b else (others => '0');
  t_sum   <= std_logic_vector(unsigned(t_operand_a_inv) + unsigned(t_operand_b) + unsigned(t_inc))
           when f = f_sum else (others => '0');

  with f select t_result <=
    t_and   when f_and,
    t_or    when f_or,
    t_not_b when f_not_b,
    t_sum   when others;

  result        <= t_result;
  negative_flag <= t_sum(31);
  zero_flag     <= '1' when t_result = x"00000000" else '0';

end architecture behavioral;
