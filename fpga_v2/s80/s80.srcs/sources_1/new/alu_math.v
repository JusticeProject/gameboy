`include "defines.v"

module alu_math(
    input wire [15:0] alu_a_in,
    input wire [15:0] alu_b_in,
    
    input wire [`ALU_OP_IDX:0] alu_op_sel,
    
    output reg [15:0] alu_math_out
);

//*************************************************************************************************

always @*
begin
    // TODO: parallel_case?
    case (alu_op_sel)
        `ALU_A_PASS:
            alu_math_out = alu_a_in;
        `ALU_B_PASS:
            alu_math_out = alu_b_in;
        `ALU_ADD_WORD:
            alu_math_out = alu_a_in + alu_b_in;
        // TODO: need to handle flags
        `ALU_ADD_LO_BYTE:
            alu_math_out = alu_a_in + alu_b_in;
        `ALU_ADD_HI_BYTE:
            alu_math_out = alu_a_in + alu_b_in;
        `ALU_SUB_WORD:
            alu_math_out = alu_a_in - alu_b_in;
        `ALU_SUB_LO_BYTE:
            alu_math_out = alu_a_in - alu_b_in;
        `ALU_SUB_HI_BYTE:
            alu_math_out = alu_a_in - alu_b_in;
        default:
            alu_math_out = 16'h0000;
    endcase
end

endmodule
