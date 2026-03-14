module top(
    input clk,
    input sclk_async,
    input mosi_async,
    input is_rom_async,
    output ready,
    output [7:0] leds,
    output store
    );

// !!**!!**
// TODO: create 50MHz clock if using an FPGA board that is programmed by Vivado
// !!**!!**

// signals
wire sclk_sync, mosi_sync, is_rom_sync;
wire sclk_pos_edge;

// instantiate the synchronizers
synchronizer_2_stage synchronizer_2_stage_sclk (.clk(clk), .async(sclk_async), .sync(sclk_sync));
synchronizer_2_stage synchronizer_2_stage_mosi (.clk(clk), .async(mosi_async), .sync(mosi_sync));
synchronizer_2_stage synchronizer_2_stage_is_rom (.clk(clk), .async(is_rom_async), .sync(is_rom_sync));

// instantiate edge detection
edge_detector edge_detector_sclk (.clk(clk), .input_signal(sclk_sync), .pos_edge(sclk_pos_edge));

// instantiate the SPI receiver
spi_receiver_w_timeout spi_receiver_unit (.clk(clk), .sclk_pos_edge(sclk_pos_edge), .mosi(mosi_sync), .is_rom(is_rom_sync), 
    .ready(ready), .data_out(leds), .store(store));

endmodule
