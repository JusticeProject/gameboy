module top(
    input clk,
    input resetb,
    output [7:0] leds
    );

// signals
reg [3:0] counter_reg;
wire [3:0] counter_next;

// ROM data
reg [7:0] rom [0:15];

// the rom.mem file needs to be added as a source
initial
begin
    $readmemh("rom.mem", rom, 0, 15);
end

// clock
always @(negedge resetb, posedge clk)
    if (~resetb)
        counter_reg <= 0;
    else
        counter_reg <= counter_next;

// next state logic
assign counter_next = counter_reg + 1;

// output logic
assign leds = rom[counter_reg];

endmodule
