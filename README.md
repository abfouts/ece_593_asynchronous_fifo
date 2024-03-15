# ECE_593_Asynchronous_FIFO
In this Final project, we will design and verify the Asynchronous_FIFO using UVM, for Portland States ECE 593 Pre-Silicon Validation

The project file is setup into multiple directories
    -src: Contains the source RTL code (DUT)
    -verify: Contains the test bench files 
    -sim: Contains the makefile and work/ directory for simulation files
    -docs: Contains any useful documentation such as HLDS

To run the simulation run 'make' in the sim/ directory. This will delete and recreate the work/ directory that will
contain all of the simulation files. This allows the dirctory to be clean.

Make will delete work/, run vlib work which recreates the work directory, then it will compile the RTL / simulation files
and it will run a vsim command after that.

# This guy's a phony, a big fat phony!
