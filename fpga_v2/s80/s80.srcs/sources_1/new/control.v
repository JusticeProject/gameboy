`include "defines.v"

module control(
    input wire clk,
    input wire resetb,
    
    // control signals
    output reg pc_out_enable,
    output reg ld_instr_enable,
    output reg inc_pc_enable,
    
    // status signals
    input wire instr_reg
);

//*************************************************************************************************

// internal signals
reg [`STATE_SIZE:0] state_reg, state_next;

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
    case (state_reg)
        `RESET_EXIT:
            state_next = `sINSTR_FETCH_1A;
        `INSTR_FETCH_1A:
            state_next = `sINSTR_FETCH_1B;
        `INSTR_FETCH_1B:
            state_next = `sDECODE_1;
        `DECODE_1:
            state_next = `sEXEC;
        `EXEC:
            state_next = `sINSTR_FETCH_1A;
        default:
            state_next = `sRESET_EXIT;
    endcase
end

//*************************************************************************************************

// output logic, control signals

endmodule
