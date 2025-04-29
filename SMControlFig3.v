//==============================================================================
// SMControlFig3.v (works, modified from original proposed design)
// Control Unit for Sequential Multiplier (Fig3)
//==============================================================================

module SMControl(
    // External Inputs for Flow
    input wire          clk, // clock
    input wire          rst, // reset
    input wire          start, // start

    // Inputs from Datapath
    // multiplier register (4)
    input wire [3:0]    mr, // 4 bit multiplier register

    // Controller Outputs to Datapath
    output reg          mdld, // load multiplicand register
    output reg          mrld, // load multiplier register
    output reg          rsload, // load running sum register
    output reg          rsclear, // clear running sum register
    output reg          rsshr // shift running sum register
);

//----------------------------------------------------------------------
// FSM States
//----------------------------------------------------------------------
   
    localparam STATE_NOTSTART = 4'b0000; // 0
    localparam STATE_START = 4'b0001; // 1
    localparam STATE_MR0 = 4'b0010; // 2
    localparam STATE_MR1 = 4'b0011; // 3
    localparam STATE_MR2 = 4'b0100; // 4
    localparam STATE_MR3 = 4'b0101; // 5
    localparam STATE_END = 4'b0110; // 6
    localparam STATE_RSLOAD0 = 4'b0111; // 7
    localparam STATE_RSLOAD1 = 4'b1000; // 8
    localparam STATE_RSLOAD2 = 4'b1001; // 9
    localparam STATE_RSLOAD3 = 4'b1010; // 10

    reg [3:0] state, next_state;

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
        case (state)
            STATE_NOTSTART: begin
                // no changes in control signals
            end
            STATE_START: begin
                mdld = 1'b1; // load 4 bit multiplicand register
                mrld = 1'b1; // load 4 bit multiplier register
                rsclear = 1'b1; // clear 8 bit running sum register
            end
            STATE_MR0: begin
                // no changes in control signals
            end
            STATE_MR1: begin
                rsshr = 1'b1; // shift 8 bit running sum register 1 bit to the right
            end
            STATE_MR2: begin
                rsshr = 1'b1; // shift 8 bit running sum register 1 bit to the right
            end
            STATE_MR3: begin
                rsshr = 1'b1; // shift 8 bit running sum register 1 bit to the right
            end
            STATE_END: begin
                rsshr = 1'b1; // shift 8 bit running sum register 1 bit to the right
            end
            STATE_RSLOAD0: begin
                if (mr[0]) begin
                    rsload = 1'b1; // load 8 bit product register
                end
                else begin
                    rsload = 1'b0;
                end
            end
            STATE_RSLOAD1: begin
                if (mr[1]) begin
                    rsload = 1'b1; // load 8 bit product register
                end
                else begin
                    rsload = 1'b0;
                end
            end
            STATE_RSLOAD2: begin
                if (mr[2]) begin
                    rsload = 1'b1; // load 8 bit product register
                end
                else begin
                    rsload = 1'b0;
                end
            end
            STATE_RSLOAD3: begin
                if (mr[3]) begin
                    rsload = 1'b1; // load 8 bit product register
                end
                else begin
                    rsload = 1'b0;
                end
            end
        endcase
    end

//----------------------------------------------------------------------
// Next State Combinational Logic
//----------------------------------------------------------------------
   
    always @( * ) begin
        // default value for next state is current state
		next_state = state;

        // Next State Logic
        case (state)
            STATE_NOTSTART: begin
                if (start) begin
                    next_state = STATE_START;
                end
                else begin
                    next_state = STATE_NOTSTART;
                end
            end
            STATE_START: begin
                next_state = STATE_MR0; 
            end
            STATE_MR0: begin
                next_state = STATE_RSLOAD0;
            end
            STATE_MR1: begin
                next_state = STATE_RSLOAD1;
            end
            STATE_MR2: begin
                next_state = STATE_RSLOAD2;
            end
            STATE_MR3: begin
                next_state = STATE_RSLOAD3;
            end
            STATE_END: begin
                next_state = STATE_NOTSTART;
            end
            STATE_RSLOAD0: begin
                next_state = STATE_MR1;
            end
            STATE_RSLOAD1: begin
                next_state = STATE_MR2;
            end
            STATE_RSLOAD2: begin
                next_state = STATE_MR3;
            end
            STATE_RSLOAD3: begin
                next_state = STATE_END;
            end
        endcase
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
			// $display(next_state);
		    $display("current state: ", state);
			$display("next state: ", next_state);
		end
	end

endmodule