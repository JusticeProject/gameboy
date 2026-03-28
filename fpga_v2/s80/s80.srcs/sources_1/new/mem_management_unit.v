`include "defines.v"

module mem_management_unit(
    input wire clk,
    
    input wire mem_wr_enable,
    input wire [15:0] mem_addr,
    input wire [7:0] mem_data_wr,
    output wire [7:0] mem_data_rd
);

//*************************************************************************************************

// There are 16 address lines.
// bit 15 indicates RAM vs ROM.
// bits 14:0 indicate which address in the RAM or ROM.
// There are 2^15 addresses in RAM and 2^15 addresses in ROM.
localparam NUM_ADDRESSES = 2**15;

//*************************************************************************************************

// signals/registers
reg [15:0] addr_reg;

// ROM data
reg [7:0] rom_instructions [0:NUM_ADDRESSES-1];

// RAM
// TODO: sometimes have issues with it not inferring a BRAM. Don't just look at the Report, also check the Log.
reg [7:0] ram [0:NUM_ADDRESSES-1];

// the rom.mem file needs to be added as a source
initial
begin
    $readmemh("rom.mem", rom_instructions, 0);
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// TODO: read enable signal or read strobe signal?

// clock
always @(posedge clk)
begin
    if ((mem_wr_enable) && (mem_addr[15]))
        ram[mem_addr[14:0]] <= mem_data_wr;
    
    addr_reg <= mem_addr;
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// output logic
assign mem_data_rd = (addr_reg[15]) ? ram[addr_reg[14:0]] : rom_instructions[addr_reg[14:0]];

endmodule
