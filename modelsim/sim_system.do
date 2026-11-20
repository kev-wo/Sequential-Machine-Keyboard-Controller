# Whole keyboard controller:   do sim_system.do
vsim -t ps work.tb_controleurClavier
add wave -label HorlogeClavier /tb_controleurClavier/kb_clk
add wave -label InfoClavier    /tb_controleurClavier/kb_dat
add wave -label clk_filtree    /tb_controleurClavier/dut/clk_f
add wave -label fe             /tb_controleurClavier/dut/fe
add wave -label y1             /tb_controleurClavier/dut/u_fsm/y1
add wave -label y0             /tb_controleurClavier/dut/u_fsm/y0
add wave -label shift_reg -radix hex /tb_controleurClavier/dut/sr
add wave -label BCD1 -radix hex /tb_controleurClavier/bcd1
add wave -label BCD2 -radix hex /tb_controleurClavier/bcd2
run 1800 us
wave zoom full
