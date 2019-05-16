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
--! @file control_unit.vhd
--! @author Alberto Moriconi
--! @date 2019-05-11
--! @brief Processor control unit
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_defs.all;

--! Processor control unit

--! The control unit provides the control signals to the ALU based on the stored
--! microprogram.
--!
--! It receives the content of the MBR register and the N/Z ALU flags from the
--! datapath and produces control signals for ALU, C and B bus and memory
--! operations based on the addressed microinstruction format.
entity control_unit is
  port (
    --! Clock
    clk              : in  std_logic;
    --! Synchronous active-high reset
    reset            : in  std_logic;
    --! Content of the MBR register
    mbr_reg_in       : in  mbr_data_type;
    --! ALU negative flag
    alu_n_flag       : in  std_logic;
    --! ALU zero flag
    alu_z_flag       : in  std_logic;
    --! Control signals for the ALU
    alu_control      : out alu_ctrl_type;
    --! Control signals for the C bus
    c_to_reg_control : out c_ctrl_type;
    --! Control signals for memory operations
    mem_control      : out mem_ctrl_type;
    --! Control signals for the B bus
    reg_to_b_control : out b_ctrl_type
    );
end entity control_unit;

--! Behavioral architecture for the control unit
architecture behavioral of control_unit is

  -- Registers
  signal mpc_virtual_reg : ctrl_str_addr_type;
  signal mir_reg         : ctrl_str_word_type;
  signal n_ff            : std_logic;
  signal z_ff            : std_logic;

  -- Signals
  signal control_store_word   : ctrl_str_word_type;
  signal ctrl_nxt_addr_no_msb : mbr_data_type;
  signal jmpc_addr            : mbr_data_type;
  signal high_bit             : std_logic;
  signal reg_to_b_decoder_out : b_ctrl_type;

begin  -- architecture behavioral

  -- Control store instantiation
  control_store : entity work.control_store
    port map (
      address => mpc_virtual_reg,
      word    => control_store_word);

  -- Registers
  reg_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        mir_reg <= "000000001000000000000000000000001001";  -- Entry point may change in future versions
        n_ff    <= '0';
        z_ff    <= '0';
      else
        mir_reg <= control_store_word;
        n_ff    <= alu_n_flag;
        z_ff    <= alu_z_flag;
      end if;
    end if;
  end process reg_proc;

  -- MPC virtual register
  ctrl_nxt_addr_no_msb <= mir_reg(ctrl_nxt_addr_no_msb_type'range);
  jmpc_addr            <= ctrl_nxt_addr_no_msb or mbr_reg_in
               when mir_reg(ctrl_jmpc) = '1' else ctrl_nxt_addr_no_msb;
  high_bit        <= (alu_n_flag and mir_reg(ctrl_jamn)) or (alu_z_flag and mir_reg(ctrl_jamz));
  mpc_virtual_reg <= (mir_reg(ctrl_nxt_addr_msb) or high_bit) & jmpc_addr;

  -- B_BUS control decoder
  reg_to_b_decoder : process(mir_reg(ctrl_b'range)) is
  begin
    reg_to_b_decoder_out <= (others => '0');

    if unsigned(mir_reg(ctrl_b'range)) < b_ctrl_width then
      reg_to_b_decoder_out(to_integer(unsigned(mir_reg(ctrl_b'range)))) <= '1';
    end if;
  end process reg_to_b_decoder;

  -- Output to datapath
  alu_control      <= mir_reg(ctrl_alu'range);
  c_to_reg_control <= mir_reg(ctrl_c'range);
  mem_control      <= mir_reg(ctrl_mem'range);
  reg_to_b_control <= reg_to_b_decoder_out;

end architecture behavioral;
