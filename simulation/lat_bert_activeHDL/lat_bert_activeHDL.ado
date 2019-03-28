setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "C:/git/lat_bert/simulation/lat_bert_activeHDL/lat_bert_activeHDL.adf"]} { 
	design create lat_bert_activeHDL "C:/git/lat_bert/simulation"
  set newDesign 1
}
design open "C:/git/lat_bert/simulation/lat_bert_activeHDL"
cd "C:/git/lat_bert/simulation"
designverincludedir -clear
designverlibrarysim -PL -clear
designverlibrarysim -L -clear
designverlibrarysim -PL pmi_work
designverlibrarysim ovi_ecp5um
designverdefinemacro -clear
if {$newDesign == 0} { 
  removefile -Y -D *
}
addfile "C:/git/lat_bert/rtl_sources/prbs7x1_chk.v"
addfile "C:/git/lat_bert/rtl_sources/prbs7x1_gen.v"
addfile "C:/git/lat_bert/rtl_sources/prbs_loopback_top.v"
addfile "C:/git/lat_bert/rtl_sources/sim_sources/prbs_loopback_top_tb.v"
vlib "C:/git/lat_bert/simulation/lat_bert_activeHDL/work"
set worklib work
adel -all
vlog -dbg -work work "C:/git/lat_bert/rtl_sources/prbs7x1_chk.v"
vlog -dbg -work work "C:/git/lat_bert/rtl_sources/prbs7x1_gen.v"
vlog -dbg -work work "C:/git/lat_bert/rtl_sources/prbs_loopback_top.v"
vlog -dbg -work work "C:/git/lat_bert/rtl_sources/sim_sources/prbs_loopback_top_tb.v"
module prbs_loopback_top_tb
vsim  +access +r prbs_loopback_top_tb   -PL pmi_work -L ovi_ecp5um
add wave *
run 1000ns
