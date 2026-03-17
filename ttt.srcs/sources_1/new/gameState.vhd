-- work
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity gameState is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        cellState : in  STD_LOGIC_VECTOR(17 downto 0);
        winState  : out STD_LOGIC;
        colorCell : out STD_LOGIC_VECTOR(8 downto 0)
    );
end gameState;

architecture Behavioral of gameState is
begin
    process(clk, reset)
        variable cells : STD_LOGIC_VECTOR(17 downto 0);
        variable x_player : STD_LOGIC_VECTOR(8 downto 0);
        variable o_player : STD_LOGIC_VECTOR(8 downto 0);
        variable win : STD_LOGIC;
	variable row : line;
    begin
        if reset = '1' then
            winState <= '0';
            colorCell <= (others => '0');
        elsif rising_edge(clk) then
            cells := cellState;
            
            for i in 0 to 8 loop
                if cells(i*2+1 downto i*2) = "01" then
                    x_player(i) := '1';
                else
                    x_player(i) := '0';
                end if;
                
                if cells(i*2+1 downto i*2) = "11" then
                    o_player(i) := '1';
                else
                    o_player(i) := '0';
                end if;
            end loop;
            
            win := '0';
            colorCell <= (others => '0');
            
            -- X wins: top row
            if (x_player(0) = '1' and x_player(1) = '1' and x_player(2) = '1') then
                win := '1'; colorCell <= "000000111";
            -- X wins: middle row
            elsif (x_player(3) = '1' and x_player(4) = '1' and x_player(5) = '1') then
                win := '1'; colorCell <= "000111000";
            -- X wins: bottom row
            elsif (x_player(6) = '1' and x_player(7) = '1' and x_player(8) = '1') then
                win := '1'; colorCell <= "111000000";
            -- X wins: left column
            elsif (x_player(0) = '1' and x_player(3) = '1' and x_player(6) = '1') then
                win := '1'; colorCell <= "001001001";
            -- X wins: middle column
            elsif (x_player(1) = '1' and x_player(4) = '1' and x_player(7) = '1') then
                win := '1'; colorCell <= "010010010";
            -- X wins: right column
            elsif (x_player(2) = '1' and x_player(5) = '1' and x_player(8) = '1') then
                win := '1'; colorCell <= "100100100";
            -- X wins: diagonal top-left to bottom-right
            elsif (x_player(0) = '1' and x_player(4) = '1' and x_player(8) = '1') then
                win := '1'; colorCell <= "100010001";
            -- X wins: diagonal top-right to bottom-left
            elsif (x_player(2) = '1' and x_player(4) = '1' and x_player(6) = '1') then
                win := '1'; colorCell <= "001010100";
            -- O wins: top row
            elsif (o_player(0) = '1' and o_player(1) = '1' and o_player(2) = '1') then
                win := '1'; colorCell <= "000000111";
            -- O wins: middle row
            elsif (o_player(3) = '1' and o_player(4) = '1' and o_player(5) = '1') then
                win := '1'; colorCell <= "000111000";
            -- O wins: bottom row
            elsif (o_player(6) = '1' and o_player(7) = '1' and o_player(8) = '1') then
                win := '1'; colorCell <= "111000000";
            -- O wins: left column
            elsif (o_player(0) = '1' and o_player(3) = '1' and o_player(6) = '1') then
                win := '1'; colorCell <= "001001001";
            -- O wins: middle column
            elsif (o_player(1) = '1' and o_player(4) = '1' and o_player(7) = '1') then
                win := '1'; colorCell <= "010010010";
            -- O wins: right column
            elsif (o_player(2) = '1' and o_player(5) = '1' and o_player(8) = '1') then
                win := '1'; colorCell <= "100100100";
            -- O wins: diagonal top-left to bottom-right
            elsif (o_player(0) = '1' and o_player(4) = '1' and o_player(8) = '1') then
                win := '1'; colorCell <= "100010001";
            -- O wins: diagonal top-right to bottom-left
            elsif (o_player(2) = '1' and o_player(4) = '1' and o_player(6) = '1') then
                win := '1'; colorCell <= "001010100";
            end if;
            
            winState <= win;
        end if;
    end process;
end Behavioral;
