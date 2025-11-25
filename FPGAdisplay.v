module FPGAdisplay(userquit, ingameOn, gameOver, hex0hldr, hex4hldr, hex5hldr, ledrhldr, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

input userquit, ingameOn, gameOver;
input [3:0] hex0hldr;
input [3:0] hex4hldr, hex5hldr;
input [9:0] ledrhldr;

output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

wire [7:0] deciScore1, deciScore2;

//run the module for converting the score into decimal

//every hex light
hex_7seg moderun (hex0hldr, HEX0);

//these are off
hex_7seg turnOff1 (4'b1111, HEX1);
hex_7seg turnOff2 (4'b1111, HEX2);
hex_7seg turnOff3 (4'b1111, HEX3);

decimal_conversion d0(hex4hldr, hex5hldr, deciScore1, deciScore2);

hex_7seg game4 (deciScore1, HEX4);
hex_7seg game5 (deciScore2, HEX5);

//every ledr light
assign LEDR = ledrhldr;


endmodule

//module for changing the dementia score into proper decimal
module decimal_conversion(bi4, bi5, deci4, deci5);
	input [3:0] bi4, bi5;
	output reg [7:0] deci4, deci5;

	always @(*) 
	begin
	if (bi5 == 4'b0000 && bi4 == 4'b0000) begin deci5 = 4'b0000; deci4 = 4'b0000; end //0
	else if (bi5 == 4'b0000 && bi4 == 4'b0001) begin deci5 = 4'b0000; deci4 = 4'b0001; end //1
	else if (bi5 == 4'b0000 && bi4 == 4'b0010) begin deci5 = 4'b0000; deci4 = 4'b0010; end //2
	else if (bi5 == 4'b0000 && bi4 == 4'b0011) begin deci5 = 4'b0000; deci4 = 4'b0011; end //3
	else if (bi5 == 4'b0000 && bi4 == 4'b0100) begin deci5 = 4'b0000; deci4 = 4'b0100; end //4
	else if (bi5 == 4'b0000 && bi4 == 4'b0101) begin deci5 = 4'b0000; deci4 = 4'b0101; end //5
	else if (bi5 == 4'b0000 && bi4 == 4'b0110) begin deci5 = 4'b0000; deci4 = 4'b0110; end //6
	else if (bi5 == 4'b0000 && bi4 == 4'b0111) begin deci5 = 4'b0000; deci4 = 4'b0111; end //7
	else if (bi5 == 4'b0000 && bi4 == 4'b1000) begin deci5 = 4'b0000; deci4 = 4'b1000; end //8
	else if (bi5 == 4'b0000 && bi4 == 4'b1001) begin deci5 = 4'b0000; deci4 = 4'b1001; end //9
	else if (bi5 == 4'b0000 && bi4 == 4'b1010) begin deci5 = 4'b0001; deci4 = 4'b0000; end //10
	else if (bi5 == 4'b0000 && bi4 == 4'b1011) begin deci5 = 4'b0001; deci4 = 4'b0001; end //11
	else if (bi5 == 4'b0000 && bi4 == 4'b1100) begin deci5 = 4'b0001; deci4 = 4'b0010; end //12
	else if (bi5 == 4'b0000 && bi4 == 4'b1101) begin deci5 = 4'b0001; deci4 = 4'b0011; end //13
	else if (bi5 == 4'b0000 && bi4 == 4'b1110) begin deci5 = 4'b0001; deci4 = 4'b0100; end //14
	else if (bi5 == 4'b0000 && bi4 == 4'b1111) begin deci5 = 4'b0001; deci4 = 4'b0101; end //15
	else if (bi5 == 4'b0001 && bi4 == 4'b0000) begin deci5 = 4'b0001; deci4 = 4'b0110; end //16
	else if (bi5 == 4'b0001 && bi4 == 4'b0001) begin deci5 = 4'b0001; deci4 = 4'b0111; end //17
	else if (bi5 == 4'b0001 && bi4 == 4'b0010) begin deci5 = 4'b0001; deci4 = 4'b1000; end //18
	else if (bi5 == 4'b0001 && bi4 == 4'b0011) begin deci5 = 4'b0001; deci4 = 4'b1001; end //19
	else if (bi5 == 4'b0001 && bi4 == 4'b0100) begin deci5 = 4'b0010; deci4 = 4'b0000; end //20
	else if (bi5 == 4'b0001 && bi4 == 4'b0101) begin deci5 = 4'b0010; deci4 = 4'b0001; end //21
	else if (bi5 == 4'b0001 && bi4 == 4'b0110) begin deci5 = 4'b0010; deci4 = 4'b0010; end //22
	else if (bi5 == 4'b0001 && bi4 == 4'b0111) begin deci5 = 4'b0010; deci4 = 4'b0011; end //23
	else if (bi5 == 4'b0001 && bi4 == 4'b1000) begin deci5 = 4'b0010; deci4 = 4'b0100; end //24
	else if (bi5 == 4'b0001 && bi4 == 4'b1001) begin deci5 = 4'b0010; deci4 = 4'b0101; end //25
	else if (bi5 == 4'b0001 && bi4 == 4'b1010) begin deci5 = 4'b0010; deci4 = 4'b0110; end //26
	else if (bi5 == 4'b0001 && bi4 == 4'b1011) begin deci5 = 4'b0010; deci4 = 4'b0111; end //27
	else if (bi5 == 4'b0001 && bi4 == 4'b1100) begin deci5 = 4'b0010; deci4 = 4'b1000; end //28
	else if (bi5 == 4'b0001 && bi4 == 4'b1101) begin deci5 = 4'b0010; deci4 = 4'b1001; end //29
	else if (bi5 == 4'b0001 && bi4 == 4'b1110) begin deci5 = 4'b0011; deci4 = 4'b0000; end //30
	else if (bi5 == 4'b0001 && bi4 == 4'b1111) begin deci5 = 4'b0011; deci4 = 4'b0001; end //31
	else if (bi5 == 4'b0010 && bi4 == 4'b0000) begin deci5 = 4'b0011; deci4 = 4'b0010; end //32
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