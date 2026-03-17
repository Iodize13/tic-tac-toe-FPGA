library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity menuState_tb is
end menuState_tb;

architecture Behavioral of menuState_tb is
    component menuState
        port(
            btHuman  : in  std_logic;
            btPve    : in  std_logic;
            inPort   : in  std_logic_vector(8 downto 0);
            reset    : in  std_logic;
            clk      : in  std_logic;
            hsync    : out std_logic;
            vsync    : out std_logic;
            rgb      : out std_logic_vector(11 downto 0);
            winState : out std_logic
        );
    end component;

    signal btHuman_tb : STD_LOGIC := '0';
    signal btPve_tb : STD_LOGIC := '0';
    signal inPort_tb   : STD_LOGIC_vector(8 downto 0) := "000000000";
    signal reset    : STD_LOGIC := '1';
    signal clk      : STD_LOGIC := '0';

    constant clk_period : time := 10 ns;
    
    -- Track game state
    signal move_count : integer := 0;
    signal game_over  : boolean := false;

begin
    UUT: menuState
        port map (
		     btHuman => btHuman_tb,
		     btPve => btPve_tb,
		     inPort => inPort_tb,
		     reset => reset,
		     clk => clk
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
        wait for 200 ns;
        reset <= '0';
        wait for 200 ns;
	btHuman_tb <= '1';
	btPve_tb <= '0';
        -- wait for 10 ns;
        -- reset <= '1';
        -- wait for 200 ns;
        -- reset <= '0';
        wait for 200 ns;
        
        -- Human plays at cell 0 (top-left)
        report "Human plays cell 0";
        inPort_tb <= "000000001";  -- Button 0
        wait for 100 ns;
        inPort_tb <= "000000000";
        wait for 100 ns;
        
        -- Human plays at cell 4 (center)
        report "Human plays cell 4";
        inPort_tb <= "000010000";  -- Button 4
        wait for 100 ns;
        inPort_tb <= "000000000";
        wait for 100 ns;
        
        -- Human plays at cell 8 (bottom-right)
        report "Human plays cell 8";
        inPort_tb <= "100000000";  -- Button 8
        wait for 100 ns;
        inPort_tb <= "000000000";
        wait for 100 ns;
        
        -- Continue with more moves if game not over
        -- Human plays at cell 2 (top-right)
        report "Human plays cell 2";
        inPort_tb <= "000000100";  -- Button 2
        wait for 100 ns;
        inPort_tb <= "000000000";
        wait for 100 ns;
        
        -- Human plays at cell 6 (bottom-left)
        report "Human plays cell 6";
        inPort_tb <= "001000000";  -- Button 6
        wait for 100 ns;
        inPort_tb <= "000000000";
        wait for 100 ns;
        
        report "Human plays cell 6";
        inPort_tb <= "000001000";  -- Button 6
        wait for 100 ns;
        inPort_tb <= "000000000";
        wait for 100 ns;
        report "Human plays cell 6";
        inPort_tb <= "010000000";  -- Button 6
        wait for 100 ns;
        inPort_tb <= "000000000";
        wait for 100 ns;
	reset <= '1';
        wait for 100 ns;
	reset <= '0';
        wait for 100 ns;
	btHuman_tb <= '0';
	btPve_tb <= '1';
        wait for 100 ns;

        inPort_tb <= "000010000";  -- Button 0
        wait for 200 ns;
        inPort_tb <= "000000100";
        wait for 200 ns;
        inPort_tb <= "100000000";
        wait for 100 ns;
	reset <= '1';
        wait for 100 ns;
	reset <= '0';
	btHuman_tb <= '0';
	btPve_tb <= '1';
        wait for 100 ns;

        report "Game simulation complete - captured ";
        wait;
    end process;
end Behavioral;
