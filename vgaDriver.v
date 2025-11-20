// VGA Driver code credited to Ayan Ali
// vga driver module - generates sync signals and pixel coordinates
module vgaDriver(
    input clock50MHz,               // board oscillator
    input resetn,                   // active-low reset
    input [9:0] resolutionX,        // horizontal resolution (e.g., 640)
    input [9:0] resolutionY,        // vertical resolution (e.g., 480)
    output hSync,                   // horizontal sync
    output vSync,                   // vertical sync
    output [9:0] xOrd,              // horizontal coordinate output
    output [9:0] yOrd,              // vertical coordinate output
    output visible,                 // visible area flag
    output pixelClkOut              // 25mhz pixel clock for vga dac
);
    // standard vga timing blanking periods (640x480 @ 60hz standard)
    wire [9:0] hFrontPorch = 10'd16;
    wire [9:0] hSyncPulse  = 10'd96;
    wire [9:0] hBackPorch  = 10'd48;
    wire [9:0] vFrontPorch = 10'd10;
    wire [9:0] vSyncPulse  = 10'd2;
    wire [9:0] vBackPorch  = 10'd33;
    
    // calculate timing values based on resolution and blanking periods
    wire [9:0] hSyncStart = resolutionX + hFrontPorch;
    wire [9:0] hSyncEnd   = hSyncStart + hSyncPulse;
    wire [9:0] hTotal     = resolutionX + hFrontPorch + hSyncPulse + hBackPorch;
    
    wire [9:0] vSyncStart = resolutionY + vFrontPorch;
    wire [9:0] vSyncEnd   = vSyncStart + vSyncPulse;
    wire [9:0] vTotal     = resolutionY + vFrontPorch + vSyncPulse + vBackPorch;

    wire pixelClk;
    wire [9:0] xCoord;
    wire [9:0] yCoord;
    wire hEnd;
    wire vis;

    pixelClock pc (.clock(clock50MHz), .resetn(resetn), .pulse(pixelClk));
    
    hCounter hc (
        .pixelClock(pixelClk), 
        .resetn(resetn),
        .hTotal(hTotal),
        .xOrd(xCoord), 
        .hEnd(hEnd)
    );
    
    vCounter vc (
        .pixelClock(pixelClk), 
        .resetn(resetn), 
        .hEnd(hEnd),
        .vTotal(vTotal),
        .yOrd(yCoord)
    );
    
    syncGenerator sg (
        .xOrd(xCoord), 
        .yOrd(yCoord),
        .hVisible(resolutionX),
        .hSyncStart(hSyncStart),
        .hSyncEnd(hSyncEnd),
        .vVisible(resolutionY),
        .vSyncStart(vSyncStart),
        .vSyncEnd(vSyncEnd),
        .hSync(hSync), 
        .vSync(vSync), 
        .visible(vis)
    );
    
    assign xOrd = xCoord;
    assign yOrd = yCoord;
    assign visible = vis;
    assign pixelClkOut = pixelClk;
endmodule


// tff-style pixel clock: divide 50mhz by 2 to get ~25mhz
module pixelClock(
    input clock,
    input resetn,
    output reg pulse            // vga monitor expects a signal at ~25mhz
);
    always @(posedge clock or negedge resetn) begin
        if (!resetn) begin
            pulse <= 0;
        end else begin
            pulse <= ~pulse;
        end
    end
endmodule


module hCounter(
    input pixelClock,
    input resetn,
    input [9:0] hTotal,            // total horizontal pixels
    output reg [9:0] xOrd,         // horizontal pixel coordinate
    output reg hEnd                // high when the horizontal line has ended  
);
    always @(posedge pixelClock or negedge resetn) begin
        if (!resetn) begin
            xOrd <= 10'd0;
            hEnd <= 0;
        end else begin
            if (xOrd == hTotal - 1) begin
                xOrd <= 10'd0;
                hEnd <= 1;
            end else begin
                xOrd <= xOrd + 1;
                hEnd <= 0;
            end
        end
    end
endmodule


module vCounter(
    input pixelClock,
    input resetn,
    input hEnd,                    // vertical counter, incremented at end of line
    input [9:0] vTotal,            // total vertical lines
    output reg [9:0] yOrd          // vertical line coordinate
);
    always @(posedge pixelClock or negedge resetn) begin
        if (!resetn) begin
            yOrd <= 10'd0;
        end else if (hEnd) begin
            if (yOrd == vTotal - 1)
                yOrd <= 10'd0;
            else
                yOrd <= yOrd + 1;
        end
    end
endmodule


module syncGenerator(
    input wire [9:0] xOrd,
    input wire [9:0] yOrd,
    input wire [9:0] hVisible,      // horizontal visible area
    input wire [9:0] hSyncStart,    // horizontal sync start
    input wire [9:0] hSyncEnd,      // horizontal sync end
    input wire [9:0] vVisible,      // vertical visible area
    input wire [9:0] vSyncStart,    // vertical sync start
    input wire [9:0] vSyncEnd,      // vertical sync end
    output reg hSync,               // active low, 0 when xOrd is in horizontal sync pulse range
    output reg vSync,               // active low, 0 when yOrd is in vertical sync pulse range
    output reg visible              // 1 if xOrd and yOrd in visible area
);
    always @(*) begin
        // hsync conditions
        if (xOrd >= hSyncStart && xOrd < hSyncEnd)
            hSync = 0;
        else
            hSync = 1;

        // vsync conditions
        if (yOrd >= vSyncStart && yOrd < vSyncEnd)
            vSync = 0;
        else
            vSync = 1;

        // visible conditions
        if (xOrd < hVisible && yOrd < vVisible)
            visible = 1;
        else
            visible = 0;
    end
endmodule