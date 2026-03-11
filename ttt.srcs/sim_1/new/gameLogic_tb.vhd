library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity gameLogic_tb is
end gameLogic_tb;

architecture Behavioral of gameLogic_tb is
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

    signal inPort   : STD_LOGIC_VECTOR(8 downto 0) := "000000000";
    signal reset    : STD_LOGIC := '0';
    signal clk      : STD_LOGIC := '0';
    signal hsync    : STD_LOGIC;
    signal vsync    : STD_LOGIC;
    signal rgb      : STD_LOGIC_VECTOR(11 downto 0);
    signal winState : STD_LOGIC;

    constant clk_period : time := 10 ns;
    
    file out_file : TEXT;
    signal start_capture : boolean := false;
    signal capture_done : boolean := false;
    
begin
    UUT: gameLogic
        port map (
            inPort => inPort,
            reset => reset,
            clk => clk,
            hsync => hsync,
            vsync => vsync,
            rgb => rgb,
            winState => winState
        );

    clk_process: process
    begin
        while not capture_done loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus process with button presses
    stim_proc: process
    begin
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 50 ns;
        
        inPort <= "000000001";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "000000010";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "000000100";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "000001000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "000010000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "000100000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "001000000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "010000000";
        wait for 40 ns;
        inPort <= "000000000";
        wait for 40 ns;
        
        inPort <= "100000000";
        wait for 40 ns;
        inPort <= "000000000";
        
        -- Wait for capture to complete
        wait until capture_done;
        wait;
    end process;
    
    -- VGA capture process - captures one full frame
    capture_proc: process
        variable line_out : line;
        variable r, g, b : integer;
        variable pixel_x : integer := 0;
        variable pixel_y : integer := 0;
        variable frame_started : boolean := false;
    begin
        file_open(out_file, "pixels.txt", WRITE_MODE);
        
        -- Wait for reset to complete
        wait until reset = '0';
        wait for 100 ns;
        
        -- Wait for start of frame (vsync goes low then high - active low)
        wait until vsync = '0';
        wait until vsync = '1';
        
        -- Skip vertical back porch (33 lines) and some front porch
        -- Total vertical blanking is 45 lines (10 front + 33 back + 2 sync)
        for line_skip in 1 to 45 loop
            wait until hsync = '0';  -- Wait for hsync pulse
            wait until hsync = '1';  -- End of hsync
        end loop;
        
        -- Now we're at the start of active video
        report "Starting frame capture";
        
        for row in 0 to 479 loop  -- 480 active rows
            -- Wait for hsync pulse (active low)
            wait until hsync = '0';
            wait until hsync = '1';
            
            -- Skip horizontal back porch (48 pixels at 25MHz = 192 system clocks)
            for hp in 1 to 192 loop
                wait until rising_edge(clk);
            end loop;
            
            -- Capture 640 pixels per line
            for col in 0 to 639 loop
                -- Sample on every 4th clock (25MHz pixel clock from 100MHz)
                for c in 1 to 4 loop
                    wait until rising_edge(clk);
                end loop;
                
                r := to_integer(unsigned(rgb(11 downto 8)));
                g := to_integer(unsigned(rgb(7 downto 4)));
                b := to_integer(unsigned(rgb(3 downto 0)));
                write(line_out, r);
                write(line_out, string'(","));
                write(line_out, g);
                write(line_out, string'(","));
                write(line_out, b);
                writeline(out_file, line_out);
            end loop;
        end loop;
        
        file_close(out_file);
        report "VGA capture complete - saved pixels.txt (640x480)";
        capture_done <= true;
        wait;
    end process;
end Behavioral;
