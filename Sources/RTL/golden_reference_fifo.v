`timescale 1ns / 1ps
`default_nettype none

// Passive TX reference store. DEPTH must be at least 1.
// TX_TREADY is an input from Aurora; this module never backpressures TX.
module golden_reference_fifo #(
    parameter integer DEPTH = 256
) (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 USER_CLK CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF TX_MONITOR:REF_PORT, ASSOCIATED_RESET RESET, FREQ_HZ 161132813" *)
    input  wire        USER_CLK,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RESET RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input  wire        RESET,

    // Monitor mode keeps every TX signal, including TREADY, as an input.
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_MONITOR TDATA" *)
    (* X_INTERFACE_MODE = "monitor" *)
    input  wire [63:0] TX_TDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_MONITOR TKEEP" *)
    input  wire [7:0]  TX_TKEEP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_MONITOR TLAST" *)
    input  wire        TX_TLAST,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_MONITOR TVALID" *)
    input  wire        TX_TVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_MONITOR TREADY" *)
    input  wire        TX_TREADY,

    // READ_EN is the reference AXI stream's TREADY; preserve its port name.
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 REF_PORT TREADY" *)
    (* X_INTERFACE_MODE = "master" *)
    input  wire        READ_EN,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 REF_PORT TDATA" *)
    output wire [63:0] REF_TDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 REF_PORT TKEEP" *)
    output wire [7:0]  REF_TKEEP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 REF_PORT TLAST" *)
    output wire        REF_TLAST,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 REF_PORT TVALID" *)
    output wire        REF_TVALID,
    (* X_INTERFACE_IGNORE = "true" *)
    output wire        EMPTY,
    (* X_INTERFACE_IGNORE = "true" *)
    output wire        FULL,
    (* X_INTERFACE_IGNORE = "true" *)
    output reg         OVERFLOW_ERROR
);

    reg [72:0] memory [0:DEPTH-1];
    reg [((DEPTH > 1) ? $clog2(DEPTH) : 1)-1:0] write_ptr, read_ptr;
    reg [$clog2(DEPTH+1)-1:0] used;

    wire write_request = TX_TVALID && TX_TREADY;
    wire read_word     = READ_EN && !EMPTY;
    wire write_word    = write_request && (!FULL || read_word);

    assign EMPTY = (used == 0);
    assign FULL  = (used == DEPTH);
    assign REF_TVALID = !EMPTY;
    // The head is visible before READ_EN; empty outputs are not valid data.
    assign {REF_TLAST, REF_TKEEP, REF_TDATA} = EMPTY ? 73'd0 : memory[read_ptr];

    // Memory contents need no reset: resetting the pointers/count empties it.
    always @(posedge USER_CLK) begin
        if (!RESET && write_word)
            memory[write_ptr] <= {TX_TLAST, TX_TKEEP, TX_TDATA};
    end

    // Assert RESET asynchronously; release it synchronously to USER_CLK.
    always @(posedge USER_CLK or posedge RESET) begin
        if (RESET) begin
            write_ptr      <= 0;
            read_ptr       <= 0;
            used           <= 0;
            OVERFLOW_ERROR <= 1'b0;
        end else begin
            if (write_word)
                write_ptr <= (write_ptr == DEPTH-1) ? 0 : write_ptr + 1'b1;
            if (read_word)
                read_ptr <= (read_ptr == DEPTH-1) ? 0 : read_ptr + 1'b1;

            if (write_word && !read_word)
                used <= used + 1'b1;
            else if (read_word && !write_word)
                used <= used - 1'b1;

            // A full FIFO can still accept a word when one is read that cycle.
            if (write_request && !write_word)
                OVERFLOW_ERROR <= 1'b1;
        end
    end

endmodule

`default_nettype wire
