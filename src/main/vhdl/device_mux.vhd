--------------------------------------------------------------------------------
-- Device multiplexer for amic-0 system
-- Alberto Moriconi
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common_defs.all;

entity device_mux is
  port (
    proc_data_we   : in  std_logic;
    proc_data_out  : in  reg_data_type;
    proc_data_addr : in  reg_data_type;
    mem_data_out   : in  reg_data_type;
    pwm_data_out   : in  reg_data_type;
    proc_data_in   : out reg_data_type;
    mem_data_we    : out std_logic;
    mem_data_in    : out reg_data_type;
    mem_data_addr  : out reg_data_type;
    pwm_data_we    : out std_logic;
    pwm_data_in    : out reg_data_type;
    pwm_data_addr  : out reg_data_type
    );
end entity device_mux;

architecture dataflow of device_mux is

begin

  -- Device multiplexing
  with proc_data_addr(9) select mem_data_we <=
    proc_data_we when '0',
    '0'          when others;

  with proc_data_addr(9) select mem_data_in <=
    proc_data_out   when '0',
    (others => '0') when others;

  with proc_data_addr(9) select mem_data_addr <=
    proc_data_addr  when '0',
    (others => '0') when others;

  with proc_data_addr(9) select pwm_data_we <=
    proc_data_we when '1',
    '0'          when others;

  with proc_data_addr(9) select pwm_data_in <=
    proc_data_out   when '1',
    (others => '0') when others;

  with proc_data_addr(9) select pwm_data_addr <=
    proc_data_addr  when '1',
    (others => '0') when others;

  with proc_data_addr(9) select proc_data_in <=
    mem_data_out when '0',
    pwm_data_out when others;

end architecture dataflow;
