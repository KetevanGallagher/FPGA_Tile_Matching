module tilegame (SW, KEY, CLOCK_50, PS2_CLK, PS2_DAT, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;

	// Bidirectionals
	inout PS2_CLK;
	inout PS2_DAT;

	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	//STUFF FOR PS2 (TAKEN FROM DEMO)

	// Internal Wires
	wire [7:0] ps2_key_data;
	wire ps2_key_pressed;

	// Internal Registers
	reg [7:0] last_data_received;

	//signals here
	wire userquit, keytobegin, selectSW;
	assign userquit = ~KEY[0];
	assign keytobegin = ~KEY[1];
    	assign select1 = ~KEY[2];
   	 assign select2 = ~KEY[3];

	wire ingameOn; //signal to show when in game
	wire gameOver; //signal for when the game ends

	reg [7:0] dementiaScore; //counts how many moves user made
	wire [9:0] ledrhldr;

	//holders so that hexes can be turned on within the always blocks
	wire [3:0] hex0hldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr;
	
	//Remove if not debugging
	wire [3:0] gameModeState;
	wire [2:0] inGameState;

	//ALWAYS BLOCK FOR GETTING THE PS2 SIGNALS (TAKEN FROM THE DEMO)
	always @(posedge CLOCK_50)
		begin
		if (KEY[0] == 1'b0)
			last_data_received <= 8'h00;
		else if (ps2_key_pressed == 1'b1)
			last_data_received <= ps2_key_data;
	end

	//get the keyboard inputs (TAKEN FROM THE DEMO)
	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50 (CLOCK_50),
	.reset	(~KEY[0]),

	// Bidirectionals
	.PS2_CLK (PS2_CLK),
 	.PS2_DAT (PS2_DAT),

	// Outputs
	.received_data	(ps2_key_data),
	.received_data_en (ps2_key_pressed)
	);
	

	//run the fsm modules
	gameModeFSM whale1 (userquit, CLOCK_50, gameOver, ps2_key_data, ps2_key_pressed, hex0hldr, ingameOn, gameModeState); //any reason for the whales bestie..? I JUST LIKE WHALES
	ingameFSM whale2 (CLOCK_50, ingameOn, userquit, select1, select2, SW, ps2_key_data, ps2_key_pressed, last_data_received, ledrhldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr, gameOver, inGameState);

	//run the display mode for the hexes SOON TO BE CHANGED FOR VGA
	FPGAdisplay whale3 (userquit, ingameOn, gameOver, hex0hldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr, ledrhldr, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	//POTENTIALLY VGA STUFF HERE LATER


endmodule