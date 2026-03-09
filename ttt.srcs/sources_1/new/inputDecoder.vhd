library ieee;
use ieee.std_logic_1164.all;

entity inputDecoder is
    port(
        internalWin:in std_logic;
        inPort:in std_logic_vector(8 downto 0);
        cellGame:in std_logic_vector(17 downto 0);
        SqrSel:out std_logic_vector(8 downto 0)
    );
end inputDecoder;

architecture Behavioral of inputDecoder is
    signal c :std_logic_vector(8 downto 0);
    signal p :std_logic_vector(8 downto 0);
    signal active:std_logic;

begin 
    
    active <=not internalWin;
    c(8) <= inPort(6) and not cellGame(16);
    c(7) <= inPort(7) and not cellGame(14);
    c(6) <= inPort(8) and not cellGame(12);
    c(5) <= inPort(3) and not cellGame(10);
    c(4) <= inPort(4) and not cellGame(8);
    c(3) <= inPort(5) and not cellGame(6);
    c(2) <= inPort(0) and not cellGame(4);
    c(1) <= inPort(1) and not cellGame(2);
    c(0) <= inPort(2) and not cellGame(0);

    sqrSel(8) <= c(8) and active;
    p(8) <= not c(8);

    sqrSel(7) <= c(7) and active and not p(8);
    p(7) <= not c(7) and p(8);

    sqrSel(6) <= c(6) and active and not p(7);
    p(6) <= not c(6) and p(7);

    sqrSel(5) <= c(5) and active and not p(6);
    p(5) <= not c(5) and p(6);

    sqrSel(4) <= c(4) and active and not p(5);
    p(4) <= not c(4) and p(5);

    sqrSel(3) <= c(3) and active and not p(4);
    p(3) <= not c(3) and p(4);

    sqrSel(2) <= c(2) and active and not p(3);
    p(2) <= not c(2) and p(3);

    sqrSel(1) <= c(1) and active and not p(2);
    p(1) <= not c(1) and p(2);

    --ไม่ได้ใช้แต่เขียนไว้เผื่อ
    sqrSel(0) <= c(0) and active and not p(1);
    p(0) <= not c(0) and p(1);

end Behavioral;