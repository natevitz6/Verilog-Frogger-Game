module green(clock, reset, L, R, U, D, GreenPixels, RedPixels, win, lose);
    input logic clock, reset;
	 input logic [15:0][15:0] RedPixels;
    output logic [15:0][15:0] GreenPixels; // 16x16 array of red LEDs
	 input logic L, R, U, D;
	 output logic win, lose;
	 logic [3:0] currRow, currCol;
	 
	 always_ff @(posedge clock) begin
		if (reset) begin
			lose <= 0;
			win <= 0;
			currRow <= 15;
			currCol <= 7;
			GreenPixels <= 16'b0;
			GreenPixels[15] <= 16'b0000000010000000;
		end
		else if (GreenPixels[currRow][currCol] && RedPixels[currRow][currCol]) begin
			lose <= 1;
		end
		else begin
			if (currRow == 0) begin
				win <= 1;
				currRow <= 15;
				currCol <= 7;
				GreenPixels <= 16'b0;
				GreenPixels[15] <= 16'b0000000010000000;
			end
			else begin
				win <= 0;
				if (L) begin
					GreenPixels <= 16'b0;
					if (currCol < 15) begin
						currCol <= currCol + 1;
						GreenPixels[currRow] <= (1 << (currCol+1));
					end
					else begin
						currCol <= 0;
						GreenPixels[currRow] <= 16'b0000000000000001;
					end
				end
				else if (R) begin
					GreenPixels <= 16'b0;
					if (currCol > 0) begin
						currCol <= currCol - 1;
						GreenPixels[currRow] <= (1 << (currCol-1));
					end
					else begin
						currCol <= 15;
						GreenPixels[currRow] <= 16'b1000000000000000;
					end
				end
				else if (U && currCol > 0) begin
					GreenPixels <= 16'b0;
					currRow <= currRow - 1;
					GreenPixels[currRow-1] <= (1 << currCol);
				end
				else if (D && currRow < 15) begin
					GreenPixels <= 16'b0;
					currRow <= currRow + 1;
					GreenPixels[currRow+1] <= (1 << currCol);
				end
			end
			
		end
	end
endmodule



module green_testbench();
	logic CLOCK_50;
	logic reset;
	logic L, R, U, D;
	logic [15:0][15:0]GreenPixels;
	logic [15:0][15:0]RedPixels;
	logic win, lose;
	
	green dut (CLOCK_50, reset, L, R, U, D, GreenPixels, RedPixels, win, lose);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	
	// Test the design.
	initial begin
																  repeat(1) @(posedge CLOCK_50);
		reset <= 1; RedPixels <= 16'b0;					  repeat(3) @(posedge CLOCK_50); // Always reset FSMs at start
		reset <= 0; L <= 0; R <= 0; U <= 0; D <= 0; repeat(4) @(posedge CLOCK_50);
		
		for (int i = 0; i < 16; i++) begin
            L <= 0; R <= 0; U <= 1; D <= 0; repeat(1) @(posedge CLOCK_50);
            L <= 0; R <= 0; U <= 0; D <= 0; repeat(2) @(posedge CLOCK_50);
      end
		reset <= 1; @(posedge CLOCK_50);
		reset <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 10; i++) begin
            L <= 0; R <= 1; U <= 0; D <= 0; repeat(1) @(posedge CLOCK_50);
            L <= 0; R <= 0; U <= 0; D <= 0; repeat(2) @(posedge CLOCK_50);
      end
		reset <= 1; @(posedge CLOCK_50);
		reset <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 10; i++) begin
            L <= 1; R <= 0; U <= 0; D <= 0; repeat(1) @(posedge CLOCK_50);
            L <= 0; R <= 0; U <= 0; D <= 0; repeat(2) @(posedge CLOCK_50);
      end				
		reset <= 1; @(posedge CLOCK_50);
		reset <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 3; i++) begin
            L <= 0; R <= 0; U <= 0; D <= 1; repeat(1) @(posedge CLOCK_50);
            L <= 0; R <= 0; U <= 0; D <= 0; repeat(2) @(posedge CLOCK_50);
      end
		
		$stop; // End the simulation.
	end
	
endmodule
	 