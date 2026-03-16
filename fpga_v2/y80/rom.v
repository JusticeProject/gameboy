module rom(
    input wire clkc,
    input wire [15:0] mem_addr_in,
    output wire [7:0] mem_data_out
    );

// signals/registers
reg [2:0] addr_reg;

// ROM data
reg [7:0] rom_instructions [0:7];

// the rom.mem file needs to be added as a source
initial
begin
    $readmemh("rom.mem", rom_instructions, 0, 7);
end

// clock
always @(posedge clkc)
    addr_reg <= mem_addr_in[2:0];

// output logic
assign mem_data_out = rom_instructions[addr_reg];

endmodule
