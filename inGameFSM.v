module ingameFSM(clk, inGameOn, userquit, arrowUp, arrowDown, arrowR, arrowL, select, weA, weB, writeA, writeB, readA, readB, addrA, addrB, hex4hldr, hex5hldr, gameOver, currentInGameState);
    input clk, inGameOn, userquit, arrowUp, arrowDown, arrowR, arrowL, select;
    input [7:0] readA, readB;
    output reg [3:0] hex4hldr, hex5hldr;
    output reg gameOver;
    output reg [3:0] addrA, addrB;
    //Remove this if not debugging (exposed wires)
    output [2:0] currentInGameState;

	 
    reg secFlag, waitCycle, waitCycle2, firstInFlip, selectWait, compareWait, counterPulse;
	reg [1:0] selectWait2;
    reg [26:0] counter;
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
	
	
    

	

    localparam SelectState = 3'b000, Flip = 3'b001, Compare = 3'b010, OffGameOver = 3'b011, NotInGame = 3'b100, WaitDisplay = 3'b101;
    
			
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
						  else if (selectWait || selectWait2 == 2'b01 || selectWait2 == 2'b10)
								nextInGame = SelectState;
                    else if (select_pulse)
                        nextInGame = Flip;
                    else
                        nextInGame = SelectState;
                end
            Flip: 
                begin 
                    if (userquit == 1 || !inGameOn) 
                        nextInGame = NotInGame;
						  else if (waitCycle || waitCycle2)
                        nextInGame = Flip;
                    else if (compareWait)
                        nextInGame = WaitDisplay;
                    else if (secFlag)
								nextInGame = SelectState;      
						  else
								nextInGame = Flip;
                end
            WaitDisplay:
                begin
                    if(counterPulse == 1'b1) nextInGame = Compare;
                    else nextInGame = WaitDisplay;
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
		waitCycle2 <= 1'b0;
		firstInFlip <= 1'b0;
		selectWait <= 1'b0;
		selectWait2 <= 2'b0;
        compareWait <= 1'b0;
        counter <= 27'd50000000;
		counterPulse <= 1'b0;
		
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
                    waitCycle2 <= 1'b0;
                    firstInFlip <= 1'b0;
                    selectWait <= 1'b0;
                    selectWait2 <= 2'b0;
                    compareWait <= 1'b0;
                    counter <= 27'd50000000;
		            counterPulse <= 1'b0;
                end

			SelectState:
				begin
					hex4hldr <= dementiaScore[3:0];
					hex5hldr <= dementiaScore[7:4];
					gameOver <= 1'b0;
					firstInFlip <= 1'b1;
					

					  if (selectWait2 == 2'b10)
							 begin
								 writeA <= readA & 8'b11111110;
								 writeB <= readB | 8'b00000001;
								 weA <= 1'b1;
								 weB <= 1'b1;
								 selectWait2 <= 2'b00;
							end
						
						else if (selectWait2 == 2'b01)
						begin
						   selectWait2 <= 2'b10;
						end
					  
					  else if (arrowUp_pulse)
						begin
								addrA <= currentTile;
								addrB <= currentTile - 4;
								currentTile <= currentTile - 4;
								selectWait2 <= 2'b01;
						end
						
						else if (arrowDown_pulse)
						begin
								addrA <= currentTile;
								addrB <= currentTile + 4;
								currentTile <= currentTile + 4;
								selectWait2 <= 2'b01;
						end
						
						else if (arrowL_pulse)
						begin
								addrA <= currentTile;
								addrB <= currentTile - 1;
								currentTile <= currentTile - 1;
								selectWait2 <= 2'b01;
						end
						else if (arrowR_pulse)
						begin
								addrA <= currentTile;
								addrB <= currentTile + 1;
								currentTile <= currentTile + 1;
								selectWait2 <= 2'b01;
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
                            if (firstInFlip)
                                begin
                                    // Start read cycle for first tile
                                    addrA <= currentTile;
                                    waitCycle2 <= 1'b1;
												firstInFlip <= 1'b0;
                                end
									 else if (waitCycle2)
									 begin
										waitCycle2 <= 1'b0;
										waitCycle <= 1'b1;
										firstInFlip <= 1'b0;
									 end
                            else if (waitCycle)
                                begin
                                    
                                    compareA <= readA;
                                    compareLocA <= currentTile;
                                    writeA <= readA | 8'b00000010;  // Set flip bit
                                    weA <= 1'b1;
                                    secFlag <= 1'b1;
                                    waitCycle <= 1'b0;
												firstInFlip <= 1'b1;
                                end
                        end
                    else 
                        begin
                            // Second tile logic
                            if (firstInFlip)
                                begin
                                    // Start read cycle for first tile
                                    addrB <= currentTile;
                                    waitCycle2 <= 1'b1;
												firstInFlip <= 1'b0;
                                end
									 else if (waitCycle2)
									 begin
										waitCycle2 <= 1'b0;
										waitCycle <= 1'b1;
										firstInFlip <= 1'b0;
									 end
                            else if (waitCycle)
                                begin
                                    
                                    compareB <= readB;
                                    compareLocB <= currentTile;
                                    writeB <= readB | 8'b00000010;  // Set flip bit
                                    weB <= 1'b1;
                                    waitCycle <= 1'b0;
									firstInFlip <= 1'b0;
                                    compareWait <= 1'b1;
                                end
                        end
				end

            WaitDisplay:
				begin
                secFlag <= 1'b0;
               compareWait <= 1'b0;
               hex4hldr <= dementiaScore[3:0];
						hex5hldr <= dementiaScore[7:4];
						gameOver <= 1'b0;
						if (counter == 0)
							begin
							counter <= 27'd100000000;
							counterPulse <= 1'b1;
							end
						else
							begin
							counter <= counter -1;
							counterPulse<= 1'b0;
							end
                end

			Compare:
				begin
					hex4hldr <= dementiaScore[3:0];
					hex5hldr <= dementiaScore[7:4];
					dementiaScore <= dementiaScore + 1;
               secFlag <= 1'b0;
               compareWait <= 1'b0;

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
                        writeA <= compareA & 8'b11111100;
                        addrB <= compareLocB;
                        writeB <= compareB & 8'b11111100;
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
