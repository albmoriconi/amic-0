--------------------------------------------------------------------------------
--! @file
--! @brief Dispositivo PWM con controllo di frequenza e duty cycle
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Dispositivo PWM con controllo di frequenza e duty cycle

--! Il funzionamento del dispositivo è regolato mediante i tre registri di
--! controllo di 32 bit:
--!
--! - Il registro all'indirizzo 0x0 determina il duty cycle (delta) del segnale
--!   in uscita.
--! - Il registro all'indirizzo 0x4 determina la frequenza (f) del segnale in
--!   uscita.
--! - Il registro all'indirizzo 0x8 è utilizzato per l'abilitazione della
--!   periferica, settando a 1 il bit 0 (enable).
--!
--! L'impulso di uscita ha periodo pari a f+1 cicli di clock, durante i quali
--! è alto per i primi delta cicli.
--! L'impulso di uscita è sempre alto se delta = 0 o se delta > f.
--! Il dispositivo evolve unicamente se il bit enable è settato a 1.
entity pwm is
  port (
    clk      : in  std_logic;                      --! Clock
    reset    : in  std_logic;                      --! Reset sincrono attivo alto
    regwrite : in  std_logic;                      --! Enable scrittura registri
    address  : in  std_logic_vector(3 downto 0);   --! Indirizzo registro
    data_in  : in  std_logic_vector(31 downto 0);  --! Dati
    data_out : out std_logic_vector(31 downto 0);  --! Dati
    pulse    : out std_logic                       --! Segnale PWM generato
    );
end entity pwm;

--! Architettura behavioral per il dispositivo PWM
architecture behavioral of pwm is
  -- Tipi di dato
  type regbank is array (3 downto 0) of std_logic_vector(31 downto 0);

  -- Registri
  signal control_regs   : regbank;
  signal counter_reg    : unsigned(31 downto 0);
  signal precounter_reg : unsigned(31 downto 0);
  signal output_reg     : std_logic;
  signal address_reg    : std_logic_vector(3 downto 0);

  -- Segnali di appoggio
  signal counter_next    : unsigned(31 downto 0);
  signal precounter_next : unsigned(31 downto 0);
  signal output_next     : std_logic;

  -- Alias
  alias duty_cycle : std_logic_vector(31 downto 0)
    is control_regs(0);
  alias frequency : std_logic_vector(31 downto 0)
    is control_regs(1);
  alias control : std_logic_vector(31 downto 0)
    is control_regs(2);
  alias enable : std_logic
    is control(0);

  -- Attributi
  attribute ram_style : string;
  attribute ram_style of control_regs : signal is "registers";
begin
  -- Registri
  regs : process (clk) is
  begin
    if clk'event and clk = '1' then
      -- Reset
      if (reset = '1') then
        -- Reset registri
        duty_cycle     <= (others => '0');
        frequency      <= (others => '0');
        control        <= (others => '0');
        precounter_reg <= (others => '0');
        counter_reg    <= (others => '0');
        output_reg     <= '0';
        address_reg    <= (others => '0');
      end if;
      -- Scrittura registri
      if regwrite = '1' then
        control_regs(to_integer(unsigned(address(3 downto 2)))) <= data_in;
      end if;
      -- Update contatori e buffer uscita
      if enable = '1' then
        precounter_reg <= precounter_next;
        counter_reg    <= counter_next;
        output_reg     <= output_next;
      end if;
      -- Registro indirizzo per lettura sincrona
      address_reg <= address;
    end if;
  end process;

  -- Stato prossimo
  precounter_next <= (others => '0') when (precounter_reg = unsigned(frequency))
                     else precounter_reg + 1;
  counter_next <= (others => '0') when (precounter_reg = unsigned(frequency))
                  else counter_reg + 1;
  output_next <= '1' when (counter_reg < unsigned(duty_cycle))
                 or (duty_cycle = (31 downto 0 => '0'))
                 else '0';

  -- Uscita dati
  data_out <= control_regs(to_integer(unsigned(address_reg(3 downto 2))));

  -- Uscita
  pulse <= output_reg;
end architecture behavioral;
