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

use work.common_defs.all;

--! Arithmetic logic unit based on MIC-1 ALU

--! The ALU operates on 2 operands (A, B); its operation is controlled by the 8
--! control bits:
--!
--! SLL8 | SRA1 | F_0 | F_1 | EN_A | EN_B | INV_A | INC
--!   ^                                              ^
--!  MSB                                            LSB
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
--! The zero flag (Z) is high when all bits of the result are 0; the negative
--! flag (N) is high when the operation is the arithmetical sum and the MSB of
--! the result is 1.
--!
--! When SLL8 is high, the result of the operation is shifted left 8 bits and
--! the 8 LSBs are zero filled; when SRA1 is high, the input is shifter right
--! 1 bit and the MSB is sign extended; when both bits are low, the input is
--! taken to the output unmodified; when both are high, the output is undefined.
--!
--! The shifted result goes to the output.
entity alu is
  port (
    --! ALU control
    control       : in  alu_ctrl_type;
    --! ALU operand A
    operand_a     : in  reg_data_type;
    --! ALU operand B
    operand_b     : in  reg_data_type;
    --! ALU result
    sh_result     : out reg_data_type;
    --! Negative flag
    negative_flag : out std_logic;
    --! Zero flag
    zero_flag     : out std_logic
    );
end entity alu;

--! Behavioral architecture for the ALU
architecture behavioral of alu is

  -- Alias
  alias sh    : alu_sh_type is control(alu_sh_type'range);
  alias fn    : alu_fn_type is control(alu_fn_type'range);
  alias en_a  : std_logic is control(alu_ctrl_en_a);
  alias en_b  : std_logic is control(alu_ctrl_en_b);
  alias inv_a : std_logic is control(alu_ctrl_inv_a);
  alias inc   : std_logic is control(alu_ctrl_inc);

  -- Signals
  signal t_operand_a     : reg_data_type;
  signal t_operand_a_inv : reg_data_type;
  signal t_operand_b     : reg_data_type;
  signal t_inc           : std_logic_vector(0 downto 0);
  signal t_u_sum         : unsigned(reg_data_type'range);
  signal t_and           : reg_data_type;
  signal t_or            : reg_data_type;
  signal t_not_b         : reg_data_type;
  signal t_sum           : reg_data_type;
  signal t_result        : reg_data_type;

begin  -- architecture behavioral

  -- Inputs
  t_operand_a     <= operand_a       when en_a = '1'  else (others => '0');
  t_operand_a_inv <= not t_operand_a when inv_a = '1' else t_operand_a;
  t_operand_b     <= operand_b       when en_b = '1'  else (others => '0');
  t_inc(0)        <= inc;
  t_u_sum         <= unsigned(t_operand_a_inv) + unsigned(t_operand_b) + unsigned(t_inc);

  -- ALU function
  t_and   <= t_operand_a_inv and t_operand_b when fn = alu_fn_and   else (others => '0');
  t_or    <= t_operand_a_inv or t_operand_b  when fn = alu_fn_or    else (others => '0');
  t_not_b <= not t_operand_b                 when fn = alu_fn_not_b else (others => '0');
  t_sum   <= reg_data_type(t_u_sum)          when fn = alu_fn_sum   else (others => '0');

  with fn select t_result <=
    t_and   when alu_fn_and,
    t_or    when alu_fn_or,
    t_not_b when alu_fn_not_b,
    t_sum   when others;

  -- ALU flags
  negative_flag <= t_sum(31);
  zero_flag     <= '1' when t_result = x"00000000" else '0';

  -- Shifter
  with sh select sh_result <=
    t_result(23 downto 0) & x"00"        when alu_sh_sll8,
    t_result(31) & t_result(31 downto 1) when alu_sh_sra1,
    t_result                             when others;

end architecture behavioral;
