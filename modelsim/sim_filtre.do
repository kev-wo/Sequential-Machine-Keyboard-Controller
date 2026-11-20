# Digital filter with a bouncing keyboard clock:   do sim_filtre.do
vsim -t ps work.tb_filtre_digitale
add wave -divider "inputs"
add wave -label clk    /tb_filtre_digitale/clk
add wave -label resetb /tb_filtre_digitale/resetb
add wave -label hc     /tb_filtre_digitale/hc
add wave -divider "8 samples (shift register)"
add wave -label samples -radix binary /tb_filtre_digitale/dut/s
add wave -divider "detectors -> asynchronous SR latch"
add wave -label set_all_1 /tb_filtre_digitale/dut/set
add wave -label rst_all_0 /tb_filtre_digitale/dut/rst
add wave -label latch_Q   /tb_filtre_digitale/dut/u_latch/q
add wave -label latch_Qn  /tb_filtre_digitale/dut/u_latch/qn
add wave -divider "output"
add wave -label clk_filtree /tb_filtre_digitale/clk_filtree
run -all
wave zoom full
