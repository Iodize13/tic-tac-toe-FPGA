library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Cell is
    Port (
        clk   : in  STD_LOGIC;
        Sel   : in  STD_LOGIC;
        Turn  : in  STD_LOGIC;
        Reset : in  STD_LOGIC;
        State : out STD_LOGIC_VECTOR (1 downto 0)
    );
end Cell;

architecture Behavioral of Cell is

    type states is (N, X, O);
    signal PS, NS : states;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if Reset = '1' then
                PS <= N;
            else
                PS <= NS;
            end if;
        end if;
    end process;

    process(PS, Sel, Turn)
    begin
        case PS is
        
            when N =>
                State <= "00";
                
                if (Sel = '1' and Turn = '0') then
                    NS <= X;
                elsif (Sel = '1' and Turn = '1') then
                    NS <= O;
                else
                    NS <= PS;
                end if;
                
            when X =>
                State <= "01";
                NS <= PS;
                
            when O =>
                State <= "11";
                NS <= PS;
                
        end case;
    end process;

end Behavioral;