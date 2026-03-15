library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity XO_AI is
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

        -- M0, M1, M2,
        -- M3, M4, M5,
        -- M6, M7, M8 : out STD_LOGIC
	M_vec: out STD_LOGIC_VECTOR(8 downto 0)
    );
end XO_AI;

architecture Behavioral of XO_AI is
        signal M0, M1, M2, M3, M4, M5, M6, M7, M8: STD_LOGIC;
begin

-- process(C0,C1,C2,C3,C4,C5,C6,C7,C8)
process(clk)
begin

    -- default
    M0<='0'; M1<='0'; M2<='0';
    M3<='0'; M4<='0'; M5<='0';
    M6<='0'; M7<='0'; M8<='0';

    -------------------------------------------------
    -- 1) O Win (11)
    -------------------------------------------------

    -- Rows
    if (C0="01" and C1="01" and C2="00") then M2<='1';
    elsif (C0="01" and C2="01" and C1="00") then M1<='1';
    elsif (C1="01" and C2="01" and C0="00") then M0<='1';

    elsif (C3="01" and C4="01" and C5="00") then M5<='1';
    elsif (C3="01" and C5="01" and C4="00") then M4<='1';
    elsif (C4="01" and C5="01" and C3="00") then M3<='1';

    elsif (C6="01" and C7="01" and C8="00") then M8<='1';
    elsif (C6="01" and C8="01" and C7="00") then M7<='1';
    elsif (C7="01" and C8="01" and C6="00") then M6<='1';

    -- Columns
    elsif (C0="01" and C3="01" and C6="00") then M6<='1';
    elsif (C0="01" and C6="01" and C3="00") then M3<='1';
    elsif (C3="01" and C6="01" and C0="00") then M0<='1';

    elsif (C1="01" and C4="01" and C7="00") then M7<='1';
    elsif (C1="01" and C7="01" and C4="00") then M4<='1';
    elsif (C4="01" and C7="01" and C1="00") then M1<='1';

    elsif (C2="01" and C5="01" and C8="00") then M8<='1';
    elsif (C2="01" and C8="01" and C5="00") then M5<='1';
    elsif (C5="01" and C8="01" and C2="00") then M2<='1';

    -- Diagonals
    elsif (C0="01" and C4="01" and C8="00") then M8<='1';
    elsif (C0="01" and C8="01" and C4="00") then M4<='1';
    elsif (C4="01" and C8="01" and C0="00") then M0<='1';

    elsif (C2="01" and C4="01" and C6="00") then M6<='1';
    elsif (C2="01" and C6="01" and C4="00") then M4<='1';
    elsif (C4="01" and C6="01" and C2="00") then M2<='1';

    -------------------------------------------------
    -- 2) Block X (11)
    -------------------------------------------------

    -- Rows
    elsif (C0="11" and C1="11" and C2="00") then M2<='1';
    elsif (C0="11" and C2="11" and C1="00") then M1<='1';
    elsif (C1="11" and C2="11" and C0="00") then M0<='1';

    elsif (C3="11" and C4="11" and C5="00") then M5<='1';
    elsif (C3="11" and C5="11" and C4="00") then M4<='1';
    elsif (C4="11" and C5="11" and C3="00") then M3<='1';

    elsif (C6="11" and C7="11" and C8="00") then M8<='1';
    elsif (C6="11" and C8="11" and C7="00") then M7<='1';
    elsif (C7="11" and C8="11" and C6="00") then M6<='1';

    -- Columns
    elsif (C0="11" and C3="11" and C6="00") then M6<='1';
    elsif (C0="11" and C6="11" and C3="00") then M3<='1';
    elsif (C3="11" and C6="11" and C0="00") then M0<='1';

    elsif (C1="11" and C4="11" and C7="00") then M7<='1';
    elsif (C1="11" and C7="11" and C4="00") then M4<='1';
    elsif (C4="11" and C7="11" and C1="00") then M1<='1';

    elsif (C2="11" and C5="11" and C8="00") then M8<='1';
    elsif (C2="11" and C8="11" and C5="00") then M5<='1';
    elsif (C5="11" and C8="11" and C2="00") then M2<='1';

    -- Diagonals
    elsif (C0="11" and C4="11" and C8="00") then M8<='1';
    elsif (C0="11" and C8="11" and C4="00") then M4<='1';
    elsif (C4="11" and C8="11" and C0="00") then M0<='1';

    elsif (C2="11" and C4="11" and C6="00") then M6<='1';
    elsif (C2="11" and C6="11" and C4="00") then M4<='1';
    elsif (C4="11" and C6="11" and C2="00") then M2<='1';

    -------------------------------------------------
    -- 3) Center
    -------------------------------------------------
    elsif (C4="00") then M4<='1';

    -------------------------------------------------
    -- 4) Corners
    -------------------------------------------------
    elsif (C0="00") then M0<='1';
    elsif (C2="00") then M2<='1';
    elsif (C6="00") then M6<='1';
    elsif (C8="00") then M8<='1';

    -------------------------------------------------
    -- 5) Sides
    -------------------------------------------------
    elsif (C1="00") then M1<='1';
    elsif (C3="00") then M3<='1';
    elsif (C5="00") then M5<='1';
    elsif (C7="00") then M7<='1';

    end if;

    -- M_vec <= M6 & M7 & M8 & M3 & M4 & M5 & M0 & M1 & M2;
    M_vec <= M8 & M7 & M6 & M5 & M4 & M3 & M2 & M1 & M0;

end process;

end Behavioral;
