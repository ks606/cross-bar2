derive_clock_uncertainty

create_clock -period 40Mhz -name {clk} [get_ports {clk}]

set_input_delay -clock { clk } -max 1.187 [get_ports rst_in]
set_input_delay -clock { clk } -min 0.0 [get_ports rst_in]

set_input_delay -clock { clk } -max 1.187 [get_ports {master_1_req master_2_req master_3_req master_4_req}]
set_input_delay -clock { clk } -min 0.0 [get_ports {master_1_req master_2_req master_3_req master_4_req}]

set_input_delay -clock { clk } -max 1.187 [get_ports {master_1_cmd master_2_cmd master_3_cmd master_4_cmd}]
set_input_delay -clock { clk } -min 0.0 [get_ports {master_1_cmd master_2_cmd master_3_cmd master_4_cmd}]

set_input_delay -clock { clk } -max 1.187 [get_ports {slave_1_resp slave_2_resp slave_3_resp slave_4_resp}]
set_input_delay -clock { clk } -min 0.0 [get_ports {slave_1_resp slave_2_resp slave_3_resp slave_4_resp}]

set_input_delay -clock { clk } -max 1.187 [get_ports {slave_1_ack slave_2_ack slave_3_ack slave_4_ack}]
set_input_delay -clock { clk } -min 0.0 [get_ports {slave_1_ack slave_2_ack slave_3_ack slave_4_ack}]

set_input_delay -clock { clk } -max 1.187 [get_ports {master_1_addr* master_2_addr* master_3_addr* master_4_addr*}]
set_input_delay -clock { clk } -min 0.0 [get_ports {master_1_addr* master_2_addr* master_3_addr* master_4_addr*}]

set_input_delay -clock { clk } -max 1.187 [get_ports {master_1_wdata* master_2_wdata* master_3_wdata* master_4_wdata*}]
set_input_delay -clock { clk } -min 0.0 [get_ports {master_1_wdata* master_2_wdata* master_3_wdata* master_4_wdata*}]

set_input_delay -clock { clk } -max 1.187 [get_ports {slave_1_rdata* slave_2_rdata* slave_3_rdata* slave_4_rdata*}]
set_input_delay -clock { clk } -min 0.0 [get_ports {slave_1_rdata* slave_2_rdata* slave_3_rdata* slave_4_rdata*}]


set_output_delay -clock { clk } -max 1.187 [get_ports {slave_1_req slave_2_req slave_3_req slave_4_req}]
set_output_delay -clock { clk } -min 0.0 [get_ports {slave_1_req slave_2_req slave_3_req slave_4_req}]

set_output_delay -clock { clk } -max 1.187 [get_ports {slave_1_cmd slave_2_cmd slave_3_cmd slave_4_cmd}]
set_output_delay -clock { clk } -min 0.0 [get_ports {slave_1_cmd slave_2_cmd slave_3_cmd slave_4_cmd}]

set_output_delay -clock { clk } -max 1.187 [get_ports {master_1_ack master_2_ack master_3_ack master_4_ack}]
set_output_delay -clock { clk } -min 0.0 [get_ports {master_1_ack master_2_ack master_3_ack master_4_ack}]

set_output_delay -clock { clk } -max 1.187 [get_ports {master_1_resp master_2_resp master_3_resp master_4_resp}]
set_output_delay -clock { clk } -min 0.0 [get_ports {master_1_resp master_2_resp master_3_resp master_4_resp}]

set_output_delay -clock { clk } -max 1.187 [get_ports {slave_1_addr* slave_2_addr* slave_3_addr* slave_4_addr*}]
set_output_delay -clock { clk } -min 0.0 [get_ports {slave_1_addr* slave_2_addr* slave_3_addr* slave_4_addr*}]

set_output_delay -clock { clk } -max 1.187 [get_ports {slave_1_wdata* slave_2_wdata* slave_3_wdata* slave_4_wdata*}]
set_output_delay -clock { clk } -min 0.0 [get_ports {slave_1_wdata* slave_2_wdata* slave_3_wdata* slave_4_wdata*}]

set_output_delay -clock { clk } -max 1.187 [get_ports {master_1_rdata* master_2_rdata* master_3_rdata* master_4_rdata*}]
set_output_delay -clock { clk } -min 0.0 [get_ports {master_1_rdata* master_2_rdata* master_3_rdata* master_4_rdata*}]

set_false_path -from {master_1_addr*} -to {round_robin:rr_slave1_arbiter|pointer*}





























