library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- AI plays first (as X), Human plays as O
entity pveAiFirst is
    port(
        inPort    : in  std_logic_vector(8 downto 0);
        execute   : in  std_logic;  -- Execute button
        reset     : in  std_logic;
        clk       : in  std_logic;
        hsync     : out std_logic;
        vsync     : out std_logic;
        rgb       : out std_logic_vector(11 downto 0);
        winState  : out std_logic;
        cellTemp  : out std_logic_vector(17 downto 0)
    );
end pveAiFirst;

architecture structural of pveAiFirst is
    signal sqrSel      : std_logic_vector(8 downto 0);
    signal cellGames   : std_logic_vector(17 downto 0);
    signal turnReg     : std_logic := '0';  -- X (AI) starts
    signal colorSig    : std_logic_vector(8 downto 0); 
    signal internalWin : std_logic;
    signal rst         : std_logic := '0';
    
    type state_t is (AI_FIRST, IDLE, SELECT_CELL, EXECUTE_WAIT, APPLY_MOVE, AI_DELAY, AI_TURN, GAME_OVER);
    signal state : state_t := AI_FIRST;
    signal delay_cnt : integer range 0 to 31 := 0;
    signal prev_execute : std_logic := '0';
    signal ai_move_latched : std_logic_vector(8 downto 0) := (others => '0');
    signal human_move_latched : std_logic_vector(8 downto 0) := (others => '0');
    signal selected_cell : integer range 0 to 8 := 0;
    signal selected_move : std_logic_vector(8 downto 0) := (others => '0');
    signal execute_debounced : std_logic := '0';
    signal execute_prev : std_logic := '0';
    
    signal M_ai : std_logic_vector(8 downto 0);  -- O_AI (AI plays as X)

    function is_empty(cell_idx : integer; cells : std_logic_vector(17 downto 0)) return boolean is
    begin
        return cells(cell_idx*2+1 downto cell_idx*2) = "00";
    end function;

    component Cell
        port(clk : in std_logic; sel : in std_logic; turn : in std_logic; 
             reset : in std_logic; State : out std_logic_vector(1 downto 0));
    end component;
    
    component gameState
        port(clk : in std_logic; reset : in std_logic; cellState : in std_logic_vector(17 downto 0);
             winState : out std_logic; colorCell : out std_logic_vector(8 downto 0));
    end component;
    
    component videoElement
        port(clk : in std_logic; reset : in std_logic; hsync : out std_logic; 
             vsync : out std_logic; rgb : out std_logic_vector(11 downto 0); 
             Cells : in std_logic_vector(17 downto 0); Color : in std_logic_vector(8 downto 0);
             Turn : in std_logic);
    end component;
    
    component O_AI
        port(clk: in std_logic; C0, C1, C2, C3, C4, C5, C6, C7, C8 : in std_logic_vector(1 downto 0);
             M_vec: out std_logic_vector(8 downto 0));
    end component;
    
    component button_debouncer
        Generic (
            CLK_FREQ    : integer := 100_000_000;
            DEBOUNCE_MS : integer := 10
        );
        Port ( 
            Clk      : in  STD_LOGIC;
            BTN_In   : in  STD_LOGIC;
            BTN_Out  : out STD_LOGIC
        );
    end component;
    
    component inputDecoder
        port(
            internalWin : in  std_logic;
            inPort      : in  std_logic_vector(8 downto 0);
            cellGame    : in  std_logic_vector(17 downto 0);
            SqrSel      : out std_logic_vector(8 downto 0)
        );
    end component;
    
    signal decoder_sel : std_logic_vector(8 downto 0);

