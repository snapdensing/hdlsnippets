set PROJ_NAME [list dmatest]
set PROJ_PATH [file normalize [file join [file dirname [info script]] "../proj"]]

create_project $PROJ_NAME $PROJ_PATH -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.4 [current_project]
set_property simulator_language Verilog [current_project]

# IP Repository paths
set IPREPO_DIR [file normalize [file join [file dirname [info script]] "../ip_repo"]]
set_property  ip_repo_paths ${IPREPO_DIR} [current_project]
update_ip_catalog

create_bd_design "design_1"

# Zynq
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]
set_property -dict [list CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1}] [get_bd_cells processing_system7_0]
# DMA
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
set_property -dict [list CONFIG.c_s_axis_s2mm_tdata_width.VALUE_SRC USER] [get_bd_cells axi_dma_0]
set_property -dict [list CONFIG.c_include_mm2s {0} CONFIG.c_s_axis_s2mm_tdata_width {8}] [get_bd_cells axi_dma_0]
set_property -dict [list CONFIG.c_include_sg {0} CONFIG.c_sg_include_stscntrl_strm {0}] [get_bd_cells axi_dma_0]

# Datagen
create_bd_cell -type ip -vlnv user.org:user:datagen_axiwrapper:1.0 datagen_axiwrapper_0

# Datagen routing
connect_bd_intf_net [get_bd_intf_pins datagen_axiwrapper_0/m00_axis] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0 (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/axi_dma_0/S_AXI_LITE} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins datagen_axiwrapper_0/m00_axis_aclk]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0 (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/datagen_axiwrapper_0/S00_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins datagen_axiwrapper_0/S00_AXI]
connect_bd_net [get_bd_pins datagen_axiwrapper_0/irq] [get_bd_pins processing_system7_0/IRQ_F2P]

# DMA to Zynq routing
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/axi_dma_0/M_AXI_S2MM} Slave {/processing_system7_0/S_AXI_HP0} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]

