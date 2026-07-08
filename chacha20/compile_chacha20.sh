#!/bin/bash
export PROJECTNAME="."
echo "the project location is : $PROJECTNAME"
echo "removing libs"
vdel -lib $PROJECTNAME/lib/lib_rtl -all
vdel -lib $PROJECTNAME/lib/lib_bench -all
echo "creating library "
vlib $PROJECTNAME/lib/lib_rtl
vmap lib_rtl $PROJECTNAME/lib/lib_rtl
vlib $PROJECTNAME/lib/lib_bench
vmap lib_bench $PROJECTNAME/lib/lib_bench
# compilation des fichiers sources
echo "compile systemverilog sources"
vlog -sv +acc -svinputport=net -work lib_rtl $PROJECTNAME/src/rtl/chacha_pack.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_rtl $PROJECTNAME/src/rtl/arx.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_rtl $PROJECTNAME/src/rtl/quarter_round.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_rtl $PROJECTNAME/src/rtl/chacha_round.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_rtl $PROJECTNAME/src/rtl/chacha_block.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_rtl $PROJECTNAME/src/rtl/register_state.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_rtl $PROJECTNAME/src/rtl/chacha_fsm.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_rtl $PROJECTNAME/src/rtl/counter.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_rtl $PROJECTNAME/src/rtl/chacha20_top.sv | grep Error
# Compilation des fichiers TB
echo "compile systemverilog test bench"
vlog -sv +acc -svinputport=net -work lib_bench $PROJECTNAME/src/rtl/chacha_pack.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_bench $PROJECTNAME/src/bench/arx_tb.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_bench $PROJECTNAME/src/bench/quarter_round_tb.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_bench $PROJECTNAME/src/bench/chacha_round_tb.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_bench $PROJECTNAME/src/bench/chacha_block_tb.sv | grep Error
vlog -sv +acc -svinputport=net -work lib_bench $PROJECTNAME/src/bench/chacha20_top_tb.sv | grep Error
# lancement du simulateur
echo "compilation finished"
echo "start simulation..."
# attention un seul VSIM decommente a la fois!
#vsim -L lib_rtl lib_bench.arx_tb &
#vsim -L lib_rtl lib_bench.quarter_round_tb &
#vsim -L lib_rtl lib_bench.chacha_round_tb &
#vsim -L lib_rtl lib_bench.chacha_block_tb &
vsim -L lib_rtl lib_bench.chacha20_top_tb &

