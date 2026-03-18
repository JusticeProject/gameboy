`include "defines.v"

module control(
    input wire clk,
    input wire resetb,
    
    // output control signals
    output reg pc_out_enable,
    output reg hl_out_enable,
    output reg a_out_enable,
    output reg mem_wr_enable,
    
    // load control signals
    output reg ld_instr_enable,
    output reg [1:0] ld_din_enable,
    // TODO: combine these
    output reg ld_a_enable,
    output reg ld_hl_enable,
    
    // misc control signals
    output reg inc_pc_enable,
    
    // status signals
    input wire [7:0] instr_reg
);

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// internal signals
reg [`STATE_SIZE:0] state_reg, state_next;

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// do the state transition
always @(negedge resetb, posedge clk)
begin
    if (!resetb)
        state_reg <= `sRESET;
    else
        state_reg <= state_next;
end   

//*************************************************************************************************

// next state logic
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `RESET_EXIT:
            state_next = `sINSTR_FETCH_1A;
        `INSTR_FETCH_1A:
            state_next = `sINSTR_FETCH_1B;
        `INSTR_FETCH_1B:
            state_next = `sDECODE_1;
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b11110011,      // TODO: disable interrupts
                8'b00000000:
                    state_next = `sEXEC;
                default:
                    state_next = `sRESET_EXIT;
            endcase
        `EXEC:
            state_next = `sINSTR_FETCH_1A;
        default:
            state_next = `sRESET_EXIT;
    endcase
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// output control signals for mem_addr
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A:
            begin
                // send the pc out onto the mem_addr bus
                pc_out_enable = 1'b1;
                hl_out_enable = 1'b0;
            end
        `WRITE_RAM_1A:
            begin
                // send the hl register onto the mem_addr bus
                pc_out_enable = 1'b0;
                hl_out_enable = 1'b1;
            end
        default:
            begin
                // don't put anything onto the mem_addr bus
                pc_out_enable = 1'b0;
                hl_out_enable = 1'b0;
            end
    endcase
end

//*************************************************************************************************

// output control signals for data out
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `WRITE_RAM_1A:
            (* parallel_case *)
            case (instr_reg)
                8'b01110111:                           // ld [hl], a
                    a_out_enable = 1'b1;
                default:
                    a_out_enable = 1'b0;
            endcase
        default:
            a_out_enable = 1'b0;
    endcase
end

//*************************************************************************************************

// output control signals for mem write control
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `WRITE_RAM_1A:
            mem_wr_enable = 1'b1;
        default:
            mem_wr_enable = 1'b0;
    endcase
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// load control signals, load instruction register
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1B:
            ld_instr_enable = 1'b1;
        default:
            ld_instr_enable = 1'b0;
    endcase
end

//*************************************************************************************************

// load control signals, din0 and din1
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `READ_RAM_1A:
            ld_din_enable = `DIN_DIN1;
        default:
            ld_din_enable = `DIN_NONE;
    endcase
end

//*************************************************************************************************

// load control signals for registers
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `EXEC:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xxx110:     // ld a,n8
                    begin
                        ld_a_enable = 1'b1;
                        ld_hl_enable = 1'b0;
                    end
                8'b00100001:     // ld hl,n16
                    begin
                        ld_a_enable = 1'b0;
                        ld_hl_enable = 1'b1;
                    end
                default:
                    begin
                        ld_a_enable = 1'b0;
                        ld_hl_enable = 1'b0;
                    end
            endcase
        default:
            begin
                ld_a_enable = 1'b0;
                ld_hl_enable = 1'b0;
            end
    endcase
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// misc control signals,
// increment program counter
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `EXEC:
            inc_pc_enable = 1'b1;
        default:
            inc_pc_enable = 1'b0;
    endcase
end

endmodule
