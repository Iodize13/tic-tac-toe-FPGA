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
            
            if (x_player(0) = '1' and x_player(1) = '1' and x_player(2) = '1') then
                win := '1'; colorCell <= "111111111";
		report "case: 0";
            elsif (x_player(3) = '1' and x_player(4) = '1' and x_player(5) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 1";
            elsif (x_player(6) = '1' and x_player(7) = '1' and x_player(8) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 2";
            elsif (x_player(0) = '1' and x_player(3) = '1' and x_player(6) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 3";
            elsif (x_player(1) = '1' and x_player(4) = '1' and x_player(7) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 4";
            elsif (x_player(2) = '1' and x_player(5) = '1' and x_player(8) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 5";
            elsif (x_player(0) = '1' and x_player(4) = '1' and x_player(8) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 6";
            elsif (x_player(2) = '1' and x_player(4) = '1' and x_player(6) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 7";
            elsif (o_player(0) = '1' and o_player(1) = '1' and o_player(2) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 8";
            elsif (o_player(3) = '1' and o_player(4) = '1' and o_player(5) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 9";
            elsif (o_player(6) = '1' and o_player(7) = '1' and o_player(8) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 10";
            elsif (o_player(0) = '1' and o_player(3) = '1' and o_player(6) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 11";
            elsif (o_player(1) = '1' and o_player(4) = '1' and o_player(7) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 12";
            elsif (o_player(2) = '1' and o_player(5) = '1' and o_player(8) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 13";
            elsif (o_player(0) = '1' and o_player(4) = '1' and o_player(8) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 14";
            elsif (o_player(2) = '1' and o_player(4) = '1' and o_player(6) = '1') then
                win := '1'; colorCell <= "111111111";
		-- report "case: 15";
            else
                colorCell <= (others => '0');
            end if;
            
            winState <= win;
        end if;
    end process;
end Behavioral;
