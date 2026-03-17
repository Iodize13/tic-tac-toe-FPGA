library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity menuState is
    Port ( btHuman : in STD_LOGIC;
           btPve : in STD_LOGIC;
	   inPort   : in  std_logic_vector(8 downto 0);
	   reset    : in  std_logic;
	   clk      : in  std_logic;
	   hsync    : out std_logic;
	   vsync    : out std_logic;
	   rgb      : out std_logic_vector(11 downto 0);
	   winState : out std_logic
       );
end menuState;

architecture Behavioral of menuState is
    subtype stateBits is std_logic_vector(1 downto 0);

    component humanGame
	port(
		inPort   : in  std_logic_vector(8 downto 0);
		reset    : in  std_logic;
		clk      : in  std_logic;
		hsync    : out std_logic;
		vsync    : out std_logic;
		rgb      : out std_logic_vector(11 downto 0);
		winState : out std_logic
	    );
    end component;

    component gameLogic
	port(
		inPort   : in  std_logic_vector(8 downto 0);
		reset    : in  std_logic;
		clk      : in  std_logic;
		hsync    : out std_logic;
		vsync    : out std_logic;
		rgb      : out std_logic_vector(11 downto 0);
		winState : out std_logic
	    );
    end component;

    component mux4
	port(
	     a0 : in  STD_LOGIC;
	     a1 : in  STD_LOGIC;
	     a2 : in  STD_LOGIC;
	     a3 : in  STD_LOGIC_VECTOR(11 downto 0);  -- RGB for state 11
	     b0 : in  STD_LOGIC;
	     b1 : in  STD_LOGIC;
	     b2 : in  STD_LOGIC;
	     b3 : in  STD_LOGIC_VECTOR(11 downto 0);  -- RGB for state 11
	     sel : in  stateBits;
	     y0   : out STD_LOGIC;
	     y1   : out STD_LOGIC;
	     y2   : out STD_LOGIC;
	     y3   : out STD_LOGIC_VECTOR(11 downto 0)
	    );
    end component;

    constant MENU : stateBits := "00";
    constant PVE : stateBits := "1X";
    constant HUMAN : stateBits := "01";
    signal curState: stateBits := MENU;
    signal hsync0, vsync0, winState0, hsync1, vsync1, winState1: std_logic;
    signal rgb0, rgb1: std_logic_vector(11 downto 0);


begin

--    report "enter the realm";
    HUMAN_INST: humanGame
	port map (inPort => inPort, reset => reset, clk => clk, hsync => hsync0, vsync => vsync0, rgb => rgb0, winState => winState0);

    PVE_INST: gameLogic
	port map (inPort => inPort, reset => reset, clk => clk, hsync => hsync1, vsync => vsync1, rgb => rgb1, winState => winState1);
    MENU_INST: process(clk)
    begin
	if rising_edge(clk) then
            if reset = '1' then
		curState <= MENU;
	    else
		case curState is
		    when MENU =>
			if btHuman = '1' then
			    curState <= HUMAN;
			    report "case: 0";
			elsif btPve = '1' then
			    curState <= PVE;
			    report "case: 1";
			end if;
		    when HUMAN =>
		    -- TODO: implement with Human mode

			report "case: 2";
		    when PVE =>
			report "case: 3";
		    when others =>
			report "case: 4";
		end case;
	    end if;
	end if;
    end process;
    MUX_INST: mux4
	port map (a0 => hsync0, a1 => vsync0, a2 => winState0, a3 => rgb0, b0 => hsync1, b1 => vsync1, b2 => winState1, b3 => rgb1, sel => curState, y0 => hsync, y1 => vsync, y2 => winState, y3 => rgb);
end Behavioral;
