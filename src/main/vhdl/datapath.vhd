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
--! @file datapath.vhd
--! @author Alberto Moriconi
--! @date 2019-05-01
--! @brief Processor datapath
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common_defs.all;

--! Processor datapath

--! # Inputs
--!
--! The datapath contains the ALU, the processor registers and the memory interface.
--!
--! It provides to the control unit the content of the MBR register and the N/Z
--! ALU flags, and receives control signals for ALU, C and B bus and memory.
--! It also produces the signals that operate the memory (addresses, data and enables).
entity datapath is
  port (
    --! Clock
    clk              : in  std_logic;
    --! Synchronous active-high reset
    reset            : in  std_logic;
    --! Control signals for the ALU
    alu_control      : in  alu_ctrl_type;
    --! Control signals for the C bus
    c_to_reg_control : in  c_ctrl_type;
    --! Control signals for memory operations
    mem_control      : in  mem_ctrl_type;
    --! Control signals for the B bus
    reg_to_b_control : in  b_ctrl_type;
    --! Content of the MBR register
    mbr_reg_out      : out mbr_data_type;
    --! ALU negative flag
    alu_n_flag       : out std_logic;
    --! ALU zero flag
    alu_z_flag       : out std_logic;
    --! Memory data write enable
    mem_data_we      : out std_logic;
    --! Port for memory data read
    mem_data_in      : in  reg_data_type;
    --! Port for memory data write
    mem_data_out     : out reg_data_type;
    --! Memory address for memory data operations
    mem_data_addr    : out reg_data_type;
    --! Port for memory instruction read
    mem_instr_in     : in  mbr_data_type;
    --! Memory address for memory instruction fetch
    mem_instr_addr   : out reg_data_type
    );
end entity datapath;

--! Structural architecture for the datapath
architecture behavioral of datapath is

  -- Registers
  signal sp_reg   : reg_data_type;
  signal lv_reg   : reg_data_type;
  signal cpp_reg  : reg_data_type;
  signal tos_reg  : reg_data_type;
  signal opc_reg  : reg_data_type;
  signal h_reg    : reg_data_type;
  signal mar_reg  : reg_data_type;
  signal mdr_reg  : reg_data_type;
  signal pc_reg   : reg_data_type;
  signal mbr_reg  : mbr_data_type;
  signal rd_ff    : std_logic;
  signal fetch_ff : std_logic;
  signal wr_ff    : std_logic;

  -- Signals
  signal a_bus : reg_data_type;
  signal b_bus : reg_data_type;
  signal c_bus : reg_data_type;

  signal mbr_u : reg_data_type;
  signal mbr_s : reg_data_type;

begin  -- architecture structural

  -- ALU instantiation
  alu : entity work.alu
    port map (
      control       => alu_control,
      operand_a     => a_bus,
      operand_b     => b_bus,
      sh_result     => c_bus,
      negative_flag => alu_n_flag,
      zero_flag     => alu_z_flag);

  -- Processor registers
  reg_proc : process(clk) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        sp_reg  <= x"00000101";
        lv_reg  <= x"00000100";
        cpp_reg <= x"00000080";
        tos_reg <= (others => '0');
        opc_reg <= (others => '0');
        h_reg   <= (others => '0');
        mar_reg <= (others => '0');
        mdr_reg <= (others => '0');
        pc_reg  <= (others => '0');
        mbr_reg <= (others => '0');

        rd_ff    <= '0';
        fetch_ff <= '0';
        wr_ff    <= '0';
      else
        if c_to_reg_control(c_ctrl_mar) = '1' then
          mar_reg <= c_bus;
        end if;
        if c_to_reg_control(c_ctrl_pc) = '1' then
          pc_reg <= c_bus;
        end if;
        if c_to_reg_control(c_ctrl_sp) = '1' then
          sp_reg <= c_bus;
        end if;
        if c_to_reg_control(c_ctrl_lv) = '1' then
          lv_reg <= c_bus;
        end if;
        if c_to_reg_control(c_ctrl_tos) = '1' then
          tos_reg <= c_bus;
        end if;
        if c_to_reg_control(c_ctrl_cpp) = '1' then
          cpp_reg <= c_bus;
        end if;
        if c_to_reg_control(c_ctrl_h) = '1' then
          h_reg <= c_bus;
        end if;
        if c_to_reg_control(c_ctrl_opc) = '1' then
          opc_reg <= c_bus;
        end if;

        -- MDR can also receive data from memory
        if c_to_reg_control(c_ctrl_mdr) = '1' then
          mdr_reg <= c_bus;
        elsif rd_ff = '1' then
          mdr_reg <= mem_data_in;
        end if;

        -- MBR can't be written from C bus
        if fetch_ff = '1' then
          mbr_reg <= mem_instr_in;
        end if;

        -- Effects on regs on next clock cycle
        rd_ff    <= mem_control(mem_ctrl_read);
        fetch_ff <= mem_control(mem_ctrl_fetch);
        wr_ff    <= mem_control(mem_ctrl_write);
      end if;
    end if;
  end process reg_proc;

  -- A bus is reserved for register H
  a_bus <= h_reg;

  -- B bus MUX
  mbr_u(mbr_s_ext'range)     <= (others => '0');
  mbr_u(mbr_data_type'range) <= mbr_reg;
  mbr_s(mbr_s_ext'range)     <= (others => mbr_reg(mbr_data_type'high));
  mbr_s(mbr_data_type'range) <= mbr_reg;

  with reg_to_b_control select b_bus <=
    mdr_reg         when b_ctrl_mdr,
    pc_reg          when b_ctrl_pc,
    mbr_s           when b_ctrl_mbr,
    mbr_u           when b_ctrl_mbru,
    sp_reg          when b_ctrl_sp,
    lv_reg          when b_ctrl_lv,
    cpp_reg         when b_ctrl_cpp,
    tos_reg         when b_ctrl_tos,
    opc_reg         when b_ctrl_opc,
    (others => '0') when others;

  -- Output
  mbr_reg_out    <= mbr_reg;
  mem_data_out   <= mdr_reg;
  mem_data_addr  <= mar_reg;
  mem_data_we    <= wr_ff;
  mem_instr_addr <= pc_reg;

end architecture behavioral;
