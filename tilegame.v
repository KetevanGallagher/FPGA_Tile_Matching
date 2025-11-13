module tilegame (SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	//signals here
	wire userquit, keytobegin, selectSW; //buttons for controlling modes: userquit also acts as a reset
	assign userquit = ~KEY[0];
	assign keytobegin = ~KEY[1];
    assign select1 = ~KEY[2];
    assign select2 = ~KEY[3];

	wire ingameOn; //signal to show when 
	wire gameOver; //signal for when the game ends

	reg [7:0] dementiaScore; //counts how many moves the user made
	wire [9:0] ledrhldr;

	//holders so that hexes can be turned on within the always blocks
	wire [3:0] hex0hldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr;

	//run the fsm modules
	gameModeFSM whale1 (userquit, keytobegin, CLOCK_50, gameOver, hex0hldr, ingameOn); //any reason for the whales bestie..?
	ingameFSM whale2 (CLOCK_50, ingameOn, userquit, selectSW, SW, ledrhldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr, gameOver);

	//run the display mode for the hexes SOON TO BE CHANGED FOR VGA
	FPGAdisplay whale3 (userquit, ingameOn, gameOver, hex0hldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr, ledrhldr, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	//POTENTIALLY VGA STUFF HERE LATER

endmodule