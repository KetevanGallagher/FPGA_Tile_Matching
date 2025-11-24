module TileGenerator(visible, clk, xOrd, yOrd, addrC, readC, vgaR, vgaG, vgaB);
    input [9:0] xOrd, yOrd;
    input [7:0] readC;
	 input visible, clk;
    output reg [3:0] addrC;
    output reg [7:0] vgaR, vgaG, vgaB;
	 reg tileFlag;
	 reg [3:0] tileCounter;
	 
	 
    always @(*)
		begin
				 
            tileFlag <= 1'b0;
            tileCounter <= 4'b0000;
            
            //row 1
            if (10'd80 < xOrd & 10'd170 > xOrd & 10'd24 < yOrd & 10'd114 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b0000;
            end
            else if (10'd210 < xOrd & 10'd300 > xOrd & 10'd24 < yOrd & 10'd114 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b0001;
            end
            else if (10'd340 < xOrd & 10'd430 > xOrd & 10'd24 < yOrd & 10'd114 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b0010;
            end
            else if (10'd470 < xOrd & 10'd560 > xOrd & 10'd24 < yOrd & 10'd114 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b0011;
            end
            
            
            //row 2
            else if (10'd80 < xOrd & 10'd170 > xOrd & 10'd138 < yOrd & 10'd228 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b0100;
            end
            else if (10'd210 < xOrd & 10'd300 > xOrd & 10'd138 < yOrd & 10'd228 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b0101;
            end
            else if (10'd340 < xOrd & 10'd430 > xOrd & 10'd138 < yOrd & 10'd228 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b0110;
            end
            else if (10'd470 < xOrd & 10'd560 > xOrd & 10'd138 < yOrd & 10'd228 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b0111;
            end
            
            //row 3
            else if (10'd80 < xOrd & 10'd170 > xOrd & 10'd252 < yOrd & 10'd342 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b1000;
            end
            else if (10'd210 < xOrd & 10'd300 > xOrd & 10'd252 < yOrd & 10'd342 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b1001;
            end
            else if (10'd340 < xOrd & 10'd430 > xOrd & 10'd252 < yOrd & 10'd342 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b1010;
            end
            else if (10'd470 < xOrd & 10'd560 > xOrd & 10'd252 < yOrd & 10'd342 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b1011;
            end
            
            //row 4
            else if (10'd80 < xOrd & 10'd170 > xOrd & 10'd366 < yOrd & 10'd456 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b1100;
            end
            else if (10'd210 < xOrd & 10'd300 > xOrd & 10'd366 < yOrd & 10'd456 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b1101;
            end
            else if (10'd340 < xOrd & 10'd430 > xOrd & 10'd366 < yOrd & 10'd456 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b1110;
            end
            else if (10'd470 < xOrd & 10'd560 > xOrd & 10'd366 < yOrd & 10'd456 > yOrd)
            begin
            tileFlag <= 1'b1;
            tileCounter <= 4'b1111;
            end
                    
        end
        
        always@(posedge clk) begin     
            addrC <= tileCounter;
        end
                
        always@(posedge clk) begin	  
            
            if (!visible) begin
            vgaR <= 8'b00000000;
                vgaG <= 8'b00000000;
                vgaB <= 8'b00000000;
            end
            else
            
                begin
                if (tileFlag) begin
                
                    if (!readC[0] & !readC[1])
                    begin
                            vgaR <= 8'b00000000;
                            vgaG <= 8'b00000000;
                            vgaB <= 8'b00000000;
                    end
                    else if (readC[0] & !readC[1])
                    begin
                            vgaR <= 8'b10000000;
                            vgaG <= 8'b10000000;
                            vgaB <= 8'b10000000;
                    end
                    else if (readC[1])
                    begin
                            vgaR <= {readC[7:6], 6'b000000};
                            vgaG <= {readC[5:4], 6'b000000};
                            vgaB <= {readC[3:2], 6'b000000};
                    end

                end
                
                else begin
                    vgaR <= 8'b11111111;
                    vgaG <= 8'b11111111;
                    vgaB <= 8'b11111111;
                end
                
                end 
    end
endmodule