module DE1_SoC (CLOCK_50, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, KEY, LEDR, SW, GPIO_1);
	input logic CLOCK_50; // 50MHz clock.
	input logic [3:0] KEY; // True when not pressed, False when pressed
	input logic [9:0] SW;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
   output logic [35:0] GPIO_1;
	
	logic reset;
	logic [15:0][5:0] out; // used to hold outputs of LSFR for different redRow modules
	logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
   logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
	
	assign RedPixels[15] = 16'b0 ;
	
	logic L, R, U, D, in; // player inputs, in is just an OR of all inputs
	logic win, lose, game_over;
	assign in = L || R || U || D;
	assign reset = SW[9] || game_over || lose; // resets game, player goes to start, score goes to 0 
	
	logic [31:0] div_clk;
	parameter which_clock = 14;
	clock_divider cdiv (.clock(CLOCK_50), .reset(reset), .divided_clocks(div_clk));
	logic clkSelect;
	
	//assign clkSelect = CLOCK_50; // for simulation
	assign clkSelect = div_clk[which_clock]; // for board
	
	// input for each of the four keys is inverted and converted to impulses
	inputChange user_inputR (.clock(clkSelect), .reset(SW[9]), .in(KEY[0]), .player(R));
	inputChange user_inputD (.clock(clkSelect), .reset(SW[9]), .in(KEY[1]), .player(D));
	inputChange user_inputU (.clock(clkSelect), .reset(SW[9]), .in(KEY[2]), .player(U));
	inputChange user_inputL (.clock(clkSelect), .reset(SW[9]), .in(KEY[3]), .player(L));
	
	// each row of RedPixels is controlled by its own module
	// odd rows are always off if hard mode is off
	// each row has a different starting mode/frequency based on LSFR output
	genvar i;
	generate
		for(i=0; i<15; i++) begin : redPixels
			wire [5:0] start = 6'b101110 + i ;
			wire odd = ((i % 2) != 0);
			LSFR randomize (.clock(clkSelect), .reset(SW[9]), .out(out[i]), .start(start));		
			redRow rr (.clock(clkSelect), .reset(reset), .RedPixels(RedPixels[i]), .out(out[i]), .odd(odd), .hard(SW[8]));
		end
	endgenerate
	
	// all green leds are controlled by the same module
	// user inputs mpve it left, right, up, or down, restarts to bottom middle after reset
	green greenLights (.clock(clkSelect), .reset(reset), .L(L), .R(R), .U(U), .D(D), .GreenPixels(GrnPixels), .RedPixels(RedPixels), .lose(lose), .win(win));
	
	
	// HEX displays player score, goes from 0 to 10, displays U LOSE if player loses
	score scoreDisplay (.clock(clkSelect), .reset(SW[9]), .win(win), .lose(lose), .game_over(game_over), .HEX5(HEX5), .HEX4(HEX4), .HEX3(HEX3), .HEX2(HEX2), .HEX1(HEX1), .HEX0(HEX0), .in(in));
	
	/* Standard LED Driver instantiation - set once and 'forget it'. 
	   See LEDDriver.sv for more info. Do not modify unless you know what you are doing! */
	LEDDriver Driver (.CLK(clkSelect), .RST(reset), .EnableCount(1'b1), .RedPixels(RedPixels), .GrnPixels(GrnPixels), .GPIO_1(GPIO_1));
	
endmodule

module DE1_SoC_testbench();
	logic CLOCK_50;
	logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	logic [9:0] LEDR;
	logic [9:0] SW;
	logic [3:0] KEY;
	logic [35:0] GPIO_1;
	
	DE1_SoC dut (CLOCK_50, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, KEY, LEDR, SW, GPIO_1);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	
	// Test the design.
	initial begin
																							 repeat(1) @(posedge CLOCK_50);
		SW[9] <= 1; SW[8] <= 0;												  	 	 repeat(3) @(posedge CLOCK_50); // Always reset FSMs at start
		SW[9] <= 0; KEY[3] <= 1; KEY[2] <= 1; KEY[1] <= 1; KEY[0] <= 1; repeat(30) @(posedge CLOCK_50);
		for (int i = 0; i < 20; i++) begin
			KEY[3] <= 1; KEY[2] <= 0; KEY[1] <= 1; KEY[0] <= 1; repeat(5) @(posedge CLOCK_50);
			KEY[3] <= 1; KEY[2] <= 1; KEY[1] <= 1; KEY[0] <= 1; repeat(10) @(posedge CLOCK_50);
		end
		SW[9] <= 1; @(posedge CLOCK_50);
		SW[9] <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 20; i++) begin
			KEY[3] <= 1; KEY[2] <= 1; KEY[1] <= 1; KEY[0] <= 0; repeat(5) @(posedge CLOCK_50);
			KEY[3] <= 1; KEY[2] <= 1; KEY[1] <= 1; KEY[0] <= 1; repeat(10) @(posedge CLOCK_50);
		end
		SW[9] <= 1; @(posedge CLOCK_50);
		SW[9] <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 20; i++) begin
			KEY[3] <= 0; KEY[2] <= 1; KEY[1] <= 1; KEY[0] <= 1; repeat(5) @(posedge CLOCK_50);
			KEY[3] <= 1; KEY[2] <= 1; KEY[1] <= 1; KEY[0] <= 1; repeat(10) @(posedge CLOCK_50);
		end
		SW[9] <= 1; SW[8] <= 0; @(posedge CLOCK_50);
		SW[9] <= 0; 				@(posedge CLOCK_50);
		for (int i = 0; i < 20; i++) begin
			KEY[3] <= 1; KEY[2] <= 0; KEY[1] <= 1; KEY[0] <= 1; repeat(5) @(posedge CLOCK_50);
			KEY[3] <= 1; KEY[2] <= 1; KEY[1] <= 1; KEY[0] <= 1; repeat(10) @(posedge CLOCK_50);
		end
											 
		$stop; // End the simulation.
	end
	
endmodule