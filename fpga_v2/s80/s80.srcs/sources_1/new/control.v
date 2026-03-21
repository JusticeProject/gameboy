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
    output reg [`LD_REG_IDX:0] ld_reg_enable,
    
    // ALU control signals
    output reg [`ALU_A_IDX:0] alu_a_mux_sel,
    output reg [`ALU_B_IDX:0] alu_b_mux_sel,
    output reg [`ALU_OP_IDX:0] alu_op_sel,
    
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
                8'b00111110,              // ld a,n8
                8'b00011000:              // jr s8
                    state_next = `sIDLE_1;
                default:
                    state_next = `sDONE;
            endcase
        `IDLE_1:
             state_next = `sINSTR_FETCH_2A;
        `INSTR_FETCH_2A:
            state_next = `sINSTR_FETCH_2B;
        `INSTR_FETCH_2B:
            state_next = `sDECODE_2;
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000:                // jr s8
                    state_next = `sIDLE_2;
                default:
                    state_next = `sDONE;
            endcase
        `IDLE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000:              // jr s8
                    state_next = `sEXEC_1A;
                default:
                    state_next = `sINSTR_FETCH_3A;
            endcase
        `EXEC_1A:
            state_next = `sEXEC_1B;
        `EXEC_1B:
            state_next = `sEXEC_1C;
        `EXEC_1C:
            (* parallel_case *)
            casex (instr_reg)
                default:
                    state_next = `sDONE;
            endcase
        `DONE:
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
    // TODO: do I want to combine these signals into a bus? Are there other registers that go out to the mem_addr bus?
    pc_out_enable = 1'b0; // by default don't put anything onto the mem_addr bus
    hl_out_enable = 1'b0;
                
    (* parallel_case *)
    casex (state_reg)
        `RESET_EXIT,
        `IDLE_1,
        `IDLE_2,
        `IDLE_3,
        `IDLE_4,
        `IDLE_5,
        `DONE:
            begin
                // send the pc out onto the mem_addr bus on the NEXT clock cycle
                pc_out_enable = 1'b1;
            end
        // TODO:
        `EXEC_1A:
            // TODO:
            (* parallel_case *)
            casex (instr_reg)
                8'b01110111:                 // ld [hl],a
                    // send the hl register onto the mem_addr bus
                    hl_out_enable = 1'b1;
            endcase
    endcase
end

//*************************************************************************************************

// output control signals for data out
always @*
begin
    // TODO: will need a bus for all of the signals
    
    (* parallel_case *)
    casex (state_reg)
        // TODO:
        `EXEC_1B:
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
    mem_wr_enable = 1'b0; // set the default value
    
    (* parallel_case *)
    casex (state_reg)
        `EXEC_1B:
            (* parallel_case *)
            casex (instr_reg)
                8'b01110111:                     // ld [hl],a
                    mem_wr_enable = 1'b1;
            endcase
    endcase
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// control signals for ALU A mux
always @*
begin
    alu_a_mux_sel = `ALU_A_NONE; // set the default value
    
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A,
        `INSTR_FETCH_2A,
        `INSTR_FETCH_3A:
            alu_a_mux_sel = `ALU_A_PC; // increment pc
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b0011110x:        // inc a or dec a
                    alu_a_mux_sel = `ALU_A_A;
            endcase
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00111110:                  // ld a,n8
                    alu_a_mux_sel = `ALU_A_DIN;
            endcase
        `EXEC_1C:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000:             // jr s8
                    alu_a_mux_sel = `ALU_A_PC;
            endcase
    endcase
end

//*************************************************************************************************

// control signals for ALU B mux
always @*
begin
    alu_b_mux_sel = `ALU_B_ZERO;  // set the default value

    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A,
        `INSTR_FETCH_2A:
            alu_b_mux_sel = `ALU_B_ONE_LOW; // increment pc
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b0011110x:       // inc a or dec a
                    alu_b_mux_sel = `ALU_B_ONE_HIGH;
            endcase
        `EXEC_1C:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000:         // jr s8
                    alu_b_mux_sel = `ALU_B_DIN0_SIGN_EXT;
            endcase
    endcase
end

//*************************************************************************************************

// control signals for ALU operation
always @*
begin
    alu_op_sel = `ALU_A_PASS; // set the default value
    
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A,
        `INSTR_FETCH_2A:
            alu_op_sel = `ALU_ADD_WORD; // increment pc
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xxx100:                 // inc a
                    alu_op_sel = `ALU_ADD_HI_BYTE;
                8'b00xxx101:                 // dec a
                    alu_op_sel = `ALU_SUB_HI_BYTE;
            endcase
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xxx110:                   // ld r,n8, TODO: what if it's ld [hl],n8?
                    alu_op_sel = `ALU_A_PASS;
            endcase
        `EXEC_1C:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000:               // jr s8
                    alu_op_sel = `ALU_ADD_WORD;
            endcase
    endcase
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// control signals for load instruction register
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

// control signals for din0 and din1
always @*
begin
    ld_din_enable = `DIN_NONE; // set the default value
    
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_2B:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000,                   // jr s8
                8'b00111110:                   // ld a,n8
                    ld_din_enable = `DIN_BOTH;
            endcase
        // TODO: for ld a,[hl] should I load [hl] into both din0 and din1, followed by moving alu_out_bus to a?
    endcase
end

//*************************************************************************************************

// control signals for load registers
always @*
begin
    ld_reg_enable = `LD_REG_NONE; // set the default value
    
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A,
        `INSTR_FETCH_2A,
        `INSTR_FETCH_3A:
            ld_reg_enable = `LD_REG_PC;  // increment pc
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b0011110x:        // inc a or dec a
                    ld_reg_enable = `LD_REG_A;
            endcase
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00111110:     // ld a,n8
                    ld_reg_enable = `LD_REG_A;
                //8'b00100001:     // ld hl,n16 // TODO:
                //    ld_reg_enable = `LD_REG_HL;
            endcase
        `EXEC_1C:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000:           // jr s8
                    ld_reg_enable = `LD_REG_PC;
            endcase
    endcase
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************



endmodule
