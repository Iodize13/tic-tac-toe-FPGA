library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFF_Gate is
    Port (
        clk : in  STD_LOGIC;
        D   : in  STD_LOGIC;
        Q   : out STD_LOGIC
    );
end DFF_Gate;

architecture Structural of DFF_Gate is

    signal nClk : STD_LOGIC;
    signal S1,R1,QM,nQM : STD_LOGIC;
    signal S2,R2,Q_int,nQ_int : STD_LOGIC;

begin

    -- Inverter
    nClk <= not clk;

    ---------------------------
    -- Master latch
    ---------------------------
    S1 <= not (D and clk);
    R1 <= not ((not D) and clk);

    QM  <= not (S1 and nQM);
    nQM <= not (R1 and QM);

    ---------------------------
    -- Slave latch
    ---------------------------
    S2 <= not (QM and nClk);
    R2 <= not (nQM and nClk);

    Q_int  <= not (S2 and nQ_int);
    nQ_int <= not (R2 and Q_int);

    ---------------------------

    Q <= Q_int;

end Structural;