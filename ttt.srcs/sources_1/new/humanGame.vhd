library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity humanGame is
    port(
        inPort   : in  std_logic_vector(8 downto 0);
        reset    : in  std_logic;
        clk      : in  std_logic;
        hsync    : out std_logic;
        vsync    : out std_logic;
        rgb      : out std_logic_vector(11 downto 0);
        winState : out std_logic
    );
end humanGame; 

architecture structural of humanGame is
    signal sqrSel      : std_logic_vector(8 downto 0);
    signal cellGames   : std_logic_vector(17 downto 0);
    signal prevIn      : std_logic_vector(8 downto 0) := (others => '0');
    signal myIn        : std_logic_vector(8 downto 0) := (others => '0');
    signal turnReg     : std_logic := '1';
    signal colorSig    : std_logic_vector(8 downto 0); 
    signal internalWin : std_logic;
    signal clk_count : integer := 0;
    signal heartbeat : std_logic := '0';
    signal rst : std_logic := '0';
    

    component Cell
        port(
            clk   : in  std_logic;
            sel   : in  std_logic;
            turn  : in  std_logic;
            reset : in  std_logic;
            State : out std_logic_vector(1 downto 0)
        );
    end component;
    
    component gameState
        port(
            clk       : in  std_logic;
            reset     : in  std_logic;
            cellState : in  std_logic_vector(17 downto 0);
            winState  : out std_logic;
            colorCell : out std_logic_vector(8 downto 0)
        );
    end component;
    
    -- phai
    component videoElement
        port(
            clk       : in  std_logic;
            reset     : in  std_logic;
            hsync     : out std_logic;
            vsync     : out std_logic;
            rgb       : out std_logic_vector(11 downto 0); 
            Cells     : in  std_logic_vector(17 downto 0);
            Color     : in  std_logic_vector(8 downto 0);
            Turn      : in  std_logic
        );
    end component;

begin

    rst <= reset;
    winState <= internalWin or heartbeat;

    process(clk)
    begin
        if rising_edge(clk) then

            if clk_count = 50000000 then
                clk_count <= 0;
                heartbeat <= not heartbeat;
            else
                clk_count <= clk_count + 1;
            end if;
        end if;
    end process;

    process(internalWin, inPort, cellGames)
    begin
        sqrSel <= (others => '0');
        if internalWin = '0' then 
            -- if    (inPort(6) = '1' and cellGames(16) = '0') then sqrSel(8) <= '1';
            -- elsif (inPort(7) = '1' and cellGames(14) = '0') then sqrSel(7) <= '1';
            -- elsif (inPort(8) = '1' and cellGames(12) = '0') then sqrSel(6) <= '1';
            -- elsif (inPort(3) = '1' and cellGames(10) = '0') then sqrSel(5) <= '1';
            -- elsif (inPort(4) = '1' and cellGames(8) = '0')  then sqrSel(4) <= '1';
            -- elsif (inPort(5) = '1' and cellGames(6) = '0')  then sqrSel(3) <= '1';
            -- elsif (inPort(0) = '1' and cellGames(4) = '0')  then sqrSel(2) <= '1';
            -- elsif (inPort(1) = '1' and cellGames(2) = '0')  then sqrSel(1) <= '1';
            -- elsif (inPort(2) = '1' and cellGames(0) = '0')  then sqrSel(0) <= '1';
            if    (inPort(8) = '1' and cellGames(16) = '0') then sqrSel(8) <= '1';
            elsif (inPort(7) = '1' and cellGames(14) = '0') then sqrSel(7) <= '1';
            elsif (inPort(6) = '1' and cellGames(12) = '0') then sqrSel(6) <= '1';
            elsif (inPort(5) = '1' and cellGames(10) = '0') then sqrSel(5) <= '1';
            elsif (inPort(4) = '1' and cellGames(8) = '0')  then sqrSel(4) <= '1';
            elsif (inPort(3) = '1' and cellGames(6) = '0')  then sqrSel(3) <= '1';
            elsif (inPort(2) = '1' and cellGames(4) = '0')  then sqrSel(2) <= '1';
            elsif (inPort(1) = '1' and cellGames(2) = '0')  then sqrSel(1) <= '1';
            elsif (inPort(0) = '1' and cellGames(0) = '0')  then sqrSel(0) <= '1';
            end if;
        end if;
    end process;
     
    process(clk)
    begin
        --อย่ากดปุ่มค้าง
        if falling_edge(clk) then
	    if reset = '1' then
		turnReg <= '0';
            elsif (prevIn /= myIn and myIn /= "000000000") then
                turnReg <= not turnReg;
            end if;
            prevIn <= myIn;
            myIn   <= inPort;
        end if;
    end process;
     
    STATE_INST : gameState 
        port map (clk => clk, reset => rst, cellState => cellGames, winState => internalWin, colorCell => colorSig);

    VGA_INST : videoElement
        port map (clk => clk, reset => rst, hsync => hsync, vsync => vsync, 
                  rgb => rgb, Cells => cellGames, Color => colorSig, Turn => turnReg);

    GEN_CELLS: for i in 0 to 8 generate
        CELL_I : Cell
            port map(
                clk   => clk,
                reset => rst,
                turn  => turnReg,
                sel   => sqrSel(i),
                State => cellGames((i*2)+1 downto i*2)
            ); 
    end generate;
               
end structural;
