`include "defines.v"

module alu_a_mux(
    // tells us which item to pass through the multiplexer
    input wire [`ALUA_IDX:0] alu_a_mux_sel,
    
    // the various sources of input data
    input wire [7:0] a_reg,
    input wire [7:0] b_reg,
    input wire [7:0] c_reg,
    input wire [7:0] d_reg,
    input wire [7:0] e_reg,
    input wire [7:0] h_reg,
    input wire [7:0] l_reg,
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
        `ALUA_A:
            alu_a_mux_out = {8'h00, a_reg};
        `ALUA_B:
            alu_a_mux_out = {8'h00, b_reg};
        `ALUA_C:
            alu_a_mux_out = {8'h00, c_reg};
        `ALUA_BC:
            alu_a_mux_out = {b_reg, c_reg};
        `ALUA_D:
            alu_a_mux_out = {8'h00, d_reg};
        `ALUA_E:
            alu_a_mux_out = {8'h00, e_reg};
        `ALUA_DE:
            alu_a_mux_out = {d_reg, e_reg};
        `ALUA_H:
            alu_a_mux_out = {8'h00, h_reg};
        `ALUA_L:
            alu_a_mux_out = {8'h00, l_reg};
        `ALUA_HL:
            alu_a_mux_out = {h_reg, l_reg};
        `ALUA_DIN:
            alu_a_mux_out = din_reg;
        `ALUA_PC:
            alu_a_mux_out = pc_reg;
        default:
            alu_a_mux_out = 16'h0000;
    endcase
end

endmodule
