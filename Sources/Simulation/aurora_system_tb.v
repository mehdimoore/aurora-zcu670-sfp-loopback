`timescale 1ns / 1fs

module aurora_system_tb;

    reg clk_300mhz    = 1'b0;
    reg clk_156p25mhz = 1'b0;
    reg reset        = 1'b1;

    wire [0:0] sfp0_tx_txp, sfp0_tx_txn;
    wire [0:0] sfp0_rx_rxp, sfp0_rx_rxn;
    wire [0:0] sfp1_tx_txp, sfp1_tx_txn;
    wire [0:0] sfp1_rx_rxp, sfp1_rx_rxn;

    // Board clock sources
    always #1.666666667 clk_300mhz    = ~clk_300mhz;
    always #3.2         clk_156p25mhz = ~clk_156p25mhz;

    // Design under test
    aurora_system_wrapper dut (
        .default_sysclk_c0_300mhz_clk_p ( clk_300mhz),
        .default_sysclk_c0_300mhz_clk_n (~clk_300mhz),
        .GT_DIFF_REFCLK1_0_clk_p         ( clk_156p25mhz),
        .GT_DIFF_REFCLK1_0_clk_n         (~clk_156p25mhz),
        .reset                          (reset),

        .sfp0_tx_txp (sfp0_tx_txp),
        .sfp0_tx_txn (sfp0_tx_txn),
        .sfp0_rx_rxp (sfp0_rx_rxp),
        .sfp0_rx_rxn (sfp0_rx_rxn),

        .sfp1_tx_txp (sfp1_tx_txp),
        .sfp1_tx_txn (sfp1_tx_txn),
        .sfp1_rx_rxp (sfp1_rx_rxp),
        .sfp1_rx_rxn (sfp1_rx_rxn)
    );

    // Simulated cable: Aurora 0 TX -> Aurora 1 RX
    assign sfp1_rx_rxp = sfp0_tx_txp;
    assign sfp1_rx_rxn = sfp0_tx_txn;

    // Simulated cable: Aurora 1 TX -> Aurora 0 RX
    assign sfp0_rx_rxp = sfp1_tx_txp;
    assign sfp0_rx_rxn = sfp1_tx_txn;

    // Status signals for waveform viewing and checking
    wire channel_up_0 =
        dut.aurora_system_i.aurora_64b66b_0.channel_up;
    wire channel_up_1 =
        dut.aurora_system_i.aurora_64b66b_1.channel_up;
    wire checker_error =
        dut.aurora_system_i.frame_checker_0.ERROR;
    wire [31:0] rx_frames =
        dut.aurora_system_i.frame_checker_0.RX_FRAME_COUNT;

    initial begin
        #100 reset = 1'b0;   // Release board reset after 100 ns

        #999900;             // Check and pause at 1 ms total

        if ((channel_up_0 === 1'b1) &&
            (channel_up_1 === 1'b1) &&
            (checker_error === 1'b0) &&
            (rx_frames > 0))
            $display("TEST_PASS: received %0d frames", rx_frames);
        else
            $error("TEST_FAIL: up0=%b up1=%b frames=%0d error=%b",
                   channel_up_0, channel_up_1, rx_frames, checker_error);

        $stop;
    end

endmodule
