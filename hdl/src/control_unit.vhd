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

--! Processor control unit

--! The control unit provides the control signals to the ALU based on the stored
--! microprogram.
--!
--! # Inputs
--! The external clock is provided to the MPC register; reset is asynchronous,
--! active high.
--!
--! The content of the MBR register and the N/Z ALU flags are provided from the
--! datapath.
--!
--! # Outputs
--! The control signals for ALU, C and B bus and memory operations are provided
--! to the datapath, based on the addressed microinstruction format.
entity control_unit is
  port (
    --! Clock
    clk              : in  std_logic;
    --! Asynchronous active-high reset
    reset            : in  std_logic;
    --! Content of the MBR register
    mbr_reg_out      : in  std_logic_vector(7 downto 0);
    --! ALU negative flag
    alu_n_flag       : in  std_logic;
    --! ALU zero flag
    alu_z_flag       : in  std_logic;
    --! Control signals for the ALU
    alu_control      : out std_logic_vector(7 downto 0);
    --! Control signals for the C bus
    c_to_reg_control : out std_logic_vector(8 downto 0);
    --! Control signals for memory operations
    mem_control      : out std_logic_vector(2 downto 0);
    --! Control signals for the B bus
    reg_to_b_control : out std_logic_vector(8 downto 0)
    );
end entity control_unit;

--! Behavioral architecture for the control unit
architecture behavioral of control_unit is

  -- Registers
  signal mpc_virtual_reg : std_logic_vector(8 downto 0);
  signal mir_reg         : std_logic_vector(35 downto 0);
  signal n_ff            : std_logic;
  signal z_ff            : std_logic;

  -- Signals
  signal control_store_word   : std_logic_vector(35 downto 0);
  signal jmpc_addr            : std_logic_vector(7 downto 0);
  signal high_bit             : std_logic;
  signal reg_to_b_decoder_out : std_logic_vector(8 downto 0);

begin  -- architecture behavioral

  -- Control store instantiation
  control_store : entity work.control_store
    port map (
      address => mpc_virtual_reg,
      word    => control_store_word);

  -- MIR register
  mir_reg_proc : process(clk, reset) is
  begin
    if reset = '1' then
      mir_reg <= (others => '0');
    elsif rising_edge(clk) then
      mir_reg <= control_store_word;
    end if;
  end process mir_reg_proc;

  -- N flag flip-flop
  n_ff_proc : process(clk, reset) is
  begin
    if reset = '1' then
      n_ff <= '0';
    elsif rising_edge(clk) then
      n_ff <= alu_n_flag;
    end if;
  end process n_ff_proc;

  -- Z flag flip-flop
  z_ff_proc : process(clk, reset) is
  begin
    if reset = '1' then
      z_ff <= '0';
    elsif rising_edge(clk) then
      z_ff <= alu_z_flag;
    end if;
  end process z_ff_proc;

  -- MPC virtual register
  jmpc_addr <= mir_reg(34 downto 27) or mbr_reg_out when mir_reg(26) = '1' else
               mir_reg(34 downto 27);
  high_bit        <= (alu_n_flag and mir_reg(25)) or (alu_z_flag and mir_reg(24));
  mpc_virtual_reg <= (mir_reg(35) or high_bit) & jmpc_addr;

  -- B_BUS control decoder
  reg_to_b_decoder : process(mir_reg(3 downto 0)) is
  begin
    reg_to_b_decoder_out                                            <= (others => '0');
    reg_to_b_decoder_out(to_integer(unsigned(mir_reg(3 downto 0)))) <= '1';
  end process reg_to_b_decoder;

  -- Output to datapath
  alu_control      <= mir_reg(23 downto 16);
  c_to_reg_control <= mir_reg(15 downto 7);
  mem_control      <= mir_reg(6 downto 4);
  reg_to_b_control <= reg_to_b_decoder_out;

end architecture behavioral;
