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
        winState : out std_logic;
	cellTemp : out std_logic_vector(17 downto 0)
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
    
    -- State machine signals
    type state_t is (IDLE, HUMAN_PLAY, AI_DELAY, AI_PLAY, GAME_OVER);
    signal state : state_t := IDLE;
    signal delay_cnt : integer range 0 to 10 := 0;
    signal prev_inPort : std_logic_vector(8 downto 0) := (others => '0');
    signal ai_move_latched : std_logic_vector(8 downto 0) := (others => '0');
    signal move_to_play : std_logic_vector(8 downto 0) := (others => '0');
    
    signal M_inter     : std_logic_vector(8 downto 0);

    -- Function to check if a cell is empty (00)
    function is_empty(cell_idx : integer; cells : std_logic_vector(17 downto 0)) return boolean is
    begin
        return cells(cell_idx*2+1 downto cell_idx*2) = "00";
    end function;

    component Cell
        port(
            clk  : in  std_logic;
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
	    clk: in std_logic;
            C0, C1, C2, C3, C4, C5, C6, C7, C8 : in std_logic_vector(1 downto 0);
            M_vec: out std_logic_vector(8 downto 0)
        );
    end component;

begin

    rst <= reset;
    winState <= internalWin or heartbeat;

    -- Heartbeat counter
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

    -- AI component (combinational)
    AI_INST : XO_AI
        port map (
	    clk => clk,
            C0 => cellGames(1 downto 0),
            C1 => cellGames(3 downto 2),
            C2 => cellGames(5 downto 4),
            C3 => cellGames(7 downto 6),
            C4 => cellGames(9 downto 8),
            C5 => cellGames(11 downto 10),
            C6 => cellGames(13 downto 12),
            C7 => cellGames(15 downto 14),
            C8 => cellGames(17 downto 16),
            M_vec => M_inter
        );

    -- Main state machine
    process(clk)
        variable human_move : std_logic_vector(8 downto 0);
        variable move_valid : boolean;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                sqrSel <= (others => '0');
                turnReg <= '0';
                delay_cnt <= 0;
                prev_inPort <= (others => '0');
                ai_move_latched <= (others => '0');
                move_to_play <= (others => '0');
            else
                -- Default: no move
                sqrSel <= (others => '0');
                
                case state is
                    when IDLE =>
                        -- Check for win first
                        if internalWin = '1' then
                            state <= GAME_OVER;
                        elsif inPort /= prev_inPort then
                            -- Input changed - check if valid move
                            human_move := (others => '0');
                            move_valid := false;
                            
                            -- Check which cell is selected and if empty
                            if inPort(0) = '1' and is_empty(0, cellGames) then
                                human_move(0) := '1'; move_valid := true;
                            elsif inPort(1) = '1' and is_empty(1, cellGames) then
                                human_move(1) := '1'; move_valid := true;
                            elsif inPort(2) = '1' and is_empty(2, cellGames) then
                                human_move(2) := '1'; move_valid := true;
                            elsif inPort(3) = '1' and is_empty(3, cellGames) then
                                human_move(3) := '1'; move_valid := true;
                            elsif inPort(4) = '1' and is_empty(4, cellGames) then
                                human_move(4) := '1'; move_valid := true;
                            elsif inPort(5) = '1' and is_empty(5, cellGames) then
                                human_move(5) := '1'; move_valid := true;
                            elsif inPort(6) = '1' and is_empty(6, cellGames) then
                                human_move(6) := '1'; move_valid := true;
                            elsif inPort(7) = '1' and is_empty(7, cellGames) then
                                human_move(7) := '1'; move_valid := true;
                            elsif inPort(8) = '1' and is_empty(8, cellGames) then
                                human_move(8) := '1'; move_valid := true;
                            end if;
                            
                            if move_valid then
                                move_to_play <= human_move;
                                state <= HUMAN_PLAY;
                            end if;
                        end if;
                        prev_inPort <= inPort;
                        
                    when HUMAN_PLAY =>
                        -- Execute human move
                        sqrSel <= move_to_play;
                        -- Toggle turn
                        turnReg <= '1';  -- AI's turn
                        -- Start delay
                        delay_cnt <= 0;
                        state <= AI_DELAY;
                        
                    when AI_DELAY =>
                        -- Wait 10 cycles
                        if delay_cnt < 10 then
                            delay_cnt <= delay_cnt + 1;
                        else
			-- Latch AI move immediately while board state is stable
			    ai_move_latched <= M_inter;
                            state <= AI_PLAY;
                        end if;
                        
                    when AI_PLAY =>
                        -- Execute AI move
                        sqrSel <= ai_move_latched;
                        -- Toggle turn back to human
                        turnReg <= '0';
                        -- Go back to idle to wait for next human move
                        state <= IDLE;
                        
                    when GAME_OVER =>
                        -- Stay in game over state
                        -- Reset required to start new game
                        null;
                        
                    when others =>
                        state <= IDLE;
                end case;
            end if;
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

    cellTemp <= cellGames;
               
end structural;
