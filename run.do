vlib work
vlog +acc rtl/*.sv rtl/*.v tb/*
vsim -gui +acc work.SPI_TB
log -r /*
do wave.do
run -all
