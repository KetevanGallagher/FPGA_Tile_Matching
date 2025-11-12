module tilegame (SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	//signals here
	wire userquit, keytobegin; //buttons for control
	reg gameOver; //signal for when the game ends
	reg [3:0] currentMode, nextMode; //what mode in
	reg [2:0] currentInGame, nextInGame; //what state of th game
	reg [7:0] dementiaScore; //counts how many moves the user made

	reg [9:0] ledrhldr;
	reg new, new2;

	//signals from LEDFromTile
	reg [10:0] code;
	reg on;

	//signals from ingame mode
	reg [9:0] currentOn, nextCurrentOn1, nextCurrentOn2;
	reg [10:0] tileCode1, tileCode2;

	//signals to manage the timing of twotiles
	reg [25:0] counter2s;
	reg twosec;

	//holders so that hexes canbe turned on within the always blocks
	reg [3:0] hex0hldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr;

	assign userquit = ~KEY[0];
	assign keytobegin = ~KEY[1];

	//set up each tile, 10 FOR FPGA INTIAL
	wire [10:0] T_0, T_1, T_2, T_3, T_4, T_5, T_6, T_8, T_9; 
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

	//assign codes for the ingame fsm
	localparam Gmenu = 4'b0000, Gingame = 4'b0011, Gendgame = 4'b0101, Gleaderboard = 4'b1001;
	localparam Idle = 3'b000, OneTile = 3'b001, TwoTile = 3'b011;

//a bunch of always bloicks go here to control game modes and what happens in them
//first one controls how the switch between states happens
	always @ (*)
	begin
	case (currentMode)  
		Gmenu:   
			begin
				if (keytobegin == 1)   
					 nextMode <= Gingame;
				else   
					 nextMode <= Gmenu;   
			end  

		Gingame:
			begin	
				if (gameOver == 1)
					 nextMode <= Gendgame; 
				else
					 nextMode <= Gingame; 
			end 

		Gendgame:
			nextMode <= Gendgame;   

		default: nextMode <= Gmenu;  
	endcase

	end //end for changing game mode

//second one controls how the switch between in game happens
	always @ (*)
	begin
	case (currentInGame)  
		Idle:   
			begin   
	  		//user quits
			if (userquit == 1) 
				 nextInGame <= Idle;
			else
				begin
				if (new)
					nextInGame <= OneTile;
				else
					nextInGame <= Idle;
				end  
			end

		OneTile: 
			begin 
			//user quits
			if (userquit == 1) 
				 nextInGame <= Idle;
			else
				begin
				if (new2)
					nextInGame <= TwoTile;
				else
					nextInGame <= OneTile;
				end 
			end

		TwoTile:   
			begin 
	  		//if user quits
			if (userquit == 1)   
				nextInGame <= Idle;
			//if all are matched just go back to the default
			else
  				begin  
        			//do the counting up to two seconsd  
        			if (twosec != 1)  
					nextInGame <= TwoTile;
				else
					nextInGame <= Idle;
				end
					
			end

		default: nextInGame <= Idle;  

	endcase  
	end //end for changing in game

//an always block that updates states as often as possible  
	always @ (posedge CLOCK_50)  
	begin  
	if (userquit == 1)
		begin
		currentMode <= Gmenu;
		currentInGame <= Idle;
		end

	else  
		begin
		currentMode <= nextMode;  
		if (currentMode == Gingame) 
			currentInGame <= nextInGame;
	  	end
	end //end of updating states

//an always block for what to do in each mode
	always @ (posedge CLOCK_50)  
	begin 
	if (userquit == 1) 
		//SET ALL VARIABLES TO ZEROS HERE
		begin
		hex0hldr <= 4'b0000;
		hex2hldr <= 4'b1111;
		hex3hldr <= 4'b1111;
		hex4hldr <= 4'b1111;
		hex5hldr <= 4'b1111;
		currentOn <= 10'b0000000000; 
		nextCurrentOn1 <= 10'b0000000000; 
		nextCurrentOn2 <= 10'b0000000000;
		dementiaScore <= 8'b00000000;
		new <= 0;
		new2 <= 0;
		tileCode1 <= 11'b00000000000;
		tileCode2 <= 11'b00000000000;
		gameOver <= 1'b0;
		counter2s <= 26'b00000000000000000000000000;
		twosec <= 0;
		end

	else //literally do everything else
		begin
		if (currentMode == Gmenu)
			begin
			//any vga stuff
			hex0hldr <= 4'b0000;
			hex2hldr <= 4'b1111;
			hex3hldr <= 4'b1111;
			hex4hldr <= 4'b1111;
			hex5hldr <= 4'b1111;
			currentOn <= 10'b0000000000; 
			nextCurrentOn1 <= 10'b0000000000; 
			nextCurrentOn2 <= 10'b0000000000;
			dementiaScore <= 8'b00000000;
			new <= 0;
			new2 <= 0;
			tileCode1 <= 11'b00000000000;
			tileCode2 <= 11'b00000000000;
			gameOver <= 1'b0;
			counter2s <= 26'b00000000000000000000000000;
			twosec <= 0;
			ledrhldr <= 10'b0000000000;
			end

		else if (currentMode == Gingame)
			begin
			hex0hldr <= 4'b0001;
			hex4hldr <= dementiaScore[3:0];
			hex5hldr <= dementiaScore[7:4];
			//try chucking in the entirety of the in game what to do here
			if (currentInGame == Idle)
				begin
				ledrhldr <= currentOn;
				hex2hldr <= 4'b1111;
				hex3hldr <= 4'b1111;
				new <= 1'b0;
				//simulate running get tile by changing what goes into it -  current on same
				//module getTile(SW, pastOn, tileCode, new, newOn);
				if (SW[0] && !currentOn[0])
					begin
					tileCode1 <= T_0;
					nextCurrentOn1 <= currentOn;
					nextCurrentOn1[0] <= 1'b1;
					new <= 1'b1;
					end
				else if (SW[1] && !currentOn[1])
					begin
					tileCode1 <= T_1;
					nextCurrentOn1 <= currentOn;
					nextCurrentOn1[1] <= 1'b1;
					new <= 1'b1;
					end
				else if (SW[2] && !currentOn[2])
					begin
					tileCode1 <= T_2;
					nextCurrentOn1 <= currentOn;
					nextCurrentOn1[2] <= 1'b1;
					new <= 1'b1;
					end
				else if (SW[3] && !currentOn[3])
					begin
					tileCode1 <= T_3;
					nextCurrentOn1 <= currentOn;
					nextCurrentOn1[3] <= 1'b1;
					new <= 1'b1;
					end
				else if (SW[4] && !currentOn[4])
					begin
					tileCode1 <= T_4;
					nextCurrentOn1 <= currentOn;
					nextCurrentOn1[4] <= 1'b1;
					new <= 1'b1;
					end
				else if (SW[5] && !currentOn[5])
					begin
					tileCode1 <= T_5;
					nextCurrentOn1 <= currentOn;
					nextCurrentOn1[5] <= 1'b1;
					new <= 1'b1;
					end
				else if (SW[6] && !currentOn[6])
					begin
					tileCode1 <= T_6;
					nextCurrentOn1 <= currentOn;
					nextCurrentOn1[6] <= 1'b1;
					new <= 1'b1;
					end
				else if (SW[7] && !currentOn[7])
					begin
					tileCode1 <= T_7;
					nextCurrentOn1 <= currentOn;
					nextCurrentOn1[7] <= 1'b1;
					new <= 1'b1;
					end
				else if (SW[8] && !currentOn[8])
					begin
					tileCode1 <= T_8;
					nextCurrentOn1 <= currentOn;
					nextCurrentOn1[8] <= 1'b1;
					new <= 1'b1;
					end
				else if (SW[9] && !currentOn[9])
					begin
					tileCode1 <= T_9;
					nextCurrentOn1 <= currentOn;
					nextCurrentOn1[9] <= 1'b1;
					new <= 1'b1;
					end
				else
					nextCurrentOn1 <= currentOn;
				end //end of idle state

			else if (currentInGame == OneTile)
				begin
				ledrhldr <= nextCurrentOn1;
                    		hex3hldr <= tileCode1[5:1];
				hex2hldr <= 4'b1111;
				new <= 1'b0;
            			gameOver <= 1'b0; 

				//do the get tile again just in here
				//module getTile(SW, pastOn, tileCode, new, newOn);
				if (SW[0] && !nextCurrentOn1[0])
					begin
					tileCode2 <= T_0;
					nextCurrentOn2 <= nextCurrentOn1;
					nextCurrentOn2[0] <= 1'b1;
					new2 <= 1'b1;
					end
				else if (SW[1] && !nextCurrentOn1[1])
					begin
					tileCode2 <= T_1;
					nextCurrentOn2 <= nextCurrentOn1;
					nextCurrentOn2[1] <= 1'b1;
					new2 <= 1'b1;
					end
				else if (SW[2] && !nextCurrentOn1[2])
					begin
					tileCode2 <= T_2;
					nextCurrentOn2 <= nextCurrentOn1;
					nextCurrentOn2[2] <= 1'b1;
					new2 <= 1'b1;
					end
				else if (SW[3] && !nextCurrentOn1[3])
					begin
					tileCode2 <= T_3;
					nextCurrentOn2 <= nextCurrentOn1;
					nextCurrentOn2[3] <= 1'b1;
					new2 <= 1'b1;
					end
				else if (SW[4] && !nextCurrentOn1[4])
					begin
					tileCode2 <= T_4;
					nextCurrentOn2 <= nextCurrentOn1;
					nextCurrentOn2[4] <= 1'b1;
					new2 <= 1'b1;
					end
				else if (SW[5] && !nextCurrentOn1[5])
					begin
					tileCode2 <= T_5;
					nextCurrentOn2 <= nextCurrentOn1;
					nextCurrentOn2[5] <= 1'b1;
					new2 <= 1'b1;
					end
				else if (SW[6] && !nextCurrentOn1[6])
					begin
					tileCode2 <= T_6;
					nextCurrentOn2 <= nextCurrentOn1;
					nextCurrentOn2[6] <= 1'b1;
					new2 <= 1'b1;
					end
				else if (SW[7] && !nextCurrentOn1[7])
					begin
					tileCode2 <= T_7;
					nextCurrentOn2 <= nextCurrentOn1;
					nextCurrentOn2[7] <= 1'b1;
					new2 <= 1'b1;
					end
				else if (SW[8] && !nextCurrentOn1[8])
					begin
					tileCode2 <= T_8;
					nextCurrentOn2 <= nextCurrentOn1;
					nextCurrentOn2[8] <= 1'b1;
					new2 <= 1'b1;
					end
				else if (SW[9] && !nextCurrentOn1[9])
					begin
					tileCode2 <= T_9;
					nextCurrentOn2 <= nextCurrentOn1;
					nextCurrentOn2[9] <= 1'b1;
					new2 <= 1'b1;
					end
				else
					nextCurrentOn2 <= nextCurrentOn1;
				end //enmd of one tiel state

			else if (currentInGame == TwoTile)
				begin
				new <= 1'b0;

        			//if (counter2s == 26'b01011111010111100001000000) //0b101111101011110000100000000if the counter has reached 2 seconds  
        			if (counter2s == 26'b00000000000000000000001010) //if the counter has reached 2 seconds  
            				begin  
            				counter2s <= 26'b0;  
            				twosec <= ~twosec;  
					dementiaScore <= dementiaScore + 1;
					//since counter only runing once do the mathc check in here
					if (tileCode1[5:1] == tileCode2[5:1])
						//if they match, update the currentOn, but if all are now on the
						begin
						currentOn <= nextCurrentOn2;
						ledrhldr <= currentOn;
						tileCode1 <= 11'b0;
						tileCode2 <= 11'b0;
						nextCurrentOn1 <= 26'b0;
						nextCurrentOn2 <= 26'b0;

						if (currentOn == 10'b1111111111)
							gameOver <= 1'b1;
						else
							gameOver <= 1'b0;
						end
            				end  
        			else  
           				begin   
            				twosec <= 0;  
					counter2s <= counter2s + 1;

					//do display signals
					ledrhldr <= nextCurrentOn2;
                    			hex3hldr <= tileCode1[5:1];
                    			hex2hldr <= tileCode2[5:1];
					end  
				end //end of two tile state	
			end //end of being in game

		else if (currentMode == Gendgame)
			begin   
			//setter stuff to avoid latches
			//any vga stuff
			currentOn <= 10'b1111111111; 
			dementiaScore <= 8'b00000000;
			new <= 0;
			new2 <= 0;
			tileCode1 <= 11'b00000000000;
			tileCode2 <= 11'b00000000000;
			gameOver <= 1'b1;
			counter2s <= 26'b00000000000000000000000000;
			twosec <= 0;

			//display stuff
			hex0hldr <= 4'b0010;
			hex2hldr <= 4'b1111;
			hex3hldr <= 4'b1111;
			hex4hldr <= dementiaScore[3:0];
			hex5hldr <= dementiaScore[7:4];
			ledrhldr <= currentOn;
			end  

		end //end of the game modes else
	end //end of the always balck for what to do in a game mode

//after that, make sure the lights get the right outputs
	//every hex light
	hex_7seg moderun (hex0hldr, HEX0);
	hex_7seg moderun1 (4'b1111, HEX1);
	//if in the game and one or two tiles then run the hex 3
	hex_7seg game3 (hex3hldr, HEX3);
	//if in game and two tiles on run the hex2
	hex_7seg game2 (hex2hldr, HEX2);
	//FOR SCORE 	shoudl be given a dummy placeholder when not on
	hex_7seg game4 (hex4hldr, HEX4);
	hex_7seg game5 (hex5hldr, HEX5);
	//every ledr light
	assign LEDR = ledrhldr;


endmodule


module hex_7seg(C, h);
	input [3:0] C;
	output reg [6:0] h;

	always @(*) 
	begin
		case(C)
			4'h0: h = 7'b1000000;
			4'h1: h = 7'b1111001;
			4'h2: h = 7'b0100100;
			4'h3: h = 7'b0110000;
			4'h4: h = 7'b0011001;
			4'h5: h = 7'b0010010;
			4'h6: h = 7'b0000010;
			4'h7: h = 7'b1111000;
			4'h8: h = 7'b0000000;
			4'h9: h = 7'b0010000;
			4'hA: h = 7'b0001000;
			4'hB: h = 7'b0000011;
			4'hC: h = 7'b1000110;
			4'hD: h = 7'b0100001;
			4'hE: h = 7'b0000110;
			4'hF: h = 7'b1111111; //cahnged to be the default off 0001110 is regular F
			default: h = 7'b1111111;
		endcase
	end
endmodule
