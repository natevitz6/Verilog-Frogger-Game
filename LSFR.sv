module LSFR (clock, reset, out, start);
	input logic clock, reset;
	input logic [5:0] start;
	output logic [5:0] out;
	logic d1, d2, d3, d4, d5, d6;
	
	//random 5 bit number created
	always_ff @(posedge clock) begin
		if (reset) d1 <= start[5];
		else d1 <= (!d5 && d6 || d5 && !d6);
	end
	
	always_ff @(posedge clock) begin
		if (reset) d2 <= start[4];
		else d2 <= d1;
	end
	
	always_ff @(posedge clock) begin
		if (reset) d3 <= start[3];
		else d3 <= d2;
	end
	
	always_ff @(posedge clock) begin
		if (reset) d4 <= start[2];
		else d4 <= d3;
	end
	
	always_ff @(posedge clock) begin
		if (reset) d5 <= start[1];
		else d5 <= d4;
	end
	
	always_ff @(posedge clock) begin
		if (reset) d6 <= start[0];
		else d6 <= d5;
	end
	
	always_ff @(posedge clock) begin
		out <= {d1, d2, d3, d4, d5, d6};
	end
endmodule

module LSFR_testbench();
	logic CLOCK_50;
	logic reset;
	logic [5:0] out;
	
	LSFR dut (CLOCK_50, reset, out);
	
		// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	
	// Test the design.
	initial begin
						@(posedge CLOCK_50);
		reset <= 1; @(posedge CLOCK_50); // Always reset FSMs at start
		reset <= 0; repeat (50) @(posedge CLOCK_50);
						
		$stop; // End the simulation.
	end 
endmodule