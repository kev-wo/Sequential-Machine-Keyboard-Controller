# Creates the Vivado project, loads sources, constraints and testbench, and runs the behavioural
# simulation (XSim).
#   Vivado GUI : Tools > Run Tcl Script... > setup_project.tcl
set root [file normalize [file dirname [info script]]]
set proj lab4_clavier
catch {close_sim}
catch {close_project}

create_project $proj $root/vivado_proj -part xc7a100tcsg324-1 -force
set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]

set srcs [glob $root/src/*.vhd]
add_files -norecurse -fileset sources_1 $srcs
set_property file_type {VHDL} [get_files -of_objects [get_filesets sources_1]]
set_property top controleurClavier [get_filesets sources_1]

add_files -norecurse -fileset constrs_1 $root/constr/controleurClavier.xdc

add_files -norecurse -fileset sim_1 $root/sim/tb_controleurClavier.vhd
set_property file_type {VHDL} [get_files $root/sim/tb_controleurClavier.vhd]
add_files -norecurse -fileset sim_1 $root/sim/tb_composants.vhd
set_property file_type {VHDL} [get_files $root/sim/tb_composants.vhd]
set_property top tb_controleurClavier [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {0ns} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

launch_simulation -mode behavioral

set tb /tb_controleurClavier
add_wave_divider Keyboard
add_wave -name HorlogeG        $tb/clk
add_wave -name ResetG          $tb/resetg
add_wave -name HorlogeClavier  $tb/kb_clk
add_wave -name InfoClavier     $tb/kb_dat
add_wave_divider Internal
add_wave -name clk_filtree $tb/dut/clk_f
add_wave -name fe          $tb/dut/fe
add_wave -name state_y1 $tb/dut/u_fsm/y1
add_wave -name state_y0 $tb/dut/u_fsm/y0
add_wave -name count -radix unsigned $tb/dut/cnt
add_wave -name shift_reg -radix hex $tb/dut/sr
add_wave -name parity_ok   $tb/dut/pok
add_wave_divider Outputs
add_wave -name BCD1 -radix hex $tb/bcd1
add_wave -name BCD2 -radix hex $tb/bcd2
add_wave -name SEG -radix bin $tb/seg
add_wave -name AN  -radix bin $tb/an

restart
run 1800 us
puts "Check the lines above for:  Note: *** SIMULATION PASSED: all keyboard frames and display outputs are correct ***"
