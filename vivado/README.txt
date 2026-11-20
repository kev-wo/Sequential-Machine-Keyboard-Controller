Lab 4 - Keyboard Controller (CEG3155)  Kevin Wong, 300447192
src/      design VHDL (top: controleurClavier)
sim/      tb_controleurClavier.vhd (system), tb_composants.vhd (components)
constr/   controleurClavier.xdc (Nexys A7-100T)
setup_project.tcl   vivado -mode batch -source setup_project.tcl   (creates project, runs behavioural sim)
build_bitstream.tcl vivado -mode batch -source build_bitstream.tcl (synth, impl, bitstream)
Board: plug a USB keyboard in the USB-HID port (J5). The last byte received is shown on the two
right-hand 7-segment digits (high nibble = BCD1 on AN1, low nibble = BCD2 on AN0).
Press A: 1C, then on release F0 followed by 1C. Reset = CPU RESET button.
