library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_receiver_w_timeout is
    port ( clk_50MHz : in  std_logic;
           sclk_pos_edge : in  std_logic;
           mosi : in  std_logic;
           is_rom : in  std_logic;
           ready : out  std_logic;
           data_out : out  std_logic_vector (7 downto 0);
           store : out  std_logic
          );
end spi_receiver_w_timeout;

-- see finite state machine diagram for details
architecture Behavioral of spi_receiver_w_timeout is
    type state_type is (idle, capturing, done);
    signal state_reg, state_next : state_type;
    signal bit_counter_reg, bit_counter_next : unsigned(3 downto 0);
    signal timeout_counter_reg, timeout_counter_next : unsigned(24 downto 0);
    signal shift_reg, shift_next : std_logic_vector(7 downto 0);
    signal data_reg, data_next : std_logic_vector(7 downto 0);
    signal store_reg, store_next : std_logic;
    
    constant BIT_COUNTER_MAX : integer := 8;
    constant TIMEOUT_COUNTER_MAX : integer := 25000000; -- half a second at 50MHz
begin
    -- state and data registers
    process (clk_50MHz)
    begin
        if rising_edge(clk_50MHz) then
            state_reg <= state_next;
            bit_counter_reg <= bit_counter_next;
            timeout_counter_reg <= timeout_counter_next;
            shift_reg <= shift_next;
            data_reg <= data_next;
            store_reg <= store_next;
        end if;
    end process;

    -- next state logic and data path
    process (state_reg, sclk_pos_edge, mosi, bit_counter_reg, bit_counter_next, 
        timeout_counter_reg, timeout_counter_next, shift_reg, data_reg, store_reg, is_rom)
    begin
        state_next <= state_reg; -- default back to same state
        bit_counter_next <= bit_counter_reg;
        timeout_counter_next <= timeout_counter_reg;
        shift_next <= shift_reg;
        data_next <= data_reg;
        store_next <= store_reg;
        ready <= '0';
        case state_reg is
            when idle =>
                if sclk_pos_edge = '1' then
                    bit_counter_next <= "0001";
                    timeout_counter_next <= (others=>'0');
                    store_next <= is_rom;
                    shift_next(0) <= mosi;
                    state_next <= capturing;
                end if;
            when capturing =>
                if sclk_pos_edge = '1' then
                    bit_counter_next <= bit_counter_reg + 1;
                    shift_next <= shift_reg(6 downto 0) & mosi;
                    if bit_counter_next >= BIT_COUNTER_MAX then
                        -- all 8 bits have been received, send the data to the output latch
                        data_next <= shift_next;
                        state_next <= done;
                    end if;
                else
                    timeout_counter_next <= timeout_counter_reg + 1;
                    if timeout_counter_next >= TIMEOUT_COUNTER_MAX then
                        state_next <= idle;
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
