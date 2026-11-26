module core_control_logic (
    (* X_INTERFACE_INFO = "xilinx.com:display_aurora64b66b:core_control_in:1.0 CORE_CONTROL GT_RXCDROVRDEN_IN" *)
    (* X_INTERFACE_MODE = "mirroredSlave" *)
    output wire       gt_rxcdrovrden_in,
    (* X_INTERFACE_INFO = "xilinx.com:display_aurora64b66b:core_control_in:1.0 CORE_CONTROL LOOPBACK" *)
    output wire [2:0] loopback,
    (* X_INTERFACE_INFO = "xilinx.com:display_aurora64b66b:core_control_in:1.0 CORE_CONTROL Power_down" *)
    output wire       power_down
);
    assign power_down        = 1'b0;
    assign loopback          = 3'b000;
    assign gt_rxcdrovrden_in  = 1'b0;

endmodule

