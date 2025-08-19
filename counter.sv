module counter #(parameter WIDTH = 1) (clock, reset, out);
	input logic clock, reset;
	output logic out;
	logic [WIDTH:0] counterValue;
	
	
	always_ff @(posedge clock) begin
		if (reset) begin
			out <= 0;
			counterValue <= {WIDTH{1'b1}};
		end
		else begin
			if (counterValue > 0) begin
				out <= 0;
				counterValue <= counterValue - 1;
			end
			else begin
				out <= 1;
				counterValue <= {WIDTH{1'b1}};
			end
		end
	end
endmodule

module counter_testbench();
	logic CLOCK_50;
   logic reset;
	logic out;
	
	counter #(5) dut (CLOCK_50, reset, out);
	
		// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	
	// Test the design.
	initial begin
				 		 @(posedge CLOCK_50);
		reset <= 1;  @(posedge CLOCK_50); 
		reset <= 0; repeat(1050) @(posedge CLOCK_50);
						
		$stop; // End the simulation.
	end 
endmodule