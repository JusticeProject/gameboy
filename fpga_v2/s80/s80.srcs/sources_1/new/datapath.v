`include "defines.v"

module datapath(
    input wire clk,
    input wire resetb,
    
    // control signals
    input wire pc_out_enable,
    input wire ld_instr_enable,
    input wire inc_pc_enable,
    
    // status signals
    output reg instr_reg,
    
    // memory signals
    input wire [7:0] mem_data_rd,
    output reg mem_wr_enable,
    output wire [15:0] mem_addr,
    output wire [7:0] mem_data_wr
);

//*************************************************************************************************

//*************************************************************************************************

endmodule
