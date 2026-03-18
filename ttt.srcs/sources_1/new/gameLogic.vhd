library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gameLogic is
    port(
        inPort    : in  std_logic_vector(8 downto 0);
        execute   : in  std_logic;  -- Execute button
        reset     : in  std_logic;
        clk       : in  std_logic;
        playFirst : in  std_logic;  -- '1' = Human plays first, '0' = AI plays first
        hsync     : out std_logic;
        vsync     : out std_logic;
        rgb       : out std_logic_vector(11 downto 0);
        winState  : out std_logic;
        cellTemp  : out std_logic_vector(17 downto 0)
    );
end gameLogic;

architecture structural of gameLogic is
    -- Signals for pveHumanFirst (human plays first)
    signal h_hsync, h_vsync : std_logic;
    signal h_rgb : std_logic_vector(11 downto 0);
    signal h_winState : std_logic;
    signal h_cellTemp : std_logic_vector(17 downto 0);
    
    -- Signals for pveAiFirst (AI plays first)
    signal a_hsync, a_vsync : std_logic;
    signal a_rgb : std_logic_vector(11 downto 0);
    signal a_winState : std_logic;
    signal a_cellTemp : std_logic_vector(17 downto 0);

    component pveHumanFirst
        port(
            inPort    : in  std_logic_vector(8 downto 0);
            execute   : in  std_logic;
            reset     : in  std_logic;
            clk       : in  std_logic;
            hsync     : out std_logic;
            vsync     : out std_logic;
            rgb       : out std_logic_vector(11 downto 0);
            winState  : out std_logic;
            cellTemp  : out std_logic_vector(17 downto 0)
        );
    end component;
    
    component pveAiFirst
        port(
            inPort    : in  std_logic_vector(8 downto 0);
            execute   : in  std_logic;
            reset     : in  std_logic;
            clk       : in  std_logic;
            hsync     : out std_logic;
            vsync     : out std_logic;
            rgb       : out std_logic_vector(11 downto 0);
            winState  : out std_logic;
            cellTemp  : out std_logic_vector(17 downto 0)
        );
    end component;

begin
    -- Instantiate both game modules
    HUMAN_FIRST : pveHumanFirst
        port map (
            inPort   => inPort,
            execute  => execute,
            reset    => reset,
            clk      => clk,
            hsync    => h_hsync,
            vsync    => h_vsync,
            rgb      => h_rgb,
            winState => h_winState,
            cellTemp => h_cellTemp
        );
    
    AI_FIRST : pveAiFirst
        port map (
            inPort   => inPort,
            execute  => execute,
            reset    => reset,
            clk      => clk,
            hsync    => a_hsync,
            vsync    => a_vsync,
            rgb      => a_rgb,
            winState => a_winState,
            cellTemp => a_cellTemp
        );
    
    -- Mux to select which module's output to use
    hsync    <= h_hsync when playFirst = '1' else a_hsync;
    vsync    <= h_vsync when playFirst = '1' else a_vsync;
    rgb      <= h_rgb when playFirst = '1' else a_rgb;
    winState <= h_winState when playFirst = '1' else a_winState;
    cellTemp <= h_cellTemp when playFirst = '1' else a_cellTemp;

end structural;
