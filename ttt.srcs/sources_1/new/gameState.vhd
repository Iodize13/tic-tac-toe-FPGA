library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gameState is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        cellState : in  STD_LOGIC_VECTOR(17 downto 0);
        winState  : out STD_LOGIC;
        colorCell : out STD_LOGIC_VECTOR(8 downto 0)
    );
end gameState;

architecture GateLevel of gameState is

    -- Present State register
    signal PS : std_logic := '0';
    signal NS : std_logic;
    
    -- Decoded X and O positions
    signal X0,X1,X2,X3,X4,X5,X6,X7,X8 : std_logic;
    signal O0,O1,O2,O3,O4,O5,O6,O7,O8 : std_logic;
    
    -- Win detection signals
    signal X_win, O_win : std_logic;
    signal row1_X, row2_X, row3_X : std_logic;
    signal col1_X, col2_X, col3_X : std_logic;
    signal diag1_X, diag2_X : std_logic;
    signal row1_O, row2_O, row3_O : std_logic;
    signal col1_O, col2_O, col3_O : std_logic;
    signal diag1_O, diag2_O : std_logic;
    
    -- Color encoding signals
    signal c1,c2,c3,c4,c5,c6,c7,c8 : std_logic;

begin

    -- =====================================
    -- Decode cellState into X and O positions
    -- X = "01" (bit 0 = 1, bit 1 = 0)
    -- O = "11" (bit 0 = 1, bit 1 = 1)
    -- Empty = "00"
    -- =====================================
    
    -- X detection: cellState(i*2) = '1' AND cellState(i*2+1) = '0'
    X0 <= cellState(0) and (not cellState(1));
    X1 <= cellState(2) and (not cellState(3));
    X2 <= cellState(4) and (not cellState(5));
    X3 <= cellState(6) and (not cellState(7));
    X4 <= cellState(8) and (not cellState(9));
    X5 <= cellState(10) and (not cellState(11));
    X6 <= cellState(12) and (not cellState(13));
    X7 <= cellState(14) and (not cellState(15));
    X8 <= cellState(16) and (not cellState(17));
    
    -- O detection: cellState(i*2) = '1' AND cellState(i*2+1) = '1'
    O0 <= cellState(0) and cellState(1);
    O1 <= cellState(2) and cellState(3);
    O2 <= cellState(4) and cellState(5);
    O3 <= cellState(6) and cellState(7);
    O4 <= cellState(8) and cellState(9);
    O5 <= cellState(10) and cellState(11);
    O6 <= cellState(12) and cellState(13);
    O7 <= cellState(14) and cellState(15);
    O8 <= cellState(16) and cellState(17);

    -- =====================================
    -- X Win Detection (3 in a row)
    -- =====================================
    
    -- Rows
    row1_X <= X0 and X1 and X2;  -- Top row
    row2_X <= X3 and X4 and X5;  -- Middle row
    row3_X <= X6 and X7 and X8;  -- Bottom row
    
    -- Columns
    col1_X <= X0 and X3 and X6;  -- Left column
    col2_X <= X1 and X4 and X7;  -- Middle column
    col3_X <= X2 and X5 and X8;  -- Right column
    
    -- Diagonals
    diag1_X <= X0 and X4 and X8;  -- Top-left to bottom-right
    diag2_X <= X2 and X4 and X6;  -- Top-right to bottom-left
    
    -- Combined X win
    X_win <= row1_X or row2_X or row3_X or col1_X or col2_X or col3_X or diag1_X or diag2_X;

    -- =====================================
    -- O Win Detection (3 in a row)
    -- =====================================
    
    -- Rows
    row1_O <= O0 and O1 and O2;  -- Top row
    row2_O <= O3 and O4 and O5;  -- Middle row
    row3_O <= O6 and O7 and O8;  -- Bottom row
    
    -- Columns
    col1_O <= O0 and O3 and O6;  -- Left column
    col2_O <= O1 and O4 and O7;  -- Middle column
    col3_O <= O2 and O5 and O8;  -- Right column
    
    -- Diagonals
    diag1_O <= O0 and O4 and O8;  -- Top-left to bottom-right
    diag2_O <= O2 and O4 and O6;  -- Top-right to bottom-left
    
    -- Combined O win
    O_win <= row1_O or row2_O or row3_O or col1_O or col2_O or col3_O or diag1_O or diag2_O;

    -- =====================================
    -- Win State Register
    -- =====================================
    
    -- Next state: set to 1 if win detected, stay 1 once set
    NS <= PS or X_win or O_win;
    
    -- State register with asynchronous reset
    process(clk, reset)
    begin
        if reset = '1' then
            PS <= '0';
        elsif rising_edge(clk) then
            PS <= NS;
        end if;
    end process;
    
    -- Output
    winState <= PS;

    -- =====================================
    -- Color Encoding (which cells to highlight)
    -- Priority encoder: only show first win line
    -- =====================================
    
    c1 <= row1_X or row1_O;
    c2 <= (not c1) and (row2_X or row2_O);
    c3 <= (not c1) and (not c2) and (row3_X or row3_O);
    c4 <= (not c1) and (not c2) and (not c3) and (col1_X or col1_O);
    c5 <= (not c1) and (not c2) and (not c3) and (not c4) and (col2_X or col2_O);
    c6 <= (not c1) and (not c2) and (not c3) and (not c4) and (not c5) and (col3_X or col3_O);
    c7 <= (not c1) and (not c2) and (not c3) and (not c4) and (not c5) and (not c6) and (diag1_X or diag1_O);
    c8 <= (not c1) and (not c2) and (not c3) and (not c4) and (not c5) and (not c6) and (not c7) and (diag2_X or diag2_O);
    
    colorCell <=
        ("000000111" and (8 downto 0 => c1)) or
        ("000111000" and (8 downto 0 => c2)) or
        ("111000000" and (8 downto 0 => c3)) or
        ("001001001" and (8 downto 0 => c4)) or
        ("010010010" and (8 downto 0 => c5)) or
        ("100100100" and (8 downto 0 => c6)) or
        ("100010001" and (8 downto 0 => c7)) or
        ("001010100" and (8 downto 0 => c8));

end GateLevel;
