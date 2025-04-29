//==============================================================================
// SMControlFig3.v (works, modified from original proposed design)
// Control Unit for Sequential Multiplier (Fig3)
// with Bitwidths as Input Parameters (Referenced Marina's code)
//==============================================================================

module MultiplierControl #(
    parameter WIDTH = 4,      // width of multiplier (mr)
    parameter STATE_WIDTH = 4 // width for FSM state variables (s and n)
)(
    input [STATE_WIDTH-1:0]  reset_state,
    
    // External Inputs
	input   clk,           // clock
    input   rst,           // reset
	input   start,

	// Inputs from Datapath
    input [WIDTH - 1:0] mr,

	// Outputs to Datapath
	output reg  rsload,
	output reg  rsclear,
	output reg  rsshr,
    output reg  mrld,
    output reg  mdld,

    output reg [STATE_WIDTH-1:0] s,
    output reg [STATE_WIDTH-1:0] n,
    output reg done
);
//----------------------------------------------------------------------
// FSM States
//----------------------------------------------------------------------
   
    localparam STATE_NOTSTART = 4'd0;
	localparam STATE_START = 4'd1;
    localparam STATE_NOTHING = 4'd2;
    localparam STATE_END = 2 * (WIDTH + 1);

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
        if (s == STATE_NOTSTART) begin
            // no changes in control signals
        end
        // same for all multipliers
        else if (s == STATE_START) begin
            mdld = 1'b1; // load 4 bit multiplicand register
            mrld = 1'b1; // load 4 bit multiplier register
            rsclear = 1'b1; // clear 8 bit running sum register
        end
        // same for all multipliers
        else if (s == STATE_END) begin
            rsshr = 1'b1;
            done = 1'b1;
        end
        else if (s == STATE_NOTHING) begin
            // no changes in control signals
        end
        // odd
        else if (s[0] == 1) begin
            if (mr[((s - 1) >> 1) - 1]) begin
                rsload = 1'b1;
            end
            else begin
                // nothing
            end
        end
        // even
        else begin
            rsshr = 1'b1; 
        end
    end

//----------------------------------------------------------------------
// Next State Combinational Logic
//----------------------------------------------------------------------
   
    always @( * ) begin
        // default value for next state is current state
		n = s;

        // Next State Logic
        // same for all multipliers
        if (s == STATE_NOTSTART) begin
            if (start) begin
                n = STATE_START;
            end
            else begin
                n = STATE_NOTSTART;
            end
        end
        // same for all multipliers
        else if (s == STATE_START) begin
            n = s + 1;
        end
        // same for all multipliers
        else if (s == STATE_END) begin
            n = STATE_NOTSTART;
        end
        else begin
            n = s + 1;
        end
    end

//----------------------------------------------------------------------
// State Update Sequential Logic
//----------------------------------------------------------------------

    always @(posedge clk) begin
		if (rst) begin
			s <= reset_state; // STATE_NOTSTART;
		end
		else begin
			s <= n;
		end
	end

endmodule