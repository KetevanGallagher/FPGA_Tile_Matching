`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 10;

    reg [9:0] SW;
    reg [3:0] KEY;
    reg CLOCK_50;
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	// initial begin
    //     KEY[0] <= 1'b0;
    //     #10 KEY[0] <= 1'b1;
	// end // initial

	initial begin
        SW  = 10'b0;
        KEY = 4'b1111;

        #50 KEY[1] <= 1'b0;  // Press
        #70 KEY[1] <= 1'b1;  // Release

        #100 SW[1] <= 1'b1;
        #120 SW[2] <= 1'b1;

	end // initial


	tilegame U1 (SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

endmodule
