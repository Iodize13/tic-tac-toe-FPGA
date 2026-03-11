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
    constant lineWeight : integer := 2;
    constant outlineThick : integer := 4;  -- Thickness of X outline
    
    signal hsync_int, vsync_int, video_on, p_tick : STD_LOGIC;
    signal hPos, vPos : STD_LOGIC_VECTOR(9 downto 0);
    signal pDisp : STD_LOGIC_VECTOR(2 downto 0);  -- [2]=isSymbol, [1]=isRed, [0]=filled
    
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
    
    -- Function to check if point is in outline of a rectangle
    function in_outline(h, v, h1, v1, h2, v2, thick : integer) return boolean is
        variable in_rect : boolean;
        variable in_inner : boolean;
    begin
        in_rect := (h >= h1 and h <= h2 and v >= v1 and v <= v2);
        in_inner := (h >= h1 + thick and h <= h2 - thick and v >= v1 + thick and v <= v2 - thick);
        return in_rect and not in_inner;
    end function;
    
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
        -- Cell boundaries
        variable cell_h1, cell_h2, cell_v1, cell_v2 : integer;
        -- Cell state: bit1 = MSB (isO), bit0 = LSB (isX)
        variable isX, isO : boolean;
    begin
        if rising_edge(p_tick) then
            h := to_integer(unsigned(hPos));
            v := to_integer(unsigned(vPos));
            
            -- Grid lines
            if (h > hBorder and h < hRes - hBorder and 
                ((v > hLinePos1 - lineWeight and v < hLinePos1 + lineWeight) or 
                 (v > hLinePos2 - lineWeight and v < hLinePos2 + lineWeight))) then
                pDisp <= "001";  -- Grid line: white
            elsif (v > vBorder and v < vRes - vBorder and 
                   ((h > vLinePos1 - lineWeight and h < vLinePos1 + lineWeight) or 
                    (h > vLinePos2 - lineWeight and h < vLinePos2 + lineWeight))) then
                pDisp <= "001";  -- Grid line: white
            else
                pDisp <= "000";  -- Background/black
            end if;
            
            -- Cell 0 (top-left): Cells(1 downto 0)
            cell_h1 := hBorder + sqBorder;
            cell_h2 := vLinePos1 - sqBorder;
            cell_v1 := vBorder + sqBorder;
            cell_v2 := hLinePos1 - sqBorder;
            isX := (Cells(1) = '0' and Cells(0) = '1');  -- "01" = X
            isO := (Cells(1) = '1' and Cells(0) = '1');  -- "11" = O
            if (h >= cell_h1 and h <= cell_h2 and v >= cell_v1 and v <= cell_v2) then
                if isO then
                    pDisp <= "111";  -- O: filled red
                elsif isX and in_outline(h, v, cell_h1, cell_v1, cell_h2, cell_v2, outlineThick) then
                    pDisp <= "011";  -- X: white outline
                end if;
            end if;
            
            -- Cell 1 (top-mid): Cells(3 downto 2)
            cell_h1 := vLinePos1 + sqBorder;
            cell_h2 := vLinePos2 - sqBorder;
            isX := (Cells(3) = '0' and Cells(2) = '1');
            isO := (Cells(3) = '1' and Cells(2) = '1');
            if (h >= cell_h1 and h <= cell_h2 and v >= cell_v1 and v <= cell_v2) then
                if isO then
                    pDisp <= "111";
                elsif isX and in_outline(h, v, cell_h1, cell_v1, cell_h2, cell_v2, outlineThick) then
                    pDisp <= "011";
                end if;
            end if;
            
            -- Cell 2 (top-right): Cells(5 downto 4)
            cell_h1 := vLinePos2 + sqBorder;
            cell_h2 := hRes - hBorder - sqBorder;
            isX := (Cells(5) = '0' and Cells(4) = '1');
            isO := (Cells(5) = '1' and Cells(4) = '1');
            if (h >= cell_h1 and h <= cell_h2 and v >= cell_v1 and v <= cell_v2) then
                if isO then
                    pDisp <= "111";
                elsif isX and in_outline(h, v, cell_h1, cell_v1, cell_h2, cell_v2, outlineThick) then
                    pDisp <= "011";
                end if;
            end if;
            
            -- Cell 3 (mid-left): Cells(7 downto 6)
            cell_h1 := hBorder + sqBorder;
            cell_h2 := vLinePos1 - sqBorder;
            cell_v1 := hLinePos1 + sqBorder;
            cell_v2 := hLinePos2 - sqBorder;
            isX := (Cells(7) = '0' and Cells(6) = '1');
            isO := (Cells(7) = '1' and Cells(6) = '1');
            if (h >= cell_h1 and h <= cell_h2 and v >= cell_v1 and v <= cell_v2) then
                if isO then
                    pDisp <= "111";
                elsif isX and in_outline(h, v, cell_h1, cell_v1, cell_h2, cell_v2, outlineThick) then
                    pDisp <= "011";
                end if;
            end if;
            
            -- Cell 4 (center): Cells(9 downto 8)
            cell_h1 := vLinePos1 + sqBorder;
            cell_h2 := vLinePos2 - sqBorder;
            isX := (Cells(9) = '0' and Cells(8) = '1');
            isO := (Cells(9) = '1' and Cells(8) = '1');
            if (h >= cell_h1 and h <= cell_h2 and v >= cell_v1 and v <= cell_v2) then
                if isO then
                    pDisp <= "111";
                elsif isX and in_outline(h, v, cell_h1, cell_v1, cell_h2, cell_v2, outlineThick) then
                    pDisp <= "011";
                end if;
            end if;
            
            -- Cell 5 (mid-right): Cells(11 downto 10)
            cell_h1 := vLinePos2 + sqBorder;
            cell_h2 := hRes - hBorder - sqBorder;
            isX := (Cells(11) = '0' and Cells(10) = '1');
            isO := (Cells(11) = '1' and Cells(10) = '1');
            if (h >= cell_h1 and h <= cell_h2 and v >= cell_v1 and v <= cell_v2) then
                if isO then
                    pDisp <= "111";
                elsif isX and in_outline(h, v, cell_h1, cell_v1, cell_h2, cell_v2, outlineThick) then
                    pDisp <= "011";
                end if;
            end if;
            
            -- Cell 6 (bot-left): Cells(13 downto 12)
            cell_h1 := hBorder + sqBorder;
            cell_h2 := vLinePos1 - sqBorder;
            cell_v1 := hLinePos2 + sqBorder;
            cell_v2 := vRes - vBorder - sqBorder;
            isX := (Cells(13) = '0' and Cells(12) = '1');
            isO := (Cells(13) = '1' and Cells(12) = '1');
            if (h >= cell_h1 and h <= cell_h2 and v >= cell_v1 and v <= cell_v2) then
                if isO then
                    pDisp <= "111";
                elsif isX and in_outline(h, v, cell_h1, cell_v1, cell_h2, cell_v2, outlineThick) then
                    pDisp <= "011";
                end if;
            end if;
            
            -- Cell 7 (bot-mid): Cells(15 downto 14)
            cell_h1 := vLinePos1 + sqBorder;
            cell_h2 := vLinePos2 - sqBorder;
            isX := (Cells(15) = '0' and Cells(14) = '1');
            isO := (Cells(15) = '1' and Cells(14) = '1');
            if (h >= cell_h1 and h <= cell_h2 and v >= cell_v1 and v <= cell_v2) then
                if isO then
                    pDisp <= "111";
                elsif isX and in_outline(h, v, cell_h1, cell_v1, cell_h2, cell_v2, outlineThick) then
                    pDisp <= "011";
                end if;
            end if;
            
            -- Cell 8 (bot-right): Cells(17 downto 16)
            cell_h1 := vLinePos2 + sqBorder;
            cell_h2 := hRes - hBorder - sqBorder;
            isX := (Cells(17) = '0' and Cells(16) = '1');
            isO := (Cells(17) = '1' and Cells(16) = '1');
            if (h >= cell_h1 and h <= cell_h2 and v >= cell_v1 and v <= cell_v2) then
                if isO then
                    pDisp <= "111";
                elsif isX and in_outline(h, v, cell_h1, cell_v1, cell_h2, cell_v2, outlineThick) then
                    pDisp <= "011";
                end if;
            end if;
        end if;
    end process;
    
    process(pDisp, video_on)
    begin
        if video_on = '0' then
            rgb <= (others => '0');
        elsif pDisp(2) = '1' then  -- Symbol (X or O)
            if pDisp(1) = '1' then   -- Red
                rgb <= X"F00";       -- O: Red filled
            else
                rgb <= X"FFF";       -- X: White outline
            end if;
        elsif pDisp(0) = '1' then
            rgb <= X"FFF";           -- Grid lines: White
        else
            rgb <= X"000";           -- Background: Black
        end if;
    end process;
     
end Behavioral;
