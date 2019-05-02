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
--! @file memory_interface.vhd
--! @author Alberto Moriconi
--! @date 2019-04-30
--! @brief Memory interface registers for the processor datapath
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Memory interface registers for the processor datapath

--! The memory interface comprises two separate sub-interfaces.
--! Both share the same clock and the asynchronous, active-high,  reset.
--!
--! # 32-bit data sub-interface
--!
--! The read and write operations are triggered by the mem_read and mem_write
--! control signals.
--! The memory is word-addressed by the 30 LSBs of MAR, multiplied by 4.
--! Data (32 bits) from/to memory is written to/from MDR.
--! Simultaneous reads/writes give undefined results.
--!
--! # 8-bit program sub-interface
--!
--! The sub-interface is read-only; read operation is triggered by the
--! mem_fetch control signal.
--! The memory is byte-addressed by PC.
--! Data (8 bits) from memory is written to MBR.
--! MBR contents can be accessed (via the B bus) in two ways: sign-extended or
--! 0-extended on 32 bits. The 8 bit content is always on the mbr_reg_out out,
--! regardless of other enables.
entity memory_interface is
  port (
    --! Clock
    clk             : in    std_logic;
    --! Asynchronous active-high reset
    reset           : in    std_logic;
    --! Data memory read trigger
    mem_read        : in    std_logic;
    --! Data memory write trigger
    mem_write       : in    std_logic;
    --! Program memory read trigger
    mem_fetch       : in    std_logic;
    --! Input to MAR register from C bus
    mar_data_in     : in    std_logic_vector(31 downto 0);
    --! Output from MAR register to memory
    mar_mem_out     : out   std_logic_vector(31 downto 0);
    --! Enable write to MAR register from C bus
    mar_write_en    : in    std_logic;
    --! Input to MDR register from C bus
    mdr_data_in     : in    std_logic_vector(31 downto 0);
    --! Input/output between MDR register and memory
    mdr_mem_inout   : inout std_logic_vector(31 downto 0);
    --! Output from MDR register to B bus
    mdr_data_out    : out   std_logic_vector(31 downto 0);
    --! Enable read from MAR register to B bus
    mdr_read_en     : in    std_logic;
    --! Enable write to MAR register from C bus
    mdr_write_en    : in    std_logic;
    --! Input to PC register from C bus
    pc_data_in      : in    std_logic_vector(31 downto 0);
    --! Output from PC register to B bus
    pc_data_out     : out   std_logic_vector(31 downto 0);
    --! Output from PC register to memory
    pc_mem_out      : out   std_logic_vector(31 downto 0);
    --! Enable read from MAR register to B bus
    pc_read_en      : in    std_logic;
    --! Enable write to MAR register from C bus
    pc_write_en     : in    std_logic;
    --! Input to MBR register from memory
    mbr_mem_in      : in    std_logic_vector(7 downto 0);
    --! Output from MBR register to outside the datapath
    mbr_reg_out     : out   std_logic_vector(7 downto 0);
    --! Output from MBR register to B bus (0-extended)
    mbr_8_data_out  : out   std_logic_vector(31 downto 0);
    --! Output from MBR register to B bus (sign-extended)
    mbr_32_data_out : out   std_logic_vector(31 downto 0);
    --! Enable read from MBR register to B bus (0-extended)
    mbr_8_read_en   : in    std_logic;
    --! Enable read from MBR register to B bus (sign-extended)
    mbr_32_read_en  : in    std_logic
    );
end entity memory_interface;

--! Behavioral architecture for the memory interface
architecture behavioral of memory_interface is

  -- Signals
  signal mar_data     : std_logic_vector(31 downto 0);
  signal mar_data_sl2 : std_logic_vector(31 downto 0);
  signal mdr_data     : std_logic_vector(31 downto 0);
  signal pc_data      : std_logic_vector(31 downto 0);
  signal mbr_data     : std_logic_vector(7 downto 0);
  signal mbr_8_t      : std_logic_vector(31 downto 0);
  signal mbr_32_t     : std_logic_vector(31 downto 0);

begin  -- architecture behavioral

  -- Process for MAR register
  mar_register : process(clk, reset)
  begin
    if reset = '1' then
      mar_data <= (others => '0');
    elsif rising_edge(clk) and mar_write_en = '1' then
      mar_data <= mar_data_in;
    end if;
  end process;

  -- Process for MDR register
  mdr_register : process(clk, reset)
  begin
    if reset = '1' then
      mdr_data <= (others => '0');
    elsif rising_edge(clk) then
      if mdr_write_en = '1' then
        mdr_data <= mdr_data_in;
      end if;
      if mem_read = '1' then
        mdr_data <= mdr_mem_inout;
      end if;
    end if;
  end process;

  -- Process for PC register
  pc_register : process(clk, reset)
  begin
    if reset = '1' then
      pc_data <= (others => '0');
    elsif rising_edge(clk) and pc_write_en = '1' then
      pc_data <= pc_data_in;
    end if;
  end process;

  -- Process for MBR register
  mbr_register : process(clk, reset)
  begin
    if reset = '1' then
      mbr_data <= (others => '0');
    elsif rising_edge(clk) and mem_fetch = '1' then
      mbr_data <= mbr_mem_in;
    end if;
  end process;

  mar_data_sl2 <= mar_data(29 downto 0) & "00";
  mar_mem_out  <= mar_data_sl2 when mem_read = '1' or mem_write = '1' else (others => 'Z');

  mdr_mem_inout <= mdr_data when mem_write = '1'   else (others => 'Z');
  mdr_data_out  <= mdr_data when mdr_read_en = '1' else (others => 'Z');

  pc_mem_out  <= pc_data when mem_fetch = '1'  else (others => 'Z');
  pc_data_out <= pc_data when pc_read_en = '1' else (others => 'Z');

  mbr_reg_out           <= mbr_data;
  mbr_8_t               <= x"000000" & mbr_data;
  mbr_32_t(7 downto 0)  <= mbr_data;
  mbr_32_t(31 downto 8) <= (others                                        => mbr_data(7));
  mbr_8_data_out        <= mbr_8_t  when mbr_8_read_en = '1' else (others => 'Z');
  mbr_32_data_out       <= mbr_32_t when mbr_8_read_en = '1' else (others => 'Z');

end architecture behavioral;
