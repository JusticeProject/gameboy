`include "defines.v"

module mem_management_unit(
    input wire clk,
    
    input wire mem_wr_enable,
    input wire [15:0] mem_addr,
    input wire [7:0] mem_data_wr,
    output wire [7:0] mem_data_rd
);

//*************************************************************************************************

// The 16th address line will always indicate RAM vs ROM
localparam USABLE_ADDR_LINES = 15;
localparam NUM_ADDRESSES = 2**USABLE_ADDR_LINES;

//*************************************************************************************************

// signals/registers
reg is_ram;
reg [USABLE_ADDR_LINES-1:0] addr_reg;

// ROM data
reg [7:0] rom_instructions [0:NUM_ADDRESSES-1];

// RAM
// TODO: sometimes have issues with it not inferring a BRAM
reg [7:0] ram [0:NUM_ADDRESSES-1];

// the rom.mem file needs to be added as a source
initial
begin
    $readmemh("rom.mem", rom_instructions, 0);
end

//*************************************************************************************************

// clock
always @(posedge clk)
begin
    if ((mem_wr_enable) && (mem_addr[15]))
        ram[mem_addr[USABLE_ADDR_LINES-1:0]] <= mem_data_wr;
    
    addr_reg <= mem_addr[USABLE_ADDR_LINES-1:0];
    /*if (mem_addr[15])
        if (mem_wr_enable)
            ram[mem_addr[USABLE_ADDR_LINES-1:0]] <= mem_data_wr;
        else
            mem_data_rd <= ram[mem_addr[USABLE_ADDR_LINES-1:0]];
    else
        mem_data_rd <= rom_instructions[mem_addr[USABLE_ADDR_LINES-1:0]];*/
        
end

//*************************************************************************************************

// output logic
assign mem_data_rd = (mem_addr[15]) ? ram[addr_reg] : rom_instructions[addr_reg];

endmodule
