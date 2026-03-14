
module synchronizer_2_stage(
    input wire clk,
    input wire async,
    output reg sync
    );

// signal declarations
reg mid;

// first stage
always @(posedge clk)
    mid <= async;

// second stage
always @(posedge clk)
    sync <= mid;

endmodule
