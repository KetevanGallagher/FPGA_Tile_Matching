module ramModule (clk, addrA, writeA, weA, readA, addrB, writeB, weB, readB, addrC, writeC, weC, readC);

    input clk, weA, weB, weC;
    input [3:0] addrA, addrB, addrC;
    input [7:0] writeA, writeB, writeC;
    output reg [7:0] readA, readB, readC;

    reg [7:0] tileRam [0:15];

    initial begin
        tileRam[0] = 8'b00111111; //teal
        tileRam[1] = 8'b11001011; //magenta
        tileRam[2] = 8'b11100011; //orange
        tileRam[3] = 8'b11100011; //orange
        tileRam[4] = 8'b11010011; //tomato
        tileRam[5] = 8'b10001111; //purple
        tileRam[6] = 8'b11110010; //yellow
        tileRam[7] = 8'b00001110; //blue
        tileRam[8] = 8'b11001010; //magenta
        tileRam[9] = 8'b11010010; //tomato
        tileRam[10] = 8'b11110010; //yellow
        tileRam[11] = 8'b01110010; //green
        tileRam[12] = 8'b10001110; //purple
        tileRam[13] = 8'b01110010; //green
        tileRam[14] = 8'b00111110; //teal
        tileRam[15] = 8'b00001110; //blue
    end

    always @(posedge clk) begin
        if (weA) tileRam[addrA] <= writeA;
        readA <= tileRam[addrA];

        if (weB) tileRam[addrB] <= writeB;
        readB <= tileRam[addrB];

        if (weC) tileRam[addrC] <= writeC;
        readC <= tileRam[addrC];
    end

endmodule