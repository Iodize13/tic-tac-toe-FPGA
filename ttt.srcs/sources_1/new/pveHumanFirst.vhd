library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Human plays first (as X), AI plays as O
entity pveHumanFirst is
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
end pveHumanFirst;

architecture structural of pveHumanFirst is
    signal sqrSel      : std_logic_vector(8 downto 0);
    signal cellGames   : std_logic_vector(17 downto 0);
    signal turnReg     : std_logic := '1';  -- X (human) starts
    signal colorSig    : std_logic_vector(8 downto 0); 
    signal internalWin : std_logic;
    signal clk_count   : integer := 0;
    signal heartbeat   : std_logic := '0';
    signal rst         : std_logic := '0';
    
    type state_t is (IDLE, SELECT_CELL, EXECUTE_WAIT, HUMAN_TURN, AI_DELAY, AI_TURN, GAME_OVER);
    signal state : state_t := IDLE;
    signal delay_cnt : integer range 0 to 15 := 0;
    signal prev_execute : std_logic := '0';
    signal ai_move_latched : std_logic_vector(8 downto 0) := (others => '0');
    signal human_move_latched : std_logic_vector(8 downto 0) := (others => '0');
    signal selected_cell : integer range 0 to 8 := 0;
    
    signal M_ai : std_logic_vector(8 downto 0);  -- X_AI (AI plays as O)

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
    
    component X_AI
        port(clk: in std_logic; C0, C1, C2, C3, C4, C5, C6, C7, C8 : in std_logic_vector(1 downto 0);
             M_vec: out std_logic_vector(8 downto 0));
    end component;

begin
    rst <= reset;
    winState <= internalWin or heartbeat;

    -- Heartbeat
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

    -- AI component (AI plays as O, so uses X_AI)
    AI_INST : X_AI port map (
        clk => clk, C0 => cellGames(1 downto 0), C1 => cellGames(3 downto 2),
        C2 => cellGames(5 downto 4), C3 => cellGames(7 downto 6), C4 => cellGames(9 downto 8),
        C5 => cellGames(11 downto 10), C6 => cellGames(13 downto 12), C7 => cellGames(15 downto 14),
        C8 => cellGames(17 downto 16), M_vec => M_ai);

    -- State machine
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                sqrSel <= (others => '0');
                turnReg <= '1';  -- X (human) starts
                delay_cnt <= 0;
                prev_execute <= '0';
                ai_move_latched <= (others => '0');
                human_move_latched <= (others => '0');
            else
                sqrSel <= (others => '0');
                
                case state is
                    when IDLE =>
                        if internalWin = '1' then
                            state <= GAME_OVER;
                        else
                            state <= SELECT_CELL;
                        end if;
                        
                    when SELECT_CELL =>
                        -- Check which switch is pressed (priority order)
                        if inPort(0) = '1' and is_empty(0, cellGames) then
                            selected_cell <= 0;
                            state <= EXECUTE_WAIT;
                        elsif inPort(1) = '1' and is_empty(1, cellGames) then
                            selected_cell <= 1;
                            state <= EXECUTE_WAIT;
                        elsif inPort(2) = '1' and is_empty(2, cellGames) then
                            selected_cell <= 2;
                            state <= EXECUTE_WAIT;
                        elsif inPort(3) = '1' and is_empty(3, cellGames) then
                            selected_cell <= 3;
                            state <= EXECUTE_WAIT;
                        elsif inPort(4) = '1' and is_empty(4, cellGames) then
                            selected_cell <= 4;
                            state <= EXECUTE_WAIT;
                        elsif inPort(5) = '1' and is_empty(5, cellGames) then
                            selected_cell <= 5;
                            state <= EXECUTE_WAIT;
                        elsif inPort(6) = '1' and is_empty(6, cellGames) then
                            selected_cell <= 6;
                            state <= EXECUTE_WAIT;
                        elsif inPort(7) = '1' and is_empty(7, cellGames) then
                            selected_cell <= 7;
                            state <= EXECUTE_WAIT;
                        elsif inPort(8) = '1' and is_empty(8, cellGames) then
                            selected_cell <= 8;
                            state <= EXECUTE_WAIT;
                        end if;
                        
                    when EXECUTE_WAIT =>
                        -- Wait for execute button
                        if execute = '1' and prev_execute = '0' then
                            -- Convert selected cell to move
                            case selected_cell is
                                when 0 => human_move_latched <= "000000001";
                                when 1 => human_move_latched <= "000000010";
                                when 2 => human_move_latched <= "000000100";
                                when 3 => human_move_latched <= "000001000";
                                when 4 => human_move_latched <= "000010000";
                                when 5 => human_move_latched <= "000100000";
                                when 6 => human_move_latched <= "001000000";
                                when 7 => human_move_latched <= "010000000";
                                when 8 => human_move_latched <= "100000000";
                                when others => null;
                            end case;
                            state <= HUMAN_TURN;
                        end if;
                        prev_execute <= execute;
                        
                    when HUMAN_TURN =>
                        sqrSel <= human_move_latched;
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
