//==============================================================================
// SMDatapath.v
// Sequential Multiplier
//==============================================================================

module SequentialMultiplier(
	// External Inputs
	input wire          clk, // clock
    input wire          rst, // reset
	input wire          start, // start

    input wire [3:0] multiplier,
    input wire [3:0] multiplicand,

    // External Outputs
    output wire [7:0]   product
);

//----------------------------------------------------------------------
// Interconnect Wires
//----------------------------------------------------------------------

    wire [3:0] mr;

    wire mdld;
    wire mrld;
    wire rsload;
    wire rsclear;
    wire rsshr;


//----------------------------------------------------------------------
// Control Module
//----------------------------------------------------------------------

    SMControl control(
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
        .rsshr          (rsshr) // shift running sum register
    );

//----------------------------------------------------------------------
// Datapath Module
//----------------------------------------------------------------------

    SMDatapath datapath(
        // External Inputs for Flow
        .clk            (clk), // clock
        .rst            (rst), // reset
        .start          (start), // start

        // External Inputs for Computation
        .multiplier     (multiplier), // 4 bit multiplier
        .multiplicand   (multiplicand), // 4 bit multiplicand

        // Signals from Controller
        .mdld           (mdld), // load multiplicand register
        .mrld           (mrld), // load multiplier register
        .rsload         (rsload), // load running sum register
        .rsclear        (rsclear), // clear running sum register
        .rsshr          (rsshr), // shift running sum register

        // Datapath Outputs to Controller
        // multiplier register (4)
        .mr             (mr), // 4 bit multiplier register

        // Datapath Outputs NOT to Controller
        // running sum register (8)
        .product        (product) // 8 bit product
    );

endmodule