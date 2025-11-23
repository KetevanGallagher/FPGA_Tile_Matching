module ingameFSM(clk, inGameOn, userquit, arrowUp, arrowDown, arrowR, arrowL, select, weA, weB, writeA, writeB, readA, readB, addrA, addrB, hex4hldr, hex5hldr, gameOver, currentInGameState);
    input clk, inGameOn, userquit, arrowUp, arrowDown, arrowR, arrowL, select;
    input [7:0] readA, readB;
    output reg [3:0] hex4hldr, hex5hldr;
    output reg gameOver;
    output reg [3:0] addrA, addrB;
    //Remove this if not debugging (exposed wires)
    output [2:0] currentInGameState;

    reg secFlag, waitCycle;
    output reg weA, weB;
    reg [7:0] dementiaScore;
    reg [2:0] currentInGame, nextInGame;
	//exposed for debugging
	assign currentInGameState = currentInGame;
	reg [3:0] currentMatched;
	reg [7:0] compareA, compareB; 
   output reg [7:0] writeA, writeB;
   reg [3:0] currentTile, compareLocA, compareLocB;
    
	 
	 
	reg arrowUp_prev, arrowDown_prev, arrowL_prev, arrowR_prev, select_prev;
	wire arrowUp_pulse  = arrowUp && !arrowUp_prev;
	wire arrowDown_pulse= arrowDown && !arrowDown_prev;
	wire arrowL_pulse   = arrowL && !arrowL_prev;
	wire arrowR_pulse   = arrowR && !arrowR_prev;
	wire select_pulse   = select && !select_prev;
	
	
    

	

    localparam SelectState = 3'b000, Flip = 3'b001, Compare = 3'b010, OffGameOver = 3'b011, NotInGame = 3'b100;
    
			
			always @(posedge clk) begin
			 arrowUp_prev <= arrowUp;
			 arrowDown_prev <= arrowDown;
			 arrowL_prev <= arrowL;
			 arrowR_prev <= arrowR;
			 select_prev <= select;
		end
	
	
	
    always @ (*)
    begin
        case (currentInGame)
            NotInGame:
                begin
                    if (inGameOn)
                        nextInGame = SelectState;
                    else
                        nextInGame = NotInGame;
                end
            SelectState:   
                begin   
                    if (userquit == 1 || !inGameOn) 
                        nextInGame = NotInGame;
                    else if (select_pulse)
                        nextInGame = Flip;
                    else
                        nextInGame = SelectState;
                end
            Flip: 
                begin 
                    if (userquit == 1 || !inGameOn) 
                        nextInGame = NotInGame;
						  else if (waitCycle)
                        nextInGame = Flip;
                    else if (select_pulse & secFlag)
                        nextInGame = Compare;
                    else if (select_pulse & !secFlag)
                        nextInGame = SelectState;
                    else
                        nextInGame = Flip;
                end
            Compare:   
                begin 
                    if (userquit == 1)   
                        nextInGame = NotInGame;
                    else if (currentMatched == 4'b1000)
                        nextInGame = OffGameOver;
                    else
                        nextInGame = SelectState;
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
	 
	always @ (posedge clk)  
	begin  
		if (userquit == 1)
			currentInGame <= NotInGame;
		else  
			currentInGame <= nextInGame;
		
	end
	
	//initialize state to NotInGame on startup
	initial
	begin
		currentInGame <= NotInGame;
		nextInGame <= NotInGame;
		gameOver <= 1'b0;
      weA <= 1'b0;
      weB <= 1'b0;
		currentMatched <= 4'b0000;
		compareA <= 8'b00000000000;
		compareB <= 8'b00000000000;
		dementiaScore <= 8'b00000000;
      currentTile <= 4'b0000;
		waitCycle <= 1'b0;
		
	end

    always @ (posedge clk)  
	begin
		weA <= 1'b0;
		weB <= 1'b0;
        case (currentInGame)
            NotInGame:
                begin
                    hex4hldr <= 4'b1111;
                    hex5hldr <= 4'b1111;
                    gameOver <= 1'b0;
                    weA <= 1'b0;
                    weB <= 1'b0;
                    secFlag <= 1'b0;
                    currentMatched <= 4'b0000;
                    compareA <= 8'b00000000000;
                    compareB <= 8'b00000000000;
                    dementiaScore <= 8'b00000000;
                    currentTile <= 4'b0000;
						  waitCycle <= 1'b0;
                end

			SelectState:
				begin
					hex4hldr <= dementiaScore[3:0];
					hex5hldr <= dementiaScore[7:4];
					gameOver <= 1'b0;


                    if (arrowUp_pulse) 
                        begin

                            addrA <= currentTile;
                            writeA <= readA & 8'b11111110;
                            addrB <= currentTile - 4;
                            writeB <= readB | 8'b00000001;
                            currentTile <= currentTile - 4;
                            weA <= 1'b1;
                            weB <= 1'b1;
                        end
                    else if (arrowDown_pulse)
                        begin
                            addrA <= currentTile;
                            writeA <= readA & 8'b11111110;
                            addrB <= currentTile + 4;
                            writeB <= readB | 8'b00000001;
                            currentTile <= currentTile + 4;
                            weA <= 1'b1;
                            weB <= 1'b1;
                        end
                    else if (arrowL_pulse)
                        begin
                            addrA <= currentTile;
                            writeA <= readA & 8'b11111110;
                            addrB <= currentTile - 1;
                            writeB <= readB | 8'b00000001;
                            currentTile <= currentTile - 1;
                            weA <= 1'b1;
                            weB <= 1'b1;
                        end
                    else if (arrowR_pulse)
                        begin
                            addrA <= currentTile;
                            writeA <= readA & 8'b11111110;
                            addrB <= currentTile + 1;
                            writeB <= readB | 8'b00000001;
                            currentTile <= currentTile + 1;
                            weA <= 1'b1;
                            weB <= 1'b1;
                        end

                    
				end

			Flip:
				begin
					hex4hldr <= dementiaScore[3:0];
					hex5hldr <= dementiaScore[7:4];
					gameOver <= 1'b0;
//                    weA <= 1'b0;
//                    weB <= 1'b0;
						
						if (!secFlag)
                        begin
                            // First tile logic
                            if (select_pulse)
                                begin
                                    // Start read cycle for first tile
                                    addrA <= currentTile;
                                    waitCycle <= 1'b1;
                                end
                            else if (waitCycle)
                                begin
                                    
                                    compareA <= readA;
                                    compareLocA <= currentTile;
                                    writeA <= readA | 8'b00000010;  // Set flip bit
                                    weA <= 1'b1;
                                    secFlag <= 1'b1;
                                    //waitCycle <= 1'b0;
                                end
                        end
                    else 
                        begin
                            if (select_pulse)
                                begin
                                    // Start read cycle for second tile
                                    addrA <= currentTile;
                                    waitCycle <= 1'b1;
                                end
                            else if (waitCycle)
                                begin
                                   
                                    compareB <= readA;
                                    compareLocB <= currentTile;
                                    writeA <= readA | 8'b00000010;  // Set flip bit
                                    weA <= 1'b1;
                                    //waitCycle <= 1'b0; 
                                end
                        end
				end

			Compare:
				begin
					hex4hldr <= dementiaScore[3:0];
					hex5hldr <= dementiaScore[7:4];
					dementiaScore <= dementiaScore + 1;
                    secFlag <= 1'b0;

					//compare tiles
					if (compareA[7:2] == compareB[7:2])
					begin
						currentMatched <= currentMatched + 1;
                        if (currentMatched == 4'b0111) gameOver <= 1'b1; //if current is 8, because 8 pairs
                        else gameOver <= 1'b0;
					end
					else
					begin
						addrA <= compareLocA;
                        writeA <= compareA & 8'b11111101;
                        addrB <= compareLocB;
                        writeB <= compareB & 8'b11111101;
                        weA <= 1'b1;
                        weB <= 1'b1;

					end
                    gameOver <= (currentMatched == 4'b0111) ? 1'b1 : 1'b0;
				end

            OffGameOver:
                begin
                    hex4hldr <= dementiaScore[3:0];
                    hex5hldr <= dementiaScore[7:4];
                    gameOver <= 1'b1; 
                    weA <= 1'b0;
                    weB <= 1'b0;
                end

            default:
                begin
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
