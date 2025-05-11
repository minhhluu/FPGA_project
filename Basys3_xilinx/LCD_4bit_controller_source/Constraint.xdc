# Clock signal
#Bank = 34, Pin name = ,					Sch name = CLK100MHZ
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# Switches
set_property PACKAGE_PIN R2 [get_ports {rst}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst}]

# Switch_0 : contrast switch
#set_property PACKAGE_PIN V17 [get_ports {sw0}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw0}]

# LEDs
set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]

#Pmod Header JB
#Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {LCD_VO}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LCD_VO}]
##Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports {LCD_RS}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LCD_RS}]
##Sch name = JB3
set_property PACKAGE_PIN B15 [get_ports {LCD_RW}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LCD_RW}]
##Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports {LCD_EN}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LCD_EN}]
#Sch name = JB7
set_property PACKAGE_PIN A15 [get_ports {LCD_DATA[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LCD_DATA[0]}]
#Sch name = JB8
set_property PACKAGE_PIN A17 [get_ports {LCD_DATA[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LCD_DATA[1]}]
#Sch name = JB9
set_property PACKAGE_PIN C15 [get_ports {LCD_DATA[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {LCD_DATA[2]}]
#Sch name = JB10 
set_property PACKAGE_PIN C16 [get_ports {LCD_DATA[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LCD_DATA[3]}]
 
#Buttons
#Bank = 14, Pin name = ,					Sch name = BTNC
set_property PACKAGE_PIN U18 [get_ports {BTN[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[4]}]
#Bank = 14, Pin name = ,					Sch name = BTNU
set_property PACKAGE_PIN T18 [get_ports {BTN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[0]}]
#Bank = 14, Pin name = ,	Sch name = BTNL
set_property PACKAGE_PIN W19 [get_ports {BTN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[1]}]
#Bank = 14, Pin name = ,							Sch name = BTNR
set_property PACKAGE_PIN T17 [get_ports {BTN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[2]}]
#Bank = 14, Pin name = ,					Sch name = BTND
set_property PACKAGE_PIN U17 [get_ports {BTN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[3]}]

# LEDs
set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
set_property PACKAGE_PIN W18 [get_ports {LED[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
set_property PACKAGE_PIN U15 [get_ports {LED[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
set_property PACKAGE_PIN U14 [get_ports {LED[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
set_property PACKAGE_PIN V14 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
set_property PACKAGE_PIN V13 [get_ports {LED[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]
set_property PACKAGE_PIN V3 [get_ports {LED[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
set_property PACKAGE_PIN W3 [get_ports {LED[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
set_property PACKAGE_PIN U3 [get_ports {LED[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
set_property PACKAGE_PIN P3 [get_ports {LED[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]
set_property PACKAGE_PIN N3 [get_ports {LED[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]
set_property PACKAGE_PIN P1 [get_ports {LED[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]
set_property PACKAGE_PIN L1 [get_ports {LED[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]
