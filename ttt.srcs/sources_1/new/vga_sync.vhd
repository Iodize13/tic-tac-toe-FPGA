library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_sync is
    Port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        hsync   : out STD_LOGIC;
        vsync   : out STD_LOGIC;
        video_on : out STD_LOGIC;
        p_tick  : out STD_LOGIC;
        x       : out STD_LOGIC_VECTOR(9 downto 0);
        y       : out STD_LOGIC_VECTOR(9 downto 0)
    );
end vga_sync;

architecture Behavioral of vga_sync is
    signal clk_2 : std_logic := '0';
    signal pix_clock : std_logic := '0';
    
    signal h_cnt : unsigned(9 downto 0) := (others => '0');
    signal v_cnt : unsigned(9 downto 0) := (others => '0');
    
begin
    -- Clock divider: 100MHz -> 25MHz pixel clock
    clk_div_2: process(clk, reset)
    begin
        if (reset = '1') then 
            clk_2 <= '0';
        elsif rising_edge(clk) then 
            clk_2 <= not clk_2;
        end if; 
    end process;

    pix_clk_gen: process(clk_2, reset)
    begin 
        if (reset = '1') then 
            pix_clock <= '0';
        elsif rising_edge(clk_2) then
            pix_clock <= not pix_clock;
        end if;
    end process;
    
    p_tick <= pix_clock;
    
    -- Sync signals (active low)
    hsync <= '0' when h_cnt >= 656 and h_cnt < 752 else '1';
    vsync <= '0' when v_cnt = 490 or v_cnt = 491 else '1';
    
    -- Video on during active display area
    video_on <= '1' when h_cnt < 640 and v_cnt < 480 else '0';
    
    -- Position outputs
    x <= std_logic_vector(h_cnt);
    y <= std_logic_vector(v_cnt);
    
    -- Counter control
    control: process(pix_clock, reset) 
    begin
        if (reset = '1') then
            h_cnt <= (others => '0');
            v_cnt <= (others => '0'); 
        elsif rising_edge(pix_clock) then
            if (h_cnt < 799) then
                h_cnt <= h_cnt + 1;
            else 
                h_cnt <= (others => '0');
                if (v_cnt < 524) then 
                    v_cnt <= v_cnt + 1;
                else 
                    v_cnt <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
