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
--! @file system.vhd
--! @author Alberto Moriconi
--! @date 2019-05-31
--! @brief A sample system based on amic-0
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common_defs.all;

--! A sample system based on amic-0

--! The system contains the processor, a RAM and a PWM generator
entity system is
  port (
    --! Clock
    clk   : in  std_logic;
    --! Synchronous active-high reset
    reset : in  std_logic;
    --! Memory data output
    pulse : out std_logic
    );
end entity system;

-- Structural architecture for the system
architecture structural of system is

  signal proc_data_we   : std_logic;
  signal proc_data_in   : reg_data_type;
  signal proc_data_out  : reg_data_type;
  signal proc_data_addr : reg_data_type;
  signal mem_data_we    : std_logic;
  signal mem_data_in    : reg_data_type;
  signal mem_data_out   : reg_data_type;
  signal mem_data_addr  : reg_data_type;
  signal mem_instr_in   : mbr_data_type;
  signal mem_instr_addr : reg_data_type;
  signal pwm_data_we    : std_logic;
  signal pwm_data_in    : reg_data_type;
  signal pwm_data_out   : reg_data_type;
  signal pwm_data_addr  : reg_data_type;

begin  -- architecture structural

  -- Processor instantiation
  processor : entity work.processor
    port map (
      clk            => clk,
      reset          => reset,
      mem_data_we    => proc_data_we,
      mem_data_in    => proc_data_in,
      mem_data_out   => proc_data_out,
      mem_data_addr  => proc_data_addr,
      mem_instr_in   => mem_instr_in,
      mem_instr_addr => mem_instr_addr);

  -- RAM instantiation
  dp_ar_ram : entity work.dp_ar_ram
    port map (
      clk        => clk,
      we_1       => mem_data_we,
      data_in_1  => mem_data_in,
      data_out_1 => mem_data_out,
      address_1  => mem_data_addr,
      we_2       => '0',
      data_in_2  => (others => '0'),
      data_out_2 => mem_instr_in,
      address_2  => mem_instr_addr);

  -- PWM instantiation
  pwm : entity work.pwm
    port map (
      clk      => clk,
      reset    => reset,
      regwrite => pwm_data_we,
      address  => pwm_data_addr(3 downto 0),
      data_in  => pwm_data_in,
      data_out => pwm_data_out,
      pulse    => pulse);

  -- Device MUX instantiation
  device_mux: entity work.device_mux
    port map (
      proc_data_we   => proc_data_we,
      proc_data_out  => proc_data_out,
      proc_data_addr => proc_data_addr,
      mem_data_out   => mem_data_out,
      pwm_data_out   => pwm_data_out,
      proc_data_in   => proc_data_in,
      mem_data_we    => mem_data_we,
      mem_data_in    => mem_data_in,
      mem_data_addr  => mem_data_addr,
      pwm_data_we    => pwm_data_we,
      pwm_data_in    => pwm_data_in,
      pwm_data_addr  => pwm_data_addr);
end architecture structural;
