if [file exists "work"] {vdel -all}
vlib work

vlog -sv -cover bcefs async_fifo.sv
vlog -sv interface.sv
vlog -sv transaction.sv
vlog -sv coverage.sv
vlog -sv Driver.sv
vlog -sv sequencer.sv
vlog -sv monitor.sv
vlog -sv Scoreboard.sv
vlog -sv environment.sv
vlog -sv agent.sv
vlog -sv sequence_item.sv
vlog -sv test.sv
vlog -sv top_tb.sv +acc



# Simulate the testbench with coverage
vsim -coverage work.top_tb +UVM_VERBOSITY=MEDIUM


#add wave -r *

run -all

# Generate coverage reports
coverage report -details -srcfile=async_fifo.sv

