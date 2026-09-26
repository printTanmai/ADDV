###################################################################

# Created by write_sdc on Sat Sep 26 08:25:42 2026

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current uA
set_driving_cell -lib_cell INVX1 [get_ports write_en]
set_driving_cell -lib_cell INVX1 [get_ports read_en]
set_driving_cell -lib_cell INVX1 [get_ports {w_data[7]}]
set_driving_cell -lib_cell INVX1 [get_ports {w_data[6]}]
set_driving_cell -lib_cell INVX1 [get_ports {w_data[5]}]
set_driving_cell -lib_cell INVX1 [get_ports {w_data[4]}]
set_driving_cell -lib_cell INVX1 [get_ports {w_data[3]}]
set_driving_cell -lib_cell INVX1 [get_ports {w_data[2]}]
set_driving_cell -lib_cell INVX1 [get_ports {w_data[1]}]
set_driving_cell -lib_cell INVX1 [get_ports {w_data[0]}]
create_clock [get_ports w_clk]  -period 0.666667  -waveform {0 0.333333}
create_clock [get_ports r_clk]  -period 0.666667  -waveform {0 0.333333}
set_input_delay -clock w_clk  0.1  [get_ports write_en]
set_input_delay -clock w_clk  0.1  [get_ports {w_data[7]}]
set_input_delay -clock w_clk  0.1  [get_ports {w_data[6]}]
set_input_delay -clock w_clk  0.1  [get_ports {w_data[5]}]
set_input_delay -clock w_clk  0.1  [get_ports {w_data[4]}]
set_input_delay -clock w_clk  0.1  [get_ports {w_data[3]}]
set_input_delay -clock w_clk  0.1  [get_ports {w_data[2]}]
set_input_delay -clock w_clk  0.1  [get_ports {w_data[1]}]
set_input_delay -clock w_clk  0.1  [get_ports {w_data[0]}]
set_input_delay -clock r_clk  0.1  [get_ports read_en]
set_output_delay -clock w_clk  0.1  [get_ports full]
set_output_delay -clock w_clk  0.1  [get_ports almost_full]
set_output_delay -clock r_clk  0.1  [get_ports empty]
set_output_delay -clock r_clk  0.1  [get_ports almost_empty]
set_output_delay -clock r_clk  0.1  [get_ports {r_data[7]}]
set_output_delay -clock r_clk  0.1  [get_ports {r_data[6]}]
set_output_delay -clock r_clk  0.1  [get_ports {r_data[5]}]
set_output_delay -clock r_clk  0.1  [get_ports {r_data[4]}]
set_output_delay -clock r_clk  0.1  [get_ports {r_data[3]}]
set_output_delay -clock r_clk  0.1  [get_ports {r_data[2]}]
set_output_delay -clock r_clk  0.1  [get_ports {r_data[1]}]
set_output_delay -clock r_clk  0.1  [get_ports {r_data[0]}]
set_clock_groups  -asynchronous -name w_clk_1  -group [get_clocks w_clk]       \
-group [get_clocks r_clk]
set_false_path   -from [list [get_ports w_rst_b] [get_ports r_rst_b]]
