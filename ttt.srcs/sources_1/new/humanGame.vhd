library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity humanGame is
    port(
        inPort   : in  std_logic_vector(8 downto 0);
        execute  : in  std_logic;  -- Execute button
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
    signal turnReg     : std_logic := '1';
    signal colorSig    : std_logic_vector(8 downto 0); 
    signal internalWin : std_logic;
    signal rst         : std_logic := '0';
    
    type state_t is (IDLE, SELECT_CELL, EXECUTE_MOVE);
    signal state : state_t := IDLE;
    signal selected_move : std_logic_vector(8 downto 0) := (others => '0');
    signal execute_debounced : std_logic := '0';
    signal execute_prev : std_logic := '0';

    function is_empty(cell_idx : integer; cells : std_logic_vector(17 downto 0)) return boolean is
    begin
        return cells(cell_idx*2+1 downto cell_idx*2) = "00";
    end function;

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
    EXEC_DEBOUNCE : button_debouncer
        generic map (
            CLK_FREQ    => 100_000_000,
            DEBOUNCE_MS => 10
        )
        port map (
            Clk     => clk,
            BTN_In  => execute,
            BTN_Out => execute_debounced
        );

    -- Input decoder for switch selection
    DECODER : inputDecoder
        port map (
            internalWin => internalWin,
            inPort      => inPort,
            cellGame    => cellGames,
            SqrSel      => decoder_sel
        );

    -- State machine with execute button
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                sqrSel <= (others => '0');
                turnReg <= '1';  -- X starts
                execute_prev <= '0';
                selected_move <= (others => '0');
            else
                sqrSel <= (others => '0');
                
                case state is
                    when IDLE =>
                        if internalWin = '0' then
                            state <= SELECT_CELL;
                        end if;
                        
                    when SELECT_CELL =>
                        -- Use inputDecoder to check which switch is pressed
                        if decoder_sel /= "000000000" then
                            selected_move <= decoder_sel;
                            state <= EXECUTE_MOVE;
                        end if;
                        
                    when EXECUTE_MOVE =>
                        -- Check if switch is still held
                        if (selected_move and inPort) = "000000000" then
                            -- Switch released, go back to selection
                            state <= SELECT_CELL;
                        elsif execute_debounced = '1' and execute_prev = '0' then
                            -- Execute the move only if switch still held
                            sqrSel <= selected_move;
                            turnReg <= not turnReg;
                            state <= IDLE;
                        end if;
                        execute_prev <= execute_debounced;
                        
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
                
end structural;
