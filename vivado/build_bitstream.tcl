# Synthesis -> implementation -> bitstream for the Nexys A7-100T. Run after setup_project.tcl
# (close the simulation first: Simulation > Close Simulation).
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
open_run impl_1
report_timing_summary -file timing_summary.rpt
report_utilization    -file utilization.rpt
puts "Bitstream: [get_property DIRECTORY [get_runs impl_1]]/controleurClavier.bit"
puts "Program: Flow Navigator > Open Hardware Manager > Open Target > Auto Connect > Program Device"
