`timescale 1ns / 1ps
`default_nettype none

// Compare Aurora RX against the golden-reference FIFO, one word per clock.
// COUNTER_WIDTH must be at least 1. Both counters saturate at all ones.
module frame_checker #(
    parameter integer COUNTER_WIDTH = 32
) (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 USER_CLK CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF RX:REF_PORT, ASSOCIATED_RESET RESET, FREQ_HZ 161132813" *)
    input  wire        USER_CLK,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RESET RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input  wire        RESET,

    // Aurora RX cannot be backpressured: there is no RX_TREADY port.
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX TDATA" *)
    (* X_INTERFACE_MODE = "slave" *)
    input  wire [63:0] RX_TDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX TKEEP" *)
    input  wire [7:0]  RX_TKEEP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX TLAST" *)
    input  wire        RX_TLAST,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX TVALID" *)
    input  wire        RX_TVALID,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 REF_PORT TDATA" *)
    (* X_INTERFACE_MODE = "slave" *)
    input  wire [63:0] REF_TDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 REF_PORT TKEEP" *)
    input  wire [7:0]  REF_TKEEP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 REF_PORT TLAST" *)
    input  wire        REF_TLAST,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 REF_PORT TVALID" *)
    input  wire        REF_TVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 REF_PORT TREADY" *)
    output wire        REF_TREADY,

    (* X_INTERFACE_IGNORE = "true" *)
    input  wire        FIFO_OVERFLOW_ERROR,
    (* X_INTERFACE_IGNORE = "true" *)
    output reg         ERROR,
    (* X_INTERFACE_IGNORE = "true" *)
    output reg [COUNTER_WIDTH-1:0] ERROR_COUNT,
    (* X_INTERFACE_IGNORE = "true" *)
    output reg [COUNTER_WIDTH-1:0] RX_FRAME_COUNT
);

    reg data_error;
    integer byte_index;

    // Unused bytes may differ; the keep masks themselves must match exactly.
    always @* begin
        data_error = 1'b0;
        for (byte_index = 0; byte_index < 8; byte_index = byte_index + 1)
            if (REF_TKEEP[byte_index] &&
                RX_TDATA[byte_index*8 +: 8] != REF_TDATA[byte_index*8 +: 8])
                data_error = 1'b1;
    end

    wire word_error = !REF_TVALID || data_error ||
                      (RX_TKEEP != REF_TKEEP) || (RX_TLAST != REF_TLAST);

    // Consume an available reference for every RX word, including bad words.
    assign REF_TREADY = RX_TVALID && !RESET;

    // Assert RESET asynchronously; release it synchronously to USER_CLK.
    always @(posedge USER_CLK or posedge RESET) begin
        if (RESET) begin
            ERROR          <= 1'b0;
            ERROR_COUNT    <= 0;
            RX_FRAME_COUNT <= 0;
        end else begin
            if (FIFO_OVERFLOW_ERROR)
                ERROR <= 1'b1;

            if (RX_TVALID) begin
                if (word_error) begin
                    ERROR <= 1'b1;
                    if (!(&ERROR_COUNT))
                        ERROR_COUNT <= ERROR_COUNT + 1'b1;
                end
                if (RX_TLAST && !(&RX_FRAME_COUNT))
                    RX_FRAME_COUNT <= RX_FRAME_COUNT + 1'b1;
            end
        end
    end

endmodule

`default_nettype wire
