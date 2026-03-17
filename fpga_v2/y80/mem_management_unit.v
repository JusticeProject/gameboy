module mem_management_unit(
    input wire clkc,
    input wire mem_wr,
    input wire [15:0] mem_addr_in,
    input wire [7:0] mem_data_in,
    output wire [7:0] mem_data_out
    );

// The 16th address line will always indicate RAM vs ROM
localparam USABLE_ADDR_LINES = 15;
localparam NUM_ADDRESSES = 2**USABLE_ADDR_LINES;

// signals/registers
reg is_ram;
reg [USABLE_ADDR_LINES-1:0] addr_reg;

// ROM data
reg [7:0] rom_instructions [0:NUM_ADDRESSES-1];

// RAM
reg [7:0] ram [0:NUM_ADDRESSES-1];

// the rom.mem file needs to be added as a source
initial
begin
    $readmemh("rom.mem", rom_instructions, 0);
end

// clock
always @(posedge clkc)
begin
    if (mem_addr_in[15])
        begin
            is_ram <= 1'b1;
            if (mem_wr)
                ram[mem_addr_in[USABLE_ADDR_LINES-1:0]] <= mem_data_in;
        end
    else
        begin
            is_ram <= 1'b0;
        end
    
    addr_reg <= mem_addr_in[USABLE_ADDR_LINES-1:0];
end

// output logic
assign mem_data_out = (is_ram) ? ram[addr_reg] : rom_instructions[addr_reg];

endmodule
