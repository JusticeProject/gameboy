`include "defines.v"

module datapath(
    input wire clk,
    input wire resetb,
    
    // control signals
    input wire pc_out_enable,
    input wire ld_instr_enable,
    input wire inc_pc_enable,
    
    // status signals
    output reg [7:0] instr_reg,
    
    // memory signals
    input wire [7:0] mem_data_rd,
    output wire mem_wr_enable,
    output reg [15:0] mem_addr,
    output wire [7:0] mem_data_wr
);

//*************************************************************************************************

// internal signals/registers
// instr_reg was declared above as an output
reg [15:0] pc_reg; // the main program counter
wire [15:0] pc_next;

//*************************************************************************************************

// respond to control signals

//*************************************************************************************************

// reset or increment pc
always @(negedge resetb, posedge clk)
begin
    if (!resetb)
        pc_reg <= 16'h0000;
    else if (inc_pc_enable)
        pc_reg <= pc_next;
end

// TODO: use () ? : 
// if we are assigning a different value to PC.
// In the always block above we can use
// else if (inc_pc_enable || ld_pc_enable)
assign pc_next = pc_reg + 1;

//*************************************************************************************************

// output PC onto the mem_addr bus
// TODO: put a memory address onto the bus for a memory fetch
always @(negedge resetb, posedge clk)
begin
    if (!resetb)
        mem_addr <= 16'h0000;
    else if (pc_out_enable)
        mem_addr <= pc_reg;
end

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

// TODO: mem_wr_enable
assign mem_wr_enable = 1'b0;
// TODO: mem_data_wr
assign mem_data_wr = 8'h00;

endmodule
