`include "defines.v"

module datapath(
    input wire clk,
    input wire resetb,
    
    // output control signals
    input wire pc_out_enable,
    input wire hl_out_enable,
    input wire a_out_enable,
    
    // load control signals
    input wire ld_instr_enable,
    input wire [1:0] ld_din_enable,
    input wire [`LD_REG_IDX:0] ld_reg_enable,
    
    // ALU control signals
    input wire [`ALU_A_IDX:0] alu_a_mux_sel,
    input wire [`ALU_B_IDX:0] alu_b_mux_sel,
    input wire [`ALU_OP_IDX:0] alu_op_sel,
    
    // status signals
    output reg [7:0] instr_reg,
    
    // memory signals
    input wire [7:0] mem_data_rd,
    output reg [15:0] mem_addr,
    output reg [7:0] mem_data_wr
);

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// internal signals/registers
// instr_reg was declared above as an output
reg [15:0] pc_reg; // the main program counter

// the registers
reg [7:0] a_reg;
reg [15:0] hl_reg;

// control signals for loading the registers
wire ld_a_enable;
wire ld_hl_enable;
wire ld_pc_enable;

reg [7:0] din0, din1;

// signals to/from the ALU
wire [15:0] alu_a_in, alu_b_in;
wire [15:0] alu_out_bus;

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// output an address onto the mem_addr bus
always @(negedge resetb, posedge clk)
begin
    if (!resetb)
        mem_addr <= 16'h0000;
    else if (pc_out_enable)
        mem_addr <= pc_reg;
    else if (hl_out_enable)
        mem_addr <= hl_reg;
end

//*************************************************************************************************

// send data out to RAM
always @(negedge resetb, posedge clk)
begin
    if (!resetb)
        mem_data_wr <= 8'h00;
    else if (a_out_enable)
        mem_data_wr <= a_reg;
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// load the instruction register
always @(negedge resetb, posedge clk)
begin
    if (!resetb)
        instr_reg <= 8'h00;
    else if (ld_instr_enable)
        instr_reg <= mem_data_rd;
end

//*************************************************************************************************

// load input data from the bus
always @(negedge resetb, posedge clk)
begin
    if (!resetb)
        begin
            din0 <= 8'h00;
            din1 <= 8'h00;
        end
    else if (ld_din_enable[0])
        din0 <= mem_data_rd;
    else if (ld_din_enable[1])
        din1 <= mem_data_rd;
end

//*************************************************************************************************

assign ld_a_enable = ld_reg_enable[`LD_A];
assign ld_hl_enable = ld_reg_enable[`LD_HL];
assign ld_pc_enable = ld_reg_enable[`LD_PC];

//*************************************************************************************************

// load main registers
always @(negedge resetb, posedge clk)
begin
    if (!resetb)
        begin
            a_reg <= 8'h00;
            hl_reg <= 16'h0000;
        end
    else
        begin
            if (ld_a_enable)
                a_reg <= alu_out_bus[15:8];
            if (ld_hl_enable)
                hl_reg <= alu_out_bus;
        end
end

//*************************************************************************************************

// load the PC
always @(negedge resetb, posedge clk)
begin
    // TODO: need to start at h0100 for GameBoy ROM
    if (!resetb)
        pc_reg <= 16'h0000;
    else if (ld_pc_enable)
        pc_reg <= alu_out_bus;
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// instantiate the ALU modules
alu_a_mux ALU_A_MUX_UNIT (.alu_a_mux_sel(alu_a_mux_sel), 
                          .a_reg(a_reg), .hl_reg(hl_reg), .din_reg({din1, din0}), .pc_reg(pc_reg),
                          .alu_a_mux_out(alu_a_in));

alu_b_mux ALU_B_MUX_UNIT (.alu_b_mux_sel(alu_b_mux_sel),
                          .alu_b_mux_out(alu_b_in));

alu_math ALU_MATH_UNIT (.alu_a_in(alu_a_in), .alu_b_in(alu_b_in), .alu_op_sel(alu_op_sel), .alu_math_out(alu_out_bus));


endmodule
