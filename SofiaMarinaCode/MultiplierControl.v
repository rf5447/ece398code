//==============================================================================
// Control Module for Sequential Multiplier
//==============================================================================

module MultiplierControl #(parameter WIDTH = 4)(
	// External Inputs
	input   clk,           // Clock
    input   rst,           // reset
	input   start,

    // External Output
    output reg productDone,

	// Outputs to Datapath
	output reg  rsload,
	output reg  rsclear,
	output reg  rsshr,
    output reg  mrld,
    output reg  mdld,

	// Inputs from Datapath
    input [WIDTH - 1:0] multiplierReg
);
	// Local Vars
	// # of states = 2 * WIDTH + 3
    localparam STATE_WIDTH = $clog2(3 * WIDTH + 3);
    localparam STATE_NOTSTART = 4'd0;
	localparam STATE_START = 4'd1;
    localparam STATE_END = (3 * WIDTH) + 2;

    reg [STATE_WIDTH - 1:0] state;
	reg [STATE_WIDTH - 1:0] next_state;

//----------------------------------------------------------------------
// Output Combinational Logic
//----------------------------------------------------------------------
   
    always @( * ) begin
        // default values for outputs to prevent implicit latching
        // should all be 0 unless in a special state that makes them 1
        mdld = 1'b0; // load multiplicand register
        mrld = 1'b0; // load multiplier register
        rsload = 1'b0; // load running sum register
        rsclear = 1'b0; // clear running sum register
        rsshr = 1'b0;

        // Output Logic
        // same for all multipliers
        if (state == STATE_NOTSTART) begin
            // no changes in control signals
        end
        // same for all multipliers
        else if (state == STATE_START) begin
            mdld = 1'b1; // load 4 bit multiplicand register
            mrld = 1'b1; // load 4 bit multiplier register
            rsclear = 1'b1; // clear 8 bit running sum register
        end
        // same for all multipliers
        else if (state == STATE_END) begin
            rsshr = 1'b1;
            productDone = 1'b1;
        end
        // 2, 5, 8, 11
        else if (state % 3 == 2) begin
            rsshr = 1'b1;
        end
        // 3, 6, 9, 12
        else if (state % 3 == 0) begin
            // no changes in control signals
        end
        // 4, 7, 10, 13
        else begin
            rsload = 1'b1; 
        end
    end

//----------------------------------------------------------------------
// Next State Combinational Logic
//----------------------------------------------------------------------
   
    always @( * ) begin
        // default value for next state is current state
		next_state = state;

        // Next State Logic
        // same for all multipliers
        if (state == STATE_NOTSTART) begin
            if (start) begin
                next_state = STATE_START;
            end
            else begin
                next_state = STATE_NOTSTART;
            end
        end
        // same for all multipliers
        else if (state == STATE_START) begin
            next_state = state + 1;
        end
        // same for all multipliers
        else if (state == STATE_END) begin
            next_state = STATE_NOTSTART;
        end
        // 2, 5, 8, 11
        else if (state % 3 == 2) begin
            if (multiplierReg[((state - 2) / 3)]) begin
                next_state = state + 2;
            end
            else begin
                next_state = state + 1;
            end
        end
        // 3, 6, 9, 12
        else if (state % 3 == 0) begin
            next_state = state + 2;
        end
        // 4, 7, 10, 13
        else begin
            next_state = state + 1;
        end
    end

//----------------------------------------------------------------------
// State Update Sequential Logic
//----------------------------------------------------------------------

    always @(posedge clk) begin
		if (rst) begin
			state <= STATE_NOTSTART;
		end
		else begin
			state <= next_state;
			// // $display(next_state);
		    // $display("current state: ", state);
			// $display("next state: ", next_state);
		end
	end

endmodule