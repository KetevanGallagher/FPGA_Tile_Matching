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

	//ketevan signals from get tile
	reg [9:0] pastOn;
	reg [10:0] tileCode;
	reg new;
	reg [9:0] newOn;

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

	assign userquit = KEY[0];
	assign keytobegin = KEY[1];

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
//an always block for when to change modes
	always @ (*)  
	begin  
	case (currentMode)  
		Gmenu:   
			begin
				hex0hldr <= 4'b0000;
				hex2hldr <= 4'b1111;
				hex3hldr <= 4'b1111;
				hex4hldr <= 4'b1111;
				hex5hldr <= 4'b1111;
				currentOn <= 10'b0000000000;
				if (keytobegin == 1)   
					 nextMode <= Gingame;
				else   
					 nextMode <= Gmenu;   
			end  

		Gingame:
			begin
				hex0hldr <= 4'b0001;
				hex4hldr <= dementiaScore[3:0];
				hex5hldr <= dementiaScore[7:4];
				
				if (gameOver == 1)
					 nextMode <= Gendgame; 
				else if (userquit == 1) 
					 nextMode <= Gmenu;
				else
					 nextMode <= Gingame; 
			end 

		Gendgame:
			begin   
				hex0hldr <= 4'b0010;
				hex2hldr <= 4'b1111;
				hex3hldr <= 4'b1111;
				hex4hldr <= dementiaScore[3:0];
				hex5hldr <= dementiaScore[7:4];
				if (userquit == 1)   
					 nextMode <= Gmenu; 
				else   
					 nextMode <= Gendgame;   
			end   

		default: nextMode <= Gmenu;  
	endcase  
	end

//an always block for when to change in game modes
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
				ledrhldr <= currentOn;
				hex2hldr <= 4'b1111;
				hex3hldr <= 4'b1111;
				//simulate running get tile by changing what goes into it -  current on same
				pastOn <= currentOn;
				tileCode1 <= tileCode;
				nextCurrentOn1 <= newOn;

				if (new)
					nextInGame <= OneTile;
				else
					begin
            				gameOver <= 1'b0; 
					nextInGame <= Idle;
					end
				end  
			end

		OneTile: 
			begin 
			gameOver <= 1'b0;
			//user quits
			if (userquit == 1) 
				 nextInGame <= Idle;
			else
				begin
				ledrhldr <= nextCurrentOn1;
                    		hex3hldr <= tileCode1[5:1];
				hex2hldr <= 4'b1111;

				//do all the stuff to see if a new tile flipped
				pastOn <= nextCurrentOn1; 
				tileCode2 <= tileCode;
				nextCurrentOn2 <= newOn;

				if (new)
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
        			if (counter2s == 26'b01011111010111100001000000) //if the counter has reached 2 seconds  
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
						if (currentOn == 10'b1111111111)
							begin
							gameOver <= 1'b1;
							nextInGame <= Idle;
							end
						else
							begin
							gameOver <= 1'b0;
							nextInGame <= Idle;
							end
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
				end 
			end

		default: nextInGame <= Idle;  

	endcase  
	end

//previously the get tile module, just changed to another always block running concurrently
	always @ (*)  
		begin  
		new <= 1'b0; //default new
		tileCode <= 4'b0000;
			if (SW[0] && !pastOn[0])
				begin
					tileCode <= T_0;
					newOn <= pastOn;
					newOn[0] <= 1'b1;
					new <= 1'b1;
				end
			else if (SW[1] && !pastOn[1])
				begin
					tileCode <= T_1;
					newOn <= pastOn;
					newOn[1] <= 1'b1;
					new <= 1'b1;
				end
			else if (SW[2] && !pastOn[2])
				begin
					tileCode <= T_2;
					newOn <= pastOn;
					newOn[2] <= 1'b1;
					new <= 1'b1;
				end
			else if (SW[3] && !pastOn[3])
				begin
					tileCode <= T_3;
					newOn <= pastOn;
					newOn[3] <= 1'b1;
					new <= 1'b1;
				end
			else if (SW[4] && !pastOn[4])
				begin
					tileCode <= T_4;
					newOn <= pastOn;
					newOn[4] <= 1'b1;
					new <= 1'b1;
				end
			else if (SW[5] && !pastOn[5])
				begin
					tileCode <= T_5;
					newOn <= pastOn;
					newOn[5] <= 1'b1;
					new <= 1'b1;
				end
			else if (SW[6] && !pastOn[6])
				begin
					tileCode <= T_6;
					newOn <= pastOn;
					newOn[6] <= 1'b1;
					new <= 1'b1;
				end
			else if (SW[7] && !pastOn[7])
				begin
					tileCode <= T_7;
					newOn <= pastOn;
					newOn[7] <= 1'b1;
					new <= 1'b1;
				end
			else if (SW[8] && !pastOn[8])
				begin
					tileCode <= T_8;
					newOn <= pastOn;
					newOn[8] <= 1'b1;
					new <= 1'b1;
				end
			else if (SW[9] && !pastOn[9])
				begin
					tileCode <= T_9;
					newOn <= pastOn;
					newOn[9] <= 1'b1;
					new <= 1'b1;
				end
			else
				newOn <= pastOn;
			
	end

//previously ledfrom tile module
	always @(*) 
	begin
	  case(code)
			T_0: begin 
				if (on) ledrhldr[0] <= 1'b1; 
				else ledrhldr[0] <= 1'b0;
			end
			T_1: begin 
				if (on) ledrhldr[1] <= 1'b1; 
				else ledrhldr[1] <= 1'b0;
			end
			T_2: begin 
				if (on) ledrhldr[2] <= 1'b1; 
				else ledrhldr[2] <= 1'b0;
			end
			T_3: begin 
				if (on) ledrhldr[3] <= 1'b1; 
				else ledrhldr[3] <= 1'b0;
			end
			T_4: begin 
				if (on) ledrhldr[4] <= 1'b1; 
				else ledrhldr[4] <= 1'b0;
			end
			T_5: begin 
				if (on) ledrhldr[5] <= 1'b1; 
				else ledrhldr[5] <= 1'b0;
			end
			T_6: begin 
				if (on) ledrhldr[6] <= 1'b1; 
				else ledrhldr[6] <= 1'b0;
			end
			T_7: begin 
				if (on) ledrhldr[7] <= 1'b1; 
				else ledrhldr[7] <= 1'b0;
			end
			T_8: begin 
				if (on) ledrhldr[8] <= 1'b1; 
				else ledrhldr[8] <= 1'b0;
			end
			T_9: begin 
				if (on) ledrhldr[9] <= 1'b1; 
				else ledrhldr[9] <= 1'b0;
			end
			default: ledrhldr <= 10'b0000000000;
			
			
	  endcase
	end

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
	end 
//after that, make sure the lights get the right outputs
	//every hex light
	hex_7seg moderun (hex1hldr, HEX0);
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
