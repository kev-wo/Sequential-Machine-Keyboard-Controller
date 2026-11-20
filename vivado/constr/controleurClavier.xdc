## Nexys A7-100T (xc7a100tcsg324-1) constraints for controleurClavier
## Pin numbers follow Table 4 of the Lab 4 handout / Digilent Nexys-A7-100T-Master.xdc.
## The digital filter ends in an asynchronous SR latch (bascule_sr): its loop waiver is at the end.

## ---- 100 MHz clock -------------------------------------------------------
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports HorlogeG]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports HorlogeG]

## ---- Reset (CPU RESETN, active low) ------------------------------------------------
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports ResetG]

## ---- Keyboard (USB keyboard on J5, PS/2 signals recreated by the PIC24) --------------
set_property -dict { PACKAGE_PIN F4  IOSTANDARD LVCMOS33 PULLUP true } [get_ports HorlogeClavier]
set_property -dict { PACKAGE_PIN B2  IOSTANDARD LVCMOS33 PULLUP true } [get_ports InfoClavier]

## ---- 7-segment display: SEG[0..6] = CA..CG, AN[0..7], DP, all active low ------------------
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {SEG[0]}]
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports {SEG[1]}]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports {SEG[2]}]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports {SEG[3]}]
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {SEG[4]}]
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports {SEG[5]}]
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports {SEG[6]}]
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports DP]
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {AN[0]}]
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports {AN[1]}]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports {AN[2]}]
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports {AN[3]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {AN[4]}]
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports {AN[5]}]
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports {AN[6]}]
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports {AN[7]}]

## ---- BCD1 (high nibble) on LD15..LD12, BCD2 (low nibble) on LD7..LD4 ---------------------
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33 } [get_ports {BCD1[3]}]   ;# LD15
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports {BCD1[2]}]   ;# LD14
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports {BCD1[1]}]   ;# LD13
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports {BCD1[0]}]   ;# LD12
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {BCD2[3]}]   ;# LD7
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports {BCD2[2]}]   ;# LD6
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {BCD2[1]}]   ;# LD5
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports {BCD2[0]}]   ;# LD4

## ---- bitstream properties required by the Artix-7 ---------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## ---- the digital filter ends in an asynchronous SR latch (two cross-coupled NOR gates) ---------
## Intentional combinational loop (lab section 8.3): Vivado reports "found timing loop" (Synth 8-295)
## for it, which is expected. The waiver below lets the bitstream DRC (LUTLP-1) pass.
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -quiet -hierarchical -filter {NAME =~ "*u_latch/q*" || NAME =~ "*u_filtre/q*" || NAME =~ "*clk_f"}]
set_property SEVERITY {Warning} [get_drc_checks LUTLP-1]
