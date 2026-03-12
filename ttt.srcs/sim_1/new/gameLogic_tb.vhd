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
    signal reset    : STD_LOGIC := '1';
    signal clk      : STD_LOGIC := '0';
    signal hsync    : STD_LOGIC;
    signal vsync    : STD_LOGIC;
    signal rgb      : STD_LOGIC_VECTOR(11 downto 0);
    signal winState : STD_LOGIC;

    constant clk_period : time := 10 ns;
    
    signal capture_req : integer := -1;
    signal capture_ack : integer := -1;
    
    -- Track game state
    signal move_count : integer := 0;
    signal game_over  : boolean := false;
    
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
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Game simulation: Human (X) plays against AI (O)
    stim_proc: process
        variable frame_num : integer := 0;
    begin
        reset <= '1';
        wait for 200 ns;
        reset <= '0';
        wait for 200 ns;
        
        -- Capture initial empty board
        capture_req <= frame_num;
        wait until capture_ack = frame_num;
        frame_num := frame_num + 1;
        wait for 500 ns;
        
        -- Human plays at cell 0 (top-left)
        report "Human plays cell 0";
        inPort <= "000000001";  -- Button 0
        wait for 100 ns;
        inPort <= "000000000";
        wait for 100 ns;
        
        -- Wait for AI response and capture
        wait for 2 us;
        capture_req <= frame_num;
        wait until capture_ack = frame_num;
        frame_num := frame_num + 1;
        wait for 500 ns;
        
        -- Human plays at cell 4 (center)
        report "Human plays cell 4";
        inPort <= "000010000";  -- Button 4
        wait for 100 ns;
        inPort <= "000000000";
        wait for 100 ns;
        
        wait for 2 us;
        capture_req <= frame_num;
        wait until capture_ack = frame_num;
        frame_num := frame_num + 1;
        wait for 500 ns;
        
        -- Human plays at cell 8 (bottom-right)
        report "Human plays cell 8";
        inPort <= "100000000";  -- Button 8
        wait for 100 ns;
        inPort <= "000000000";
        wait for 100 ns;
        
        wait for 2 us;
        capture_req <= frame_num;
        wait until capture_ack = frame_num;
        frame_num := frame_num + 1;
        wait for 500 ns;
        
        -- Continue with more moves if game not over
        -- Human plays at cell 2 (top-right)
        report "Human plays cell 2";
        inPort <= "000000100";  -- Button 2
        wait for 100 ns;
        inPort <= "000000000";
        wait for 100 ns;
        
        wait for 2 us;
        capture_req <= frame_num;
        wait until capture_ack = frame_num;
        frame_num := frame_num + 1;
        wait for 500 ns;
        
        -- Human plays at cell 6 (bottom-left)
        report "Human plays cell 6";
        inPort <= "001000000";  -- Button 6
        wait for 100 ns;
        inPort <= "000000000";
        wait for 100 ns;
        
        wait for 2 us;
        capture_req <= frame_num;
        wait until capture_ack = frame_num;
        frame_num := frame_num + 1;
        wait for 500 ns;
        
        -- Final capture
        wait for 2 us;
        capture_req <= frame_num;
        wait until capture_ack = frame_num;
        
        report "Game simulation complete - captured " & integer'image(frame_num + 1) & " frames";
        wait;
    end process;
    
    capture_proc: process
        file out_file : TEXT;
        variable line_out : line;
        variable r, g, b : integer;
        variable filename : string(1 to 12);
        variable req_num : integer;
        variable line_cnt : integer := 0;
    begin
        -- Wait for reset to complete
        wait until reset = '0';
        wait for 200 ns;
        
        loop
            -- Wait for capture request
            wait until capture_req >= 0;
            req_num := capture_req;
            
            -- Build filename
            filename := "pixels_0.txt";
            if req_num < 10 then
                filename(8) := character'val(character'pos('0') + req_num);
            else
                filename(7) := '1';
                filename(8) := character'val(character'pos('0') + (req_num - 10));
            end if;
            
            file_open(out_file, filename, WRITE_MODE);
            report "Starting capture to " & filename;
            
            -- Wait for vsync pulse (active low)
            wait until vsync = '0';
            wait until vsync = '1';
            
            -- Skip vertical blanking: front porch (10) + sync (2) + back porch (33) = 45 lines
            for i in 1 to 45 loop
                wait until hsync = '0';
                wait until hsync = '1';
            end loop;
            
            -- Capture 480 active lines
            line_cnt := 0;
            for row in 0 to 479 loop
                -- Wait for hsync pulse (active low)
                wait until hsync = '0';
                wait until hsync = '1';
                
                -- Skip horizontal blanking: front porch (16) + sync (96) + back porch (48) = 160 pixels
                -- At 25MHz pixel clock, each pixel is 4 system clocks
                -- So skip 160 * 4 = 640 system clocks
                for i in 1 to 640 loop
                    wait until rising_edge(clk);
                end loop;
                
                -- Capture 640 pixels
                for col in 0 to 639 loop
                    -- Sample pixel (every 4th clock for 25MHz)
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
                
                line_cnt := line_cnt + 1;
            end loop;
            
            file_close(out_file);
            report "Captured " & integer'image(line_cnt) & " lines to " & filename;
            
            -- Acknowledge completion
            capture_ack <= req_num;
            
            -- Reset request
            wait for 10 ns;
        end loop;
    end process;
end Behavioral;
