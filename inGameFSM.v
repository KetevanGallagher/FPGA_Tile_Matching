module ingameFSM(CLOCK_50, inGameOn, userquit, select1, select2, SW, ledrhldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr, gameOver);
    input CLOCK_50, inGameOn, userquit, select1, select2;
    input [9:0] SW;

    output reg [9:0] ledrhldr;
    output reg [6:0] hex2hldr, hex3hldr, hex4hldr, hex5hldr;
    output reg gameOver;

    reg twosec, newSW, continueToIdle;
    reg [7:0] dementiaScore;
    reg [2:0] currentInGame, nextInGame; //what state of the game
	 reg [9:0] currentOn, nextCurrentOn1, nextCurrentOn2;
	 reg [10:0] tileCode1, tileCode2;

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
                        nextInGame <= Idle;
                    else
                        nextInGame <= NotInGame;
                end
            Idle:   
                begin   
                //user quits
                if (userquit == 1 || !inGameOn) 
                    nextInGame <= NotInGame;
                else
                    begin
                    if (newSW)
                        nextInGame <= OneTile;
                    else
                        nextInGame <= Idle;
                    end  
                end

            OneTile: 
                begin 
                //user quits
                if (userquit == 1 || !inGameOn) 
                    nextInGame <= NotInGame;
                else
                    begin
							  if (newSW)
									nextInGame <= TwoTile;
							  else
									nextInGame <= OneTile;
                    end 
                end

            TwoTile:   
                begin 
                //if user quits
                if (userquit == 1)   
                    nextInGame <= NotInGame;
                //if all are matched just go back to the default
                else
                    begin  
                        if (gameOver) nextInGame <= OffGameOver;
                        //see if select has been pushed  
                        else if (continueToIdle != 1) nextInGame <= TwoTile;
                        else nextInGame <= Idle;

                    end
                        
                end

            OffGameOver:
                begin
                    // doing this because if inGameOn is on, then when it goes to NotInGame,
                    // all values will get reset and it'll immediately go to idle
                    if (inGameOn || userquit) nextInGame <= NotInGame;
                    else nextInGame <= OffGameOver;
                end

            default: nextInGame <= NotInGame;  

        endcase  
    end //end for changing in game
	 
	 
	 //always block for updating in game mode
	 always @ (posedge CLOCK_50)  
	begin  
	if (userquit == 1)
		begin
		currentInGame <= NotInGame;
		end

	else  
		begin
		currentInGame <= nextInGame;  
	  	end
	end //end of updating states


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
                    newSW <= 0;
                    tileCode1 <= 11'b00000000000;
                    tileCode2 <= 11'b00000000000;
                    gameOver <= 1'b0;
                    continueToIdle <= 0;
                end

			Idle:
				begin
				ledrhldr <= currentOn;
				hex2hldr <= 4'b1111;
				hex3hldr <= 4'b1111;
                hex4hldr <= dementiaScore[3:0];
                hex5hldr <= dementiaScore[7:4];
				newSW <= 1'b0;
                gameOver <= 1'b0;
                continueToIdle <= 0;
				//simulate running get tile by changing what goes into it -  current on same
				//module getTile(SW, pastOn, tileCode, newSW, newOn);
                if (select1)
                    begin
                    nextCurrentOn1 <= currentOn;
                    
                    if (SW[0])
                        begin
                        tileCode1 <= T_0;
                        nextCurrentOn1[0] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[1])
                        begin
                        tileCode1 <= T_1;
                        nextCurrentOn1[1] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[2])
                        begin
                        tileCode1 <= T_2;
                        nextCurrentOn1[2] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[3])
                        begin
                        tileCode1 <= T_3;
                        nextCurrentOn1[3] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[4])
                        begin
                        tileCode1 <= T_4;
                        nextCurrentOn1[4] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[5])
                        begin
                        tileCode1 <= T_5;
                        nextCurrentOn1[5] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[6])
                        begin
                        tileCode1 <= T_6;
                        nextCurrentOn1[6] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[7])
                        begin
                        tileCode1 <= T_7;
                        nextCurrentOn1[7] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[8])
                        begin
                        tileCode1 <= T_8;
                        nextCurrentOn1[8] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[9])
                        begin
                        tileCode1 <= T_9;
                        nextCurrentOn1[9] <= 1'b1;
                        newSW <= 1'b1;
                        end
				end //end of idle state

			OneTile:
				begin
				ledrhldr <= nextCurrentOn1;
                hex3hldr <= tileCode1[5:1];
				hex2hldr <= 4'b1111;
                hex4hldr <= dementiaScore[3:0];
                hex5hldr <= dementiaScore[7:4];
				newSW <= 1'b0;
            	gameOver <= 1'b0; 
                continueToIdle <= 0;

				//do the get tile again just in here
				//module getTile(SW, pastOn, tileCode, newSW, newOn);
                if (select2)
                    begin
                    nextCurrentOn2 <= nextCurrentOn1;
                    if (SW[0])
                        begin
                        tileCode2 <= T_0;
                        nextCurrentOn2[0] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[1])
                        begin
                        tileCode2 <= T_1;
                        nextCurrentOn2[1] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[2])
                        begin
                        tileCode2 <= T_2;
                        nextCurrentOn2[2] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[3])
                        begin
                        tileCode2 <= T_3;
                        nextCurrentOn2[3] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[4])
                        begin
                        tileCode2 <= T_4;
                        nextCurrentOn2[4] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[5])
                        begin
                        tileCode2 <= T_5;
                        nextCurrentOn2[5] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[6])
                        begin
                        tileCode2 <= T_6;
                        nextCurrentOn2[6] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[7])
                        begin
                        tileCode2 <= T_7;
                        nextCurrentOn2[7] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[8])
                        begin
                        tileCode2 <= T_8;
                        nextCurrentOn2[8] <= 1'b1;
                        newSW <= 1'b1;
                        end
                    else if (SW[9])
                        begin
                        tileCode2 <= T_9;
                        nextCurrentOn2[9] <= 1'b1;
                        newSW <= 1'b1;
                        end
                end
				end //end of one tile state

			TwoTile:
				begin
				ledrhldr <= nextCurrentOn2;
                hex3hldr <= tileCode1[5:1];
				hex2hldr <= tileCode2[5:1];
                hex4hldr <= dementiaScore[3:0];
                hex5hldr <= dementiaScore[7:4];
				newSW <= 1'b0;
            	gameOver <= 1'b0; 
                continueToIdle <= 0;

            	if (select1)
                    begin
                    dementiaScore <= dementiaScore + 1;
                    continueToIdle <= 1;
					if (tileCode1[5:1] == tileCode2[5:1])
						//if they match, update the currentOn, but if all are now on the
						begin
						currentOn <= nextCurrentOn2;
						tileCode1 <= 11'b0;
						tileCode2 <= 11'b0;
						nextCurrentOn1 <= 10'b0;
						nextCurrentOn2 <= 10'b0;
                        ledrhldr <= currentOn;
                        
                        // if all of the tiles have been matched
						if (currentOn == 10'b1111111111) gameOver <= 1'b1;
						else gameOver <= 1'b0;
						end
                    // so if they don't match, do this  
        			else  
           				begin   
            				tileCode1 <= 11'b0;
                            tileCode2 <= 11'b0;
                            nextCurrentOn1 <= 10'b0;
                            nextCurrentOn2 <= 10'b0;
                            ledrhldr <= currentOn;
                        end
					end  
				end //end of two tile state	

            OffGameOver:
                begin
                    ledrhldr <= 10'b0;
                    hex3hldr <= 4'b1111;
                    hex2hldr <= 4'b1111;
                    hex4hldr <= dementiaScore[3:0];
                    hex5hldr <= dementiaScore[7:4];
                    newSW <= 1'b0;
                    gameOver <= 1'b1; 
                    continueToIdle <= 0;
                end
			end //end of being in game
		endcase //end of the game modes else
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