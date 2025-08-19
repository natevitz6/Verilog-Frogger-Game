module inputChange(clock, reset, in, player);
	input logic clock, reset, in;
	output logic player;
	logic firstDFF, secondDFF;
	
	enum {released, pressed} ps, ns;
	
	//First two DFFs keep input correct through change, no metastability
	//Reset sends value to true (key not pressed)
	always_ff @(posedge clock) begin
		if (reset)
			firstDFF <= 1'b1;
		else
			firstDFF <= in;
	end
	
	always_ff @(posedge clock) begin
      if (reset)
			secondDFF <= 1'b1;
		else
			secondDFF <= firstDFF;
	end
	
	always_ff @(posedge clock) begin
		 if (reset) 
            ps <= released;
        else 
            ps <= ns;
	end
	
	//Next state logic
	always_comb begin
		case(ps)
			released: 
				if (secondDFF == 0)
					ns = pressed;
				else 
					ns = released;
			pressed:
				if (secondDFF == 1)
					ns = released;
				else 
					ns = pressed;
		endcase
	end
	
	//Output logic, only output true at instant of change to false input
	always_comb begin
        if (ps == released && secondDFF == 0) 
            player = 1;
        else 
            player = 0; 
    end
	
endmodule

module inputChange_testbench();
	logic CLOCK_50;
	logic [6:0] HEX0;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic reset;
	
	inputChange dut (CLOCK_50, reset, KEY[0], LEDR[0]);

		// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	
	// Test the design.
	initial begin
									  @(posedge CLOCK_50);
		reset <= 1; 			  @(posedge CLOCK_50); // Always reset FSMs at start
		reset <= 0; KEY[0] = 1; @(posedge CLOCK_50);
		            KEY[0] = 0; @(posedge CLOCK_50);
						KEY[0] = 0; @(posedge CLOCK_50);
						KEY[0] = 0; @(posedge CLOCK_50);
						KEY[0] = 0; @(posedge CLOCK_50);
						KEY[0] = 0; @(posedge CLOCK_50);
						KEY[0] = 1; @(posedge CLOCK_50);
						KEY[0] = 1; @(posedge CLOCK_50);
						KEY[0] = 1; @(posedge CLOCK_50);
						KEY[0] = 1; @(posedge CLOCK_50);
						KEY[0] = 0; @(posedge CLOCK_50);
						KEY[0] = 0; @(posedge CLOCK_50);
		$stop; // End the simulation.
	end 
endmodule