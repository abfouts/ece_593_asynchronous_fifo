# Define Environment Variable

PROJ_NAME = 'ASYNC_FIFO'
PROJ_HOME = ../

make:
	rm -rf work
	vlib work
	vlog -sv -64 -cover bcse -f rtl_manifest.f
	vlog -sv -64 -cover bcse -f manifest.f
	vsim -gui -do run.do -classdebug -coverage -voptargs="+acc" -uvmcontrol=all -msgmode both -displaymsgmode both work.top -wlf $(PROJ_NAME).wlf &

UVM_LOW:
	rm -rf work
	vlib work
	vlog -sv -64 -cover bcse -f rtl_manifest.f
	vlog -sv -64 -cover bcse -f manifest.f
	vsim -gui -do run.do -classdebug -coverage -voptargs="+acc" +UVM_VERBOSITY=UVM_LOW -uvmcontrol=all -msgmode both -displaymsgmode both work.top -wlf $(PROJ_NAME).wlf &

#Clean is ran automatically performed on 'make' to limit simulator issues
clean:
	rm -rf work
