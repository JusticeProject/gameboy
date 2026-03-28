`include "defines.v"

module top(
    input clk,
    input resetb
);

// output control signals
wire [`MEM_ADDR_OUT_IDX:0] mem_addr_out_enable;
wire a_out_enable;
wire mem_wr_enable;

// load control signals
wire ld_instr_enable;
wire [1:0] ld_din_enable;
wire [`LD_REG_IDX:0] ld_reg_enable;

// ALU control signals
wire [`ALUA_IDX:0] alu_a_mux_sel;
wire [`ALUB_IDX:0] alu_b_mux_sel;
wire [`ALU_OP_IDX:0] alu_op_sel;

// flag control signals
wire z_flag_enable;

// status signals
wire [7:0] instr_reg;
wire z_flag_reg;

// memory signals
wire [15:0] mem_addr;
wire [7:0] mem_data_wr;
wire [7:0] mem_data_rd;

//*************************************************************************************************

// TODO: instantiate the clocking wizard.
// TODO: Use clock gating to reduce power? See Digital VLSI Design on YouTube, lecture 4e

// instantiate the control unit
control CONTROL_UNIT (.clk(clk), .resetb(resetb),
                      .mem_addr_out_enable(mem_addr_out_enable), .a_out_enable(a_out_enable), .mem_wr_enable(mem_wr_enable), 
                      .ld_instr_enable(ld_instr_enable), .ld_din_enable(ld_din_enable), .ld_reg_enable(ld_reg_enable),
                      .alu_a_mux_sel(alu_a_mux_sel), .alu_b_mux_sel(alu_b_mux_sel), .alu_op_sel(alu_op_sel),
                      .z_flag_enable(z_flag_enable),
                      .instr_reg(instr_reg), .z_flag_reg(z_flag_reg));

// instantiate the datapath unit
datapath DATAPATH_UNIT (.clk(clk), .resetb(resetb), 
                        .mem_addr_out_enable(mem_addr_out_enable), .a_out_enable(a_out_enable),
                        .ld_instr_enable(ld_instr_enable), .ld_din_enable(ld_din_enable), .ld_reg_enable(ld_reg_enable),
                        .alu_a_mux_sel(alu_a_mux_sel), .alu_b_mux_sel(alu_b_mux_sel), .alu_op_sel(alu_op_sel),
                        .z_flag_enable(z_flag_enable),
                         .instr_reg(instr_reg), .z_flag_reg(z_flag_reg),
                        .mem_data_rd(mem_data_rd), .mem_addr(mem_addr), .mem_data_wr(mem_data_wr));

// instantiate the MMU
mem_management_unit MMU (.clk(clk), 
                         .mem_wr_enable(mem_wr_enable), .mem_addr(mem_addr), .mem_data_wr(mem_data_wr), .mem_data_rd(mem_data_rd));

endmodule
