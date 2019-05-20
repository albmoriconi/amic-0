library ieee;
use ieee.std_logic_1164.all;

use work.common_defs.all;

-------------------------------------------------------------------------------

entity processor_tb is

end entity processor_tb;

-------------------------------------------------------------------------------

architecture behavioral of processor_tb is

  -- component ports
  signal reset          : std_logic;
  signal mem_data_we    : std_logic;
  signal mem_data_in    : reg_data_type;
  signal mem_data_out   : reg_data_type;
  signal mem_data_addr  : reg_data_type;
  signal mem_instr_in   : mbr_data_type;
  signal mem_instr_addr : reg_data_type;

  -- clock
  signal clk : std_logic := '1';

  shared variable end_run : boolean := false;

begin  -- architecture behavioral

  -- component instantiation
  DUT: entity work.processor
    port map (
      clk            => clk,
      reset          => reset,
      mem_data_we    => mem_data_we,
      mem_data_in    => mem_data_in,
      mem_data_out   => mem_data_out,
      mem_data_addr  => mem_data_addr,
      mem_instr_in   => mem_instr_in,
      mem_instr_addr => mem_instr_addr);

  program_store_1: entity work.program_store
    port map (
      address => mem_instr_addr,
      word    => mem_instr_in);

  data_memory_1: entity work.data_memory
    port map (
      clk      => clk,
      we       => mem_data_we,
      data_in  => mem_data_out,
      data_out => mem_data_in,
      address  => mem_data_addr);

  -- clock generation
  clk_proc : process
  begin
    while end_run = false loop
      clk <= not clk;
      wait for 5 ns;
    end loop;

    wait;
  end process clk_proc;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait until Clk = '1';
    wait for 2 ns;

    reset <= '1';
    wait for 10 ns;
    reset <= '0';

    wait until mem_instr_addr = x"00000021";
    end_run := true;
    wait;
  end process WaveGen_Proc;

end architecture behavioral;

-------------------------------------------------------------------------------

configuration processor_tb_behavioral_cfg of processor_tb is
  for behavioral
  end for;
end processor_tb_behavioral_cfg;

-------------------------------------------------------------------------------
