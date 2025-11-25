module FPGAdisplay(userquit, ingameOn, gameOver, hex0hldr, dementiaScore, ledrhldr, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
input userquit, ingameOn, gameOver;
input [3:0] hex0hldr;
input [7:0] dementiaScore;
input [9:0] ledrhldr;

output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

//run the module for converting the score into decimal

//every hex light
hex_7seg moderun (hex0hldr, HEX0);

//these are off
hex_7seg turnOff1 (4'b1111, HEX1);
hex_7seg turnOff2 (4'b1111, HEX2);
hex_7seg turnOff3 (4'b1111, HEX3);


hex_7seg game4 (hex4hldr, HEX4);
hex_7seg game5 (hex5hldr, HEX5);

//every ledr light
assign LEDR = ledrhldr;


endmodule

//module for changing the dementia score into proper decimal
module decimal_conversion(bi, deci);
    input [7:0] bi;
    output reg [7:0] deci;

    always @(*) 
    begin
        case(bi)
            8'b00000000: deci = 8'b00000000; //0
            8'b00000001: deci = 8'b00000001; //1
            8'b00000010: deci = 8'b00000010; //2
            8'b00000011: deci = 8'b00000011; //3
            8'b00000100: deci = 8'b00000100; //4
            8'b00000101: deci = 8'b00000101; //5
            8'b00000110: deci = 8'b00000110; //6
            8'b00000111: deci = 8'b00000111; //7
            8'b00001000: deci = 8'b00001000; //8
            8'b00001001: deci = 8'b00001001; //9
            8'b00001010: deci = 8'b00010000; //10
            8'b00001011: deci = 8'b00010001; //11
            8'b00001100: deci = 8'b00010010; //12
            8'b00001101: deci = 8'b00010011; //13
            8'b00001110: deci = 8'b00010100; //14
            8'b00001111: deci = 8'b00010101; //15
            8'b00010001: deci = 8'b00010110; //16
            8'b00010010: deci = 8'b00010111; //17
            8'b00010011: deci = 8'b00011000; //18
            8'b00010100: deci = 8'b00011001; //19
            8'b00010101: deci = 8'b00100000; //20
            8'b00010110: deci = 8'b00100001; //21
            8'b00010111: deci = 8'b00100010; //22
            8'b00011000: deci = 8'b00100011; //23
            8'b00011001: deci = 8'b00100100; //24
            8'b00011010: deci = 8'b00100101; //25
            8'b00011011: deci = 8'b00100110; //26
            8'b00011100: deci = 8'b00100111; //27
            8'b00011101: deci = 8'b00101000; //28
            8'b00011110: deci = 8'b00101001; //29
            8'b00011111: deci = 8'b00110000; //30
            8'b00100000: deci = 8'b00110001; //31
            8'b00100001: deci = 8'b00110010; //32
            default: deci = 8'b1111111;
        endcase
    end
endmodule

//note: consider changing the hexdecoder to work with a 5 bit number so we can use f in the counter
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
            4'hF: h = 7'b1111111; //cahnged to be the default off 0001110 is regular F
            default: h = 7'b1111111;
        endcase
    end
endmodule