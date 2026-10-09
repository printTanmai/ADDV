#/**************************************************/
#/* Compile Script for Synopsys Design Compiler    */
#/* Single-Stage MIPS Processor Synthesis          */
#/* Directory: LAB2/SINGLE_STAGE/SYNTH             */
#/* OSU FreePDK 45nm (No SRAM Macros)              */
#/**************************************************/

#/* Automatically gather all RTL SystemVerilog files, excluding the SRAM wrapper */
set my_verilog_files [glob ../RTL/*.sv]
set my_verilog_files [lsearch -all -inline -glob -not $my_verilog_files "*top_with_sram.sv"]

#/* Top-level Module                               */
set my_toplevel mips

#/* Clock Pin Name                                 */
set my_clock_pin clk

#/* Target frequency in MHz for optimization       */
set my_clk_freq_MHz 1000

#/* Delay of input signals (Clock-to-Q, Package etc.)  */
set my_input_delay_ns 0.1

#/* Reserved time for output signals (Holdtime etc.)   */
set my_output_delay_ns 0.1

#/**************************************************/
#/* Process library setup (OSU FreePDK 45nm)       */
#/**************************************************/
set OSU_FREEPDK [format "%s%s" [getenv "PDK_DIR"] "/osu_soc/lib/files"]

set search_path [concat $search_path $OSU_FREEPDK]
set alib_library_analysis_path $OSU_FREEPDK

set target_library [list gscl45nm.db]
set link_library [concat [list *] $target_library [list dw_foundation.sldb]]

define_design_lib WORK -path ./WORK
set verilogout_show_unconnected_pins "true"

# Analyze all RTL source files
analyze -format sverilog $my_verilog_files

# Elaborate top-level module
elaborate $my_toplevel

current_design $my_toplevel

link
uniquify

# Clock and Timing Constraints Setup
set my_period [expr 1000.0 / $my_clk_freq_MHz]

set find_clock [find port [list $my_clock_pin]]
if {$find_clock != [list]} {
   set clk_name $my_clock_pin
   create_clock -period $my_period $clk_name
} else {
   set clk_name vclk
   create_clock -period $my_period -name $clk_name
}

# Treat reset as an ideal network
if {[find port reset] != [list]} {
    set_ideal_network [get_ports reset]
}

set_driving_cell -lib_cell INVX1 [all_inputs]

set_input_delay \
    $my_input_delay_ns \
    -clock $clk_name \
    [remove_from_collection [all_inputs] $my_clock_pin]

set_output_delay \
    $my_output_delay_ns \
    -clock $clk_name \
    [all_outputs]

# Optimization and Compilation
compile -ungroup_all -map_effort medium
compile -incremental_mapping -map_effort medium

check_design
report_constraint -all_violators

# Generate Synthesis Output Reports
redirect timing.rep { report_timing }
redirect clock.rep  { report_clock }
redirect cell.rep   { report_cell }
redirect power.rep  { report_power }
redirect area.rep   { report_area }

quit