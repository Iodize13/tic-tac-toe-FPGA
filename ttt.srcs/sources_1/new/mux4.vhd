library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4 is
    Port (
	     a0 : in  STD_LOGIC;
	     a1 : in  STD_LOGIC;
	     a2 : in  STD_LOGIC;
	     a3 : in  STD_LOGIC_VECTOR(11 downto 0);  -- RGB for state 11
	     b0 : in  STD_LOGIC;
	     b1 : in  STD_LOGIC;
	     b2 : in  STD_LOGIC;
	     b3 : in  STD_LOGIC_VECTOR(11 downto 0);  -- RGB for state 11
	     sel : in  STD_LOGIC_VECTOR(1 downto 0);
	     y0   : out STD_LOGIC;
	     y1   : out STD_LOGIC;
	     y2   : out STD_LOGIC;
	     y3   : out STD_LOGIC_VECTOR(11 downto 0)
         );
end mux4;

architecture Behavioral of mux4 is
begin
    process(a0, a1, a2, a3, b0, b1, b2, b3, sel)
    begin
	if sel = "1X" then
	    report "mux: case 1";
            y0 <= b0;
            y1 <= b1;
            y2 <= b2;
            y3 <= b3;
	else
            y0 <= a0;
            y1 <= a1;
            y2 <= a2;
            y3 <= a3;
	end if;
    end process;
end Behavioral;
