module vgaConnection(clock50MHz, resetn, hSync, vSync, xOrd, yOrd, visible, vgaR, vgaG, vgaB, pixelClkOut);
	 input clock50MHz, resetn;
    output hSync, vSync;
    output [9:0] xOrd, yOrd;
    output visible, pixelClkOut;
    output [7:0] vgaR, vgaG, vgaB;
    
	 wire [9:0] xCoord, yCoord;
    wire vis;
    
    wire [9:0] resX, resY;
	 
	assign resX = 10'd640;
	assign resY = 10'd480;
	 
	wire [3:0] addrA, addrB, addrC;
	wire weA, weB, weC;
	wire [7:0] writeA, writeB, writeC, readA, readB, readC;
	
	assign writeA = 8'b00000000;
	assign writeB = 8'b00000000;
	assign writeC = 8'b00000000;
	assign weA = 1'b0;
	assign weB = 1'b0;
	assign weC = 1'b0;
    
    // instantiate the vga driver (timing/sync generator)
    vgaDriver vga (clock50MHz, resetn, resX, resY, hSync, vSync, xCoord, yCoord, vis, pixelClkOut);
	ramModule u0(pixelClkOut, addrA, writeA, weA, readA, addrB, writeB, weB, readB, addrC, writeC, weC, readC);
    TileGenerator u1(vis, pixelClkOut, xCoord, yCoord, addrC, readC, vgaR, vgaG, vgaB);
	 
    
    // output coordinates and visible signal
    assign xOrd = xCoord;
    assign yOrd = yCoord;
    assign visible = vis;    
endmodule