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

    signal PS, NS : std_logic;

    signal h1,h2,h3,v1,v2,v3,d1,d2 : std_logic;
    signal w1,w2,w3,w4,w5,w6,w7,w8 : std_logic;

begin

-- =====================================
-- Win Detection Logic (Combinational)
-- =====================================

-- Horizontal row 1 (cells 0,1,2)
h1 <=
(
 ((cellState(0) and cellState(2)) or ((not cellState(0)) and (not cellState(2)))) and
 ((cellState(1) and cellState(3)) or ((not cellState(1)) and (not cellState(3)))) and
 ((cellState(2) and cellState(4)) or ((not cellState(2)) and (not cellState(4)))) and
 (cellState(0) or cellState(1))
);

-- Horizontal row 2 (cells 3,4,5)
h2 <=
(
 ((cellState(6) and cellState(8)) or ((not cellState(6)) and (not cellState(8)))) and
 ((cellState(7) and cellState(9)) or ((not cellState(7)) and (not cellState(9)))) and
 ((cellState(8) and cellState(10)) or ((not cellState(8)) and (not cellState(10)))) and
 (cellState(6) or cellState(7))
);

-- Horizontal row 3 (cells 6,7,8)
h3 <=
(
 ((cellState(12) and cellState(14)) or ((not cellState(12)) and (not cellState(14)))) and
 ((cellState(13) and cellState(15)) or ((not cellState(13)) and (not cellState(15)))) and
 ((cellState(14) and cellState(16)) or ((not cellState(14)) and (not cellState(16)))) and
 (cellState(12) or cellState(13))
);

-- Vertical column 1 (cells 0,3,6)
v1 <=
(
 ((cellState(0) and cellState(6)) or ((not cellState(0)) and (not cellState(6)))) and
 ((cellState(1) and cellState(7)) or ((not cellState(1)) and (not cellState(7)))) and
 ((cellState(6) and cellState(12)) or ((not cellState(6)) and (not cellState(12)))) and
 (cellState(0) or cellState(1))
);

-- Vertical column 2 (cells 1,4,7)
v2 <=
(
 ((cellState(2) and cellState(8)) or ((not cellState(2)) and (not cellState(8)))) and
 ((cellState(3) and cellState(9)) or ((not cellState(3)) and (not cellState(9)))) and
 ((cellState(8) and cellState(14)) or ((not cellState(8)) and (not cellState(14)))) and
 (cellState(2) or cellState(3))
);

-- Vertical column 3 (cells 2,5,8)
v3 <=
(
 ((cellState(4) and cellState(10)) or ((not cellState(4)) and (not cellState(10)))) and
 ((cellState(5) and cellState(11)) or ((not cellState(5)) and (not cellState(11)))) and
 ((cellState(10) and cellState(16)) or ((not cellState(10)) and (not cellState(16)))) and
 (cellState(4) or cellState(5))
);

-- Diagonal 1 (cells 0,4,8)
d1 <=
(
 ((cellState(0) and cellState(8)) or ((not cellState(0)) and (not cellState(8)))) and
 ((cellState(1) and cellState(9)) or ((not cellState(1)) and (not cellState(9)))) and
 ((cellState(8) and cellState(16)) or ((not cellState(8)) and (not cellState(16)))) and
 (cellState(0) or cellState(1))
);

-- Diagonal 2 (cells 2,4,6)
d2 <=
(
 ((cellState(4) and cellState(8)) or ((not cellState(4)) and (not cellState(8)))) and
 ((cellState(5) and cellState(9)) or ((not cellState(5)) and (not cellState(9)))) and
 ((cellState(8) and cellState(12)) or ((not cellState(8)) and (not cellState(12)))) and
 (cellState(4) or cellState(5))
);

-- Priority encoder for win lines
w1 <= h1;
w2 <= (not w1) and h2;
w3 <= (not w1) and (not w2) and h3;
w4 <= (not w1) and (not w2) and (not w3) and v1;
w5 <= (not w1) and (not w2) and (not w3) and (not w4) and v2;
w6 <= (not w1) and (not w2) and (not w3) and (not w4) and (not w5) and v3;
w7 <= (not w1) and (not w2) and (not w3) and (not w4) and (not w5) and (not w6) and d1;
w8 <= (not w1) and (not w2) and (not w3) and (not w4) and (not w5) and (not w6) and (not w7) and d2;

-- Next state logic
NS <= PS or ((not PS) and (w1 or w2 or w3 or w4 or w5 or w6 or w7 or w8));

-- State register with reset
process(clk, reset)
begin
    if reset = '1' then
        PS <= '0';
    elsif rising_edge(clk) then
        PS <= NS;
    end if;
end process;

-- Output assignments
winState <= PS;

colorCell <=
    ("000000111" and (8 downto 0 => w1)) or
    ("000111000" and (8 downto 0 => w2)) or
    ("111000000" and (8 downto 0 => w3)) or
    ("001001001" and (8 downto 0 => w4)) or
    ("010010010" and (8 downto 0 => w5)) or
    ("100100100" and (8 downto 0 => w6)) or
    ("100010001" and (8 downto 0 => w7)) or
    ("001010100" and (8 downto 0 => w8));

end GateLevel;
