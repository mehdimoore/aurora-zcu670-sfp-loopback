set_property PACKAGE_PIN K28 [get_ports {GT_DIFF_REFCLK1_0_clk_p}]
set_property PACKAGE_PIN K29 [get_ports {GT_DIFF_REFCLK1_0_clk_n}]

# 156.25 MHz GT reference clock: period = 6.400 ns
create_clock -name gt_refclk_156p25 -period 6.400 [get_ports {GT_DIFF_REFCLK1_0_clk_p}]

# SFP0 TX differential pair
set_property PACKAGE_PIN N30 [get_ports {sfp0_tx_txp[0]}]
set_property PACKAGE_PIN N31 [get_ports {sfp0_tx_txn[0]}]

# SFP0 RX differential pair
set_property PACKAGE_PIN P33 [get_ports {sfp0_rx_rxp[0]}]
set_property PACKAGE_PIN P34 [get_ports {sfp0_rx_rxn[0]}]

# SFP1 TX differential pair
set_property PACKAGE_PIN L30 [get_ports {sfp1_tx_txp[0]}]
set_property PACKAGE_PIN L31 [get_ports {sfp1_tx_txn[0]}]

# SFP1 RX differential pair
set_property PACKAGE_PIN M33 [get_ports {sfp1_rx_rxp[0]}]
set_property PACKAGE_PIN M34 [get_ports {sfp1_rx_rxn[0]}]
