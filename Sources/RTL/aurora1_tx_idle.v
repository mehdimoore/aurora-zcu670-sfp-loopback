module aurora_tx_idle (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 USER_CLK CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 161132813, ASSOCIATED_BUSIF M_AXIS" *)
    input wire USER_CLK,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *)
    output wire [63:0] m_axis_tdata,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TKEEP" *)
    output wire [7:0] m_axis_tkeep,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TLAST" *)
    output wire m_axis_tlast,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *)
    output wire m_axis_tvalid,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TREADY" *)
    input wire m_axis_tready
);
    assign m_axis_tdata  = 64'd0;
    assign m_axis_tkeep  = 8'd0;
    assign m_axis_tlast  = 1'b0;
    assign m_axis_tvalid = 1'b0;
endmodule
