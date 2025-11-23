module ingameFSM(clk, inGameOn, userquit, select1, select2, SW, ps2_key_data, ps2_key_pressed, last_data_received, weA, weB, writeA, writeB, readA, readB, addrA, addrB, ledrhldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr, gameOver, currentInGameState);
    input clk, inGameOn, userquit, select1, select2;
    input [7:0] readA, readB;
    input [9:0] SW;
	//PS2 INPUT STUFF
	// Internal Wires
	input [7:0] ps2_key_data;
	input ps2_key_pressed;
// Internal Registers
	input [7:0] last_data_received;

    output reg [9:0] ledrhldr;
    output reg [3:0] hex2hldr, hex3hldr, hex4hldr, hex5hldr;
    output reg gameOver;
    output reg [3:0] addrA, addrB;
    output reg weA, weB;
    //Remove this if not debugging (exposed wires)
    output [2:0] currentInGameState;

    reg [7:0] dementiaScore;
    reg [2:0] currentInGame, nextInGame;
	//exposed for debugging
	assign currentInGameState = currentInGame;
	reg [9:0] currentOn, nextCurrentOn1, nextCurrentOn2;
	reg [7:0] tileCode1, tileCode2;
    reg [4:0] tile1Loc, tile2Loc;
	
	//edge detection for keys (active low, so detect falling edge)
	reg select1Prev, select2Prev;
	wire select1Edge, select2Edge;
	assign select1Edge = !select1 && select1Prev;  // falling edge: was high, now low
	assign select2Edge = !select2 && select2Prev;  // falling edge: was high, now low

    localparam Idle = 3'b000, OneTile = 3'b001, TwoTile = 3'b011, OffGameOver = 3'b100, NotInGame = 3'b101, Waiting = 3'b010;
    
    //set up each tile, 10 FOR FPGA INTIAL
	wire [10:0] T_0, T_1, T_2, T_3, T_4, T_5, T_6, T_7, T_8, T_9; 
	//2-row, 2-col, 6-color, 1-flipped
	assign T_0 = 8'b00111100;
	assign T_1 = 8'b11001000;
	assign T_2 = 8'b11100000;
	assign T_3 = 8'b11100000;
	assign T_4 = 8'b11010000;
	assign T_5 = 8'b10001100;
	assign T_6 = 8'b11110000;
	assign T_7 = 8'b00001100;
	assign T_8 = 8'b11001000;
	assign T_9 = 8'b11010000;
	assign T_10 = 8'b11110000;
	assign T_11 = 8'b01110000;
	assign T_12 = 8'b10001100;
	assign T_13 = 8'b01110000;
	assign T_14 = 8'b00111100;
	assign T_15 = 8'b00001100;

//clock stuff
wire halfsec;
halfseccounter  tick (clk, userquit, halfsec);

