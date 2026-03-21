// time unit / time precision
`timescale 1ns / 10ps

module top_tb();

// input signals to the uut
reg clk = 0;
reg resetb = 0;

// Generate clock signal
always
begin
    // delay for 10 time units (half a clock period), then change the clock
    #10
    clk = ~clk;
end

// instantiate the uut
top uut (.clk(clk), .resetb(resetb));

// give it some input
initial
begin
    resetb = 1'b0;
    #20
    resetb = 1'b1;
    #4000
    resetb = 1'b0;
end

endmodule