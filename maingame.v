module tilegame (SW, KEY, CLOCK_50, LEDR, HEX0);
input [9:0] SW;
input [3:0] KEY;
input CLOCK_50;
output [9:0] LEDR;

//signals here
reg userquit, keytobegin; //buttons for control
reg allMatched; //counter for if all tiles matched
reg [1:0] switchesOn; //how many switches are on at a time
reg [3:0] currentMode, nextMode;  //for keeping track of what game mode we are in
reg [2:0] currentInGame, nextInGame;  //for keeping track of what game mode we are in
reg [1:0] currentTileState, nextTileState;  //for keeping track of what game mode we are in
reg [7:0] dementiaScore; //counts how many moves the user made

assign userquit = KEY[0];
assign keytobegin = KEY[1];

//assign codes for the different game modes 
localparam Gmenu = 4'b0000, Gingame = 4'b0011, Gendgame = 4'b0101, Gleaderboard = 4'b1001;  

//assign codes for the ingame fsm
localparam Idle = 3'b000; OneTile = 3'b001, TwoTile = 3'b011;

//assign codes for the tile state fsm DO WE NEED THIS????
localparam down = 2'b00, flipup = 2'b01, matched = 2'b11;

//an always block for when to change modes
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
        if (allMatched == 1) 
            nextMode <= Gendgame; 
        else if (userquit == 1) 
            nextMode <= Gmenu; 
        else
            nextMode <= Gingame; 
        end 

    Gendgame:   
        begin   
        if (userquit == 1)   
            nextMode <= Gmenu; 
        else   
            nextMode <= Gendgame;   
        end  

    //not touched yet,  to be implemented later if time 
    Gleaderboard: nextMode <= Gmenu;  

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
            nextMode <= Gmenu;   
        end  

    OneTile: 
        begin 
	//user quits
        if (userquit == 1) 
            nextInGame <= Idle; 
        else if (switchesOn == 2'b10) 
            nextMode <= Gmenu; 
        else
            nextInGame <= OneTile; 
        end 

    TwoTile:   
        begin   
	//if user quits
        if (userquit == 1)   
		nextInGame <= Idle; 
	//if all are matched just go back to the default
        else if (matched == 5)
		nextMode <= Gendgame;  
	else 
		nextInGame <= Idle; 
        end 

    default: nextInGame <= Idle;  

endcase  
end  

  

//an always block that updates states as often as possible  
always @ (posedge CLOCK_50)  
begin  
if (resetn == 0)  
	currentMode <= Gmenu;
	currentInGame <= Gidle

else  
	begin
	currentMode <= nextMode;  
	if (currentMode == Gingame) 
		currentInGame <= nextInGame;
		//potentially add the tile fsm here too
	end
end  


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
