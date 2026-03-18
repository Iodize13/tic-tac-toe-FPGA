library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity XO_AI_gl is
    Port (
        C0,C1,C2,C3,C4,C5,C6,C7,C8 : in STD_LOGIC_VECTOR(1 downto 0);
        M0,M1,M2,M3,M4,M5,M6,M7,M8 : out STD_LOGIC
    );
end XO_AI_gl;

architecture gate_level of XO_AI_gl is

-- Decode state
signal O0,O1,O2,O3,O4,O5,O6,O7,O8 : STD_LOGIC;
signal X0,X1,X2,X3,X4,X5,X6,X7,X8 : STD_LOGIC;
signal E0,E1,E2,E3,E4,E5,E6,E7,E8 : STD_LOGIC;

-- Win / Block
signal W0,W1,W2,W3,W4,W5,W6,W7,W8 : STD_LOGIC;
signal B0,B1,B2,B3,B4,B5,B6,B7,B8 : STD_LOGIC;

-- Position
signal CENTER : STD_LOGIC;
signal CORNER0,CORNER2,CORNER6,CORNER8 : STD_LOGIC;
signal SIDE1,SIDE3,SIDE5,SIDE7 : STD_LOGIC;

signal CORNER_ANY : STD_LOGIC;

-- Priority flags
signal WIN_ANY,BLOCK_ANY : STD_LOGIC;

-- Candidate moves
signal S0,S1,S2,S3,S4,S5,S6,S7,S8 : STD_LOGIC;

begin

-- =====================================
-- Decode O
-- =====================================
O0 <= C0(1) and C0(0);
O1 <= C1(1) and C1(0);
O2 <= C2(1) and C2(0);
O3 <= C3(1) and C3(0);
O4 <= C4(1) and C4(0);
O5 <= C5(1) and C5(0);
O6 <= C6(1) and C6(0);
O7 <= C7(1) and C7(0);
O8 <= C8(1) and C8(0);

-- =====================================
-- Decode X
-- =====================================
X0 <= (not C0(1)) and C0(0);
X1 <= (not C1(1)) and C1(0);
X2 <= (not C2(1)) and C2(0);
X3 <= (not C3(1)) and C3(0);
X4 <= (not C4(1)) and C4(0);
X5 <= (not C5(1)) and C5(0);
X6 <= (not C6(1)) and C6(0);
X7 <= (not C7(1)) and C7(0);
X8 <= (not C8(1)) and C8(0);

-- =====================================
-- Decode EMPTY
-- =====================================
E0 <= (not C0(1)) and (not C0(0));
E1 <= (not C1(1)) and (not C1(0));
E2 <= (not C2(1)) and (not C2(0));
E3 <= (not C3(1)) and (not C3(0));
E4 <= (not C4(1)) and (not C4(0));
E5 <= (not C5(1)) and (not C5(0));
E6 <= (not C6(1)) and (not C6(0));
E7 <= (not C7(1)) and (not C7(0));
E8 <= (not C8(1)) and (not C8(0));

-- =====================================
-- WIN CONDITIONS
-- =====================================
W2 <= (O0 and O1 and E2) or (O5 and O8 and E2) or (O4 and O6 and E2);
W1 <= (O0 and O2 and E1) or (O4 and O7 and E1);
W0 <= (O1 and O2 and E0) or (O3 and O6 and E0) or (O4 and O8 and E0);

W5 <= (O3 and O4 and E5) or (O2 and O8 and E5);
W4 <= (O3 and O5 and E4) or (O1 and O7 and E4) or (O0 and O8 and E4) or (O2 and O6 and E4);
W3 <= (O4 and O5 and E3) or (O0 and O6 and E3);

W8 <= (O6 and O7 and E8) or (O2 and O5 and E8) or (O0 and O4 and E8);
W7 <= (O6 and O8 and E7) or (O1 and O4 and E7);
W6 <= (O7 and O8 and E6) or (O0 and O3 and E6) or (O2 and O4 and E6);

WIN_ANY <= W0 or W1 or W2 or W3 or W4 or W5 or W6 or W7 or W8;

