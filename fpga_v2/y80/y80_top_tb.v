// time unit / time precision
`timescale 1ns / 10ps

module y80_top_tb();

// input signals to the uut
reg clkc = 0;
reg clearb = 0;
reg resetb = 0;

// output signals of the uut
wire t1;

// Generate clock signal
always
begin
    // delay for 10 time units (half a clock period), then change the clock
    #10
    clkc = ~clkc;
end

// instantiate the uut
y80_top uut (.clkc(clkc), .clearb(clearb), .resetb(resetb), .t1(t1));

// give it some input
initial
begin
    clearb = 1'b0;
    resetb = 1'b0;
    #20
    clearb = 1'b1;
    resetb = 1'b1;
    #800
    clearb = 1'b0;
    resetb = 1'b0; // need to end with a statement instead of a delay
end

endmodule
