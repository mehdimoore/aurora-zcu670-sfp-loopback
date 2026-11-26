# Recreate the ZCU670 Aurora SFP loopback project in Vivado 2025.2.
# Usage: vivado -mode batch -source Scripts/build.tcl
# Optional output directory: -tclargs /path/to/new/build

if {[version -short] ne "2025.2"} {
    error "This project requires Vivado 2025.2."
}
if {[llength [get_projects -quiet]] != 0} {
    error "Run this script in a Vivado session with no project open."
}

set repo_root [file dirname [file dirname [file normalize [info script]]]]
set project_name aurora_zcu670_sfploopback
set project_dir [file join $repo_root build]
if {[info exists ::argc] && $::argc > 1} {
    error "Usage: build.tcl ?output_directory?"
}
if {[info exists ::argc] && $::argc == 1} {
    set project_dir [file normalize [lindex $::argv 0]]
}
if {[file exists [file join $project_dir ${project_name}.xpr]]} {
    error "Project already exists in $project_dir. Open it or choose a new output directory."
}

create_project $project_name $project_dir -part xczu67dr-fsve1156-2-i
set_property board_part xilinx.com:zcu670:part0:2.0 [current_project]
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property target_simulator XSim [current_project]

set rtl_dir [file join $repo_root Sources RTL]
add_files -norecurse [list \
    [file join $rtl_dir frame_generator.v] \
    [file join $rtl_dir golden_reference_fifo.v] \
    [file join $rtl_dir frame_checker.v] \
    [file join $rtl_dir core_control_logic.v] \
    [file join $rtl_dir reset_logic.v] \
    [file join $rtl_dir aurora1_tx_idle.v]]
add_files -fileset constrs_1 -norecurse [file join $repo_root Sources Constraints zcu670_pins.xdc]
add_files -fileset sim_1 -norecurse [file join $repo_root Sources Simulation aurora_system_tb.v]
update_compile_order -fileset sources_1

source -notrace [file join $repo_root Sources BD aurora_system.tcl]
if {[llength [get_bd_cells -quiet -hierarchical]] != 12} {
    error "Expected twelve blocks in aurora_system. Block-design recreation is incomplete."
}
set bd_file [get_files aurora_system.bd]
validate_bd_design
save_bd_design
generate_target all $bd_file
add_files -norecurse [make_wrapper -files $bd_file -top]
create_ip_run $bd_file

set_property top aurora_system_wrapper [get_filesets sources_1]
set_property top aurora_system_tb [get_filesets sim_1]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
set_property STEPS.SYNTH_DESIGN.ARGS.SHREG_MIN_SIZE 3 [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.CONTROL_SET_OPT_THRESHOLD auto [get_runs synth_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "AURORA_PROJECT_RECREATED [file join $project_dir ${project_name}.xpr]"
