library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
    signal reset    : STD_LOGIC := '0';
    signal clk      : STD_LOGIC := '0';
    signal hsync    : STD_LOGIC;
    signal vsync    : STD_LOGIC;
    signal rgb      : STD_LOGIC_VECTOR(11 downto 0);
    signal winState : STD_LOGIC;

    constant clk_period : time := 10 ns;
    
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

    stim_proc: process
    begin
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 50 ns;
        
        inPort <= "000000001";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "000000010";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "000000100";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "000001000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "000010000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "000100000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "001000000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "010000000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "100000000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;

        wait;
    end process;
end Behavioral;
