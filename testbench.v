`timescale 1ns / 1ps

module testbench ( );
	parameter CLOCK_PERIOD = 10;

    reg [9:0] SW;
    reg [3:0] KEY;
    reg CLOCK_50;
	wire PS2_CLK;
	wire PS2_DAT;
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

//additional signals for ps2
	reg [7:0] ps2_key_data;
	reg ps2_key_pressed;
    
    // TODO: Remove these debug signals before final implementation
    wire [3:0] gameModeState;
    wire [2:0] inGameState;

	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end

	initial begin
        SW  = 10'b0;
        KEY = 4'b1111;

        // ============================================
        // TEST CASE 1: Start game
        // ============================================
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h5a;      // Press enter key to start
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition

        // ============================================
        // TEST CASE 2: Non-matching tiles (SW[0] and SW[1])
        // SW[0] = color 1, SW[1] = color 2 (no match)
        // ============================================
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h16;      // Press tile 0
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h1e;      // Press tile 1
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #200; // wait for comparison

        // ============================================
        // TEST CASE 3: Matching tiles (SW[0] and SW[7])
        // Both have color 1 (should match)
        // ============================================
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h16;      // Press tile 0
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h2d;      // Press tile 7
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #200; // wait for comparison

        // ============================================
        // TEST CASE 4: Another matching pair (SW[1] and SW[4])
        // Both have color 2 (should match)
        // ============================================
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h1e;      // Press tile 1
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h15;      // Press tile 4
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #200; // wait for comparison

        // ============================================
        // TEST CASE 5: Non-matching tiles (SW[2] and SW[3])
        // SW[2] = color 3, SW[3] = color 4 (no match)
        // ============================================
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h26;      // Press tile 2
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition

        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h25;      // Press tile 3
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #200; // wait for comparison

        // ============================================
        // TEST CASE 6: Matching pair (SW[2] and SW[6])
        // Both have color 3 (should match)
        // ============================================
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h26;      // Press tile 2
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h24;      // Press tile 6
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #200; // wait for comparison

        // ============================================
        // TEST CASE 7: Matching pair (SW[3] and SW[5])
        // Both have color 4 (should match)
        // ============================================
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h25;      // Press tile 3
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h1d;      // Press tile 5
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #200; // wait for comparison

        // ============================================
        // TEST CASE 8: Matching pair (SW[8] and SW[9])
        // Both have color 5 (should match)
        // ============================================
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h1c;      // Press tile 8
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #50 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h1b;      // Press tile 9
        #10 ps2_key_pressed <= 1'b0;
        #100; // wait for state transition
        
        #200; // wait for comparison

        // ============================================
        // TEST CASE 9: Test reset (KEY[0])
        // ============================================
        #200 KEY[0] <= 1'b0;  // Press KEY[0] to reset
        #200 KEY[0] <= 1'b1;  // Release
        #200; // wait for reset

        // ============================================
        // TEST CASE 10: Restart game and test edge case
        // ============================================
        #200 ps2_key_pressed <= 1'b1; ps2_key_data = 8'h5a;      // Press enter key to start
        #70 ps2_key_pressed <= 1'b0;
        #200; // wait for state transition

	end // initial

	tilegame U1 (SW, KEY, CLOCK_50, PS2_CLK, PS2_DAT, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	// Remove these if not debugging
	assign gameModeState = U1.gameModeState;
	assign inGameState = U1.inGameState;
endmodule
