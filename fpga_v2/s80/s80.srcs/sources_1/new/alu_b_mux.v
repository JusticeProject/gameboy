`include "defines.v"

module alu_b_mux(
    // tells us which item to pass through the multiplexer
    input wire [`ALUB_IDX:0] alu_b_mux_sel,
    
    // the various sources of input data
    input wire [15:0] din_reg,

    // the output data
    output reg [15:0] alu_b_mux_out
);

//*************************************************************************************************

always @*
begin
    // TODO: parallel_case?
    case (alu_b_mux_sel)
        `ALUB_ZERO:
            alu_b_mux_out = 16'h0000;
        `ALUB_ONE_LOW:
            alu_b_mux_out = 16'h0001;
        `ALUB_ONE_HIGH:
            alu_b_mux_out = 16'h0100;
        `ALUB_DIN:
            alu_b_mux_out = din_reg;
        `ALUB_DIN0_SIGN_EXT:
            // Could use the replication feature but this seems clearer. We output din0 but sign extended to fill 16 bits.
            alu_b_mux_out = {din_reg[7], din_reg[7], din_reg[7], din_reg[7], din_reg[7], din_reg[7], din_reg[7], din_reg[7], din_reg[7:0]};
        default:
            alu_b_mux_out = 16'h0000;
    endcase
end

endmodule
