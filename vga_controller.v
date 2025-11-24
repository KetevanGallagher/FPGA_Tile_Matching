/* This module implements the VGA controller. It assumes a 25MHz clock is supplied as input.
 * General approach:
 * Go through each line of the screen and read the color each pixel on that line should have from
 * the Video memory. To do that for each (x,y) pixel on the screen convert (x,y) coordinate to
 * a memory_address at which the pixel color is stored in Video memory. Once the pixel color is
 * read from video memory its brightness is first increased before it is forwarded to the VGA DAC.
 */

//CODE IS FROM GIVEN VGA DEMO WITH SOME MODIFICATIONS
// writing to memory changed to x and y coords, output vga clock as pixel clock
module vga_controller(vga_clock, resetn, xCoord, yCoord, VGA_HS, VGA_VS, visible, VGA_SYNC_N, pixelClk);

    // The VGA resolution, which can be set to "640x480", "320x240", and "160x120"
    parameter RESOLUTION = "640x480";
	parameter COLOR_DEPTH = 3;          // color depth for the video memory
    parameter COLS = 160, ROWS = 120;   // default COLS x ROWS memory
    // See video adaptor for descriptions of the above parameters
    
	// Timing parameters:
	/* The VGA specification requires that a few more rows and columns are drawn
	 * than are actually present on the screen. This is necessary to generate the vertical
     * and horizontal syncronization signals.  */
	parameter C_VERT_NUM_PIXELS  = 11'd480;
	parameter C_VERT_SYNC_START  = 11'd490; //vresolution plus vfrontporch
	parameter C_VERT_SYNC_END    = 11'd492; //vsyncstart plus vpulse; 
	parameter C_VERT_TOTAL_COUNT = 11'd525; // vsync end plus vbackporch

	parameter C_HORZ_NUM_PIXELS  = 11'd640;
	parameter C_HORZ_SYNC_START  = 11'd656; // hresolution plus hfrontporch
	parameter C_HORZ_SYNC_END    = 11'd752; //hsyncstart plus hpulse; 
	parameter C_HORZ_TOTAL_COUNT = 11'd800; // h sync end plus hbackporch
		
	/*****************************************************************************/
	/* Declare inputs and outputs.                                               */
	/*****************************************************************************/
	
	input wire vga_clock, resetn;
	output [9:0] xCoord;
    output [9:0] yCoord;
	output reg VGA_HS;
	output reg VGA_VS;
	output reg visible;
	output wire VGA_SYNC_N, pixelClk;
	
	/*****************************************************************************/
	/* Local Signals.                                                            */
	/*****************************************************************************/
	
	reg VGA_HS1;
	reg VGA_VS1;
	reg VGA_BLANK1; 
	reg [9:0] xCounter, yCounter;
	wire xCounter_clear;
	wire yCounter_clear;
	wire vcc;
	
	reg [9:0] x; 
	reg [9:0] y;	
	/* Inputs to the converter. */
	
	reg pixelClkInternal;
	
	/*****************************************************************************/
	/* Controller implementation.                                                */
	/*****************************************************************************/

	assign vcc =1'b1;
	
	//added: get 25mhz clock
	always @(posedge vga_clock)
	begin
		if (!resetn)
			pixelClkInternal <= 1'b0;
		else
			pixelClkInternal <= ~pixelClkInternal;
	end
	
	/* A counter to scan through a horizontal line. */
	always @(posedge pixelClkInternal or negedge resetn)
	begin
		if (!resetn)
			xCounter <= 10'd0;
		else if (xCounter_clear)
			xCounter <= 10'd0;
		else
		begin
			xCounter <= xCounter + 1'b1;
		end
	end
	assign xCounter_clear = (xCounter == (C_HORZ_TOTAL_COUNT-1));

	/* A counter to scan vertically, indicating the row currently being drawn. */
	always @(posedge pixelClkInternal or negedge resetn)
	begin
		if (!resetn)
			yCounter <= 10'd0;
		else if (xCounter_clear && yCounter_clear)
			yCounter <= 10'd0;
		else if (xCounter_clear)		//Increment when x counter resets
			yCounter <= yCounter + 1'b1;
	end
	assign yCounter_clear = (yCounter == (C_VERT_TOTAL_COUNT-1)); 
	
	/* Convert the xCounter/yCounter location from screen pixels (640x480) to our
	 * local dots (320x240 or 160x120). Here we effectively divide x/y coordinate by 2 or 4,
	 * depending on the resolution. */
	always @(*)
	begin
        x = xCounter[9:(RESOLUTION == "640x480") ? 0 : ((RESOLUTION == "320x240") ? 1 : 2)];
        y = yCounter[8:(RESOLUTION == "640x480") ? 0 : ((RESOLUTION == "320x240") ? 1 : 2)];
	end
	
	assign xCoord = x;
    assign yCoord = y;


	/* Generate the vertical and horizontal synchronization pulses. */
	always @(posedge pixelClkInternal)
	begin
		//- Sync Generator (ACTIVE LOW)
		VGA_HS1 <= ~((xCounter >= C_HORZ_SYNC_START) && (xCounter <= C_HORZ_SYNC_END));
		VGA_VS1 <= ~((yCounter >= C_VERT_SYNC_START) && (yCounter <= C_VERT_SYNC_END));
		
		//- Current X and Y is valid pixel range
		VGA_BLANK1 <= ((xCounter < C_HORZ_NUM_PIXELS) && (yCounter < C_VERT_NUM_PIXELS));	
	
		//- Add 1 cycle delay
		VGA_HS <= VGA_HS1;
		VGA_VS <= VGA_VS1;
		visible <= VGA_BLANK1;	
	end
	
	/* VGA sync should be 1 at all times. */
	assign VGA_SYNC_N = vcc;
	
	/* Generate the VGA clock signal. */
	assign pixelClk = pixelClkInternal;
	


endmodule