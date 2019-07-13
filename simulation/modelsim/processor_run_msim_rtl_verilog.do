transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Documents/School/CSE_141L/Lab_2 {D:/Documents/School/CSE_141L/Lab_2/reg_file.v}
vlog -vlog01compat -work work +incdir+D:/Documents/School/CSE_141L/Lab_2 {D:/Documents/School/CSE_141L/Lab_2/processor.v}
vlog -vlog01compat -work work +incdir+D:/Documents/School/CSE_141L/Lab_2 {D:/Documents/School/CSE_141L/Lab_2/serial_buf.v}
vlog -vlog01compat -work work +incdir+D:/Documents/School/CSE_141L/Lab_2 {D:/Documents/School/CSE_141L/Lab_2/inst_rom.v}
vlog -vlog01compat -work work +incdir+D:/Documents/School/CSE_141L/Lab_2 {D:/Documents/School/CSE_141L/Lab_2/data_memory.v}
vlog -vlog01compat -work work +incdir+D:/Documents/School/CSE_141L/Lab_2 {D:/Documents/School/CSE_141L/Lab_2/async_memory.v}
vlog -vlog01compat -work work +incdir+D:/Documents/School/CSE_141L/Lab_2 {D:/Documents/School/CSE_141L/Lab_2/alu.v}
vlog -vlog01compat -work work +incdir+D:/Documents/School/CSE_141L/Lab_2 {D:/Documents/School/CSE_141L/Lab_2/control.v}

