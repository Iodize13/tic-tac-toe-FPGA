library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gameLogic is
    port(
        inPort   : in  std_logic_vector(8 downto 0);
        reset    : in  std_logic;
        clk      : in  std_logic;
        hsync    : out std_logic;
        vsync    : out std_logic;
        rgb      : out std_logic_vector(11 downto 0);
        winState : out std_logic
    );
end gameLogic; 

architecture structural of gameLogic is
    signal sqrSel      : std_logic_vector(8 downto 0);
    signal cellGames   : std_logic_vector(17 downto 0);
    signal prevIn      : std_logic_vector(8 downto 0) := (others => '0');
    signal myIn        : std_logic_vector(8 downto 0) := (others => '0');
    signal turnReg     : std_logic := '0';
    signal colorSig    : std_logic_vector(8 downto 0); 
    signal internalWin : std_logic;
    signal clk_count   : integer := 0;
    signal heartbeat   : std_logic := '0';
    signal rst         : std_logic := '0';
    
    -- AI signals - latched move
    signal aiMoveRaw   : std_logic_vector(8 downto 0);  -- Raw output from AI module
    signal aiMove      : std_logic_vector(8 downto 0);  -- Latched move
    signal aiState     : integer range 0 to 3 := 0;     -- 0=idle, 1=latch, 2=play, 3=done
    signal aiDelay     : integer range 0 to 30 := 0;

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
    
    component XO_AI
        port(
            C0, C1, C2, C3, C4, C5, C6, C7, C8 : in std_logic_vector(1 downto 0);
            M0, M1, M2, M3, M4, M5, M6, M7, M8 : out std_logic
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

    -- Combined input processing (human + AI)
    process(internalWin, inPort, cellGames, turnReg, aiMove, aiState)
    begin
        sqrSel <= (others => '0');
        if internalWin = '0' then 
            if turnReg = '0' then
                -- X's turn (human)
                if    (inPort(6) = '1' and cellGames(16) = '0') then sqrSel(8) <= '1';
                elsif (inPort(7) = '1' and cellGames(14) = '0') then sqrSel(7) <= '1';
                elsif (inPort(8) = '1' and cellGames(12) = '0') then sqrSel(6) <= '1';
                elsif (inPort(3) = '1' and cellGames(10) = '0') then sqrSel(5) <= '1';
                elsif (inPort(4) = '1' and cellGames(8) = '0')  then sqrSel(4) <= '1';
                elsif (inPort(5) = '1' and cellGames(6) = '0')  then sqrSel(3) <= '1';
                elsif (inPort(0) = '1' and cellGames(4) = '0')  then sqrSel(2) <= '1';
                elsif (inPort(1) = '1' and cellGames(2) = '0')  then sqrSel(1) <= '1';
                elsif (inPort(2) = '1' and cellGames(0) = '0')  then sqrSel(0) <= '1';
                end if;
            elsif turnReg = '1' and aiState = 2 then
                -- O's turn (AI) - play latched move
                sqrSel <= aiMove;
            end if;
        end if;
    end process;
    
    -- Turn switching
    process(clk)
    begin
        if falling_edge(clk) then
            if (prevIn /= myIn and myIn /= "000000000") then
                turnReg <= not turnReg;
            end if;
            prevIn <= myIn;
            myIn   <= inPort;
        end if;
    end process;
    
    -- AI state machine - latches move then plays once
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                aiState <= 0;
                aiDelay <= 0;
                aiMove <= (others => '0');
            elsif turnReg = '0' then
                -- Reset during X's turn
                aiState <= 0;
                aiDelay <= 0;
                aiMove <= (others => '0');
            elsif turnReg = '1' then
                case aiState is
                    when 0 =>  -- Latch the AI move immediately
                        aiMove <= aiMoveRaw;
                        aiState <= 1;
                        aiDelay <= 0;
                    when 1 =>  -- Wait a bit
                        if aiDelay < 20 then
                            aiDelay <= aiDelay + 1;
                        else
                            aiState <= 2;
                        end if;
                    when 2 =>  -- Play the move (one cycle)
                        aiState <= 3;
                    when 3 =>  -- Done
                        null;
                    when others =>
                        aiState <= 0;
                end case;
            end if;
        end if;
    end process;
     
    STATE_INST : gameState 
        port map (clk => clk, reset => rst, cellState => cellGames, winState => internalWin, colorCell => colorSig);

    VGA_INST : videoElement
        port map (clk => clk, reset => rst, hsync => hsync, vsync => vsync, 
                  rgb => rgb, Cells => cellGames, Color => colorSig, Turn => turnReg);
    
    AI_INST : XO_AI
        port map (
            C0 => cellGames(1 downto 0),
            C1 => cellGames(3 downto 2),
            C2 => cellGames(5 downto 4),
            C3 => cellGames(7 downto 6),
            C4 => cellGames(9 downto 8),
            C5 => cellGames(11 downto 10),
            C6 => cellGames(13 downto 12),
            C7 => cellGames(15 downto 14),
            C8 => cellGames(17 downto 16),
            M0 => aiMoveRaw(0),
            M1 => aiMoveRaw(1),
            M2 => aiMoveRaw(2),
            M3 => aiMoveRaw(3),
            M4 => aiMoveRaw(4),
            M5 => aiMoveRaw(5),
            M6 => aiMoveRaw(6),
            M7 => aiMoveRaw(7),
            M8 => aiMoveRaw(8)
        );

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
