library ieee;
use ieee.std_logic_1164.all;

entity synchronizer_2_stage is
    Port ( clk : in  std_logic;
           async : in  std_logic;
           sync : out  std_logic);
end synchronizer_2_stage;

architecture Behavioral of synchronizer_2_stage is
    signal mid : std_logic;
begin

    -- first stage
    process(clk)
    begin
        if rising_edge(clk) then
            mid <= async;
        end if;
    end process;
    
    -- second stage
    process(clk)
    begin
        if rising_edge(clk) then
            sync <= mid;
        end if;
    end process;

end Behavioral;
