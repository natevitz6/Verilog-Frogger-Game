module score(clock, reset, win, lose, game_over, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, in);
	input logic clock, reset;
	output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	input logic win, lose, in;
	output logic game_over; 
	logic [3:0] points;

	
	always_ff @(posedge clock) begin
		if (reset || points == 4'b0000 && in) begin
			HEX5 <= 7'b1111111;
			HEX4 <= 7'b1111111;
			HEX3 <= 7'b1111111;
			HEX2 <= 7'b1111111;
			HEX1 <= 7'b1111111;
			HEX0 <= 7'b1000000;
			game_over <= 0;
			points <= 4'b0000;
		end
		else if (lose) begin
			points <= 4'b0000;
			HEX5 <= 7'b1000001;
			HEX4 <= 7'b1111111;
			HEX3 <= 7'b1000111;
			HEX2 <= 7'b1000000;
			HEX1 <= 7'b0010010;
			HEX0 <= 7'b0000110;
		end
		else if (win && points == 4'b0000) begin
			HEX5 <= 7'b1111111;
			HEX4 <= 7'b1111111;
			HEX3 <= 7'b1111111;
			HEX2 <= 7'b1111111;
			HEX1 <= 7'b1111111;
			HEX0 <= 7'b1111001;
			points <= points + 4'b0001;
		end
		else if (win && points == 4'b0001) begin
			HEX0 <= 7'b0100100;
			points <= points + 4'b0001;
		end
		else if (win && points == 4'b0010) begin
			HEX0 <= 7'b0110000;
			points <= points + 4'b0001;
		end
		else if (win && points == 4'b0011) begin
			HEX0 <= 7'b0011001;
			points <= points + 4'b0001;
		end
		else if (win && points == 4'b0100) begin
			HEX0 <= 7'b0010010;
			points <= points + 4'b0001;
		end
		else if (win && points == 4'b0101) begin
			HEX0 <= 7'b0000010;
			points <= points + 4'b0001;
		end
		else if (win && points == 4'b0110) begin
			HEX0 <= 7'b1111000;
			points <= points + 4'b0001;
		end
		else if (win && points == 4'b0111) begin
			HEX0 <= 7'b0000000;
			points <= points + 4'b0001;
		end
		else if (win && points == 4'b1000) begin
			HEX0 <= 7'b0011000;
			points <= points + 4'b0001;
		end
		else if (win && points == 4'b1001) begin
			HEX5 <= 7'b1000000;
			HEX4 <= 7'b0000010;
			HEX3 <= 7'b0001110;
			HEX2 <= 7'b0001000;
			HEX1 <= 7'b1000000;
			HEX0 <= 7'b0000010;
			points <= 4'b0000;
			game_over <= 1;
		end
	end
endmodule



module score_testbench();
	logic CLOCK_50;
	logic reset;
	logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	logic win, lose, game_over, in;
	
	score dut (CLOCK_50, reset, win, lose, game_over, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, in);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	
	// Test the design.
	initial begin
													repeat(1) @(posedge CLOCK_50);
		reset <= 1; 							repeat(5) @(posedge CLOCK_50); // Always reset FSMs at start
		reset <= 0; win <= 0; lose <= 0; in <= 0; repeat(5) @(posedge CLOCK_50);
		
		for (int i = 0; i < 11; i++) begin
			win <= 1; repeat (1) @(posedge CLOCK_50);
			win <= 0; repeat (3) @(posedge CLOCK_50);
		end
		reset <= 1; win <= 0; lose <= 0; in <= 0; repeat(5) @(posedge CLOCK_50);
		reset <= 0; repeat(5) @(posedge CLOCK_50);
		lose <= 1; repeat(1) @(posedge CLOCK_50);
		lose <= 0; repeat(5) @(posedge CLOCK_50);
		in <= 1; repeat(1) @(posedge CLOCK_50);
														 
		$stop; // End the simulation.
	end
	
endmodule