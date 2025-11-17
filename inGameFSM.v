module ingameFSM(CLOCK_50, inGameOn, userquit, select1, select2, SW, ledrhldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr, gameOver, currentInGameState);
    input CLOCK_50, inGameOn, userquit, select1, select2;
    input [9:0] SW;

    output reg [9:0] ledrhldr;
    output reg [3:0] hex2hldr, hex3hldr, hex4hldr, hex5hldr;
    output reg gameOver;
    //Remove this if not debugging (exposed wires)
    output [2:0] currentInGameState;

    reg [7:0] dementiaScore;
    reg [2:0] currentInGame, nextInGame;
	//exposed for debugging
	assign currentInGameState = currentInGame;
	reg [9:0] currentOn, nextCurrentOn1, nextCurrentOn2;
	reg [10:0] tileCode1, tileCode2;
	
	//edge detection for keys (active low, so detect falling edge)
	reg select1Prev, select2Prev;
	wire select1Edge, select2Edge;
	assign select1Edge = !select1 && select1Prev;  // falling edge: was high, now low
	assign select2Edge = !select2 && select2Prev;  // falling edge: was high, now low

    localparam Idle = 3'b000, OneTile = 3'b001, TwoTile = 3'b011, OffGameOver = 3'b100, NotInGame = 3'b101;
    
    //set up each tile, 10 FOR FPGA INTIAL
	wire [10:0] T_0, T_1, T_2, T_3, T_4, T_5, T_6, T_7, T_8, T_9; 
	//2-row, 2-col, 6-color, 1-flipped
	assign T_0 = 11'b00000000010;
	assign T_1 = 11'b00000000100;
	assign T_2 = 11'b00000000110;
	assign T_3 = 11'b00000001000;
	assign T_4 = 11'b00000000100;
	assign T_5 = 11'b00000001000;
	assign T_6 = 11'b00000000110;
	assign T_7 = 11'b00000000010;
	assign T_8 = 11'b00000001010;
	assign T_9 = 11'b00000001010;
	
    always @ (*)
    begin
        case (currentInGame)
            NotInGame:
                begin
                    if (inGameOn)
                        nextInGame = Idle;
                    else
                        nextInGame = NotInGame;
                end
            Idle:   
                begin   
                    if (userquit == 1 || !inGameOn) 
                        nextInGame = NotInGame;
                    else if (tileCode1 != 11'b0)
                        nextInGame = OneTile;
                    else
                        nextInGame = Idle;
                end
            OneTile: 
                begin 
                    if (userquit == 1 || !inGameOn) 
                        nextInGame = NotInGame;
                    else if (tileCode2 != 11'b0)
                        nextInGame = TwoTile;
                    else
                        nextInGame = OneTile;
                end
            TwoTile:   
                begin 
                    if (userquit == 1)   
                        nextInGame = NotInGame;
                    else if (currentOn == 10'b1111111111)
                        nextInGame = OffGameOver;
                    else if (tileCode1 == 11'b0 && tileCode2 == 11'b0)
                        nextInGame = Idle;
                    else
                        nextInGame = TwoTile;
                end
            OffGameOver:
                begin
                    if (inGameOn || userquit) 
                        nextInGame = NotInGame;
                    else 
                        nextInGame = OffGameOver;
                end
            default: nextInGame = NotInGame;  
        endcase  
    end
	 
	always @ (posedge CLOCK_50)  
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
	end

    always @ (posedge CLOCK_50)  
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
                    tileCode1 <= 11'b00000000000;
                    tileCode2 <= 11'b00000000000;
                    gameOver <= 1'b0;
                    ledrhldr <= 10'b0000000000;
                end

			Idle:
				begin
					hex2hldr <= 4'b1111;
					hex3hldr <= 4'b1111;
					hex4hldr <= dementiaScore[3:0];
					hex5hldr <= dementiaScore[7:4];
					gameOver <= 1'b0;
					
					//show current switches on LEDs combined with matched tiles
					ledrhldr <= currentOn | SW;
					
					//if select1 pressed and a switch is set, select first tile
		if (select1Edge && |SW)
		begin
			if (SW[0]) begin
				tileCode1 <= T_0;
				nextCurrentOn1 <= currentOn | 10'b0000000001;
			end else if (SW[1]) begin
				tileCode1 <= T_1;
				nextCurrentOn1 <= currentOn | 10'b0000000010;
			end else if (SW[2]) begin
				tileCode1 <= T_2;
				nextCurrentOn1 <= currentOn | 10'b0000000100;
			end else if (SW[3]) begin
				tileCode1 <= T_3;
				nextCurrentOn1 <= currentOn | 10'b0000001000;
			end else if (SW[4]) begin
				tileCode1 <= T_4;
				nextCurrentOn1 <= currentOn | 10'b0000010000;
			end else if (SW[5]) begin
				tileCode1 <= T_5;
				nextCurrentOn1 <= currentOn | 10'b0000100000;
			end else if (SW[6]) begin
				tileCode1 <= T_6;
				nextCurrentOn1 <= currentOn | 10'b0001000000;
			end else if (SW[7]) begin
				tileCode1 <= T_7;
				nextCurrentOn1 <= currentOn | 10'b0010000000;
			end else if (SW[8]) begin
				tileCode1 <= T_8;
				nextCurrentOn1 <= currentOn | 10'b0100000000;
			end else if (SW[9]) begin
				tileCode1 <= T_9;
				nextCurrentOn1 <= currentOn | 10'b1000000000;
			end
		end
				end

			OneTile:
				begin
					hex2hldr <= 4'b1111;
					hex3hldr <= tileCode1[5:1];
					hex4hldr <= dementiaScore[3:0];
					hex5hldr <= dementiaScore[7:4];
					gameOver <= 1'b0;
					
					//show first selected tile on LEDs
					ledrhldr <= nextCurrentOn1;
					
					//if select2 pressed and a switch is set, select second tile
		if (select2Edge && |SW)
		begin
			if (SW[0]) begin
				tileCode2 <= T_0;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000000001;
			end else if (SW[1]) begin
				tileCode2 <= T_1;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000000010;
			end else if (SW[2]) begin
				tileCode2 <= T_2;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000000100;
			end else if (SW[3]) begin
				tileCode2 <= T_3;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000001000;
			end else if (SW[4]) begin
				tileCode2 <= T_4;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000010000;
			end else if (SW[5]) begin
				tileCode2 <= T_5;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0000100000;
			end else if (SW[6]) begin
				tileCode2 <= T_6;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0001000000;
			end else if (SW[7]) begin
				tileCode2 <= T_7;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0010000000;
			end else if (SW[8]) begin
				tileCode2 <= T_8;
				nextCurrentOn2 <= nextCurrentOn1 | 10'b0100000000;
			end else if (SW[9]) begin
				tileCode2 <= T_9;
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
					
					//show both selected tiles on LEDs
					ledrhldr <= nextCurrentOn2;
					
					//if select1 pressed, compare tiles
					if (select1Edge)
					begin
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
						end
						
						//clear LEDS, turn off hex displays
						tileCode1 <= 11'b0;
						tileCode2 <= 11'b0;
						nextCurrentOn1 <= 10'b0;
						nextCurrentOn2 <= 10'b0;
					end
					else
					begin
						gameOver <= (currentOn == 10'b1111111111) ? 1'b1 : 1'b0;
					end
				end

            OffGameOver:
                begin
                    ledrhldr <= 10'b0;
                    hex3hldr <= 4'b1111;
                    hex2hldr <= 4'b1111;
                    hex4hldr <= dementiaScore[3:0];
                    hex5hldr <= dementiaScore[7:4];
                    gameOver <= 1'b1; 
                end

            default:
                begin
                    ledrhldr <= 10'b0;
                    hex2hldr <= 4'b1111;
                    hex3hldr <= 4'b1111;
                    hex4hldr <= 4'b1111;
                    hex5hldr <= 4'b1111;
                end
        endcase
    end
endmodule

module clock_twosec_counter(Clock, clear, pulse);
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
