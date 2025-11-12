module gamemodeFSM (userquit, keytobegin, CLOCK_50, gameOver, hex0holder, ingameOn);
	input userquit, keytobegin;
	input CLOCK_50;
	input gameOver;
	output ingameOn;
	output [6:0] hex0holder;

	reg [3:0] currentMode, nextMode; //what mode in

	//signals here
	//assign codes for the ingame fsm
	localparam Gmenu = 4'b0000, Gingame = 4'b0011, Gendgame = 4'b0101, Gleaderboard = 4'b1001;

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


//an always block that updates states as often as possible  
	always @ (posedge CLOCK_50)  
	begin  
	if (userquit == 1)
		begin
		currentMode <= Gmenu;
		end

	else  
		begin
		currentMode <= nextMode;  
	  	end
	end //end of updating states

//an always block for what to do in each mode
	always @ (posedge CLOCK_50)  
	begin 
	if (userquit == 1) 
		//SET ALL VARIABLES TO ZEROS HERE
		begin
		hex0hldr <= 4'b0000;
		ingameOn <= 1'b0;
		end

	else //literally do everything else
		begin
		if (currentMode == Gmenu)
			begin
			//any vga stuff
			hex0hldr <= 4'b0000;
			ingameOn <= 1'b0;
			end

		else if (currentMode == Gingame)
			begin
			hex0hldr <= 4'b0001;
			ingameOn <= 1'b1;
			end //end of being in game

		else if (currentMode == Gendgame)
			begin   
			//any vga stuff
			hex0hldr <= 4'b0010;
			ingameOn <= 1'b0;
			end  

		end //end of the game modes else
	end //end of the always balck for what to do in a game mode
endmodule