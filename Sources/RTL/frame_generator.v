`timescale 1ns / 1ps
`default_nettype none

// 64-bit AXI4-Stream source. FRAME_WORDS must be at least 1.
// Payload starts at zero after reset and counts continuously across frames.
module frame_generator #(
    parameter integer FRAME_WORDS = 16
) (
    // System interface, using the original example's names and reset polarity.
    input  wire        CHANNEL_UP,
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 USER_CLK CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF GENERATED_DATA_M_AXIS, ASSOCIATED_RESET RESET" *)
    input  wire        USER_CLK,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RESET RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input  wire        RESET,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 GENERATED_DATA_M_AXIS TDATA" *)
    output reg  [63:0] m_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 GENERATED_DATA_M_AXIS TKEEP" *)
    output wire [7:0]  m_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 GENERATED_DATA_M_AXIS TLAST" *)
    output wire        m_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 GENERATED_DATA_M_AXIS TVALID" *)
    output reg         m_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 GENERATED_DATA_M_AXIS TREADY" *)
    input  wire        m_axis_tready
);

    localparam integer WORD_INDEX_WIDTH = (FRAME_WORDS > 1) ? $clog2(FRAME_WORDS) : 1;
    localparam [WORD_INDEX_WIDTH-1:0] LAST_WORD = FRAME_WORDS - 1;

    reg [WORD_INDEX_WIDTH-1:0] word_index;

    assign m_axis_tkeep = 8'hFF;
    assign m_axis_tlast = (word_index == LAST_WORD);

    // Assert RESET asynchronously; release it synchronously to USER_CLK.
    always @(posedge USER_CLK or posedge RESET) begin
        if (RESET) begin
            m_axis_tdata  <= 64'd0;
            m_axis_tvalid <= 1'b0;
            word_index    <= {WORD_INDEX_WIDTH{1'b0}};
        end else begin
            // A stalled word remains valid even if CHANNEL_UP is lowered.
            if (!m_axis_tvalid || m_axis_tready)
                m_axis_tvalid <= CHANNEL_UP;

            if (m_axis_tvalid && m_axis_tready) begin
                m_axis_tdata <= m_axis_tdata + 64'd1;
                if (m_axis_tlast)
                    word_index <= {WORD_INDEX_WIDTH{1'b0}};
                else
                    word_index <= word_index + 1'b1;
            end
        end
    end

endmodule

`default_nettype wire
