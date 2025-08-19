module redRow(clock, reset, RedPixels, out, odd, hard);
   input logic clock, reset, odd, hard;
   output logic [15:0] RedPixels; 
	input logic [5:0] out;
	logic direction, truck, justReset;
	logic [1:0] new_light, river;
	logic truckCount, shiftCount;
   logic [3:0] lightCount, currLightCount;
	
			
	counter #(10) shift_count (.clock(clock), .reset(reset), .out(shiftCount)); // returns true after 2^WIDTH clock cycles		
	 
	always_ff @(posedge clock) begin
		if (!hard && odd) RedPixels <= 16'b0;
		else if (reset) begin
			new_light <= out[5:4];
			river <= out[3:2];
			truck <= out[1];
			direction <= out[0];
			currLightCount<= 3'b0;
			truckCount <= 1;
			RedPixels <= 16'b0;
			justReset <= 1;
		end
		else if (justReset) begin
			justReset <= 0;
			if (river == 2'b00) begin
				RedPixels <= 16'b1110001111000111;
				lightCount <= 3'b101;
			end
			else if (new_light == 2'b01) begin
				if (truck) begin
					if (!direction) RedPixels <= 16'b1000110001100011;
					else RedPixels <= 16'b1100011000110001;
				end
				else begin
					if (!direction) RedPixels <= 16'b0001000100010001;
					else RedPixels <= 16'b1000100010001000;
				end;
				lightCount <= 3'b011;  // 3 shifts
			end
			else if (new_light == 2'b10) begin
				if (truck) begin
					if (!direction) RedPixels <= 16'b0011000011000011;
					else RedPixels <= 16'b1100001100001100;
				end
				else begin
					RedPixels <= 16'b1000010000100001;
				end;
				lightCount <= 3'b100;  // 4 shifts
			end
			else begin
				if (truck) begin
					RedPixels <= 16'b1100000110000011;
				end
				else begin
					if (!direction) RedPixels <= 16'b0001000001000001;
					else RedPixels <= 16'b1000001000001000;
				end;
				lightCount <= 3'b101;  // 5 shifts
			end 
		end
		else begin
			justReset <= 0; 
			if (river != 2'b00) begin
				// shifts lights and adds new one if both the shift count after 2^WIDTH clock cycles is true 
				// and if the correct number of shifts since the previous light was added
				if (shiftCount && (currLightCount == lightCount)) begin
					currLightCount <= 3'b0;
					if (truck) truckCount <= 0;
					// shifts left or right based on random direction bit
					if (direction) RedPixels <= {1'b1, RedPixels[15:1]};
					else RedPixels <= {RedPixels[14:0], 1'b1};
				end
				else if (!truckCount && shiftCount) begin
					truckCount <= 1;
					if (direction) RedPixels <= {1'b1, RedPixels[15:1]};
					else RedPixels <= {RedPixels[14:0], 1'b1};
				end
				else if (shiftCount) begin
					// increments number of shifts since a light was added until it matches the desired rate
					currLightCount <= currLightCount + 3'b001;
					if (direction)RedPixels <= {1'b0, RedPixels[15:1]};
					else RedPixels <= {RedPixels[14:0], 1'b0};
				end
			end
		end
	end
endmodule


module redRow_testbench();
	logic CLOCK_50;
	logic reset;
	logic [15:0] RedPixels;
	logic [5:0] out;
	
	redRow dut (CLOCK_50, reset, RedPixels, out);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	
	// Test the design.
	initial begin
												repeat(1) @(posedge CLOCK_50);
		reset <= 1; out <= 6'b11010;  repeat(5) @(posedge CLOCK_50); // Always reset FSMs at start
		reset <= 0; 					   repeat(9000) @(posedge CLOCK_50);
		reset <= 1; out <= 6'b10101;  repeat(5) @(posedge CLOCK_50);
		reset <= 0; 						repeat(9000) @(posedge CLOCK_50);
		reset <= 1; out <= 6'b11101; 	repeat(5) @(posedge CLOCK_50);
		reset <= 0; 						repeat(9000) @(posedge CLOCK_50);
		reset <= 1; out <= 6'b11111; 	repeat(5) @(posedge CLOCK_50);
		reset <= 0;						   repeat(9000) @(posedge CLOCK_50);
		reset <= 1; out <= 6'b00000; 	repeat(5) @(posedge CLOCK_50);
		reset <= 0; 						repeat(9000) @(posedge CLOCK_50);
														 
		$stop; // End the simulation.
	end
	
endmodule
	 
	