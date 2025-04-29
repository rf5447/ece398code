//==============================================================================
// SMControlFig4Structural.v
// Control Unit for Sequential Multiplier (Fig4)
//==============================================================================

`include "SMDefines.vh"

// `define RESET_STATE 4'b0000

module SMControl(
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
    output          rsshr // shift running sum register
);

//----------------------------------------------------------------------
// FSM States
//----------------------------------------------------------------------
   
    reg [3:0] s; // s = state
    // refer to them as s[3], s[2], s[1], s[0], etc
    wire [3:0] n; // n = next_state
    wire done;

//----------------------------------------------------------------------
// Output Combinational Logic
//----------------------------------------------------------------------
   
    assign rsclear = (~s[3]) & (~s[2]) & (~s[1]) & (s[0]);
    assign mdld = (~s[3]) & (~s[2]) & (~s[1]) & (s[0]);
    assign mrld = (~s[3]) & (~s[2]) & (~s[1]) & (s[0]);

    assign rsload = (~s[3]) & (s[2]) & (s[1]) & (s[0])
                  | (s[3]) & (~s[2]) & (~s[1]) & (~s[0])
                  | (s[3]) & (~s[2]) & (~s[1]) & (s[0])
                  | (s[3]) & (~s[2]) & (s[1]) & (~s[0]);
    assign rsshr = (~s[3]) & (~s[2]) & (s[1]) & (s[0])
                 | (~s[3]) & (s[2]) & (~s[1]) & (~s[0])
                 | (~s[3]) & (s[2]) & (~s[1]) & (s[0])
                 | (~s[3]) & (s[2]) & (s[1]) & (~s[0]);

//----------------------------------------------------------------------
// Next State Combinational Logic
//----------------------------------------------------------------------

    assign n[3] = (~s[3]) & (~s[2]) & (s[1]) & (~s[0]) & (~mr[0])
                | (~s[3]) & (~s[2]) & (s[1]) & (s[0])
                | (~s[3]) & (s[2]) & (~s[1]) & (~s[0])
                | (~s[3]) & (s[2]) & (~s[1]) & (s[0]);

    assign n[2] = (~s[3]) & (~s[2]) & (s[1]) & (~s[0]) & (mr[0])
                | (~s[3]) & (~s[2]) & (s[1]) & (s[0]) & (~mr[1])
                | (s[3]) & (s[2]) & (~s[1]) & (~s[0])
                | (s[3]) & (~s[2]) & (~s[1]) & (~s[0])
                | (~s[3]) & (s[2]) & (~s[1]) & (~s[0]) & (~mr[2])
                | (s[3]) & (s[2]) & (~s[1]) & (s[0])
                | (s[3]) & (~s[2]) & (~s[1]) & (s[0])
                | (~s[3]) & (s[2]) & (~s[1]) & (s[0]) & (~mr[3])
                | (s[3]) & (s[2]) & (s[1]) & (~s[0])
                | (s[3]) & (~s[2]) & (s[1]) & (~s[0]);

    assign n[1] = (~s[3]) & (~s[2]) & (~s[1]) & (s[0])
                | (~s[3]) & (~s[2]) & (s[1]) & (~s[0])
                | (s[3]) & (~s[2]) & (s[1]) & (s[0])
                | (~s[3]) & (s[2]) & (s[1]) & (s[0])
                | (~s[3]) & (s[2]) & (~s[1]) & (s[0])
                | (s[3]) & (s[2]) & (s[1]) & (~s[0])
                | (s[3]) & (~s[2]) & (s[1]) & (~s[0]);

    assign n[0] = (~s[3]) & (~s[2]) & (~s[1]) & (~s[0]) & (start)
                | (~s[3]) & (~s[2]) & (s[1]) & (~s[0])
                | (s[3]) & (~s[2]) & (s[1]) & (s[0])
                | (~s[3]) & (s[2]) & (s[1]) & (s[0])
                | (~s[3]) & (s[2]) & (~s[1]) & (~s[0])
                | (s[3]) & (s[2]) & (~s[1]) & (s[0])
                | (s[3]) & (~s[2]) & (~s[1]) & (s[0]);

    assign done = (~s[3]) & (s[2]) & (s[1]) & (~s[0]);


//----------------------------------------------------------------------
// State Update Sequential Logic
//----------------------------------------------------------------------

     always @(posedge clk) begin
		if (rst) begin
			s <= `RESET_STATE; // 4'b0000; 
		end
		else begin
			s <= n;
		end
	end

endmodule