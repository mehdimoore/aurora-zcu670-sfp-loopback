# Tcl commands

These commands recreate and use the project. The complete IP configuration and wiring are in [aurora_system.tcl](../Sources/BD/aurora_system.tcl); project settings and source imports are in [build.tcl](../Scripts/build.tcl).

## Recreate from a terminal

Run from the repository root with Vivado 2025.2 on `PATH`:

```sh
vivado -mode batch -source Scripts/build.tcl
```

To use a different output directory:

```sh
vivado -mode batch -source Scripts/build.tcl -tclargs /path/to/new/build
```

The project is named `aurora_zcu670_sfploopback`. The script creates the block design, validates it, generates IP output products and the wrapper, and creates the IP synthesis runs. Synthesis and implementation are started separately.

## Recreate from the Vivado Tcl console

Start a Vivado session with no project open, change to the repository root, then run:

```tcl
source Scripts/build.tcl
```

## Open an existing generated project

```tcl
open_project build/aurora_zcu670_sfploopback.xpr
open_bd_design [get_files aurora_system.bd]
validate_bd_design
```

## Simulate

The recreation script selects `aurora_system_tb` as the simulation top and opens XSim at time zero. In the project Tcl console:

```tcl
launch_simulation -mode behavioral
```

In the simulation Tcl console:

```tcl
add_wave /aurora_system_tb/channel_up_0
add_wave /aurora_system_tb/channel_up_1
add_wave /aurora_system_tb/checker_error
add_wave /aurora_system_tb/rx_frames
run 1 ms
```

The testbench prints the result and pauses at 1 ms. To repeat the test from its initial state:

```tcl
restart
run 1 ms
```

Use `close_sim` to return to the project before running the build commands.

## Synthesize and generate the bitstream

```tcl
launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
```

Review each run's status and messages. The output files are in `build/aurora_zcu670_sfploopback.runs/impl_1/`:

```text
aurora_system_wrapper.bit
aurora_system_wrapper.ltx
```

## Inspect the implemented design

```tcl
open_run impl_1
report_timing_summary -report_unconstrained
report_bus_skew
report_drc
report_methodology
```

The implementation run also saves reports in its run directory. Check setup/hold timing, clock coverage, bus skew, DRC and methodology findings before programming the board.
