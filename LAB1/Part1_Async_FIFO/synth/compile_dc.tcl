#/**************************************************/
#/* Compile Script for Synopsys                    */
#/*                                                */
#/* dc_shell-t -f compile_dc.tcl                   */
#/*                                                */
#/* OSU FreePDK 45nm                               */
#/**************************************************/

#/* All verilog files, separated by spaces         */
set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir ..]]
if {[file isdirectory [file join $project_root Part1_Async_FIFO RTL]]} {
   set project_dir [file join $project_root Part1_Async_FIFO]
} else {
   set project_dir $project_root
}
set my_verilog_files [list \
      [file join $project_dir TESTBENCH fifo_if.sv] \
      [file join $project_dir RTL bin2gray.sv] \
      [file join $project_dir RTL gray2bin.sv] \
      [file join $project_dir RTL fifo_mem.sv] \
      [file join $project_dir RTL synchronizer.sv] \
      [file join $project_dir RTL read_ptr.sv] \
      [file join $project_dir RTL write_ptr.sv] \
      [file join $project_dir RTL async_fifo.sv] \
      [file join $project_dir RTL fifo_wrapper.sv] \
      ]

#/* Top-level Module                               */
set my_toplevel   fifo_wrapper

#/* The name of the clock pin. If no clock-pin     */
#/* exists, pick anything                          */

set my_wclock_pin w_clk
set my_rclock_pin r_clk

#/* Target frequency in MHz for optimization       */
set my_wclk_freq_MHz 1500.0
set my_rclk_freq_MHz 1500.0

#/* Delay of input signals (Clock-to-Q, Package etc.)  */
set my_input_delay_ns 0.1

#/* Reserved time for output signals (Holdtime etc.)   */
set my_output_delay_ns 0.1


#/**************************************************/
#/* No modifications needed below                  */
#/**************************************************/
set pdk_dir [getenv PDK_DIR]
if {$pdk_dir eq ""} {
   error "PDK_DIR is not set. Source env.cshrc (or set PDK_DIR) before running synthesis."
}
set OSU_FREEPDK [file join $pdk_dir osu_soc lib files]
if {![file isdirectory $OSU_FREEPDK]} {
   error "FreePDK library directory does not exist: $OSU_FREEPDK"
}
set search_path [concat $search_path $OSU_FREEPDK [file join $project_dir RTL] [file join $project_dir TESTBENCH]]
set alib_library_analysis_path $OSU_FREEPDK

set target_library [list gscl45nm.db]

set link_library [concat \
   "*" \
   $target_library \
   [list dw_foundation.sldb]]

define_design_lib WORK -path [file join $script_dir WORK]
set verilogout_show_unconnected_pins "true"


analyze -format sverilog $my_verilog_files

elaborate $my_toplevel

current_design $my_toplevel

link
uniquify


set my_wclk_period [expr 1000.0 / $my_wclk_freq_MHz]
set my_rclk_period [expr 1000.0 / $my_rclk_freq_MHz]

create_clock \
   -name w_clk\
   -period $my_wclk_period \
   [get_ports $my_wclock_pin]

create_clock \
   -name r_clk\
   -period $my_rclk_period \
   [get_ports $my_rclock_pin]

set_clock_groups \
   -asynchronous \
   -group [get_clocks w_clk] \
   -group [get_clocks r_clk]

set_false_path -from [get_ports {w_rst_b r_rst_b}] 

set data_inputs [remove_from_collection \
   [all_inputs]\
   [get_ports {w_clk r_clk w_rst_b r_rst_b}]\
   ]

set_driving_cell  -lib_cell INVX1  $data_inputs

set write_inputs [add_to_collection [get_ports write_en] [get_ports "w_data"]]
set read_inputs [get_ports {read_en}]

set_input_delay $my_input_delay_ns -clock w_clk $write_inputs
set_input_delay $my_input_delay_ns -clock r_clk $read_inputs

set write_outputs [get_ports {full almost_full}]
set read_outputs [add_to_collection [get_ports {empty almost_empty}] [get_ports r_data]]

set_output_delay $my_output_delay_ns -clock w_clk $write_outputs
set_output_delay $my_output_delay_ns -clock r_clk $read_outputs

compile -map_effort medium

compile -incremental_mapping -map_effort medium

# Repair remaining library design-rule violations (for example, max capacitance)
# after timing-driven mapping. Keep the library limits intact.
compile -only_design_rule

set_app_var report_default_significant_digits 6
check_design
report_constraint -all_violators

#set filename [format "%s%s"  $my_toplevel ".vh"]
#write -f verilog -output $filename

#set filename [format "%s%s"  $my_toplevel ".sdc"]
#write_sdc $filename

#set filename [format "%s%s"  $my_toplevel ".db"]
#write -f db -hier -output $filename -xg_force_db


redirect [file join $script_dir timing.rep] { report_timing -max_paths 10 }

redirect [file join $script_dir clocks.rep] { report_clocks -attributes [all_clocks] }
redirect [file join $script_dir constraints.rep] { report_constraint -all_violators }
redirect [file join $script_dir max_capacitance.rep] { report_constraint -all_violators -max_capacitance }
redirect [file join $script_dir port.rep] { report_port -verbose }


redirect [file join $script_dir cell.rep] { report_cell }
redirect [file join $script_dir power.rep] { report_power }
redirect [file join $script_dir area.rep] { report_area }

write -f verilog -hierarchy -output [file join $script_dir ${my_toplevel}.v]
write_sdc [file join $script_dir ${my_toplevel}.sdc]

quit
