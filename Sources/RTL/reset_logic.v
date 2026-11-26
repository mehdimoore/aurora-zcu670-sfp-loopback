`timescale 1ns / 1fs

module reset_logic (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 init_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME init_clk, FREQ_HZ 100000000, ASSOCIATED_RESET pma_init:reset_pb" *)
    input  wire init_clk,
    input  wire locked,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_request RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input  wire reset_request,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 pma_init RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output reg  pma_init = 1'b1,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_pb RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output reg  reset_pb = 1'b1
);
    wire reset_async = reset_request | ~locked;
    (* ASYNC_REG = "TRUE" *) reg [1:0] reset_sync = 2'b11;
    reg [10:0] count = 11'd0;

    // Assert immediately; release after two init_clk edges.
    always @(posedge init_clk or posedge reset_async)
        if (reset_async) reset_sync <= 2'b11;
        else             reset_sync <= {reset_sync[0], 1'b0};

    always @(posedge init_clk or posedge reset_sync[1]) begin
        if (reset_sync[1]) begin
            count    <= 11'd0;
            pma_init <= 1'b1;
            reset_pb <= 1'b1;
        end else if (reset_pb) begin
            count <= count + 1'b1;
            if (count == 11'd1023) pma_init <= 1'b0;
            if (count == 11'd2047) reset_pb <= 1'b0;
        end
    end
endmodule
