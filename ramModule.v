module ramModule (gameClk, vgaClk, addrA, writeA, weA, readA, addrB, writeB, weB, readB, addrC, readC);

    input gameClk, vgaClk, weA, weB;
    input [3:0] addrA, addrB, addrC;
    input [7:0] writeA, writeB;
    output reg [7:0] readA, readB, readC;

    reg [7:0] tileRam [0:15];

    initial begin
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
        if (weA) tileRam[addrA] <= writeA;
        readA <= tileRam[addrA];

        if (weB) tileRam[addrB] <= writeB;
        readB <= tileRam[addrB];

    end
	 
	 always @(posedge vgaClk) begin
        readC <= tileRam[addrC];
    end

endmodule