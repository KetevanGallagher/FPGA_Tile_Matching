module tilegame (SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, PS2_CLK, PS2_DAT);
   input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	
	//VGA sync
	output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
	output [7:0] VGA_R, VGA_G, VGA_B;
	
	// internal vga signals from vga
    wire [9:0] xOrd, yOrd;
    wire visible, pixelClk; // 25mhz pixel clock from vga
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
	wire userquit, keytobegin;
	reg arrowUp, arrowDown, arrowR, arrowL, select;
	reg breakCodeFlag;
	assign userquit = ~KEY[0];
	assign keytobegin = ~KEY[1];

	wire ingameOn; //signal to show when in game
	wire gameOver; //signal for when the game ends

	reg [7:0] dementiaScore; //counts how many moves user made
	wire [9:0] ledrhldr;
	assign ledrhldr = 10'b000000000;

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
	
	
	
		
	always @(posedge CLOCK_50)
	begin
		if (userquit == 1)
		begin
			arrowUp <= 1'b0;
			arrowDown <= 1'b0;
			arrowL <= 1'b0;
			arrowR <= 1'b0;
			select <= 1'b0;
			breakCodeFlag <= 1'b0;
		end
		else if (ps2_key_pressed)
		begin
			if (ps2_key_data == 8'hF0)
			begin
				breakCodeFlag <= 1'b1;
				arrowUp <= 1'b0;
				arrowDown <= 1'b0;
				arrowL <= 1'b0;
				arrowR <= 1'b0;
				select <= 1'b0;
			end
			else
			begin
				breakCodeFlag <= 1'b0;
				arrowUp <= (!breakCodeFlag && ps2_key_data == 8'h75);
				arrowDown <= (!breakCodeFlag && ps2_key_data == 8'h72);
				arrowL <= (!breakCodeFlag && ps2_key_data == 8'h6B);
				arrowR <= (!breakCodeFlag && ps2_key_data == 8'h74);
				select <= (!breakCodeFlag && ps2_key_data == 8'h29);
			end
		end
		else
		begin
			arrowUp <= 1'b0;
			arrowDown <= 1'b0;
			arrowL <= 1'b0;
			arrowR <= 1'b0;
			select <= 1'b0;
		end
	end
	
	
	//inital vga and ram stuff here
    wire [9:0] resX, resY;
	assign resX = 10'd640;
	assign resY = 10'd480;
    vga_controller vga0(CLOCK_50, KEY[0], xOrd, yOrd, VGA_HS, VGA_VS, visible, VGA_SYNC_N, pixelClk);
    ramModule u0(CLOCK_50, userquit, pixelClk, addrA, writeA, weA, readA, addrB, writeB, weB, readB, addrC, readC);
    

	
	
	

	
		// in tilegame module (signals coming from CLOCK_50 domain)
		reg arrowUp_s1, arrowUp_s2;
		reg arrowDown_s1, arrowDown_s2;
		reg arrowL_s1, arrowL_s2;
		reg arrowR_s1, arrowR_s2;
		reg select_s1, select_s2;
		

		always @(posedge pixelClk) begin
			 arrowUp_s1   <= arrowUp;
			 arrowUp_s2   <= arrowUp_s1;
			 arrowDown_s1 <= arrowDown;
			 arrowDown_s2 <= arrowDown_s1;
			 arrowL_s1    <= arrowL;
			 arrowL_s2    <= arrowL_s1;
			 arrowR_s1    <= arrowR;
			 arrowR_s2    <= arrowR_s1;
			 select_s1    <= select;
			 select_s2    <= select_s1;
		end
			
	

    
    gameModeFSM whale1 (userquit, keytobegin, CLOCK_50, gameOver, hex0hldr, ingameOn); //any reason for the whales bestie..?
    ingameFSM whale2 (CLOCK_50, ingameOn, userquit, arrowUp_s2, arrowDown_s2, arrowR_s2, arrowL_s2, select_s2, weA, weB, writeA, writeB, readA, readB, addrA, addrB, hex4hldr, hex5hldr, gameOver, currentInGameState);

    //run the display mode for the hexes SOON TO BE CHANGED FOR VGA
    FPGAdisplay whale3 (userquit, ingameOn, gameOver, hex0hldr, hex4hldr, hex5hldr, ledrhldr, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

    TileGenerator u1(visible, pixelClk, xOrd, yOrd, addrC, readC, vgaR, vgaG, vgaB);
    
    assign VGA_R = vgaR;
    assign VGA_G = vgaG;
    assign VGA_B = vgaB;
    
    // drive vga clock from the same pixel clock used inside vga
    assign VGA_CLK = pixelClk;
    
    // blank_n is high during visible pixels, low during blanking
    assign VGA_BLANK_N = visible;
    

endmodule