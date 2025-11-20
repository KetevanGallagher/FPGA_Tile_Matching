module vgaDisplay(CLOCK_50, KEY, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_BLANK_N, VGA_SYNC_N);
    input CLOCK_50;
    input [3:0] KEY;
    output VGA_HS, VGA_VS, VGA_CLK, VGA_BLANK_N, VGA_SYNC_N;
    output [7:0] VGA_R, VGA_G, VGA_B;
	 
	 
	 // KEY[0] is active low reset
    wire resetn = KEY[0];
    
    // internal vga signals from vgaDriverTest
    wire [9:0] xOrd, yOrd;
    wire visible, pixelClk; // 25mhz pixel clock from vgaDriver
    wire [7:0] vgaR, vgaG, vgaB;

    // instantiate the test module
    vgaConnection vgaTest (CLOCK_50, resetn, VGA_HS, VGA_VS, xOrd, yOrd, visible, vgaR, vgaG, vgaB, pixelClk);
       
    
    assign VGA_R = vgaR;
    assign VGA_G = vgaG;
    assign VGA_B = vgaB;
    
    // drive vga clock from the same pixel clock used inside vgaDriver
    assign VGA_CLK = pixelClk;
    
    // blank_n is high during visible pixels, low during blanking
    assign VGA_BLANK_N = visible;
    
    assign VGA_SYNC_N = 1'b0;
endmodule