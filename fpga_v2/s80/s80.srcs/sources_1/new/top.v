`include "defines.v"

module top(
    input clk,
    input resetb
);

// output control signals
wire pc_out_enable;
wire hl_out_enable;
wire a_out_enable;
wire mem_wr_enable;

// load control signals
wire ld_instr_enable;
wire [1:0] ld_din_enable;
// TODO: combine these
wire ld_a_enable;
wire ld_hl_enable;

// misc control signals
wire inc_pc_enable;

// status signals
wire [7:0] instr_reg;

// memory signals
wire [15:0] mem_addr;
wire [7:0] mem_data_wr;
wire [7:0] mem_data_rd;

//*************************************************************************************************

// instantiate the control unit
control CONTROL_UNIT (.clk(clk), .resetb(resetb),
                      .pc_out_enable(pc_out_enable), .hl_out_enable(hl_out_enable), .a_out_enable(a_out_enable), .mem_wr_enable(mem_wr_enable), 
                      .ld_instr_enable(ld_instr_enable), .ld_din_enable(ld_din_enable), .ld_a_enable(ld_a_enable), .ld_hl_enable(ld_hl_enable),
                      .inc_pc_enable(inc_pc_enable), 
                      .instr_reg(instr_reg));

// instantiate the datapath unit
datapath DATAPATH_UNIT (.clk(clk), .resetb(resetb), 
                        .pc_out_enable(pc_out_enable), .hl_out_enable(hl_out_enable), .a_out_enable(a_out_enable),
                        .ld_instr_enable(ld_instr_enable), .ld_din_enable(ld_din_enable), .ld_a_enable(ld_a_enable), .ld_hl_enable(ld_hl_enable),
                        .inc_pc_enable(inc_pc_enable),
                         .instr_reg(instr_reg),
                        .mem_data_rd(mem_data_rd), .mem_addr(mem_addr), .mem_data_wr(mem_data_wr));

// instantiate the MMU
mem_management_unit MMU (.clk(clk), 
                         .mem_wr_enable(mem_wr_enable), .mem_addr(mem_addr), .mem_data_wr(mem_data_wr), .mem_data_rd(mem_data_rd));

endmodule