begin
    rst <= reset;
    winState <= internalWin;

    -- Debounce the execute button
    EXEC_DEBOUNCE : 
	button_debouncer
        generic map (
            CLK_FREQ    => 100_000_000,
            DEBOUNCE_MS => 10
        )
        port map (
            Clk     => clk,
            BTN_In  => execute,
            BTN_Out => execute_debounced
        );
	-- execute_debounced <= execute;

    -- Input decoder for switch selection
    DECODER : inputDecoder
        port map (
            internalWin => internalWin,
            inPort      => inPort,
            cellGame    => cellGames,
            SqrSel      => decoder_sel
        );

    -- AI component (AI plays as X, so uses O_AI)
    AI_INST : O_AI port map (
        clk => clk, C0 => cellGames(1 downto 0), C1 => cellGames(3 downto 2),
        C2 => cellGames(5 downto 4), C3 => cellGames(7 downto 6), C4 => cellGames(9 downto 8),
        C5 => cellGames(11 downto 10), C6 => cellGames(13 downto 12), C7 => cellGames(15 downto 14),
        C8 => cellGames(17 downto 16), M_vec => M_ai);

    -- State machine
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= AI_FIRST;
                sqrSel <= (others => '0');
                turnReg <= '0';  -- X (AI) starts
                delay_cnt <= 0;
                execute_prev <= '0';
                ai_move_latched <= (others => '0');
                human_move_latched <= (others => '0');
                selected_move <= (others => '0');
            else
                sqrSel <= (others => '0');
                
                case state is
                    when AI_FIRST =>
                        -- AI makes first move - wait longer for AI to calculate
                        if delay_cnt < 20 then
                            delay_cnt <= delay_cnt + 1;
                        elsif delay_cnt = 20 then
                            -- Latch AI move (should be center for empty board)
                            ai_move_latched <= M_ai;
                            delay_cnt <= delay_cnt + 1;
                        elsif delay_cnt = 21 then
                            -- Execute the move
                            sqrSel <= ai_move_latched;
                            delay_cnt <= delay_cnt + 1;
                        elsif delay_cnt = 22 then
                            -- Clear sel and switch turn
                            sqrSel <= (others => '0');
                            turnReg <= '0';  -- Switch to O (human)
                            delay_cnt <= 0;
                            state <= IDLE;
                        end if;
                        
                    when IDLE =>
                        if internalWin = '1' then
                            state <= GAME_OVER;
                        else
                            state <= SELECT_CELL;
                        end if;
                        
                    when SELECT_CELL =>
                        -- Use inputDecoder to check which switch is pressed
                        if decoder_sel /= "000000000" then
                            selected_move <= decoder_sel;
                            state <= EXECUTE_WAIT;
                        end if;
                        
                    when EXECUTE_WAIT =>
                        -- Check if switch is still held
                        if (selected_move and inPort) = "000000000" then
                            -- Switch released, go back to selection
                            state <= SELECT_CELL;
                        elsif execute_debounced = '1' and execute_prev = '0' then
                            -- Execute button pressed, go to APPLY_MOVE
                            state <= APPLY_MOVE;
                        end if;
                        execute_prev <= execute_debounced;
                        
                    when APPLY_MOVE =>
                        -- Apply the move for one clock cycle
                        sqrSel <= selected_move;
                        turnReg <= not turnReg;
                        delay_cnt <= 0;
                        state <= AI_DELAY;
                        
                    when AI_DELAY =>
                        if delay_cnt < 5 then
                            delay_cnt <= delay_cnt + 1;
                        else
                            ai_move_latched <= M_ai;
                            delay_cnt <= 0;
                            state <= AI_TURN;
                        end if;
                        
                    when AI_TURN =>
                        sqrSel <= ai_move_latched;
                        turnReg <= not turnReg;
                        state <= IDLE;
                        
                    when GAME_OVER =>
                        null;
                        
                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
     
    STATE_INST : gameState port map (clk => clk, reset => rst, cellState => cellGames, 
                  winState => internalWin, colorCell => colorSig);

    VGA_INST : videoElement port map (clk => clk, reset => rst, hsync => hsync, vsync => vsync, 
                  rgb => rgb, Cells => cellGames, Color => colorSig, Turn => turnReg);

    GEN_CELLS: for i in 0 to 8 generate
        CELL_I : Cell port map(clk => clk, reset => rst, turn => turnReg,
                     sel => sqrSel(i), State => cellGames((i*2)+1 downto i*2));
    end generate;

    cellTemp <= cellGames;
end structural;
