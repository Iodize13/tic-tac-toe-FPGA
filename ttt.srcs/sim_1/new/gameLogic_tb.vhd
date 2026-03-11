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
    
    -- Handshake signals for capture coordination
    signal capture_req : integer := -1;  -- Set by stim_proc
    signal capture_ack : integer := -1;  -- Set by capture_proc
    signal capture_complete : boolean := false;
    
    -- Array of button patterns for each move
    type button_array is array (0 to 9) of std_logic_vector(8 downto 0);
    constant buttons : button_array := (
        "000000001",  -- cell 0
        "000000010",  -- cell 1
        "000000100",  -- cell 2
        "000001000",  -- cell 3
        "000010000",  -- cell 4
        "000100000",  -- cell 5
        "001000000",  -- cell 6
        "010000000",  -- cell 7
        "100000000",  -- cell 8
        "000000000"   -- final state
    );
    
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
        while not capture_complete loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus process - triggers capture after each button press
    stim_proc: process
    begin
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;
        
        -- Press each button and trigger capture after each
        for i in 0 to 8 loop
            inPort <= buttons(i);
            wait for 40 ns;
            inPort <= "000000000";
            
            -- Request capture of frame i
            capture_req <= i;
            
            -- Wait for capture to acknowledge completion
            wait until capture_ack = i;
            wait for 40 ns;
        end loop;
        
        -- Final capture after all moves
        capture_req <= 9;
        wait until capture_ack = 9;
        
        capture_complete <= true;
        wait;
    end process;
    
    -- VGA capture process - captures frame when requested
    capture_proc: process
        file out_file : TEXT;
        variable line_out : line;
        variable r, g, b : integer;
        variable filename : string(1 to 12);
        variable requested_frame : integer;
    begin
        wait until reset = '0';
        
        loop
            -- Wait for capture request
            wait until capture_req >= 0;
            requested_frame := capture_req;
            
            -- Build filename: pixels_N.txt
            filename := "pixels_0.txt";
            filename(8) := character'val(character'pos('0') + requested_frame);
            
            file_open(out_file, filename, WRITE_MODE);
            report "Capturing frame after button press " & integer'image(requested_frame) & " to " & filename;
            
            -- Wait for next vsync to start fresh frame
            wait until vsync = '0';
            wait until vsync = '1';
            
            -- Skip vertical blanking (45 lines)
            for line_skip in 1 to 45 loop
                wait until hsync = '0';
                wait until hsync = '1';
            end loop;
            
            -- Capture 480 active rows
            for row in 0 to 479 loop
                wait until hsync = '0';
                wait until hsync = '1';
                
                -- Skip horizontal back porch (192 clocks)
                for hp in 1 to 192 loop
                    wait until rising_edge(clk);
                end loop;
                
                -- Capture 640 pixels
                for col in 0 to 639 loop
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
            report "Saved " & filename;
            
            -- Acknowledge completion
            capture_ack <= requested_frame;
        end loop;
    end process;
end Behavioral;
