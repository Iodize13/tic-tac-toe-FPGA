# Clock constraint - 100MHz on Nexys A7-100T
# Using dedicated clock input E3
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Override clock placement rule (required when using non-dedicated clock pin)
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]

# Input constraints
# 9 push buttons for game input (inPort)
# Using right-side buttons on Nexys A7-100T
set_property PACKAGE_PIN J15 [get_ports {inPort[0]}]
set_property PACKAGE_PIN L16 [get_ports {inPort[1]}]
set_property PACKAGE_PIN M13 [get_ports {inPort[2]}]
set_property PACKAGE_PIN R15 [get_ports {inPort[3]}]
set_property PACKAGE_PIN R17 [get_ports {inPort[4]}]
set_property PACKAGE_PIN T18 [get_ports {inPort[5]}]
set_property PACKAGE_PIN U18 [get_ports {inPort[6]}]
set_property PACKAGE_PIN R13 [get_ports {inPort[7]}]
set_property PACKAGE_PIN T8 [get_ports {inPort[8]}]

# set_property -dict { PACKAGE_PIN H17    IOSTANDARD LVCMOS33 } [get_ports { winState }];
set_property IOSTANDARD LVCMOS33 [get_ports winState]
set_property PACKAGE_PIN H17 [get_ports winState]

# set_property -dict { PACKAGE_PIN V11    IOSTANDARD LVCMOS33 } [get_ports { clk }];

# Reset button (active high - pulled down so default=0)
set_property PACKAGE_PIN C12 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property PULLDOWN TRUE [get_ports reset]

# Input buttons
set_property IOSTANDARD LVCMOS33 [get_ports {inPort[*]}]

# VGA output pins - Nexys A7-100T
# Red
set_property PACKAGE_PIN A4 [get_ports {rgb[0]}]
set_property PACKAGE_PIN C5 [get_ports {rgb[1]}]
set_property PACKAGE_PIN B4 [get_ports {rgb[2]}]
set_property PACKAGE_PIN A3 [get_ports {rgb[3]}]
# Green
set_property PACKAGE_PIN A6 [get_ports {rgb[4]}]
set_property PACKAGE_PIN B6 [get_ports {rgb[5]}]
set_property PACKAGE_PIN A5 [get_ports {rgb[6]}]
set_property PACKAGE_PIN C6 [get_ports {rgb[7]}]
# Blue
set_property PACKAGE_PIN D8 [get_ports {rgb[8]}]
set_property PACKAGE_PIN D7 [get_ports {rgb[9]}]
set_property PACKAGE_PIN C7 [get_ports {rgb[10]}]
set_property PACKAGE_PIN B7 [get_ports {rgb[11]}]

# Hsync and Vsync
set_property PACKAGE_PIN B11 [get_ports hsync]
set_property PACKAGE_PIN B12 [get_ports vsync]

set_property IOSTANDARD LVCMOS33 [get_ports {rgb[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

# Allow unconstrained ports (VGA optional outputs)
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

# VGA clock constraint
create_clock -period 25.175 -name vga_clk [get_ports clk]
