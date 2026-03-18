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
    signal clk_count   : integer := 0;
    signal heartbeat   : std_logic := '0';
    signal rst         : std_logic := '0';
    
    type state_t is (IDLE, SELECT_CELL, EXECUTE_MOVE);
    signal state : state_t := IDLE;
    signal prev_execute : std_logic := '0';
    signal selected_move : std_logic_vector(8 downto 0) := (others => '0');

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

    -- State machine with execute button
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                sqrSel <= (others => '0');
                turnReg <= '1';  -- X starts
                prev_execute <= '0';
                selected_move <= (others => '0');
            else
                sqrSel <= (others => '0');
                
                case state is
                    when IDLE =>
                        if internalWin = '0' then
                            state <= SELECT_CELL;
                        end if;
                        
                    when SELECT_CELL =>
                        -- Check which switch is pressed and if cell is empty
                        if inPort(0) = '1' and is_empty(0, cellGames) then
                            selected_move <= "000000001";
                            state <= EXECUTE_MOVE;
                        elsif inPort(1) = '1' and is_empty(1, cellGames) then
                            selected_move <= "000000010";
                            state <= EXECUTE_MOVE;
                        elsif inPort(2) = '1' and is_empty(2, cellGames) then
                            selected_move <= "000000100";
                            state <= EXECUTE_MOVE;
                        elsif inPort(3) = '1' and is_empty(3, cellGames) then
                            selected_move <= "000001000";
                            state <= EXECUTE_MOVE;
                        elsif inPort(4) = '1' and is_empty(4, cellGames) then
                            selected_move <= "000010000";
                            state <= EXECUTE_MOVE;
                        elsif inPort(5) = '1' and is_empty(5, cellGames) then
                            selected_move <= "000100000";
                            state <= EXECUTE_MOVE;
                        elsif inPort(6) = '1' and is_empty(6, cellGames) then
                            selected_move <= "001000000";
                            state <= EXECUTE_MOVE;
                        elsif inPort(7) = '1' and is_empty(7, cellGames) then
                            selected_move <= "010000000";
                            state <= EXECUTE_MOVE;
                        elsif inPort(8) = '1' and is_empty(8, cellGames) then
                            selected_move <= "100000000";
                            state <= EXECUTE_MOVE;
                        end if;
                        
                    when EXECUTE_MOVE =>
                        -- Wait for execute button press
                        if execute = '1' and prev_execute = '0' then
                            -- Execute the move
                            sqrSel <= selected_move;
                            turnReg <= not turnReg;
                            state <= IDLE;
                        end if;
                        prev_execute <= execute;
                        
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
