# Compile every VHDL file (run once):   do compile.do
if {[file exists work]} {vdel -lib work -all}
vlib work
vmap work work
vcom -93 -work work gates.vhd components.vhd dff.vhd half_adder.vhd mux2_1.vhd mux2_4.vhd comp1.vhd comp4.vhd compteur4bit.vhd sync2.vhd bascule_sr.vhd filtre_digitale.vhd detect_front.vhd fsmControleur.vhd registreDecalage.vhd registre8bit.vhd parite.vhd decodeurBCD.vhd afficheur7seg.vhd controleurClavier.vhd tb_bascule_sr.vhd tb_filtre_digitale.vhd tb_composants.vhd tb_controleurClavier.vhd
