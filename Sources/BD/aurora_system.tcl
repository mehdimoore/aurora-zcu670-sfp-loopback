
################################################################
# This is a generated script based on design: aurora_system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source aurora_system_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# frame_generator, golden_reference_fifo, frame_checker, core_control_logic, reset_logic, aurora_tx_idle

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu67dr-fsve1156-2-i
   set_property BOARD_PART xilinx.com:zcu670:part0:2.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name aurora_system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:aurora_64b66b:13.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:ila:6.2\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
frame_generator\
golden_reference_fifo\
frame_checker\
core_control_logic\
reset_logic\
aurora_tx_idle\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set default_sysclk_c0_300mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 default_sysclk_c0_300mhz ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {300000000} \
   ] $default_sysclk_c0_300mhz

  set GT_DIFF_REFCLK1_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 GT_DIFF_REFCLK1_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {156250000} \
   ] $GT_DIFF_REFCLK1_0

  set sfp0_tx [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora64b66b:GT_Serial_Transceiver_Pins_TX_rtl:1.0 sfp0_tx ]

  set sfp0_rx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora64b66b:GT_Serial_Transceiver_Pins_RX_rtl:1.0 sfp0_rx ]

  set sfp1_tx [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora64b66b:GT_Serial_Transceiver_Pins_TX_rtl:1.0 sfp1_tx ]

  set sfp1_rx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora64b66b:GT_Serial_Transceiver_Pins_RX_rtl:1.0 sfp1_rx ]


  # Create ports
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset

  # Create instance: aurora_64b66b_0, and set properties
  set aurora_64b66b_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_64b66b:13.0 aurora_64b66b_0 ]
  set_property -dict [list \
    CONFIG.C_AURORA_LANES {1} \
    CONFIG.C_REFCLK_SOURCE {MGTREFCLK1_of_Quad_X0Y0} \
    CONFIG.SupportLevel {1} \
    CONFIG.drp_mode {Disabled} \
  ] $aurora_64b66b_0


  # Create instance: frame_generator_0, and set properties
  set block_name frame_generator
  set block_cell_name frame_generator_0
  if { [catch {set frame_generator_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $frame_generator_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: golden_reference_fifo_0, and set properties
  set block_name golden_reference_fifo
  set block_cell_name golden_reference_fifo_0
  if { [catch {set golden_reference_fifo_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $golden_reference_fifo_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: frame_checker_0, and set properties
  set block_name frame_checker
  set block_cell_name frame_checker_0
  if { [catch {set frame_checker_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $frame_checker_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: core_control_logic_0, and set properties
  set block_name core_control_logic
  set block_cell_name core_control_logic_0
  if { [catch {set core_control_logic_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $core_control_logic_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: reset_logic_0, and set properties
  set block_name reset_logic
  set block_cell_name reset_logic_0
  if { [catch {set reset_logic_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $reset_logic_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [list \
    CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
    CONFIG.CLKOUT1_JITTER {101.475} \
    CONFIG.CLKOUT1_PHASE_ERROR {77.836} \
    CONFIG.CLK_IN1_BOARD_INTERFACE {default_sysclk_c0_300mhz} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {4.000} \
    CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
    CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
    CONFIG.RESET_BOARD_INTERFACE {reset} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $clk_wiz_0


  # Create instance: aurora_64b66b_1, and set properties
  set aurora_64b66b_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_64b66b:13.0 aurora_64b66b_1 ]
  set_property -dict [list \
    CONFIG.C_AURORA_LANES {1} \
    CONFIG.C_REFCLK_SOURCE {MGTREFCLK1_of_Quad_X0Y0} \
    CONFIG.C_START_LANE {X0Y1} \
    CONFIG.SupportLevel {0} \
    CONFIG.drp_mode {Disabled} \
  ] $aurora_64b66b_1


  # Create instance: aurora_tx_idle_0, and set properties
  set block_name aurora_tx_idle
  set block_cell_name aurora_tx_idle_0
  if { [catch {set aurora_tx_idle_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $aurora_tx_idle_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property CONFIG.C_SIZE {1} $util_vector_logic_0


  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_1


  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0 ]
  set_property -dict [list \
    CONFIG.C_MONITOR_TYPE {Native} \
    CONFIG.C_NUM_OF_PROBES {7} \
    CONFIG.C_PROBE4_WIDTH {32} \
    CONFIG.C_PROBE5_WIDTH {32} \
  ] $ila_0


  # Create interface connections
  connect_bd_intf_net -intf_net GT_DIFF_REFCLK1_0_1 [get_bd_intf_ports GT_DIFF_REFCLK1_0] [get_bd_intf_pins aurora_64b66b_0/GT_DIFF_REFCLK1]
  connect_bd_intf_net -intf_net GT_SERIAL_RX_0_1 [get_bd_intf_ports sfp0_rx] [get_bd_intf_pins aurora_64b66b_0/GT_SERIAL_RX]
  connect_bd_intf_net -intf_net GT_SERIAL_RX_0_2 [get_bd_intf_ports sfp1_rx] [get_bd_intf_pins aurora_64b66b_1/GT_SERIAL_RX]
  connect_bd_intf_net -intf_net aurora_64b66b_0_GT_SERIAL_TX [get_bd_intf_ports sfp0_tx] [get_bd_intf_pins aurora_64b66b_0/GT_SERIAL_TX]
  connect_bd_intf_net -intf_net aurora_64b66b_1_GT_SERIAL_TX [get_bd_intf_ports sfp1_tx] [get_bd_intf_pins aurora_64b66b_1/GT_SERIAL_TX]
  connect_bd_intf_net -intf_net aurora_64b66b_1_USER_DATA_M_AXIS_RX [get_bd_intf_pins aurora_64b66b_1/USER_DATA_M_AXIS_RX] [get_bd_intf_pins frame_checker_0/RX]
  connect_bd_intf_net -intf_net aurora_tx_idle_0_M_AXIS [get_bd_intf_pins aurora_tx_idle_0/M_AXIS] [get_bd_intf_pins aurora_64b66b_1/USER_DATA_S_AXIS_TX]
  connect_bd_intf_net -intf_net default_sysclk_c0_300mhz_1 [get_bd_intf_ports default_sysclk_c0_300mhz] [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]
  connect_bd_intf_net -intf_net frame_generator_0_M_AXIS [get_bd_intf_pins frame_generator_0/GENERATED_DATA_M_AXIS] [get_bd_intf_pins aurora_64b66b_0/USER_DATA_S_AXIS_TX]
connect_bd_intf_net -intf_net [get_bd_intf_nets frame_generator_0_M_AXIS] [get_bd_intf_pins frame_generator_0/GENERATED_DATA_M_AXIS] [get_bd_intf_pins golden_reference_fifo_0/TX_MONITOR]
  connect_bd_intf_net -intf_net golden_reference_fifo_0_REF_PORT [get_bd_intf_pins frame_checker_0/REF_PORT] [get_bd_intf_pins golden_reference_fifo_0/REF_PORT]

  # Create port connections
  connect_bd_net -net Net  [get_bd_pins aurora_64b66b_0/user_clk_out] \
  [get_bd_pins frame_generator_0/USER_CLK] \
  [get_bd_pins golden_reference_fifo_0/USER_CLK] \
  [get_bd_pins frame_checker_0/USER_CLK] \
  [get_bd_pins aurora_64b66b_1/user_clk] \
  [get_bd_pins aurora_tx_idle_0/USER_CLK] \
  [get_bd_pins ila_0/clk]
  connect_bd_net -net Net1  [get_bd_pins util_vector_logic_1/Res] \
  [get_bd_pins frame_generator_0/RESET] \
  [get_bd_pins golden_reference_fifo_0/RESET] \
  [get_bd_pins frame_checker_0/RESET] \
  [get_bd_pins ila_0/probe2]
  connect_bd_net -net Net2  [get_bd_pins core_control_logic_0/loopback] \
  [get_bd_pins aurora_64b66b_0/loopback] \
  [get_bd_pins aurora_64b66b_1/loopback]
  connect_bd_net -net Net3  [get_bd_pins core_control_logic_0/gt_rxcdrovrden_in] \
  [get_bd_pins aurora_64b66b_1/gt_rxcdrovrden_in] \
  [get_bd_pins aurora_64b66b_0/gt_rxcdrovrden_in]
  connect_bd_net -net Net4  [get_bd_pins core_control_logic_0/power_down] \
  [get_bd_pins aurora_64b66b_1/power_down] \
  [get_bd_pins aurora_64b66b_0/power_down]
  connect_bd_net -net aurora_64b66b_0_channel_up  [get_bd_pins aurora_64b66b_0/channel_up] \
  [get_bd_pins util_vector_logic_0/Op2] \
  [get_bd_pins ila_0/probe0]
  connect_bd_net -net aurora_64b66b_0_gt_qpllclk_quad1_out  [get_bd_pins aurora_64b66b_0/gt_qpllclk_quad1_out] \
  [get_bd_pins aurora_64b66b_1/gt_qpllclk_quad1_in]
  connect_bd_net -net aurora_64b66b_0_gt_qplllock_quad1_out  [get_bd_pins aurora_64b66b_0/gt_qplllock_quad1_out] \
  [get_bd_pins aurora_64b66b_1/gt_qplllock_quad1_in]
  connect_bd_net -net aurora_64b66b_0_gt_qpllrefclk_quad1_out  [get_bd_pins aurora_64b66b_0/gt_qpllrefclk_quad1_out] \
  [get_bd_pins aurora_64b66b_1/gt_qpllrefclk_quad1_in]
  connect_bd_net -net aurora_64b66b_0_gt_qpllrefclklost_quad1_out  [get_bd_pins aurora_64b66b_0/gt_qpllrefclklost_quad1_out] \
  [get_bd_pins aurora_64b66b_1/gt_qpllrefclklost_quad1]
  connect_bd_net -net aurora_64b66b_0_gt_refclk1_out  [get_bd_pins aurora_64b66b_0/gt_refclk1_out] \
  [get_bd_pins aurora_64b66b_1/refclk1_in]
  connect_bd_net -net aurora_64b66b_0_gt_reset_out  [get_bd_pins aurora_64b66b_0/gt_reset_out] \
  [get_bd_pins aurora_64b66b_1/pma_init]
  connect_bd_net -net aurora_64b66b_0_mmcm_not_locked_out  [get_bd_pins aurora_64b66b_0/mmcm_not_locked_out] \
  [get_bd_pins aurora_64b66b_1/mmcm_not_locked]
  connect_bd_net -net aurora_64b66b_0_sync_clk_out  [get_bd_pins aurora_64b66b_0/sync_clk_out] \
  [get_bd_pins aurora_64b66b_1/sync_clk]
  connect_bd_net -net aurora_64b66b_0_sys_reset_out  [get_bd_pins aurora_64b66b_0/sys_reset_out] \
  [get_bd_pins util_vector_logic_1/Op2]
  connect_bd_net -net aurora_64b66b_1_channel_up  [get_bd_pins aurora_64b66b_1/channel_up] \
  [get_bd_pins util_vector_logic_0/Op1] \
  [get_bd_pins ila_0/probe1]
  connect_bd_net -net aurora_64b66b_1_sys_reset_out  [get_bd_pins aurora_64b66b_1/sys_reset_out] \
  [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net clk_wiz_0_clk_out1  [get_bd_pins clk_wiz_0/clk_out1] \
  [get_bd_pins aurora_64b66b_0/init_clk] \
  [get_bd_pins reset_logic_0/init_clk] \
  [get_bd_pins aurora_64b66b_1/init_clk]
  connect_bd_net -net clk_wiz_0_locked  [get_bd_pins clk_wiz_0/locked] \
  [get_bd_pins reset_logic_0/locked]
  connect_bd_net -net frame_checker_0_ERROR  [get_bd_pins frame_checker_0/ERROR] \
  [get_bd_pins ila_0/probe3]
  connect_bd_net -net frame_checker_0_ERROR_COUNT  [get_bd_pins frame_checker_0/ERROR_COUNT] \
  [get_bd_pins ila_0/probe4]
  connect_bd_net -net frame_checker_0_RX_FRAME_COUNT  [get_bd_pins frame_checker_0/RX_FRAME_COUNT] \
  [get_bd_pins ila_0/probe5]
  connect_bd_net -net golden_reference_fifo_0_OVERFLOW_ERROR  [get_bd_pins golden_reference_fifo_0/OVERFLOW_ERROR] \
  [get_bd_pins frame_checker_0/FIFO_OVERFLOW_ERROR] \
  [get_bd_pins ila_0/probe6]
  connect_bd_net -net reset_1  [get_bd_ports reset] \
  [get_bd_pins clk_wiz_0/reset] \
  [get_bd_pins reset_logic_0/reset_request]
  connect_bd_net -net reset_logic_0_pma_init  [get_bd_pins reset_logic_0/pma_init] \
  [get_bd_pins aurora_64b66b_0/pma_init]
  connect_bd_net -net reset_logic_0_reset_pb  [get_bd_pins reset_logic_0/reset_pb] \
  [get_bd_pins aurora_64b66b_0/reset_pb] \
  [get_bd_pins aurora_64b66b_1/reset_pb]
  connect_bd_net -net util_vector_logic_0_Res  [get_bd_pins util_vector_logic_0/Res] \
  [get_bd_pins frame_generator_0/CHANNEL_UP]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


