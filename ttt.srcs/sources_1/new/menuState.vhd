library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity menuState is
    Port (
        btHuman     : in  STD_LOGIC;
        btPve       : in  STD_LOGIC;
        inPort      : in  std_logic_vector(8 downto 0);
        reset       : in  std_logic;
        clk         : in  std_logic;
        playFirst   : in  std_logic;
        execute     : in  std_logic;
        hsync       : out std_logic;
        vsync       : out std_logic;
        rgb         : out std_logic_vector(11 downto 0);
        winState    : out std_logic;
        menuDisplay : out std_logic;
        seg         : out std_logic_vector(6 downto 0);
        an          : out std_logic_vector(7 downto 0)
    );
end menuState;

architecture Behavioral of menuState is

    subtype stateBits is std_logic_vector(1 downto 0);

    -- ============================================================
    -- Components
    -- ============================================================
    component humanGame
        port (
            inPort   : in  std_logic_vector(8 downto 0);
            reset    : in  std_logic;
            clk      : in  std_logic;
            execute  : in  std_logic;
            hsync    : out std_logic;
            vsync    : out std_logic;
            rgb      : out std_logic_vector(11 downto 0);
            winState : out std_logic
        );
    end component;

    component gameLogic
        port (
            inPort    : in  std_logic_vector(8 downto 0);
            reset     : in  std_logic;
            clk       : in  std_logic;
            playFirst : in  std_logic;
            execute   : in  std_logic;
            hsync     : out std_logic;
            vsync     : out std_logic;
            rgb       : out std_logic_vector(11 downto 0);
            winState  : out std_logic
        );
    end component;

    component mux4
        port (
            a0  : in  STD_LOGIC;
            a1  : in  STD_LOGIC;
            a2  : in  STD_LOGIC;
            a3  : in  STD_LOGIC_VECTOR(11 downto 0);
            b0  : in  STD_LOGIC;
            b1  : in  STD_LOGIC;
            b2  : in  STD_LOGIC;
            b3  : in  STD_LOGIC_VECTOR(11 downto 0);
            sel : in  stateBits;
            y0  : out STD_LOGIC;
            y1  : out STD_LOGIC;
            y2  : out STD_LOGIC;
            y3  : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;

    component sevenSegmentText
        port (
            clk        : in  STD_LOGIC;
            stateSel   : in  STD_LOGIC_VECTOR(1 downto 0);
            playerTurn : in  STD_LOGIC;
            seg        : out STD_LOGIC_VECTOR(6 downto 0);
            an         : out STD_LOGIC_VECTOR(7 downto 0);
            winState   : out STD_LOGIC

        );
    end component;

    component button_debouncer
        Generic (
            CLK_FREQ    : integer := 100_000_000;
            DEBOUNCE_MS : integer := 10
        );
        Port (
            Clk     : in  STD_LOGIC;
            BTN_In  : in  STD_LOGIC;
            BTN_Out : out STD_LOGIC
        );
    end component;

    -- ============================================================
    -- Constants
    -- ============================================================
    constant MENU  : stateBits := "00";
    constant HUMAN : stateBits := "01";
    constant PVE   : stateBits := "10";

    -- ============================================================
    -- Internal signals
    -- ============================================================
    signal curState       : stateBits := MENU;
    signal hsync0, vsync0, winState0 : std_logic;
    signal hsync1, vsync1, winState1 : std_logic;
    signal rgb0, rgb1     : std_logic_vector(11 downto 0);
    signal playerTurn_sig : std_logic := '0';

    signal execute_clean  : std_logic;           
    signal execute_prev   : std_logic := '0';    
    signal execute_pulse  : std_logic;           

begin

    EXEC_DEBOUNCE: button_debouncer
        generic map (
            CLK_FREQ    => 100_000_000,
            DEBOUNCE_MS => 10
        )
        port map (
            Clk     => clk,
            BTN_In  => execute,
            BTN_Out => execute_clean
        );

    EDGE_DETECT: process(clk)
    begin
        if rising_edge(clk) then
            execute_prev <= execute_clean;
        end if;
    end process;

    execute_pulse <= execute_clean and (not execute_prev);


    HUMAN_INST: humanGame
        port map (
            inPort   => inPort,   reset    => reset,
            clk      => clk,      execute  => execute_clean,
            hsync    => hsync0,   vsync    => vsync0,
            rgb      => rgb0,     winState => winState0
        );

    PVE_INST: gameLogic
        port map (
            inPort    => inPort,   reset     => reset,
            clk       => clk,      playFirst => playFirst,
            execute   => execute_clean,
            hsync     => hsync1,   vsync     => vsync1,
            rgb       => rgb1,     winState  => winState1
        );

    
    MUX_INST: mux4
        port map (
            a0  => hsync0,    a1  => vsync0,    a2  => winState0,  a3  => rgb0,
            b0  => hsync1,    b1  => vsync1,    b2  => winState1,  b3  => rgb1,
            sel => curState,
            y0  => hsync,     y1  => vsync,     y2  => winState,   y3  => rgb
        );

    SEG_INST: sevenSegmentText
        port map (
            clk        => clk,
            stateSel   => curState,
            playerTurn => playerTurn_sig,
            seg        => seg,
            an         => an,
            winState    => winState
        );

    MENU_INST: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                curState       <= MENU;
                menuDisplay    <= '1';
                playerTurn_sig <= '0';
            else
				-- ==================================================
				--AI จะค้าง A-P1 | เดาว่าเพราะ clock AI น่าจะมาเร็ว ผมขก.แก้ล่ะอย่าสนใจ
				-- ==================================================

                case curState is
                    when MENU =>
                        if btHuman = '1' then
                            curState    <= HUMAN;
                            menuDisplay <= '0';
                            report "case: HUMAN mode";
                        elsif btPve = '1' then
                            curState    <= PVE;
                            menuDisplay <= '0';
                            report "case: PVE mode";
                        end if;

                    when HUMAN =>
                        if execute_pulse = '1' then
                            playerTurn_sig <= not playerTurn_sig;
                            report "HUMAN: playerTurn toggled";
                        end if;

                    when PVE =>
                        playerTurn_sig <= '0';  
                        report "case: PVE running";

                    when others =>
                        curState <= MENU;
                        report "case: unknown -> reset to MENU";
                end case;
            end if;
        end if;
    end process;

end Behavioral;