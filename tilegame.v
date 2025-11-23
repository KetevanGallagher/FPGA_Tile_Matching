module tilegame (SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, PS2_CLK, PS2_DAT);
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;

    //VGA sync
	output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
	output [7:0] VGA_R, VGA_G, VGA_B;
	
	// internal vga signals from vgaDriverTest
    wire [9:0] xOrd, yOrd;
    wire visible, pixelClk; // 25mhz pixel clock from vgaDriver
    wire [7:0] vgaR, vgaG, vgaB;
	
	
	//for the RAM
	wire [3:0] addrA, addrB, addrC;
	wire weA, weB, weC;
	wire [7:0] writeA, writeB, writeC, readA, readB, readC;

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
	
    //inital vga and ram stuff here
    wire [9:0] resX, resY;
	assign resX = 10'd640;
	assign resY = 10'd480;
    vgaDriver vga0(CLOCK_50, KEY[0], resX, resY, VGA_HS, VGA_VS, xOrd, yOrd, visible, pixelClk);
    ramModule u0(pixelClk, addrA, writeA, weA, readA, addrB, writeB, weB, readB, addrC, 8'b00000000, 1'b0, readC);
    

	//run the fsm modules
	gameModeFSM whale1 (userquit, pixelClk, gameOver, ps2_key_data, ps2_key_pressed, hex0hldr, ingameOn, gameModeState); //any reason for the whales bestie..? I JUST LIKE WHALES
	ingameFSM whale2 (pixelClk, ingameOn, userquit, select1, select2, SW, ps2_key_data, ps2_key_pressed, last_data_received, weA, weB, writeA, writeB, readA, readB, addrA, addrB, ledrhldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr, gameOver, inGameState);


	//run the display mode for the hexes SOON TO BE CHANGED FOR VGA
	FPGAdisplay whale3 (userquit, ingameOn, gameOver, hex0hldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr, ledrhldr, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	//POTENTIALLY VGA STUFF HERE LATER
    TileGenerator u1(vis, pixelClk, xOrd, yOrd, addrC, readC, vgaR, vgaG, vgaB);
    
    assign VGA_R = vgaR;
    assign VGA_G = vgaG;
    assign VGA_B = vgaB;
    
    // drive vga clock from the same pixel clock used inside vgaDriver
    assign VGA_CLK = pixelClk;
    
    // blank_n is high during visible pixels, low during blanking
    assign VGA_BLANK_N = visible;
    
    assign VGA_SYNC_N = 1'b0;


endmodule