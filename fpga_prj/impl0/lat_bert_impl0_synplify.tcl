#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology ECP5UM5G
set_option -part LFE5UM5G_45F
set_option -package BG381C
set_option -speed_grade -8

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency auto
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false

set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


#-- add_file options
set_option -include_path {C:/git/lat_bert/fpga_prj}
add_file -verilog {C:/git/lat_bert/rtl_sources/prbs_loopback_top.v}
add_file -verilog {C:/git/lat_bert/rtl_sources/prbs7x1_chk.v}
add_file -verilog {C:/git/lat_bert/rtl_sources/prbs7x1_gen.v}

#-- top module name
set_option -top_module prbs_loopback_top

#-- set result format/file last
project -result_file {C:/git/lat_bert/fpga_prj/impl0/lat_bert_impl0.edi}

#-- error message log file
project -log_file {lat_bert_impl0.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run
