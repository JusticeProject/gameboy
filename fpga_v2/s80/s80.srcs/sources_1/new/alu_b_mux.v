`include "defines.v"

module alu_b_mux(
    // tells us which item to pass through the multiplexer
    input wire [`ALU_B_IDX:0] alu_b_mux_sel,
    
    // the various sources of input data

    // the output data
    output reg [15:0] alu_b_mux_out
);

//*************************************************************************************************

always @*
begin
    // TODO: parallel_case?
    case (alu_b_mux_sel)
        `ALU_B_ZERO:
            alu_b_mux_out = 16'h0000;
        `ALU_B_ONE_LOW:
            alu_b_mux_out = 16'h0001;
        `ALU_B_ONE_HIGH:
            alu_b_mux_out = 16'h0100;
        default:
            alu_b_mux_out = 16'h0000;
    endcase
end

endmodule
