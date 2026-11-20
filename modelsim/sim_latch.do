# Asynchronous SR latch alone, NO clock:   do sim_latch.do
vsim -t ps work.tb_bascule_sr
add wave -divider "SR latch (no clock)"
add wave -label S  /tb_bascule_sr/s
add wave -label R  /tb_bascule_sr/r
add wave -label Q  /tb_bascule_sr/q
add wave -label Qn /tb_bascule_sr/qn
run -all
wave zoom full
