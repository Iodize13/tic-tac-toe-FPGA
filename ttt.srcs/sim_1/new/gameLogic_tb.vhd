library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity gameLogic_tb is
end gameLogic_tb;

architecture Behavioral of gameLogic_tb is
    component gameLogic
        port(
            inPort   : in  std_logic_vector(8 downto 0);
            execute  : in  std_logic;
            reset    : in  std_logic;
            clk      : in  std_logic;
	    playFirst : in std_logic;
            hsync    : out std_logic;
            vsync    : out std_logic;
            rgb      : out std_logic_vector(11 downto 0);
            winState : out std_logic
        );
    end component;

    signal inPort   : STD_LOGIC_VECTOR(8 downto 0) := "000000000";
    signal execute  : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '1';
    signal clk      : STD_LOGIC := '0';
    signal hsync    : STD_LOGIC;
    signal vsync    : STD_LOGIC;
    signal rgb      : STD_LOGIC_VECTOR(11 downto 0);
    signal winState : STD_LOGIC;

    constant clk_period : time := 10 ns;
    
    -- Track game state
    signal move_count : integer := 0;
    signal game_over  : boolean := false;
    signal playF_tb   : std_logic := '0';
    
begin
    UUT: gameLogic
        port map (
            inPort => inPort,
            execute => execute,
            reset => reset,
            clk => clk,
            hsync => hsync,
            vsync => vsync,
            rgb => rgb,
            winState => winState,
	    playFirst => playF_tb
        );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Game simulation: Human (X) plays against AI (O)
    stim_proc: process
    begin
        reset <= '1';
	playF_tb <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 100 ns;
        
        -- Move 1: Human plays at cell 0 (top-left)
        report "Human selects cell 0";
        inPort <= "000000010";  -- Select cell 0
        wait for 245 ns;
        report "Human presses execute";
        execute <= '1';         -- Press execute
	wait for 50 ns;
        -- wait for 2 ms;
        execute <= '0';         -- Release execute
        wait for 200 ns;        -- Wait for AI response
        
        -- Move 2: Human plays at cell 4 (center)
        report "Human selects cell 4";
        inPort <= "010000010";  -- Select cell 4
        wait for 50 ns;
        report "Human presses execute";
        execute <= '1';         -- Press execute
	wait for 50 ns;
        -- wait for 2 ms;
        execute <= '0';         -- Release execute
        wait for 200 ns;        -- Wait for AI response
        
        -- Move 3: Human plays at cell 8 (bottom-right)
        report "Human selects cell 8";
        inPort <= "100000011";  -- Select cell 8
        wait for 50 ns;
        report "Human presses execute";
        execute <= '1';         -- Press execute
	wait for 50 ns;
        -- wait for 2 ms;
        execute <= '0';         -- Release execute
        wait for 200 ns;        -- Wait for AI response
        
        report "Game simulation complete";
        wait;
    end process;
    
end Behavioral;
