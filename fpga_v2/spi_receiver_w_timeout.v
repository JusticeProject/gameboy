module spi_receiver_w_timeout(
    input wire clk,
    input wire sclk_pos_edge,
    input wire mosi,
    input wire is_rom,
    output reg ready,
    output wire [7:0] data_out,
    output wire store
    );

// signals
reg [1:0] state_reg, state_next;
reg [3:0] bit_counter_reg, bit_counter_next;
reg [24:0] timeout_counter_reg, timeout_counter_next;
reg [7:0] shift_reg, shift_next;
reg [7:0] data_reg, data_next;
reg store_reg, store_next;

// states in the state machine
localparam 
    idle      = 2'b00,
    capturing = 2'b01,
    done      = 2'b10;

// constants
localparam BIT_COUNTER_MAX = 8;
localparam TIMEOUT_COUNTER_MAX = 25000000; // half a second at 50MHz

// clock the state and data registers
always @(posedge clk)
begin
    state_reg <= state_next;
    bit_counter_reg <= bit_counter_next;
    timeout_counter_reg <= timeout_counter_next;
    shift_reg <= shift_next;
    data_reg <= data_next;
    store_reg <= store_next;
end

// next-state logic and data path. See the Finite State Machine diagram.
always @*
begin
    state_next = state_reg; // default back to same state
    bit_counter_next = bit_counter_reg;
    timeout_counter_next = timeout_counter_reg;
    shift_next = shift_reg;
    data_next = data_reg;
    store_next = store_reg;
    ready = 1'b0;
    
    case (state_reg)
        idle:
            if (sclk_pos_edge)
                begin
                    bit_counter_next = 4'b0001;
                    timeout_counter_next = 0;
                    store_next = is_rom;
                    shift_next[0] = mosi;
                    state_next = capturing;
                end
        capturing:
            if (sclk_pos_edge)
                begin
                    bit_counter_next = bit_counter_reg + 1;
                    shift_next = {shift_reg[6:0], mosi};
                    if (bit_counter_next >= BIT_COUNTER_MAX)
                        begin
                            // all 8 bits have been received, send the data to the output latch
                            data_next = shift_next;
                            state_next = done;
                        end
                end
            else
                begin
                    timeout_counter_next = timeout_counter_reg + 1;
                    if (timeout_counter_next >= TIMEOUT_COUNTER_MAX)
                        state_next = idle;
                end
        done:
            begin
                ready = 1'b1;
                state_next = idle;
            end
        default:
            state_next = idle;
    endcase
end

// output logic
assign data_out = data_reg;
assign store = store_reg;

endmodule
