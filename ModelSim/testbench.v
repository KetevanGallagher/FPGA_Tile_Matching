`timescale 1ns / 1ps

module testbench ( );
	parameter CLOCK_PERIOD = 10;

    reg [9:0] SW;
    reg [3:0] KEY;
    reg CLOCK_50;
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    
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
        #50 KEY[1] <= 1'b0;  // Press KEY[1] to start
        #70 KEY[1] <= 1'b1;  // Release
        #100; // wait for state transition

        // ============================================
        // TEST CASE 2: Non-matching tiles (SW[0] and SW[1])
        // SW[0] = color 1, SW[1] = color 2 (no match)
        // ============================================
        #100 SW[0] <= 1'b1;
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to confirm first tile
        #210 KEY[2] <= 1'b1;  // Release
        #100; // wait for state transition
        
        SW[0] <= 1'b0;
        SW[1] <= 1'b1;
        #200 KEY[3] <= 1'b0;  // Press KEY[3] to confirm second tile
        #210 KEY[3] <= 1'b1;  // Release
        #100; // wait for state transition
        
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to compare (should not match)
        #210 KEY[2] <= 1'b1;  // Release
        #200; // wait for comparison
        SW[1] <= 1'b0;

        // ============================================
        // TEST CASE 3: Matching tiles (SW[0] and SW[7])
        // Both have color 1 (should match)
        // ============================================
        #200 SW[0] <= 1'b1;
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to confirm first tile
        #210 KEY[2] <= 1'b1;  // Release
        #100; // wait for state transition
        
        SW[0] <= 1'b0;
        SW[7] <= 1'b1;
        #200 KEY[3] <= 1'b0;  // Press KEY[3] to confirm second tile
        #210 KEY[3] <= 1'b1;  // Release
        #100; // wait for state transition
        
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to compare (should match)
        #210 KEY[2] <= 1'b1;  // Release
        #200; // wait for comparison
        SW[7] <= 1'b0;

        // ============================================
        // TEST CASE 4: Another matching pair (SW[1] and SW[4])
        // Both have color 2 (should match)
        // ============================================
        #200 SW[1] <= 1'b1;
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to confirm first tile
        #210 KEY[2] <= 1'b1;  // Release
        #100; // wait for state transition
        
        SW[1] <= 1'b0;
        SW[4] <= 1'b1;
        #200 KEY[3] <= 1'b0;  // Press KEY[3] to confirm second tile
        #210 KEY[3] <= 1'b1;  // Release
        #100; // wait for state transition
        
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to compare (should match)
        #210 KEY[2] <= 1'b1;  // Release
        #200; // wait for comparison
        SW[4] <= 1'b0;

        // ============================================
        // TEST CASE 5: Non-matching tiles (SW[2] and SW[3])
        // SW[2] = color 3, SW[3] = color 4 (no match)
        // ============================================
        #200 SW[2] <= 1'b1;
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to confirm first tile
        #210 KEY[2] <= 1'b1;  // Release
        #100; // wait for state transition
        
        SW[2] <= 1'b0;
        SW[3] <= 1'b1;
        #200 KEY[3] <= 1'b0;  // Press KEY[3] to confirm second tile
        #210 KEY[3] <= 1'b1;  // Release
        #100; // wait for state transition
        
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to compare (should not match)
        #210 KEY[2] <= 1'b1;  // Release
        #200; // wait for comparison
        SW[3] <= 1'b0;

        // ============================================
        // TEST CASE 6: Matching pair (SW[2] and SW[6])
        // Both have color 3 (should match)
        // ============================================
        #200 SW[2] <= 1'b1;
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to confirm first tile
        #210 KEY[2] <= 1'b1;  // Release
        #100; // wait for state transition
        
        SW[2] <= 1'b0;
        SW[6] <= 1'b1;
        #200 KEY[3] <= 1'b0;  // Press KEY[3] to confirm second tile
        #210 KEY[3] <= 1'b1;  // Release
        #100; // wait for state transition
        
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to compare (should match)
        #210 KEY[2] <= 1'b1;  // Release
        #200; // wait for comparison
        SW[6] <= 1'b0;

        // ============================================
        // TEST CASE 7: Matching pair (SW[3] and SW[5])
        // Both have color 4 (should match)
        // ============================================
        #200 SW[3] <= 1'b1;
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to confirm first tile
        #210 KEY[2] <= 1'b1;  // Release
        #100; // wait for state transition
        
        SW[3] <= 1'b0;
        SW[5] <= 1'b1;
        #200 KEY[3] <= 1'b0;  // Press KEY[3] to confirm second tile
        #210 KEY[3] <= 1'b1;  // Release
        #100; // wait for state transition
        
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to compare (should match)
        #210 KEY[2] <= 1'b1;  // Release
        #200; // wait for comparison
        SW[5] <= 1'b0;

        // ============================================
        // TEST CASE 8: Matching pair (SW[8] and SW[9])
        // Both have color 5 (should match)
        // ============================================
        #200 SW[8] <= 1'b1;
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to confirm first tile
        #210 KEY[2] <= 1'b1;  // Release
        #100; // wait for state transition
        
        SW[8] <= 1'b0;
        SW[9] <= 1'b1;
        #200 KEY[3] <= 1'b0;  // Press KEY[3] to confirm second tile
        #210 KEY[3] <= 1'b1;  // Release
        #100; // wait for state transition
        
        #200 KEY[2] <= 1'b0;  // Press KEY[2] to compare (should match - all tiles matched, game over)
        #210 KEY[2] <= 1'b1;  // Release
        #200; // wait for comparison
        SW[9] <= 1'b0;

        // ============================================
        // TEST CASE 9: Test reset (KEY[0])
        // ============================================
        #200 KEY[0] <= 1'b0;  // Press KEY[0] to reset
        #200 KEY[0] <= 1'b1;  // Release
        #200; // wait for reset

        // ============================================
        // TEST CASE 10: Restart game and test edge case
        // ============================================
        #200 KEY[1] <= 1'b0;  // Press KEY[1] to start again
        #70 KEY[1] <= 1'b1;  // Release
        #200; // wait for state transition

        // Test with switch already set before pressing KEY[2]
        SW[0] <= 1'b1;
        #300 KEY[2] <= 1'b0;  // Press KEY[2] to confirm first tile
        #210 KEY[2] <= 1'b1;  // Release
        #200; // wait for state transition

	end // initial

	tilegame U1 (SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	// Remove these if not debugging
	assign gameModeState = U1.gameModeState;
	assign inGameState = U1.inGameState;
endmodule