reg twosec;
reg [26:0] counter2;
//clock_twosec_counter tock (clk, userquit, twosec);



    always @ (*)
    begin
        case (currentInGame)
            NotInGame:
                begin
                    if (inGameOn)
                        nextInGame <= Idle;
                    else
                        nextInGame <= NotInGame;
                end
            Idle:   
                begin   
                    if (userquit == 1 || !inGameOn) 
                        nextInGame <= NotInGame;
                    else if (tileCode1 != 11'b0)
                        nextInGame <= Waiting;
                    else
                        nextInGame <= Idle;
                end
            Waiting: //seeing if adding another state to wait here will stop the issue
                begin 
                    if (userquit == 1 || !inGameOn) 
                        nextInGame <= NotInGame;
                    else if (halfsec == 1)
                        nextInGame <= OneTile;
                    else
                        nextInGame <= Waiting;
                end

            OneTile: 
                begin 
                    if (userquit == 1 || !inGameOn) 
                        nextInGame <= NotInGame;
                    else if (tileCode2 != 11'b0)
                        nextInGame <= TwoTile;
                    else
                        nextInGame <= OneTile;
                end

            TwoTile:   
                begin 
                    if (userquit == 1)   
                        nextInGame <= NotInGame;
                    else if (gameOver == 1)
                        nextInGame <= OffGameOver;
                    else if (twosec)
                        nextInGame <= Idle;
                    else
                        nextInGame <= TwoTile;
                end
            OffGameOver:
                begin
                    if (inGameOn | userquit) 
                        nextInGame <= NotInGame;
                    else 
                        nextInGame <= OffGameOver;
                end
            default: nextInGame <= NotInGame;  
        endcase  
    end
	 
	always @ (posedge clk)  
	begin  
		if (userquit == 1)
			currentInGame <= NotInGame;
		else  
			currentInGame <= nextInGame;
		
		// edge detection
		select1Prev <= select1;
		select2Prev <= select2;
	end
	
	//initialize state to NotInGame on startup
	initial
	begin
		currentInGame <= NotInGame;
		nextInGame <= NotInGame;
		gameOver <= 1'b0;
		currentOn <= 10'b0000000000;
		nextCurrentOn1 <= 10'b0000000000;
		nextCurrentOn2 <= 10'b0000000000;
		tileCode1 <= 11'b00000000000;
		tileCode2 <= 11'b00000000000;
		dementiaScore <= 8'b00000000;
		select1Prev <= 1'b0;
		select2Prev <= 1'b0;
		twosec <= 1'b0;
	end

    always @ (posedge clk)  
	begin
        case (currentInGame)
            NotInGame:
                begin
                    hex2hldr <= 4'b1111;
                    hex3hldr <= 4'b1111;
                    hex4hldr <= 4'b1111;
                    hex5hldr <= 4'b1111;
                    currentOn <= 10'b0000000000; 
                    nextCurrentOn1 <= 10'b0000000000;
                    nextCurrentOn2 <= 10'b0000000000;
                    dementiaScore <= 8'b00000000;
                    tileCode1 <= 8'b00000000;
                    tileCode2 <= 8'b00000000;
                    gameOver <= 1'b0;
                    ledrhldr <= 10'b0000000000;
		            twosec <= 1'b0;
                    weA <= 1'b0;
                    weB <= 1'b0;
                end

		Idle:
				begin
					hex2hldr <= 4'b1111;
					hex3hldr <= 4'b1111;
					hex4hldr <= dementiaScore[3:0];
					hex5hldr <= dementiaScore[7:4];
					gameOver <= 1'b0;
		            twosec <= 1'b0;
                    weB <= 1'b0;

					
					//show current switches on LEDs combined with matched tiles
					ledrhldr <= currentOn | SW;
					
					//if select1 pressed and a switch is set, select first tile
		if (ps2_key_pressed)
		begin
            weA <= 1'b1;
            
			if (ps2_key_data == 8'h16 && !currentOn[0]) begin
				tileCode1 <= T_0;
                addrA <= 4'b0000;
                tile1Loc <= 4'b0000;
                writeA <= readA | 8'b00000010;
				nextCurrentOn1 <= currentOn | 10'b0000000001;
			end else if (ps2_key_data == 8'h1e && !currentOn[1]) begin
				tileCode1 <= T_1;
                addrA <= 4'b0001;
                tile1Loc <= 4'b0001;
                writeA <= readA | 8'b00000010;
				nextCurrentOn1 <= currentOn | 10'b0000000010;
			end else if (ps2_key_data == 8'h26 && !currentOn[2]) begin
				tileCode1 <= T_2;
                addrA <= 4'd2;
                tile1Loc <= 4'd2;
                writeA <= readA | 8'b00000010;
				nextCurrentOn1 <= currentOn | 10'b0000000100;
			end else if (ps2_key_data == 8'h25 && !currentOn[3]) begin
				tileCode1 <= T_3;
                addrA <= 4'd3;
                tile1Loc <= 4'd3;
                writeA <= readA | 8'b00000010;
				nextCurrentOn1 <= currentOn | 10'b0000001000;
			end else if (ps2_key_data == 8'h15 && !currentOn[4]) begin
				tileCode1 <= T_4;
                addrA <= 4'd4;
                tile1Loc <= 4'd4;
                writeA <= readA | 8'b00000010;
				nextCurrentOn1 <= currentOn | 10'b0000010000;
			end else if (ps2_key_data == 8'h1d && !currentOn[5]) begin
				tileCode1 <= T_5;
                addrA <= 4'd5;
                tile1Loc <= 4'd5;
                writeA <= readA | 8'b00000010;
				nextCurrentOn1 <= currentOn | 10'b0000100000;
			end else if (ps2_key_data == 8'h24 && !currentOn[6]) begin
				tileCode1 <= T_6;
                addrA <= 4'd6;
                tile1Loc <= 4'd6;
                writeA <= readA | 8'b00000010;
				nextCurrentOn1 <= currentOn | 10'b0001000000;
			end else if (ps2_key_data == 8'h2d && !currentOn[7]) begin
				tileCode1 <= T_7;
                addrA <= 4'd7;
                tile1Loc <= 4'd7;
                writeA <= readA | 8'b00000010;
				nextCurrentOn1 <= currentOn | 10'b0010000000;
			end else if (ps2_key_data == 8'h1c && !currentOn[8]) begin
				tileCode1 <= T_8;
                addrA <= 4'd8;
                tile1Loc <= 4'd8;
                writeA <= readA | 8'b00000010;
				nextCurrentOn1 <= currentOn | 10'b0100000000;
			end else if (ps2_key_data == 8'h1b && !currentOn[9]) begin
				tileCode1 <= T_9;
                addrA <= 4'd9;
                tile1Loc <= 4'd9;
                writeA <= readA | 8'b00000010;
				nextCurrentOn1 <= currentOn | 10'b1000000000;
			end
		end
				end

            Waiting:
                begin
                    ledrhldr <= nextCurrentOn1;
					hex3hldr <= tileCode1[5:1];
                    hex2hldr <= 4'b1111;
                    hex4hldr <= dementiaScore[3:0];
                    hex5hldr <= dementiaScore[7:4];
                    gameOver <= 1'b0; 
                    weA <= 1'b0;
                    weB <= 1'b0;
		twosec <= 1'b0;
                end

		OneTile:
				begin
					hex2hldr <= 4'b1111;
					hex3hldr <= tileCode1[5:1];
					hex4hldr <= dementiaScore[3:0];
					hex5hldr <= dementiaScore[7:4];
					gameOver <= 1'b0;
		            twosec <= 1'b0;
                    weA <= 1'b0;
					
					//show first selected tile on LEDs
					ledrhldr <= nextCurrentOn1;
					
					//if select2 pressed and a switch is set, select second tile
		if (ps2_key_pressed && (ps2_key_data != last_data_received))
		begin
            weB = 1'b1;
			if (ps2_key_data == 8'h16 && T_0 != tileCode1 && !currentOn[0]) begin
				tileCode2 <= T_0;
                addrB <= 4'd0;
                tile2Loc <= 4'd0;
                writeB <= readb | 8'b00000010;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000000001;
			end else if (ps2_key_data == 8'h1e && T_1 != tileCode1 && !currentOn[1]) begin
				tileCode2 <= T_1;
                addrB <= 4'd1;
                tile2Loc <= 4'd1;
                writeB <= readB | 8'b00000010;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000000010;
			end else if (ps2_key_data == 8'h26 && T_2 != tileCode1 && !currentOn[2]) begin
				tileCode2 <= T_2;
                addrB <= 4'd2;
                tile2Loc <= 4'd2;
                writeB <= readB | 8'b00000010;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000000100;
			end else if (ps2_key_data == 8'h25 && T_3 != tileCode1 && !currentOn[3]) begin
				tileCode2 <= T_3;
                addrB <= 4'd3;
                tile2Loc <= 4'd3;
                writeB <= readB | 8'b00000010;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000001000;
			end else if (ps2_key_data == 8'h15 && T_4 != tileCode1 && !currentOn[4]) begin
				tileCode2 <= T_4;
                addrB <= 4'd4;
                tile2Loc <= 4'd4;
                writeB <= readB | 8'b00000010;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000010000;
			end else if (ps2_key_data == 8'h1d && T_5 != tileCode1 && !currentOn[5]) begin
				tileCode2 <= T_5;
                addrB <= 4'd5;
                tile2Loc <= 4'd5;
                writeB <= readB | 8'b00000010;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000100000;
			end else if (ps2_key_data == 8'h24 && T_6 != tileCode1 && !currentOn[6]) begin
				tileCode2 <= T_6;
                addrB <= 4'd6;
                tile2Loc <= 4'd6;
                writeB <= readB | 8'b00000010;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0001000000;
			end else if (ps2_key_data == 8'h2d && T_7 != tileCode1 && !currentOn[7]) begin
				tileCode2 <= T_7;
                addrB <= 4'd7;
                tile2Loc <= 4'd7;
                writeB <= readB | 8'b00000010;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0010000000;
			end else if (ps2_key_data == 8'h1c && T_8 != tileCode1 && !currentOn[8]) begin
				tileCode2 <= T_8;
                addrB <= 4'd8;
                tile2Loc <= 4'd8;
                writeB <= readB | 8'b00000010;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0100000000;
			end else if (ps2_key_data == 8'h1b && T_9 != tileCode1 && !currentOn[9]) begin
				tileCode2 <= T_9;
                addrB <= 4'd9;
                tile2Loc <= 4'd9;
                writeB <= readB | 8'b00000010;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b1000000000;
			end
		end
				end

			TwoTile:
				begin
				hex2hldr <= tileCode2[5:1];
				hex3hldr <= tileCode1[5:1];
				hex4hldr <= dementiaScore[3:0];
				hex5hldr <= dementiaScore[7:4];

				if (counter2 == 27'b101111101011110000100000000) //if the counter has reached 0.5 seconds 
			//for modelsim change to this line instead, does every 5 cycles as a halfsec 
			// if (counter == 26'b00000000000000000000000101) 
					begin 
					counter2 <= 27'b0; 

				//if select1 pressed, compare tiles
					dementiaScore <= dementiaScore + 1;
						
					if (tileCode1[5:1] == tileCode2[5:1])
						begin
						//LEDs stay on
						currentOn <= nextCurrentOn2;
						ledrhldr <= nextCurrentOn2;
							
						//check if all tiles matched
						if (nextCurrentOn2 == 10'b1111111111)
							gameOver <= 1'b1;
						else
							gameOver <= 1'b0;
						end
					else
						begin
						//LEDs turn off
						ledrhldr <= currentOn;
						gameOver <= 1'b0;
                        addrA <= tile1Loc;
                        addrB <= tile2Loc;
                        weA <= 1'b1;
                        weB <= 1'b1;
                        writeA <= readA | 8'b00000010;
                        writeB <= readB | 8'b00000010;
						end
						
					//clear LEDS, turn off hex displays
					tileCode1 <= 8'b0;
					tileCode2 <= 8'b0;
                    nextCurrentOn1 <= 10'b0;
                    nextCurrentOn2 <= 10'b0;

					twosec <= ~twosec; 
					end 
				else 
					begin 
					twosec <= 0; 
					counter2 <= counter2 + 1; 
					//show both selected tiles on LEDs
					ledrhldr <= nextCurrentOn2;
					end
					
				end

            OffGameOver:
                begin
                    ledrhldr <= currentOn;
                    hex3hldr <= 4'b1111;
                    hex2hldr <= 4'b1111;
                    hex4hldr <= dementiaScore[3:0];
                    hex5hldr <= dementiaScore[7:4];
                    gameOver <= 1'b1; 
                    weA <= 1'b0;
                    weB <= 1'b0;
                end

            default:
                begin
                    ledrhldr <= 10'b0;
                    hex2hldr <= 4'b1111;
                    hex3hldr <= 4'b1111;
                    hex4hldr <= 4'b1111;
                    hex5hldr <= 4'b1111;
                    weA <= 1'b0;
                    weB <= 1'b0;
                end
        endcase
    end
endmodule

module clock_twosec_counter (Clock, clear, pulse);
	input Clock, clear;
	reg [26:0]counter;
	output reg pulse;
	always@(posedge Clock)
	begin
		if(!clear)
			begin
			counter <= 27'd99999998;
			pulse <= 1'b0;
			end
		else
			begin
				if (counter == 0)
					begin
					counter <= 27'd99999998;
					pulse <= 1'b1;
					end
				else
					begin
					counter <= counter -1;
					pulse <= 1'b0;
					end
			end
	end
endmodule

module halfseccounter (Clock, clear, pulse);
	input Clock, clear;
	reg [26:0] counter;
	output reg pulse;
	always@(posedge Clock)
	begin
		if (counter == 26'b01011111010111100001000000) //if the counter has reached 0.5 seconds 

		//for modelsim change to this line instead, does every 5 cycles as a halfsec 
		// if (counter == 26'b00000000000000000000000101) 
			begin 
			counter <= 26'b0; 
			pulse <= ~pulse; 
			end 
		else 
			begin 
			pulse <= 0; 
			counter <= counter + 1; 
			end
	end
endmodule

