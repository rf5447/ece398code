//===============================================================================
// Testbench Module for SM (Sequential Multiplier)
// some code adapted from ECE206 testing material and Marina's code
//===============================================================================
`timescale 1ns/100ps

`include "SM.v"

`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t[FAILURE]:%s", (MSG)); \
			errors = errors + 1;               \
		end                                    \
	end #0

`define SET(VAR, VALUE) $display("Setting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

`define CLOCK $display("Pressing uclk..."); #1; clk = 1; #1; clk = 0; #1

`define SHOW_STATE(STATE) $display("\nEntering State: %s\n-----------------------------------", STATE)

module MultiplierTest;
    parameter NUM_BITS = 4;

	// Local Vars
	reg clk = 0;
	reg rst = 0;
	reg start = 0;
	reg [NUM_BITS - 1:0] multiplier = 4'd0;
	reg [NUM_BITS - 1:0] multiplicand = 4'd0;
    wire [2 * NUM_BITS - 1:0] product;

	// Error Counts
	reg [7:0] errors = 0;

	// VCD Dump
	initial begin
		$dumpfile("SMTest.vcd");
		$dumpvars;
	end

	// Multiplier Module //#(NUM_BITS) removed this from between Multiplier and multipliertester
	SequentialMultiplier multipliertester(
        .clk    (clk),
		.rst    (rst),
        .start  (start),
        .multiplier (multiplier),
        .multiplicand (multiplicand),
        .product (product)
	);

    integer i;
	// Main Test Logic
	initial begin
        $display("\nTest 1");
        `SET(multiplier, 13)
        `SET(multiplicand, 15)
		`SET(rst, 1);
		`CLOCK;
		`SET(rst, 0);
        `SET(start, 1);
        `CLOCK;
        `SET(start, 0);
        for (i = 0; i < 100; i = i + 1) begin
            `CLOCK;
        end
        `ASSERT_EQ(product, 195, "Product is incorrect");
        $display("%b", product);

        $display("\nTest 2");
        `SET(multiplier, 14)
        `SET(multiplicand, 9)
		`SET(rst, 1);
		`CLOCK;
		`SET(rst, 0);
        `SET(start, 1);
        `CLOCK;
        `SET(start, 0);
        for (i = 0; i < 10; i = i + 1) begin
            `CLOCK;
        end
        `ASSERT_EQ(product, 126, "Product is incorrect");
        $display("%b", product);

        $display("\nTest 3");
        `SET(multiplier, 1)
        `SET(multiplicand, 15)
		`SET(rst, 1);
		`CLOCK;
		`SET(rst, 0);
        `SET(start, 1);
        `CLOCK;
        `SET(start, 0);
        for (i = 0; i < 100; i = i + 1) begin
            `CLOCK;
        end
        `ASSERT_EQ(product, 15, "Product is incorrect");
        $display("%b", product);

        $display("\nTest 4");
        `SET(multiplier, 8)
        `SET(multiplicand, 0)
		`SET(rst, 1);
		`CLOCK;
		`SET(rst, 0);
        `SET(start, 1);
        `CLOCK;
        `SET(start, 0);
        for (i = 0; i < 100; i = i + 1) begin
            `CLOCK;
        end
        `ASSERT_EQ(product, 0, "Product is incorrect");
        $display("%b", product);

        $display("\nTest 5");
        `SET(multiplier, 4)
        `SET(multiplicand, 13)
		`SET(rst, 1);
		`CLOCK;
		`SET(rst, 0);
        `SET(start, 1);
        `CLOCK;
        `SET(start, 0);
        for (i = 0; i < 100; i = i + 1) begin
            `CLOCK;
        end
        `ASSERT_EQ(product, 52, "Product is incorrect");
        $display("%b", product);

        $display("\n");

		$display("\nTESTS COMPLETED (%d FAILURES)", errors);
		$finish;
	end

endmodule