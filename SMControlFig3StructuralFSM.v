//==============================================================================
// SMControlFig3Structural.v (works, modified from original proposed design)
// Control Unit for Sequential Multiplier (Fig3)
// with Variables Exposed in Declaration for FSM Extraction
//==============================================================================

module SMControl(
    input [3:0]  reset_state,

    // External Inputs for Flow
    input wire          clk, // clock
    input wire          rst, // reset
    input wire          start, // start

    // Inputs from Datapath
    // multiplier register (4)
    input wire [3:0]    mr, // 4 bit multiplier register

    // Controller Outputs to Datapath
    output          mdld, // load multiplicand register
    output          mrld, // load multiplier register
    output          rsload, // load running sum register
    output          rsclear, // clear running sum register
    output          rsshr, // shift running sum register

    output reg [3:0]    s,
    output wire [3:0] n,
    output done
);

//----------------------------------------------------------------------
// FSM States
//----------------------------------------------------------------------
   
    // reg [3:0] s; // s = state
    // // refer to them as s[3], s[2], s[1], s[0], etc
    // wire [3:0] n; // n = next_state

//----------------------------------------------------------------------
// Output Combinational Logic
//----------------------------------------------------------------------
   
    assign rsclear = (~s[3]) & (~s[2]) & (~s[1]) & (s[0]);
    assign mdld = (~s[3]) & (~s[2]) & (~s[1]) & (s[0]);
    assign mrld = (~s[3]) & (~s[2]) & (~s[1]) & (s[0]);

    assign rsload = (~s[3]) & (s[2]) & (s[1]) & (s[0]) & (mr[0])
                  | (s[3]) & (~s[2]) & (~s[1]) & (~s[0]) & (mr[1])
                  | (s[3]) & (~s[2]) & (~s[1]) & (s[0]) & (mr[2])
                  | (s[3]) & (~s[2]) & (s[1]) & (~s[0]) & (mr[3]);
    assign rsshr = (~s[3]) & (~s[2]) & (s[1]) & (s[0])
                 | (~s[3]) & (s[2]) & (~s[1]) & (~s[0])
                 | (~s[3]) & (s[2]) & (~s[1]) & (s[0])
                 | (~s[3]) & (s[2]) & (s[1]) & (~s[0]);

//----------------------------------------------------------------------
// Next State Combinational Logic
//----------------------------------------------------------------------

    assign n[3] = (~s[3]) & (~s[2]) & (s[1]) & (s[0])
                | (~s[3]) & (s[2]) & (~s[1]) & (~s[0])
                | (~s[3]) & (s[2]) & (~s[1]) & (s[0]);

    assign n[2] = (~s[3]) & (~s[2]) & (s[1]) & (~s[0])
                | (s[3]) & (~s[2]) & (~s[1]) & (~s[0])
                | (s[3]) & (~s[2]) & (~s[1]) & (s[0])
                | (s[3]) & (~s[2]) & (s[1]) & (~s[0]);

    assign n[1] = (~s[3]) & (~s[2]) & (~s[1]) & (s[0])
                | (~s[3]) & (~s[2]) & (s[1]) & (~s[0])
                | (~s[3]) & (s[2]) & (s[1]) & (s[0])
                | (~s[3]) & (s[2]) & (~s[1]) & (s[0])
                | (s[3]) & (~s[2]) & (s[1]) & (~s[0]);

    assign n[0] = (~s[3]) & (~s[2]) & (~s[1]) & (~s[0]) & (start)
                | (~s[3]) & (~s[2]) & (s[1]) & (~s[0])
                | (~s[3]) & (s[2]) & (s[1]) & (s[0])
                | (~s[3]) & (s[2]) & (~s[1]) & (~s[0])
                | (s[3]) & (~s[2]) & (~s[1]) & (s[0]);

//----------------------------------------------------------------------
// State Update Sequential Logic
//----------------------------------------------------------------------

     always @(posedge clk) begin
		if (rst) begin
			s <= reset_state; // 4'b0000;
		end
		else begin
			s <= n;
		end
	end

endmodule