-- =====================================
-- BLOCK X
-- =====================================
B2 <= (X0 and X1 and E2) or (X5 and X8 and E2) or (X4 and X6 and E2);
B1 <= (X0 and X2 and E1) or (X4 and X7 and E1);
B0 <= (X1 and X2 and E0) or (X3 and X6 and E0) or (X4 and X8 and E0);

B5 <= (X3 and X4 and E5) or (X2 and X8 and E5);
B4 <= (X3 and X5 and E4) or (X1 and X7 and E4) or (X0 and X8 and E4) or (X2 and X6 and E4);
B3 <= (X4 and X5 and E3) or (X0 and X6 and E3);

B8 <= (X6 and X7 and E8) or (X2 and X5 and E8) or (X0 and X4 and E8);
B7 <= (X6 and X8 and E7) or (X1 and X4 and E7);
B6 <= (X7 and X8 and E6) or (X0 and X3 and E6) or (X2 and X4 and E6);

BLOCK_ANY <= B0 or B1 or B2 or B3 or B4 or B5 or B6 or B7 or B8;

-- =====================================
-- POSITION
-- =====================================
CENTER <= E4;

CORNER0 <= E0;
CORNER2 <= E2;
CORNER6 <= E6;
CORNER8 <= E8;

CORNER_ANY <= CORNER0 or CORNER2 or CORNER6 or CORNER8;

SIDE1 <= E1;
SIDE3 <= E3;
SIDE5 <= E5;
SIDE7 <= E7;

-- =====================================
-- PRIORITY MOVE GENERATION
-- WIN > BLOCK > CENTER > CORNER > SIDE
-- =====================================
S0 <= W0 or ((not WIN_ANY) and B0) or ((not WIN_ANY) and (not BLOCK_ANY) and (not CENTER) and CORNER0);
S1 <= W1 or ((not WIN_ANY) and B1) or ((not WIN_ANY) and (not BLOCK_ANY) and (not CENTER) and (not CORNER_ANY) and SIDE1);
S2 <= W2 or ((not WIN_ANY) and B2) or ((not WIN_ANY) and (not BLOCK_ANY) and (not CENTER) and CORNER2);
S3 <= W3 or ((not WIN_ANY) and B3) or ((not WIN_ANY) and (not BLOCK_ANY) and (not CENTER) and (not CORNER_ANY) and SIDE3);
S4 <= W4 or ((not WIN_ANY) and B4) or ((not WIN_ANY) and (not BLOCK_ANY) and CENTER);
S5 <= W5 or ((not WIN_ANY) and B5) or ((not WIN_ANY) and (not BLOCK_ANY) and (not CENTER) and (not CORNER_ANY) and SIDE5);
S6 <= W6 or ((not WIN_ANY) and B6) or ((not WIN_ANY) and (not BLOCK_ANY) and (not CENTER) and CORNER6);
S7 <= W7 or ((not WIN_ANY) and B7) or ((not WIN_ANY) and (not BLOCK_ANY) and (not CENTER) and (not CORNER_ANY) and SIDE7);
S8 <= W8 or ((not WIN_ANY) and B8) or ((not WIN_ANY) and (not BLOCK_ANY) and (not CENTER) and CORNER8);

-- =====================================
-- PRIORITY ENCODER
-- =====================================
M0 <= S0;
M1 <= (not S0) and S1;
M2 <= (not S0) and (not S1) and S2;
M3 <= (not S0) and (not S1) and (not S2) and S3;
M4 <= (not S0) and (not S1) and (not S2) and (not S3) and S4;
M5 <= (not S0) and (not S1) and (not S2) and (not S3) and (not S4) and S5;
M6 <= (not S0) and (not S1) and (not S2) and (not S3) and (not S4) and (not S5) and S6;
M7 <= (not S0) and (not S1) and (not S2) and (not S3) and (not S4) and (not S5) and (not S6) and S7;
M8 <= (not S0) and (not S1) and (not S2) and (not S3) and (not S4) and (not S5) and (not S6) and (not S7) and S8;

end gate_level;

