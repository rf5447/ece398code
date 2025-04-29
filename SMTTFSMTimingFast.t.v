//===============================================================================
// Reachable-Only Testbench for n-bit Controller (Timing Experiments)
// setup code adapted from ECE206 testing material and Marina's code
// algorithm and implementation of algorithm is my own
//===============================================================================
`timescale 1ns/100ps

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

module SMControlTest;
    parameter NUM_BITS = 14;
    parameter STATE_WIDTH = $clog2(3 * NUM_BITS + 3); // $clog2(2 * NUM_BITS + 3);// choose between the two depending on the controller

	// Local Vars
	reg clk = 0;
	reg rst = 0;
	reg start = 0;
	reg [NUM_BITS - 1:0] mr = 4'd0;
    wire [2 * NUM_BITS - 1:0] product;
    wire mdld;
    wire mrld;
    wire rsload;
    wire rsclear;
    wire rsshr;
    wire [STATE_WIDTH - 1:0] s;
    wire [STATE_WIDTH - 1:0] n;
    wire done;

	reg [STATE_WIDTH - 1:0] reset_state = 4'd0;

	// Error Counts
	reg [7:0] errors = 0;

	// VCD Dump
	initial begin
		$dumpfile("SMTTInputTimingFast.vcd");
		$dumpvars;
	end

MultiplierControl #(
    .WIDTH(NUM_BITS),
    .STATE_WIDTH(STATE_WIDTH)
) SMControl (
    .reset_state    (reset_state),

    // External Inputs for Flow
    .clk            (clk), // clock
    .rst            (rst), // reset
    .start          (start), // start

    // Inputs from Datapath
    // multiplier register (4)
    .mr             (mr), // 4 bit multiplier register

    // Controller Outputs to Datapath
    .mdld           (mdld), // load multiplicand register
    .mrld           (mrld), // load multiplier register
    .rsload         (rsload), // load running sum register
    .rsclear        (rsclear), // clear running sum register
    .rsshr          (rsshr), // shift running sum register

    .s              (s),
    .n              (n),
    .done           (done)
);

    integer multiplier;
    integer st;
    integer rs;

    reg [(2 ** STATE_WIDTH) - 1:0] to_visit; // track states to visit
    reg [(2 ** STATE_WIDTH) - 1:0] visited; // bitmask for visited states

	// Main Test Logic
    initial begin
        
        visited = 0; // mark all states as unvisited
        to_visit = 0; // mark all states as unvisited
        to_visit[0] = 1;  // mark state 0 as to_visit
        
        // while haven't visited all states yet
        while ((visited != to_visit)) begin

            for (rs = 0; rs <= ((2 ** STATE_WIDTH) - 1); rs = rs + 1) begin

                if (to_visit[rs] & ~visited[rs]) begin // if transitions from this state should be tested

                    // change the RESET_STATE for the control unit
                    $display("\nTest with rs = %b", rs);
                    `SET(reset_state, rs);

                    // cycle through all (multiplier, start) combinations
                    for (multiplier = 0; multiplier <= ((2 ** NUM_BITS) - 1); multiplier = multiplier + 1) begin
                       
                        $display("\nMULTIPLIER = %b", multiplier);

                        for (st = 0; st <= 1; st = st + 1) begin
                            
                            $display("\nSTART = %b", st);

                            `SET(mr, multiplier);
                            `SET(start, st);
                            `SET(rst, 1);
                            `CLOCK;

                            `SET(rst, 0);
                            `CLOCK;

                            // if next_state hasn't been visited, add it to list of states to visit
                            if (~to_visit[s]) begin
                                to_visit[s] = 1'b1;
                            end
                           
                        end
                    end

                    visited[reset_state] = 1'b1; // mark as visited
  
                    if ((visited == to_visit)) begin
                        $display("\nAll reachable states have been tested.");
                        $finish;
                    end
                end
            end
        end
    end

endmodule