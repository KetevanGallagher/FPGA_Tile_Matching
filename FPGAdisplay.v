module FPGAdisplay(userquit, ingameOn, gameOver, hex0hldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr, ledrhldr, LEDR, HEX0, HEX2, HEX3, HEX4, HEX5);
input userquit, ingameOn, gameOver;
input [3:0] hex0hldr, hex2hldr, hex3hldr, hex4hldr, hex5hldr;
input [9:0] ledrhldr;

output [9:0] LEDR;
output [6:0] HEX0, HEX2, HEX3, HEX4, HEX5;

//every hex light
hex_7seg moderun (hex0hldr, HEX0);

//always @ (*)
//	begin
//	if (ingame == 0 && gameOver == 0)
//		begin
//		ledrhldr <= 10'b0;
//		hex2hldr <= 4'b1111;
//		hex3hldr <= 4'b1111;
//		hex4hldr <= 4'b1111;
//		hex5hldr <= 4'b1111;
//		end
//	else if (ingame == 0 && gameOver == 1)
//		begin
//		hex2hldr <= 4'b1111;
//		hex3hldr <= 4'b1111;
//		end
//
//	end

hex_7seg game2 (hex2hldr, HEX2);
hex_7seg game3 (hex3hldr, HEX3);
hex_7seg game4 (hex4hldr, HEX4);
hex_7seg game5 (hex5hldr, HEX5);

//every ledr light
assign LEDR = ledrhldr;


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