library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sevenSegmentText is
    Port (
        clk        : in  STD_LOGIC;
        stateSel   : in  STD_LOGIC_VECTOR(1 downto 0);
        playerTurn : in  STD_LOGIC;
        winState   : in  STD_LOGIC;
        seg        : out STD_LOGIC_VECTOR(6 downto 0);
        an         : out STD_LOGIC_VECTOR(7 downto 0)
    );
end sevenSegmentText;

architecture Behavioral of sevenSegmentText is
    signal refresh_counter : std_logic_vector(19 downto 0);
    signal active_digit    : std_logic_vector(2 downto 0);
    signal char_to_decode  : character;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    active_digit <= refresh_counter(19 downto 17);

    process(active_digit, stateSel, playerTurn, winState)
    begin
        an             <= (others => '1');
        char_to_decode <= ' ';

        case active_digit is

            when "000" =>        
                an <= "11111110";
                if winState = '1' then
                    char_to_decode <= ' ';
                elsif stateSel = "00" then
                    char_to_decode <= 'U';
                elsif playerTurn = '0' then
                    char_to_decode <= '1';
                else
                    char_to_decode <= '2';
                end if;

            when "001" =>               
                an <= "11111101";
                if winState = '1' then
                    char_to_decode <= ' ';
                elsif stateSel = "00" then
                    char_to_decode <= 'N';
                else
                    char_to_decode <= 'P';
                end if;

            when "010" =>               
                an <= "11111011";
                if winState = '1' then
                    char_to_decode <= 'N';
                elsif stateSel = "00" then
                    char_to_decode <= 'E';
                else
                    char_to_decode <= '-';  
                end if;

            when "011" =>               
                an <= "11110111";
                if winState = '1' then
                    char_to_decode <= 'I';
                elsif stateSel = "00" then
                    char_to_decode <= 'M';
                elsif stateSel = "01" then
                    char_to_decode <= 'H';  
                else
                    char_to_decode <= 'A';
                end if;

            when "100" =>               
                an <= "11101111";
                if winState = '1' then
                    char_to_decode <= 'W';
                else
                    char_to_decode <= ' ';
                end if;

            when "101" =>               
                an <= "11011111";
                char_to_decode <= ' ';

            when "110" =>               
                an <= "10111111";
                if winState = '1' then
                    if playerTurn = '0' then
                        char_to_decode <= '2';
                    else
                        char_to_decode <= '1';
                    end if;
                else
                    char_to_decode <= ' ';
                end if;

            when "111" =>               --
                an <= "01111111";
                if winState = '1' then
                    char_to_decode <= 'P';
                else
                    char_to_decode <= ' ';
                end if;

            when others =>
                an <= (others => '1');
        end case;
    end process;

    -- ============================================================
    -- Decoder  Active Low: 0=ON 1=OFF  |   เริ่มไล่จาก g f e d c b a
    -- ============================================================

    process(char_to_decode)
    
    begin
        case char_to_decode is
           when 'M' => seg <= "1101010";  
            when 'E' => seg <= "0000110";
            when 'N' => seg <= "1001000";   
            when 'U' => seg <= "1000001";
            when 'H' => seg <= "0001001";
            when 'A' => seg <= "0001000";
            when 'P' => seg <= "0001100";
            when 'W' => seg <= "1010101";  
            when 'I' => seg <= "1111001";  
            when '1' => seg <= "1111001";
            when '2' => seg <= "0100100";
            when '-' => seg <= "0111111";
            when others => seg <= "1111111"; 
        end case;
    end process;

end Behavioral;