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
            reset    : in  std_logic;
            clk      : in  std_logic;
            hsync    : out std_logic;
            vsync    : out std_logic;
            rgb      : out std_logic_vector(11 downto 0);
            winState : out std_logic
        );
    end component;

    signal inPort   : STD_LOGIC_VECTOR(8 downto 0) := "000000000";
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
    
begin
    UUT: gameLogic
        port map (
            inPort => inPort,
            reset => reset,
            clk => clk,
            hsync => hsync,
            vsync => vsync,
            rgb => rgb,
            winState => winState
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
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;
        
        -- Human plays at cell 0 (top-left)
        report "Human plays cell 8";
        inPort <= "000010000";  -- Button 0
        wait for 200 ns;
        inPort <= "000000100";
        wait for 200 ns;
        inPort <= "100000000";
        -- wait for 200 ns;
        
        -- Human plays at cell 4 (center)
--        report "Human plays cell 2";
--        inPort <= "000000010";  -- Button 4
--        wait for 10 ns;
--        inPort <= "000000000";
--        wait for 10 ns;
        
--        -- Human plays at cell 8 (bottom-right)
--        report "Human plays cell 6";
--        inPort <= "000100000";  -- Button 8
--        wait for 10 ns;
--        inPort <= "000000000";
--        wait for 10 ns;
        
--        -- Continue with more moves if game not over
--        -- Human plays at cell 2 (top-right)
--        report "Human plays cell 2";
--        inPort <= "000000100";  -- Button 2
--        wait for 10 ns;
--        inPort <= "000000000";
--        wait for 10 ns;
        
--        -- Human plays at cell 6 (bottom-left)
--        report "Human plays cell 6";
--        inPort <= "001000000";  -- Button 6
--        wait for 10 ns;
--        inPort <= "000000000";
--        wait for 10 ns;
        
        report "Game simulation complete - captured ";
        wait;
    end process;
    
end Behavioral;
