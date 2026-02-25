library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_receiver is
    port ( clk_50MHz : in  std_logic;
           sclk_pos_edge : in  std_logic;
           mosi : in  std_logic;
           is_rom : in  std_logic;
           ready : out  std_logic;
           data_out : out  std_logic_vector (7 downto 0);
           store : out  std_logic
          );
end spi_receiver;

-- see finite state machine diagram for details
architecture Behavioral of spi_receiver is
    type state_type is (idle, capturing, done);
    signal state_reg, state_next : state_type;
    signal counter_reg, counter_next : unsigned(3 downto 0);
    signal shift_reg, shift_next : std_logic_vector(7 downto 0);
    signal data_reg, data_next : std_logic_vector(7 downto 0);
    signal store_reg, store_next : std_logic;
    
    constant COUNTER_MAX : integer := 8;
begin
    -- state and data registers
    process (clk_50MHz)
    begin
        if rising_edge(clk_50MHz) then
            state_reg <= state_next;
            counter_reg <= counter_next;
            shift_reg <= shift_next;
            data_reg <= data_next;
            store_reg <= store_next;
        end if;
    end process;

    -- next state logic and data path
    process (state_reg, sclk_pos_edge, mosi, counter_reg, counter_next, shift_reg, data_reg, store_reg, is_rom)
    begin
        state_next <= state_reg; -- default back to same state
        counter_next <= counter_reg;
        shift_next <= shift_reg;
        data_next <= data_reg;
        store_next <= store_reg;
        ready <= '0';
        case state_reg is
            when idle =>
                if sclk_pos_edge = '1' then
                    counter_next <= "0001";
                    store_next <= is_rom;
                    shift_next(0) <= mosi;
                    state_next <= capturing;
                end if;
            when capturing =>
                if sclk_pos_edge = '1' then
                    counter_next <= counter_reg + 1;
                    shift_next <= shift_reg(6 downto 0) & mosi;
                    if counter_next >= COUNTER_MAX then
                        -- all 8 bits have been received, send the data to the output latch
                        data_next <= shift_next;
                        state_next <= done;
                    end if;
                end if;
            when done =>
                ready <= '1';
                state_next <= idle;
            when others =>
                state_next <= idle;
        end case;
    end process;
    
    -- output logic
    data_out <= data_reg;
    store <= store_reg;
    
end Behavioral;
