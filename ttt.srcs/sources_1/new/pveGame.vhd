library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pveGame is
    port(
        inPort    : in  std_logic_vector(8 downto 0);
        reset     : in  std_logic;
        clk       : in  std_logic;
        playFirst : in  std_logic;  -- '1' = Human first (as X), '0' = AI first (human as O)
        hsync     : out std_logic;
        vsync     : out std_logic;
        rgb       : out std_logic_vector(11 downto 0);
        winState  : out std_logic;
        cellTemp  : out std_logic_vector(17 downto 0)
    );
end pveGame;

architecture structural of pveGame is
    signal sqrSel      : std_logic_vector(8 downto 0);
    signal cellGames   : std_logic_vector(17 downto 0);
    signal turnReg     : std_logic := '1';  -- X starts
    signal colorSig    : std_logic_vector(8 downto 0); 
    signal internalWin : std_logic;
    signal clk_count   : integer := 0;
    signal heartbeat   : std_logic := '0';
    signal rst         : std_logic := '0';
    
    -- State machine
    type state_t is (INIT, IDLE, HUMAN_TURN, AI_DELAY, AI_TURN, GAME_OVER);
    signal state : state_t := INIT;
    signal delay_cnt : integer range 0 to 15 := 0;
    signal prev_inPort : std_logic_vector(8 downto 0) := (others => '0');
    signal ai_move_latched : std_logic_vector(8 downto 0) := (others => '0');
    signal human_move_latched : std_logic_vector(8 downto 0) := (others => '0');
    signal ai_first_done : std_logic := '0';
    
    signal M_x_ai      : std_logic_vector(8 downto 0);
    signal M_o_ai      : std_logic_vector(8 downto 0);
    signal M_inter     : std_logic_vector(8 downto 0);

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
    
    component O_AI
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

    -- AI components - both always calculate
    X_AI_INST : X_AI port map (
        clk => clk, C0 => cellGames(1 downto 0), C1 => cellGames(3 downto 2),
        C2 => cellGames(5 downto 4), C3 => cellGames(7 downto 6), C4 => cellGames(9 downto 8),
        C5 => cellGames(11 downto 10), C6 => cellGames(13 downto 12), C7 => cellGames(15 downto 14),
        C8 => cellGames(17 downto 16), M_vec => M_x_ai);
        
    O_AI_INST : O_AI port map (
        clk => clk, C0 => cellGames(1 downto 0), C1 => cellGames(3 downto 2),
        C2 => cellGames(5 downto 4), C3 => cellGames(7 downto 6), C4 => cellGames(9 downto 8),
        C5 => cellGames(11 downto 10), C6 => cellGames(13 downto 12), C7 => cellGames(15 downto 14),
        C8 => cellGames(17 downto 16), M_vec => M_o_ai);
    
    -- Mux: when playFirst='1', human is X so AI is O (use X_AI)
    --      when playFirst='0', human is O so AI is X (use O_AI)
    M_inter <= M_x_ai when playFirst = '1' else M_o_ai;

    -- State machine - handles both human and AI turns
    process(clk)
        variable inPort_diff : std_logic_vector(8 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= INIT;
                sqrSel <= (others => '0');
                turnReg <= '1';  -- X always starts
                delay_cnt <= 0;
                prev_inPort <= (others => '0');
                ai_move_latched <= (others => '0');
                human_move_latched <= (others => '0');
                ai_first_done <= '0';
            else
                sqrSel <= (others => '0');  -- Default: no move
                
                case state is
                    when INIT =>
                        -- Determine who starts
                        if playFirst = '1' then
                            state <= IDLE;  -- Human (X) starts
                        else
                            state <= AI_DELAY;  -- AI (X) starts
                            delay_cnt <= 0;
                        end if;
                        
                    when IDLE =>
                        if internalWin = '1' then
                            state <= GAME_OVER;
                        else
                            -- Check for input change (edge detection)
                            inPort_diff := inPort and (not prev_inPort);
                            if inPort_diff /= "000000000" then
                                -- Find which cell was pressed
                                if inPort_diff(0) = '1' and is_empty(0, cellGames) then
                                    human_move_latched <= "000000001";
                                    state <= HUMAN_TURN;
                                elsif inPort_diff(1) = '1' and is_empty(1, cellGames) then
                                    human_move_latched <= "000000010";
                                    state <= HUMAN_TURN;
                                elsif inPort_diff(2) = '1' and is_empty(2, cellGames) then
                                    human_move_latched <= "000000100";
                                    state <= HUMAN_TURN;
                                elsif inPort_diff(3) = '1' and is_empty(3, cellGames) then
                                    human_move_latched <= "000001000";
                                    state <= HUMAN_TURN;
                                elsif inPort_diff(4) = '1' and is_empty(4, cellGames) then
                                    human_move_latched <= "000010000";
                                    state <= HUMAN_TURN;
                                elsif inPort_diff(5) = '1' and is_empty(5, cellGames) then
                                    human_move_latched <= "000100000";
                                    state <= HUMAN_TURN;
                                elsif inPort_diff(6) = '1' and is_empty(6, cellGames) then
                                    human_move_latched <= "001000000";
                                    state <= HUMAN_TURN;
                                elsif inPort_diff(7) = '1' and is_empty(7, cellGames) then
                                    human_move_latched <= "010000000";
                                    state <= HUMAN_TURN;
                                elsif inPort_diff(8) = '1' and is_empty(8, cellGames) then
                                    human_move_latched <= "100000000";
                                    state <= HUMAN_TURN;
                                end if;
                            end if;
                            prev_inPort <= inPort;
                        end if;
                        
                    when HUMAN_TURN =>
                        -- Execute human move for one cycle
                        sqrSel <= human_move_latched;
                        -- Toggle turn and go to AI
                        turnReg <= not turnReg;
                        delay_cnt <= 0;
                        state <= AI_DELAY;
                        
                    when AI_DELAY =>
                        -- Small delay then latch AI move
                        if delay_cnt < 5 then
                            delay_cnt <= delay_cnt + 1;
                        else
                            ai_move_latched <= M_inter;
                            delay_cnt <= 0;
                            state <= AI_TURN;
                        end if;
                        
                    when AI_TURN =>
                        -- Execute AI move for one cycle
                        sqrSel <= ai_move_latched;
                        -- Toggle turn and go back to idle
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
     
    STATE_INST : gameState 
        port map (clk => clk, reset => rst, cellState => cellGames, 
                  winState => internalWin, colorCell => colorSig);

    VGA_INST : videoElement
        port map (clk => clk, reset => rst, hsync => hsync, vsync => vsync, 
                  rgb => rgb, Cells => cellGames, Color => colorSig, Turn => turnReg);

    GEN_CELLS: for i in 0 to 8 generate
        CELL_I : Cell
            port map(clk => clk, reset => rst, turn => turnReg,
                     sel => sqrSel(i), State => cellGames((i*2)+1 downto i*2));
    end generate;

    cellTemp <= cellGames;
end structural;
