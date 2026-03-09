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
    constant HD : integer := 640;
    constant HF : integer := 16;
    constant HB : integer := 48;
    constant HR : integer := 96;
    constant VD : integer := 480;
    constant VF : integer := 10;
    constant VB : integer := 33;
    constant VR : integer := 2;
    
    signal clk_div : STD_LOGIC := '0';
    signal counter : integer := 0;
    signal h_count : integer := 0;
    signal v_count : integer := 0;
    
begin
    process(clk)
    begin
        if reset = '1' then
            clk_div <= '0';
            counter <= 0;
        elsif rising_edge(clk) then
            if counter = 3 then
                clk_div <= not clk_div;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    p_tick <= clk_div;
    
    process(clk_div)
    begin
        if rising_edge(clk_div) then
            if reset = '1' then
                h_count <= 0;
                v_count <= 0;
            elsif h_count = (HD + HF + HB + HR - 1) then
                h_count <= 0;
                if v_count = (VD + VF + VB + VR - 1) then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;
    
    hsync <= '0' when h_count >= (HD + HF) and h_count < (HD + HF + HR) else '1';
    vsync <= '0' when v_count >= (VD + VF) and v_count < (VD + VF + VR) else '1';
    
    video_on <= '1' when h_count < HD and v_count < VD else '0';
    
    x <= STD_LOGIC_VECTOR(to_unsigned(h_count, 10));
    y <= STD_LOGIC_VECTOR(to_unsigned(v_count, 10));
    
end Behavioral;
