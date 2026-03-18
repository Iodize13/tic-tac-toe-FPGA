library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity button_debouncer is
    Generic (
        CLK_FREQ    : integer := 100_000_000; -- 100 MHz Nexys A7 Clock
        DEBOUNCE_MS : integer := 10           -- Wait 10 milliseconds
    );
    Port ( 
        Clk      : in  STD_LOGIC;
        BTN_In   : in  STD_LOGIC;  -- The raw, noisy physical button
        BTN_Out  : out STD_LOGIC   -- The clean, stable signal
    );
end button_debouncer;

architecture Behavioral of button_debouncer is

    -- Calculate the max counter value needed (1,000,000)
    constant MAX_COUNT : integer := (CLK_FREQ / 1000) * DEBOUNCE_MS;
    
    -- The counter variable (needs to be big enough to hold 1,000,000)
    signal counter : integer range 0 to MAX_COUNT := 0;

    -- Synchronization flip-flops to prevent metastability
    signal sync_ff1 : STD_LOGIC := '0';
    signal sync_ff2 : STD_LOGIC := '0';

    -- Memory to hold the last known "clean" state
    signal stable_state : STD_LOGIC := '0';

begin

    -- PER YOUR REQUIREMENT: Triggering on the FALLING EDGE
    process(Clk)
    begin
        if falling_edge(Clk) then
            
            -- Step 1: Synchronize the asynchronous button press
            sync_ff1 <= BTN_In;
            sync_ff2 <= sync_ff1;

            -- Step 2: The Debounce Timer Logic
            if sync_ff2 /= stable_state then
                -- The input is different from our stable state. Start counting!
                if counter < MAX_COUNT then
                    counter <= counter + 1;
                else
                    -- We reached 1,000,000 clock cycles (10ms) with no bounces.
                    -- It is safe to update the state.
                    stable_state <= sync_ff2;
                    counter <= 0; -- Reset counter for next time
                end if;
            else
                -- The input matches our stable state, so reset the counter.
                counter <= 0;
            end if;
            
        end if;
    end process;

    -- Step 3: Wire the clean memory to the output pin
    BTN_Out <= stable_state;

end Behavioral;