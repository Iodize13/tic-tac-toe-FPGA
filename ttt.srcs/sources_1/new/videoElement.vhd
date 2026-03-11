library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity videoElement is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        Cells     : in  STD_LOGIC_VECTOR(17 downto 0);
        Color     : in  STD_LOGIC_VECTOR(8 downto 0);
        Turn      : in  STD_LOGIC;
        hsync     : out STD_LOGIC;
        vsync     : out STD_LOGIC;
        rgb       : out STD_LOGIC_VECTOR(11 downto 0)
    );
end videoElement;

architecture Behavioral of videoElement is
    constant hRes : integer := 640;
    constant vRes : integer := 480;
    constant hBorder : integer := 100;
    constant vBorder : integer := 20;
    constant hLinePos1 : integer := vBorder + 147;
    constant hLinePos2 : integer := vRes - 20 - 147;
    constant vLinePos1 : integer := hBorder + 147;
    constant vLinePos2 : integer := hRes - 100 - 147;
    constant sqBorder : integer := 40;
    constant plsBorder : integer := 30;
    constant lineWeight : integer := 2;
    
    signal hsync_int, vsync_int, video_on, p_tick : STD_LOGIC;
    signal hPos, vPos : STD_LOGIC_VECTOR(9 downto 0);
    signal pDisp : STD_LOGIC_VECTOR(1 downto 0);
    
    component vga_sync is
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
    end component;
    
begin
    vga_sync_inst : vga_sync
        port map (
            clk => clk,
            reset => reset,
            hsync => hsync_int,
            vsync => vsync_int,
            video_on => video_on,
            p_tick => p_tick,
            x => hPos,
            y => vPos
        );
    
    hsync <= hsync_int;
    vsync <= vsync_int;
    
    process(p_tick)
        variable h, v : integer;
    begin
        if rising_edge(p_tick) then
            h := to_integer(unsigned(hPos));
            v := to_integer(unsigned(vPos));
            
            if (h > hBorder and h < hRes - hBorder and 
                ((v > hLinePos1 - lineWeight and v < hLinePos1 + lineWeight) or 
                 (v > hLinePos2 - lineWeight and v < hLinePos2 + lineWeight))) then
                pDisp <= "01";
            elsif (v > vBorder and v < vRes - vBorder and 
                   ((h > vLinePos1 - lineWeight and h < vLinePos1 + lineWeight) or 
                    (h > vLinePos2 - lineWeight and h < vLinePos2 + lineWeight))) then
                pDisp <= "01";
            elsif (h > hBorder + sqBorder and h < vLinePos1 - sqBorder and
                   v > vBorder + sqBorder and v < hLinePos1 - sqBorder and
                   Cells(1) = '1') then
                pDisp <= Color(0) & '1';
            elsif (h > vLinePos1 + sqBorder and h < vLinePos2 - sqBorder and
                   v > vBorder + sqBorder and v < hLinePos1 - sqBorder and
                   Cells(3) = '1') then
                pDisp <= Color(1) & '1';
            elsif (h > vLinePos2 + sqBorder and h < hRes - hBorder - sqBorder and
                   v > vBorder + sqBorder and v < hLinePos1 - sqBorder and
                   Cells(5) = '1') then
                pDisp <= Color(2) & '1';
            elsif (h > hBorder + sqBorder and h < vLinePos1 - sqBorder and
                   v > hLinePos1 + sqBorder and v < hLinePos2 - sqBorder and
                   Cells(7) = '1') then
                pDisp <= Color(3) & '1';
            elsif (h > vLinePos1 + sqBorder and h < vLinePos2 - sqBorder and
                   v > hLinePos1 + sqBorder and v < hLinePos2 - sqBorder and
                   Cells(9) = '1') then
                pDisp <= Color(4) & '1';
            elsif (h > vLinePos2 + sqBorder and h < hRes - hBorder - sqBorder and
                   v > hLinePos1 + sqBorder and v < hLinePos2 - sqBorder and
                   Cells(11) = '1') then
                pDisp <= Color(5) & '1';
            elsif (h > hBorder + sqBorder and h < vLinePos1 - sqBorder and
                   v > hLinePos2 + sqBorder and v < vRes - vBorder - sqBorder and
                   Cells(13) = '1') then
                pDisp <= Color(6) & '1';
            elsif (h > vLinePos1 + sqBorder and h < vLinePos2 - sqBorder and
                   v > hLinePos2 + sqBorder and v < vRes - vBorder - sqBorder and
                   Cells(15) = '1') then
                pDisp <= Color(7) & '1';
            elsif (h > vLinePos2 + sqBorder and h < hRes - hBorder - sqBorder and
                   v > hLinePos2 + sqBorder and v < vRes - vBorder - sqBorder and
                   Cells(17) = '1') then
                pDisp <= Color(8) & '1';
            else
                pDisp <= "00";
            end if;
        end if;
    end process;
    
    process(pDisp, video_on)
    begin
        if video_on = '0' then
            rgb <= (others => '0');
        elsif pDisp(0) = '1' then
            if pDisp(1) = '1' then
                rgb <= X"F00";
            else
                rgb <= X"FFF";
            end if;
        else
            rgb <= X"000";
        end if;
    end process;
     
end Behavioral;
