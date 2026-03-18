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
    // TODO: combine these
    input wire ld_a_enable,
    input wire ld_hl_enable,
    
    // misc control signals
    input wire inc_pc_enable,
    
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
wire [15:0] pc_next;

// the registers
reg [7:0] a_reg;
reg [15:0] hl_reg;

reg [7:0] din0, din1;

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
                a_reg <= din1;
            else if (ld_hl_enable)
                hl_reg <= {din1, din0};
        end
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// reset or increment pc
always @(negedge resetb, posedge clk)
begin
    // TODO: need to start at h0100 for GameBoy ROM
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


endmodule
