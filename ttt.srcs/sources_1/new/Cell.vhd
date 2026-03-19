library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Cell is
    Port (
        clk   : in  STD_LOGIC;
        Sel   : in  STD_LOGIC;
        Turn  : in  STD_LOGIC;
        Reset : in  STD_LOGIC;
        State : out STD_LOGIC_VECTOR (1 downto 0)
    );
end Cell;

architecture gate_level of Cell is

    component DFF_Gate
        Port (
            clk : in  STD_LOGIC;
            D   : in  STD_LOGIC;
            Q   : out STD_LOGIC
        );
    end component;

    -- Internal signals
    signal Q1, Q0 : STD_LOGIC;
    signal D0_NS, D1_NS: STD_LOGIC;

begin
    -- Next state logic (combinational)
    -- D0_NS = (not Reset and Sel) or (not Reset and Q1) or (not Reset and Q0)
    D0_NS <= ((not Reset) and Sel) or ((not Reset) and Q1) or ((not Reset) and Q0);
    
    -- D1_NS = (not Reset and Sel and Turn and not Q1 and not Q0) or (not Reset and Q1 and Q0)
    D1_NS <= ((not Reset) and Sel and Turn and (not Q1) and (not Q0)) or ((not Reset) and Q1 and Q0);
    
    -- State register (D flip-flops)
    FF0: DFF_Gate
        port map (
            clk => clk,
            D => D0_NS,
            Q => Q0
        );

    FF1: DFF_Gate
        port map (
            clk => clk,
            D => D1_NS,
            Q => Q1
        );

    -- Output mapping
    -- State(0) = Q0, State(1) = Q1
    State <= Q1 & Q0;

end gate_level;
