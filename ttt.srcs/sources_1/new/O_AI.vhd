library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- O_AI plays as X (01), blocks O (11)
-- Uses XO_AI_gl with swapped inputs (X<->O)
entity O_AI is
    Port (
        clk: STD_LOGIC;
        C0 : in STD_LOGIC_VECTOR(1 downto 0);
        C1 : in STD_LOGIC_VECTOR(1 downto 0);
        C2 : in STD_LOGIC_VECTOR(1 downto 0);
        C3 : in STD_LOGIC_VECTOR(1 downto 0);
        C4 : in STD_LOGIC_VECTOR(1 downto 0);
        C5 : in STD_LOGIC_VECTOR(1 downto 0);
        C6 : in STD_LOGIC_VECTOR(1 downto 0);
        C7 : in STD_LOGIC_VECTOR(1 downto 0);
        C8 : in STD_LOGIC_VECTOR(1 downto 0);
        M_vec: out STD_LOGIC_VECTOR(8 downto 0)
    );
end O_AI;

architecture structural of O_AI is
    signal M0, M1, M2, M3, M4, M5, M6, M7, M8: STD_LOGIC;
    
    -- Swapped cell signals (swap X and O for XO_AI_gl)
    signal S0, S1, S2, S3, S4, S5, S6, S7, S8 : STD_LOGIC_VECTOR(1 downto 0);
    
    component XO_AI_gl
        Port (
            C0,C1,C2,C3,C4,C5,C6,C7,C8 : in STD_LOGIC_VECTOR(1 downto 0);
            M0,M1,M2,M3,M4,M5,M6,M7,M8 : out STD_LOGIC
        );
    end component;
begin
    -- Swap X (01) and O (11) for each cell
    -- O("11") → present as X("01") to AI (so AI will block it)
    -- X("01") → present as O("11") to AI (so AI will win with it)
    -- E("00") → present as E("00") to AI
    S0 <= "01" when C0 = "11" else  -- O becomes X
          "11" when C0 = "01" else  -- X becomes O
          "00";                       -- Empty stays empty
    S1 <= "01" when C1 = "11" else
          "11" when C1 = "01" else
          "00";
    S2 <= "01" when C2 = "11" else
          "11" when C2 = "01" else
          "00";
    S3 <= "01" when C3 = "11" else
          "11" when C3 = "01" else
          "00";
    S4 <= "01" when C4 = "11" else
          "11" when C4 = "01" else
          "00";
    S5 <= "01" when C5 = "11" else
          "11" when C5 = "01" else
          "00";
    S6 <= "01" when C6 = "11" else
          "11" when C6 = "01" else
          "00";
    S7 <= "01" when C7 = "11" else
          "11" when C7 = "01" else
          "00";
    S8 <= "01" when C8 = "11" else
          "11" when C8 = "01" else
          "00";
    
    -- Instantiate gate-level AI with swapped inputs
    AI_GL : XO_AI_gl
        port map (
            C0 => S0, C1 => S1, C2 => S2,
            C3 => S3, C4 => S4, C5 => S5,
            C6 => S6, C7 => S7, C8 => S8,
            M0 => M0, M1 => M1, M2 => M2,
            M3 => M3, M4 => M4, M5 => M5,
            M6 => M6, M7 => M7, M8 => M8
        );
    
    -- Output mapping
    M_vec <= M8 & M7 & M6 & M5 & M4 & M3 & M2 & M1 & M0;
end structural;
