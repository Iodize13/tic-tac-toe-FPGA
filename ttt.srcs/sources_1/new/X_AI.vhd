library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- X_AI plays as O (11), blocks X (01)
-- Uses XO_AI_gl which already plays as O and blocks X
entity X_AI is
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
end X_AI;

architecture structural of X_AI is
    signal M0, M1, M2, M3, M4, M5, M6, M7, M8: STD_LOGIC;
    
    component XO_AI_gl
        Port (
            C0,C1,C2,C3,C4,C5,C6,C7,C8 : in STD_LOGIC_VECTOR(1 downto 0);
            M0,M1,M2,M3,M4,M5,M6,M7,M8 : out STD_LOGIC
        );
    end component;
begin
    -- Instantiate gate-level AI (plays as O, blocks X)
    AI_GL : XO_AI_gl
        port map (
            C0 => C0, C1 => C1, C2 => C2,
            C3 => C3, C4 => C4, C5 => C5,
            C6 => C6, C7 => C7, C8 => C8,
            M0 => M0, M1 => M1, M2 => M2,
            M3 => M3, M4 => M4, M5 => M5,
            M6 => M6, M7 => M7, M8 => M8
        );
    
    -- Output mapping: M8 & M7 & M6 & M5 & M4 & M3 & M2 & M1 & M0
    M_vec <= M8 & M7 & M6 & M5 & M4 & M3 & M2 & M1 & M0;
end structural;
