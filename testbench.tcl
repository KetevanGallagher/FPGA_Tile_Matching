        # stop any simulation that is currently running
        quit -sim

        # remove the work library to ensure clean compilation
        if {[file exists work]} {
            file delete -force work
        }

        # create the default "work" library
        vlib work;

        # compile the Verilog source code in the parent folder
        vlog tilegame.v
        vlog FPGAdisplay.v
        vlog gameModeFSM.v
        vlog ingameFSM.v
	vlog PS2_Controller.v
	vlog Altera_UP_PS2_Command_Out.v
	vlog Altera_UP_PS2_Data_In.v


        # compile the Verilog code of the testbench
        vlog testbench.v
        # start the Simulator, including some libraries that may be needed
        vsim work.testbench -Lf 220model -Lf altera_mf_ver -Lf verilog
        # show waveforms specified in wave.do
        do wave.do
        # advance the simulation the desired amount of time
        run 10000 ns
