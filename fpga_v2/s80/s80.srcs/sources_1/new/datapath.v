`include "defines.v"

module datapath(
    input wire clk,
    input wire resetb,
    
    // output control signals
    input wire [`MEM_ADDR_OUT_IDX:0] mem_addr_out_enable,
    input wire a_out_enable,
    
    // load control signals
    input wire ld_instr_enable,
    input wire [1:0] ld_din_enable,
    input wire [`LD_REG_IDX:0] ld_reg_enable,
    
    // ALU control signals
    input wire [`ALUA_IDX:0] alu_a_mux_sel,
    input wire [`ALUB_IDX:0] alu_b_mux_sel,
    input wire [`ALU_OP_IDX:0] alu_op_sel,
    
    // flag control signals
    input wire z_flag_enable,
    
    // status signals
    output reg [7:0] instr_reg,
    output wire z_flag_reg,
    
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
reg [15:0] sp_reg; // the stack pointer

// The registers. _reg is the current value, _next is the value it will get at the next rising edge of the clock
reg [7:0] a_reg, a_next;
reg [7:0] f_reg, f_next;
reg [7:0] b_reg, b_next;
reg [7:0] c_reg, c_next;
reg [7:0] d_reg, d_next;
reg [7:0] e_reg, e_next;
reg [7:0] h_reg, h_next;
reg [7:0] l_reg, l_next;

// input registers that capture the data on mem_data_rd
reg [7:0] din0, din1;

// next vaue for mem_addr bus
reg [15:0] mem_addr_next;

// signals to/from the ALU
wire [15:0] alu_a_in, alu_b_in;
wire z_flag_next;
wire [15:0] alu_out_bus;

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// next value for mem_addr bus
always @*
begin
    case (mem_addr_out_enable)
        `PC_OUT:
            mem_addr_next = pc_reg;
        `DE_OUT:
            mem_addr_next = {d_reg, e_reg};
        `HL_OUT:
            mem_addr_next = {h_reg, l_reg};
        default:
            mem_addr_next = mem_addr; // by default it will stay the same
    endcase
end

//*************************************************************************************************

// output an address onto the mem_addr bus
always @(negedge resetb, posedge clk)
begin
    if (!resetb)
        mem_addr <= 16'h0000;
    else
        mem_addr <= mem_addr_next;
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
    else
        begin
            if (ld_din_enable[0])
                din0 <= mem_data_rd;
                
            if (ld_din_enable[1])
                din1 <= mem_data_rd;
        end
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// next value for af, use flags from the ALU
always @*
begin
    a_next = a_reg; // defaults are set to the current value
    f_next = f_reg;
    
    if (ld_reg_enable[`UPD_F])
        begin
            // the flags are ZNHC----
            if (z_flag_enable)
                f_next[7] = z_flag_next;
                
            if (ld_reg_enable[`LD_A])
                a_next = alu_out_bus[7:0];
        end
    else if (ld_reg_enable[`LD_A] && ld_reg_enable[`LD_F])
        begin
            a_next = alu_out_bus[15:8];
            f_next = alu_out_bus[7:0];
        end
    else if (ld_reg_enable[`LD_A])
        a_next = alu_out_bus[7:0];
end

//*************************************************************************************************

// next value for bc
always @*
begin
    b_next = b_reg; // defaults are set to the current value
    c_next = c_reg;

    if (ld_reg_enable[`LD_B] && ld_reg_enable[`LD_C])
        begin
            b_next = alu_out_bus[15:8];
            c_next = alu_out_bus[7:0];
        end
    else if (ld_reg_enable[`LD_B])
        b_next = alu_out_bus[7:0];
    else if (ld_reg_enable[`LD_C])
        c_next = alu_out_bus[7:0];
end

//*************************************************************************************************

// next value for de
always @*
begin
    d_next = d_reg; // defaults are set to the current value
    e_next = e_reg;
    
    if (ld_reg_enable[`LD_D] && ld_reg_enable[`LD_E])
        begin
            d_next = alu_out_bus[15:8];
            e_next = alu_out_bus[7:0];
        end
    else if (ld_reg_enable[`LD_D])
        d_next = alu_out_bus[7:0];
    else if (ld_reg_enable[`LD_E])
        e_next = alu_out_bus[7:0];
end

//*************************************************************************************************

// next value for hl
always @*
begin
    h_next = h_reg; // defaults are set to the current value
    l_next = l_reg;
    
    if (ld_reg_enable[`LD_H] && ld_reg_enable[`LD_L])
        begin
            h_next = alu_out_bus[15:8];
            l_next = alu_out_bus[7:0];
        end
    else if (ld_reg_enable[`LD_H])
        h_next = alu_out_bus[7:0];
    else if (ld_reg_enable[`LD_L])
        l_next = alu_out_bus[7:0];
end

//*************************************************************************************************

// load main registers
always @(negedge resetb, posedge clk)
begin
    if (!resetb)
        begin
            a_reg <= 8'h00;
            f_reg <= 8'h00;
            b_reg <= 8'h00;
            c_reg <= 8'h00;
            d_reg <= 8'h00;
            e_reg <= 8'h00;
            h_reg <= 8'h00;
            l_reg <= 8'h00;
        end
    else
        begin
            a_reg <= a_next;
            f_reg <= f_next;
            b_reg <= b_next;
            c_reg <= c_next;
            d_reg <= d_next;
            e_reg <= e_next;
            h_reg <= h_next;
            l_reg <= l_next;
        end
end

//*************************************************************************************************

// send flags to the control unit
assign z_flag_reg = f_reg[7];

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// load the PC and SP
always @(negedge resetb, posedge clk)
begin
    // TODO: need to start at h0100 for GameBoy ROM
    if (!resetb)
        begin
            pc_reg <= 16'h0000;
            sp_reg <= 16'hFFFE;
        end
    else 
        begin
            if (ld_reg_enable[`LD_PC])
                pc_reg <= alu_out_bus;
            
            if (ld_reg_enable[`LD_SP])
                sp_reg <= alu_out_bus;
        end
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// instantiate the ALU modules
alu_a_mux ALU_A_MUX_UNIT (.alu_a_mux_sel(alu_a_mux_sel), 
                          .a_reg(a_reg), .b_reg(b_reg), .c_reg(c_reg), .d_reg(d_reg), .e_reg(e_reg), .h_reg(h_reg), .l_reg(l_reg), 
                          .din_reg({din1, din0}), .pc_reg(pc_reg), .sp_reg(sp_reg),
                          .alu_a_mux_out(alu_a_in));

alu_b_mux ALU_B_MUX_UNIT (.alu_b_mux_sel(alu_b_mux_sel),
                          .din_reg({din1, din0}), .a_reg(a_reg),
                          .alu_b_mux_out(alu_b_in));

alu_math ALU_MATH_UNIT (.alu_a_in(alu_a_in), .alu_b_in(alu_b_in), .alu_op_sel(alu_op_sel), .z_flag_next(z_flag_next), .alu_math_out(alu_out_bus));


endmodule
