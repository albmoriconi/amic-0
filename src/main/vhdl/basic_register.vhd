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
--! @file basic_register.vhd
--! @author Alberto Moriconi
--! @date 2019-05-01
--! @brief Basic register for the processor register file
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Basic register for the processor register file

--! The register stores data on the data_in input on clock rising edge if
--! write_en is high.
--! Reset is asynchronous.
--! Output is register content if read_en is high, otherwise it's high impedance.
entity basic_register is
  port (
    --! Clock
    clk      : in  std_logic;
    --! Asyncrhonous active-high reset
    reset    : in  std_logic;
    --! Input to the register
    data_in  : in  std_logic_vector(31 downto 0);
    --! When high register output is connected, otherwise it's high impedance
    read_en  : in  std_logic;
    --! When high input is written on clock rising edge
    write_en : in  std_logic;
    --! Register output
    data_out : out std_logic_vector(31 downto 0)
    );
end entity basic_register;

--! Behavioral architecture for the basic register
architecture behavioral of basic_register is

  -- Signals
  signal reg_data : std_logic_vector(31 downto 0);

begin -- architecture behavioral

  register_process : process(clk, reset) is
  begin
    if reset = '1' then
      reg_data <= (others => '0');
    elsif rising_edge(clk) and write_en = '1' then
      reg_data <= data_in;
    end if;
  end process register_process;

  data_out <= reg_data when read_en = '1' else (others => 'Z');

end architecture behavioral;
