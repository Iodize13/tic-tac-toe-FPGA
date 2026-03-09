 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;

entity Cell_TB is
end Cell_TB;

architecture Behavioral of Cell_TB is
   COMPONENT Cell
   PORT(
        clk   : in  STD_LOGIC;
        Sel   : in  STD_LOGIC;
        Turn  : in  STD_LOGIC;
        Reset : in  STD_LOGIC;
        State : out STD_LOGIC_VECTOR (1 downto 0)
        );
   END COMPONENT;

   SIGNAL clk_TB   :   STD_LOGIC;
   SIGNAL Sel_TB   :   STD_LOGIC;
   SIGNAL Turn_TB  :   STD_LOGIC;
   SIGNAL Reset_TB :   STD_LOGIC;
   SIGNAL State_TB :   STD_LOGIC_VECTOR (1 downto 0);

   type input_array_type is array (0 to 5) of std_logic;
   constant Sel_inputs: input_array_type := ('0','0','1','1','1','1');
   constant Turn_inputs: input_array_type := ('0','1','0','1','1','1');
   -- constant preset_0_inputs: input_array_type := ('0','1','1','1','1');
begin

   UUT: Cell PORT MAP(
   clk => clk_TB,
   Sel => Sel_TB,
   Turn => Turn_TB,
   Reset => Reset_TB,
   State => State_TB
   );
   PROCESS
   BEGIN
       clk_TB <= '0';
       Reset_TB <= '1';
       wait for 10 ns;
       clk_TB <= '1';
       Reset_TB <= '0';
       for ii in 0 to 2 loop
           Sel_TB <= Sel_inputs(ii);
           Turn_TB <= Turn_inputs(ii);
           clk_TB <= '0';
           wait for 5 ns;
           clk_TB <= '1';
           wait for 5 ns;
       end loop;
       clk_TB <= '0';
       Reset_TB <= '1';
       wait for 5 ns;
       clk_TB <= '1';
       wait for 5 ns;
       Reset_TB <= '0';
       for ii in 3 to 5 loop
           Sel_TB <= Sel_inputs(ii);
           Turn_TB <= Turn_inputs(ii);
           clk_TB <= '0';
           wait for 5 ns;
           clk_TB <= '1';
           wait for 5 ns;
       end loop;
       wait;
   END PROCESS;
END;