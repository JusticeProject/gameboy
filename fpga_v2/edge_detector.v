module edge_detector(
    input wire clk,
    input wire input_signal,
    output wire pos_edge
    );

// signals
reg delay_reg;

// capture the current value
always @(posedge clk)
    delay_reg <= input_signal;

// output logic, if we registered a 0 but the input is 1 then we output a 1
assign pos_edge = (~delay_reg) & input_signal;

endmodule
