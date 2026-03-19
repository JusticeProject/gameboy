`include "defines.v"

module alu_a_mux(
    // tells us which item to pass through the multiplexer
    input wire [`ALU_A_IDX:0] alu_a_mux_sel,
    
    // the various sources of input data
    input wire [7:0] a_reg,
    input wire [15:0] hl_reg,
    input wire [15:0] din_reg,
    input wire [15:0] pc_reg,
    
    // the output data
    output reg [15:0] alu_a_mux_out
);

//*************************************************************************************************

always @*
begin
    // TODO: parallel_case?
    case (alu_a_mux_sel)
        `ALU_A_A:
            alu_a_mux_out = {a_reg, 8'h00};
        `ALU_A_HL:
            alu_a_mux_out = hl_reg;
        `ALU_A_DIN:
            alu_a_mux_out = din_reg;
        `ALU_A_PC:
            alu_a_mux_out = pc_reg;
        default:
            alu_a_mux_out = 16'h0000;
    endcase
end

endmodule
