//==============================================================================
// SMDatapath.v
// Datapath for 4-bit Sequential Multiplier
//==============================================================================

module SMDatapath(
    // External Inputs for Flow
    input wire          clk, // clock
    input wire          rst, // reset
    input wire          start, // start

    // External Inputs for Computation
    input wire [3:0]    multiplier, // 4 bit multiplier
    input wire [3:0]    multiplicand, // 4 bit multiplicand

    // Signals from Controller
    input wire          mdld, // load multiplicand register
    input wire          mrld, // load multiplier register
    input wire          rsload, // load running sum register
    input wire          rsclear, // clear running sum register
    input wire          rsshr, // shift running sum register

    // Datapath Outputs to Controller
    // multiplier register (4)
    output reg [3:0]    mr, // 4 bit multiplier register

    // Datapath Outputs NOT to Controller
    // running sum register (8)
    output reg [7:0]    product // 8 bit product
);

//----------------------------------------------------------------------
// Local Registers
//----------------------------------------------------------------------
    
    // multiplicand register (4)
    reg [3:0] multiplicandr;
    reg [1:0] count = 2'd0;
    reg [4:0] sum = 5'b0;

//----------------------------------------------------------------------
// Sequential Logic
//----------------------------------------------------------------------

always @(posedge clk) begin
    // if (rst) begin
    //     product <= 8'b0; // initializing 8 bit register to 0
    //     multiplicandr <= 4'b0;
    //     mr <= 4'b0;
    //     $display("\nrstdatapath");
    // end
    // else begin
       // $display("\nelsedatapath");

        // on the clock
        // if load 
        if (mdld) begin // load multiplicand register
            multiplicandr <= multiplicand;
        end
        if (mrld) begin // load multiplier register
            mr <= multiplier;
        end
        if (rsclear) begin // clear running sum register
            product <= 8'b0; // clearing 8 bit register to 0
        end
        if (rsload) begin // load running sum register
            product [3:0] <= product [3:0];
            product [7:4] <= product [7:4] + multiplicandr; // (multiplicandr & mr[count]);

            //test <= (multiplicandr & mr[count]);
            //$display("test");
            //$display("%b", test);
            sum <= product [7:4] + multiplicandr;
            //test1 <= product[7:4];
            // count <= (count == 2'd3) ? 2'd0 : count + 1; // reset to 0 after 3 . . . 2'd0 -> 2'd1 -> 2'd2 -> 2'd3
        end
        if (rsshr) begin // shift running sum register
            product <= {sum[4], product [7:1]};
            sum <= 5'b0;
        end
    // end
    // $display("%b", product);

end

//----------------------------------------------------------------------
// Combinational Logic
//----------------------------------------------------------------------



//----------------------------------------------------------------------
// 4 bit adder
//----------------------------------------------------------------------


// partial product: AND current multiplicand bit with every bit in the multiplier to yield the partial product; 
// if current multiplicand is 1, and creates a copy of multiplier as partial product, if multiplicand is 0, AND creates 0 as partial prodict
// each step: adds partial product for current multiplicand bit to leftmost four bits of running sum, and shifts the running sum one bit to the right; shifting a 0 into the leftmost bit
// 2 cycles per bit: one to load reg with partial product if 1 and other to shift (no need to load if its a 0?)


endmodule