module ramModule (gameClk, resetn, vgaClk, addrA, writeA, weA, readA, addrB, writeB, weB, readB, addrC, readC);

    input gameClk, vgaClk, weA, weB, resetn;
    input [3:0] addrA, addrB, addrC;
    input [7:0] writeA, writeB;
    output reg [7:0] readA, readB, readC;
	 reg resetFlag;
	 reg [3:0] counter;

    reg [7:0] tileRam [0:15];

    initial begin
		  resetFlag = 1'b0;
		  counter = 4'b0000;
        tileRam[0] = 8'b00111100; //teal
        tileRam[1] = 8'b11001000; //magenta
        tileRam[2] = 8'b11100000; //orange
        tileRam[3] = 8'b11100000; //orange
        tileRam[4] = 8'b11010000; //tomato
        tileRam[5] = 8'b10001100; //purple
        tileRam[6] = 8'b11110000; //yellow
        tileRam[7] = 8'b00001100; //blue
        tileRam[8] = 8'b11001000; //magenta
        tileRam[9] = 8'b11010000; //tomato
        tileRam[10] = 8'b11110000; //yellow
        tileRam[11] = 8'b01110000; //green
        tileRam[12] = 8'b10001100; //purple
        tileRam[13] = 8'b01110000; //green
        tileRam[14] = 8'b00111100; //teal
        tileRam[15] = 8'b00001100; //blue
    end

    always @(posedge gameClk) begin
	 
	 // to implment reset:
	 // if reset is pressed, resetflag is turned on
	 // resetflag stays on until the counter counts up to 16 
	 // while counting up to sixteen, change each tile in the tileram 
	 // to its initial value
		  if (resetn == 1'b1)
				resetFlag <= 1'b1;
		  else if (resetFlag)
		  begin
				counter <= counter + 1;
				case(counter)
					4'b0000: tileRam[0] <= 8'b00111100;
					4'b0001: tileRam[1] <= 8'b11001000;
					4'b0010: tileRam[2] <= 8'b11100000;
					4'b0011: tileRam[3] <= 8'b11100000;
					4'b0100: tileRam[4] <= 8'b11010000;
					4'b0101: tileRam[5] <= 8'b10001100;
					4'b0110: tileRam[6] <= 8'b11110000;
					4'b0111: tileRam[7] <= 8'b00001100;
					4'b1000: tileRam[8] <= 8'b11001000;
					4'b1001: tileRam[9] <= 8'b11010000;
					4'b1010: tileRam[10] <= 8'b11110000;
					4'b1011: tileRam[11] <= 8'b01110000;
					4'b1100: tileRam[12] <= 8'b10001100;
					4'b1101: tileRam[13] <= 8'b01110000;
					4'b1110: tileRam[14] <= 8'b00111100;
					4'b1111: begin tileRam[15] <= 8'b00001100; counter <= 4'b0000; resetFlag <= 1'b0; end
					default: counter <= 4'b0000;
				endcase
		  end
		  
		  else
		  begin
	 
			  if (weA) tileRam[addrA] <= writeA;
			  readA <= tileRam[addrA];

			  if (weB) tileRam[addrB] <= writeB;
			  readB <= tileRam[addrB];
		  end

    end
	 
	 always @(posedge vgaClk) begin
        readC <= tileRam[addrC];
    end

endmodule