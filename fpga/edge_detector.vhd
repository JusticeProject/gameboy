library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detector is
    port (
            clk_50MHz : in std_logic;
            input_signal : in std_logic;
            pos_edge : out std_logic
        );
end edge_detector;

architecture Behavioral of edge_detector is
    signal delay_reg : std_logic;
begin
    process (clk_50MHz)
    begin
        if rising_edge(clk_50MHz) then
            delay_reg <= input_signal;
        end if;
    end process;
    
    -- output logic
    pos_edge <= (not delay_reg) and input_signal;

end Behavioral;
