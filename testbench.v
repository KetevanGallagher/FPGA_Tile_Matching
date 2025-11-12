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
	
	initial begin
        KEY[0] <= 1'b0;
        #10 KEY[0] <= 1'b1;
	end // initial

    // In the setup below we assume that the half_sec_enable signal coming
    // from the half-second clock is asserted every 3 cycles of CLOCK_50. Of
    // course, in the real circuit the half-second clock is asserted every
    // 25M cycles. The setup below produces the Morse code for A (.-) followed
    // by the Morse code for B (-...).
	initial begin
        SW <= 9'b0; KEY[1] = 1; KEY[0] = 1;// not pressed;
        #10 KEY[1] <= 0; KEY[0] <= 1;// pressed to eswitch game mode
        #10 KEY[1] <= 0; KEY[0] <= 0; //pressed reset
        #10 KEY[1] <= [1]; //started game again
        #10 SW <= 9'b000000001;
        #20 SW <= 9'b000000101;
        #30 KEY[0] <= 0; // not pressed
	end // initial
	tilegame U1 (SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

endmodule
