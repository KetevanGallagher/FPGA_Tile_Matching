module tilegame (SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5

	//signals here
	reg userquit, keytobegin; //buttons for control
	reg [4:0] allMatched; //counter for if all tiles matched
	//reg [1:0] switchesOn; //how many switches are on at a time
	reg [7:0] dementiaScore; //counts how many moves the user made

	assign userquit = KEY[0];
	assign keytobegin = KEY[1];

	

	//assign codes for the ingame fsm


endmodule


module overallGameMode (userQuits, keytobegin, allMatched, LEDR, SW, HEX0, HEX3, HEX2, HEX4, HEX5)
	input userQuits, keytobegin, allMatched;
	input [9:0] SW;
	output [6:0] HEX0, HEX2, HEX3, HEX4, HEX5;
	reg [3:0] currentMode, nextMode;  //for keeping track of what game mode we are in
	reg [6:0] hexDisplay;
	assign HEX0 = hexDisplay;

	//assign codes for the different game modes 
	localparam Gmenu = 4'b0000, Gingame = 4'b0011, Gendgame = 4'b0101, Gleaderboard = 4'b1001;  



	//an always block for when to change modes
	always @ (*)  
	begin  
	case (currentMode)  
	  Gmenu:   
			begin
				hex_7seg oGM0(4'b0000, hexDisplay);
				if (keytobegin == 1)   
					 nextMode <= Gingame;
				else   
					 nextMode <= Gmenu;   
			end  

	  Gingame: 
			begin
				hex_7seg oGM0(4'b0001, hexDisplay);
				
				if (allMatched == 1)
					 nextMode <= Gendgame; 
				else if (userQuits == 1) 
					 nextMode <= Gmenu;
				else
					 nextMode <= Gingame; 
			end 

	  Gendgame:   
			begin   
				hex_7seg oGM0(4'b0010, hexDisplay);
				if (userQuits == 1)   
					 nextMode <= Gmenu; 
				else   
					 nextMode <= Gendgame;   
			end  

	  //not touched yet,  to be implemented later if time 
	  //Gleaderboard: nextMode <= Gmenu;  

	  default: nextMode <= Gmenu;  

	endcase  
	end  
	
endmodule

module inGameMode(quitInput, allMatched, LEDR, HEX2, HEX3, HEX4, HEX5)

	input reg quitInput;
	input [9:0] SW;
	output reg allMatched;
	output [9:0] LEDR;
	
	reg [2:0] currentInGame, nextInGame;  //for keeping track of what game mode we are in
	reg [9:0] currentOn, nextCurrentOn;
	
	
	reg [10:0] tileCode1, tileCode2;
	localparam Idle = 3'b000; OneTile = 3'b001, TwoTile = 3'b011;


	//an always block for when to change in game modes
	always @ (*)  
	begin  
	case (currentInGame)  
	  Idle:   
			begin   
	  //user quits
			if (quitInput == 1) 
			begin
				 nextInGame <= Idle;
				 nextMode <= Gmenu;
			end
			else
				begin
				getTile iGM0(SW, currentOn, tileCode1, new, nextCurrentOn);
				currentOn <= nextCurrentOn;
				if (new)
					nextInGame <= OneTile;
					LEDFromTile iGM1(tileCode1, LEDR, 1'b1);
				end
				else nextInGame <= Idle; 
			end  

	  OneTile: 
			begin 
			//user quits
			if (quitInput == 1) 
				 nextInGame <= Idle;
				 nextMode <= Gmenu;
			else
				begin
				getTile iGM2(SW, currentOn, tileCode2, new);
				if (new)
					nextInGame <= TwoTile;
					LEDFromTile iGM3(tileCode2, LEDR, 1'b1);
				end
			else
				 nextInGame <= OneTile; 
			end 

	  TwoTile:   
			begin   
	  //if user quits
			if (userquit == 1)   
			nextInGame <= Idle; 
	  //if all are matched just go back to the default
			else 
			//here, check that the color codes of the two tiles are the same
			// if so, blink and keep on
			// if not, blink and turn off
			// make sure to update currentOn
			if (matched == 5)
			nextMode <= Gendgame; 
	  else 
			nextInGame <= Idle; 
			end 

	  default: nextInGame <= Idle;  

	endcase  
	end  

endmodule

module updateState(resetn, currentMode, currentInGame, CLOCK_50);
	//assign codes for the different game modes 
	localparam Gmenu = 4'b0000, Gingame = 4'b0011, Gendgame = 4'b0101, Gleaderboard = 4'b1001;  
	localparam Idle = 3'b000; OneTile = 3'b001, TwoTile = 3'b011;


	//an always block that updates states as often as possible  
	always @ (posedge CLOCK_50)  
	begin  
	if (resetn == 0)
	  currentMode <= Gmenu;
	  currentInGame <= Gidle;

	else  
	  begin
	  currentMode <= nextMode;  
	  if (currentMode == Gingame) 
			currentInGame <= nextInGame;
	  end
	end 
	
endmodule



module stateDirections(CLOCK_50, resetn, currentMode, currentState);
	//assign codes for the different game modes 
	localparam Gmenu = 4'b0000, Gingame = 4'b0011, Gendgame = 4'b0101, Gleaderboard = 4'b1001;  

	//an always block for what to do when in each state  

	always @ (posedge CLOCK_50)  
	begin  

	if (resetn == 0)  
	  begin  
	  //reset all variables here
	  end  

	else  
	  begin  
	  if (currentMode == Gmenu) //start menu  
			begin  
	  //display necessary things on the vga
	  allMatched <= 0;
	  
			end  

	  if (currentState == Gingame) //do the cases here to set up the thing properly  
			begin  
	  //include all the ingame fsm stuff hereeeeee
			end  

	  if (currentState == Gendgame) //run a clock in here that counts to 0.5 seconds from the megaheartz  
			begin  
			//do the counting up to a half second
	  end  

	  if (currentState == Gleaderboard)
	  begin  
	  //implement later if time
	  end  

	end //for the big else  
	end //for the always block 

endmodule

module getTile(SW, pastOn, tileCode, new, newOn);
	input [9:0] SW;
	input [9:0] pastOn;
	output [10:0] tileCode;
	output reg new;
	output reg newOn;
	//set up each tile, 10 FOR FPGA INTIAL
	reg [10:0] T_0, T_1, T_2, T_3, T_4, T_5, T_6, T_8, T_9; 
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
	
	assign new = 1'b0;
	
	always @ (*)  
		begin  
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
			else:
				newOn <= pastOn;
			
	end
	  
	  
endmodule

module LEDFromTile(code, LEDR, on);
	input [10:0] code;
	output [9:0] LEDR;
	//set up each tile, 10 FOR FPGA INTIAL
	reg [10:0] T_0, T_1, T_2, T_3, T_4, T_5, T_6, T_8, T_9; 
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
	
	always @(*) 
	begin
	  case(code)
			T_0: begin 
				if (on) LEDR[0] <= 1'b1; 
				else LEDR[0] <= 1'b0;
			end
			T_1: begin 
				if (on) LEDR[1] <= 1'b1; 
				else LEDR[1] <= 1'b0;
			end
			T_2: begin 
				if (on) LEDR[2] <= 1'b1; 
				else LEDR[2] <= 1'b0;
			end
			T_3: begin 
				if (on) LEDR[3] <= 1'b1; 
				else LEDR[3] <= 1'b0;
			end
			T_4: begin 
				if (on) LEDR[4] <= 1'b1; 
				else LEDR[4] <= 1'b0;
			end
			T_5: begin 
				if (on) LEDR[5] <= 1'b1; 
				else LEDR[5] <= 1'b0;
			end
			T_6: begin 
				if (on) LEDR[6] <= 1'b1; 
				else LEDR[6] <= 1'b0;
			end
			T_7: begin 
				if (on) LEDR[7] <= 1'b1; 
				else LEDR[7] <= 1'b0;
			end
			T_8: begin 
				if (on) LEDR[8] <= 1'b1; 
				else LEDR[8] <= 1'b0;
			end
			T_9: begin 
				if (on) LEDR[9] <= 1'b1; 
				else LEDR[9] <= 1'b0;
			end
			
			
	  endcase
	end
	
	

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
			4'hF: h = 7'b0001110;
			default: h = 7'b1111111;
	  endcase
	end
endmodule
