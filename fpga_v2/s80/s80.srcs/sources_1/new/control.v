`include "defines.v"

module control(
    input wire clk,
    input wire resetb,
    
    // output control signals
    output reg [`MEM_ADDR_OUT_IDX:0] mem_addr_out_enable,
    output reg a_out_enable,
    output reg mem_wr_enable,
    
    // load control signals
    output reg ld_instr_enable,
    output reg [1:0] ld_din_enable,
    output reg [`LD_REG_IDX:0] ld_reg_enable,
    
    // ALU control signals
    output reg [`ALUA_IDX:0] alu_a_mux_sel,
    output reg [`ALUB_IDX:0] alu_b_mux_sel,
    output reg [`ALU_OP_IDX:0] alu_op_sel,
    
    // flag control signals
    output reg z_flag_enable,
    
    // status signals
    input wire [7:0] instr_reg,
    input wire z_flag_reg
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
                8'b00011010,              // ld a, [de]
                8'b00xx0001,              // ld r16, n16
                8'b00100010,              // ld [hli], a
                8'b00xxx110,              // ld r8,n8 or ld [hl],n8
                8'b00011000,              // jr s8
                8'b00100000,              // jr nz, s8
                8'b01110111,              // ld [hl],a
                8'b01111110,              // ld a, [hl]
                8'b11000011:              // jp n16
                    state_next = `sIDLE_1;
                default:
                    state_next = `sDONE;
            endcase
        `IDLE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011010,              // ld a, [de]
                8'b00100010,              // ld [hli], a
                8'b01111110,              // ld a, [hl]
                8'b01110111:              // ld [hl],a
                    state_next = `sEXEC_1A;
                default:
                    state_next = `sINSTR_FETCH_2A;
            endcase
        `INSTR_FETCH_2A:
            state_next = `sINSTR_FETCH_2B;
        `INSTR_FETCH_2B:
            state_next = `sDECODE_2;
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xx0001,                // ld r16, n16
                8'b00011000,                // jr s8
                8'b11000011:                // jp n16
                    state_next = `sIDLE_2;
                8'b00100000:                // jr nz, s8
                    state_next = (z_flag_reg) ? `sDONE : `sIDLE_2;
                default:
                    state_next = `sDONE;
            endcase
        `IDLE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000,              // jr s8
                8'b00100000:              // jr nz, s8
                    state_next = `sEXEC_1A;
                default:
                    state_next = `sINSTR_FETCH_3A;
            endcase
        `INSTR_FETCH_3A:
            state_next = `sINSTR_FETCH_3B;
        `INSTR_FETCH_3B:
            state_next = `sDECODE_3;
        `DECODE_3:
            (* parallel_case *)
            casex (instr_reg)
                default:
                    state_next = `sDONE;
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
    mem_addr_out_enable = `NO_ADDR_OUT; // by default don't put anything onto the mem_addr bus
                
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
                mem_addr_out_enable = `PC_OUT;
            end
        `EXEC_1A:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011010:                 // ld a, [de]
                    mem_addr_out_enable = `DE_OUT;
                8'b00100010,                 // ld [hli], a
                8'b01110111,                 // ld [hl], a
                8'b01111110:                 // ld a, [hl]
                    mem_addr_out_enable = `HL_OUT; // send the hl register onto the mem_addr bus
            endcase
    endcase
end

//*************************************************************************************************

// output control signals for data out
always @*
begin
    // TODO: will need a bus for all of the signals
    a_out_enable = 1'b0; // set the default
    
    (* parallel_case *)
    casex (state_reg)
        `EXEC_1A:
            (* parallel_case *)
            case (instr_reg)
                8'b00100010,                           // ld [hli], a
                8'b01110111:                           // ld [hl], a
                    a_out_enable = 1'b1;
            endcase
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
                8'b00100010,                     // ld [hli], a
                8'b01110111:                     // ld [hl], a
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
    alu_a_mux_sel = `ALUA_NONE; // set the default value
    
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A,
        `INSTR_FETCH_2A,
        `INSTR_FETCH_3A:
            alu_a_mux_sel = `ALUA_PC; // increment pc
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b0000010x,        // inc b or dec b
                8'b01111000:        // ld a, b
                    alu_a_mux_sel = `ALUA_B;
                8'b0000110x,        // inc c or dec c
                8'b01111001:        // ld a, c
                    alu_a_mux_sel = `ALUA_C;
                8'b0001010x,        // inc d or dec d
                8'b01111010:        // ld a, d
                    alu_a_mux_sel = `ALUA_D;
                8'b0001110x,        // inc e or dec e
                8'b01111011:        // ld a, e
                    alu_a_mux_sel = `ALUA_E;
                8'b0010010x,        // inc h or dec h
                8'b01111100:        // ld a, h
                    alu_a_mux_sel = `ALUA_H;
                8'b0010110x,        // inc l or dec l
                8'b01111101:        // ld a, l
                    alu_a_mux_sel = `ALUA_L;
                8'b0011110x,        // inc a or dec a
                8'b01111111,        // ld a, a
                8'b10101111:        // xor a, a
                    alu_a_mux_sel = `ALUA_A;
                8'b00010011:        // inc de
                    alu_a_mux_sel = `ALUA_DE;
            endcase
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00100110,                  // ld h,n8
                8'b00101110,                  // ld l,n8
                8'b00111110:                  // ld a,n8
                    alu_a_mux_sel = `ALUA_DIN;
            endcase
        `EXEC_1C:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000,             // jr s8
                8'b00100000:             // jr nz, s8
                    alu_a_mux_sel = `ALUA_PC;
                8'b00100010:             // ld [hli], a
                    alu_a_mux_sel = `ALUA_HL;
            endcase
        `DECODE_3:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xx0001,            // ld r16, n16
                8'b11000011:            // jp n16
                    alu_a_mux_sel = `ALUA_DIN;
            endcase
        `DONE:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011010,             // ld a, [de]
                8'b01111110:             // ld a, [hl]
                    alu_a_mux_sel = `ALUA_DIN;
            endcase
    endcase
end

//*************************************************************************************************

// control signals for ALU B mux
always @*
begin
    alu_b_mux_sel = `ALUB_ZERO;  // set the default value

    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A,
        `INSTR_FETCH_2A,
        `INSTR_FETCH_3A:
            alu_b_mux_sel = `ALUB_ONE; // increment pc
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b0000010x,        // inc b or dec b
                8'b0000110x,        // inc c or dec c
                8'b00010011,        // inc de
                8'b0001010x,        // inc d or dec d
                8'b0001110x,        // inc e or dec e
                8'b0010010x,        // inc h or dec h
                8'b0010110x,        // inc l or dec l
                8'b0011110x:        // inc a or dec a
                    alu_b_mux_sel = `ALUB_ONE;
                8'b10101111:        // xor a, a
                    alu_b_mux_sel = `ALUB_A;
            endcase
        `EXEC_1C:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000,         // jr s8
                8'b00100000:         // jr nz, s8
                    alu_b_mux_sel = `ALUB_DIN0_SIGN_EXT;
                8'b00100010:         // ld [hli], a
                    alu_b_mux_sel = `ALUB_ONE;
            endcase
    endcase
end

//*************************************************************************************************

// control signals for ALU operation
always @*
begin
    alu_op_sel = `ALU_A_PASS; // set the default value
    // TODO: could maybe get rid of the case statements below that use ALU_A_PASS since it's the default
    
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A,
        `INSTR_FETCH_2A,
        `INSTR_FETCH_3A:
            alu_op_sel = `ALU_ADD_WORD; // increment pc
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b00010011:                 // inc de
                    alu_op_sel = `ALU_ADD_WORD;
                8'b00xxx100:                 // inc r8, will also trigger for inc [hl] but it won't matter
                    alu_op_sel = `ALU_ADD_BYTE;
                8'b00xxx101:                 // dec r8, will also trigger for dec [hl] but it won't matter
                    alu_op_sel = `ALU_SUB_BYTE;
                8'b10101111:                 // xor a, a
                    alu_op_sel = `ALU_XOR_BYTE;
            endcase
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00100110,                   // ld h,n8
                8'b00101110,                   // ld l,n8
                8'b00111110:                   // ld a,n8
                    alu_op_sel = `ALU_A_PASS;
            endcase
        `EXEC_1C:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000,               // jr s8
                8'b00100000,               // jr nz, s8
                8'b00100010:               // ld [hli], a
                    alu_op_sel = `ALU_ADD_WORD;
            endcase
        `DECODE_3:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xx0001,              // ld r16, n16
                8'b11000011:              // jp n16
                    alu_op_sel = `ALU_A_PASS;
            endcase
        `DONE:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011010,                // ld a, [de]
                8'b01111110:                // ld a, [hl]
                    alu_op_sel = `ALU_A_PASS;
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
                8'b00xx0001,                   // ld r16, n16
                8'b00011000,                   // jr s8
                8'b00100000,                   // jr nz, s8
                8'b00100110,                   // ld h,n8
                8'b00101110,                   // ld l,n8
                8'b00111110,                   // ld a,n8
                8'b11000011:                  // jp n16
                    ld_din_enable = `DIN_DIN0;
            endcase
        `INSTR_FETCH_3B:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xx0001,                   // ld r16, n16
                8'b11000011:                   // jp n16
                    ld_din_enable = `DIN_DIN1;
            endcase
        `EXEC_1C:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011010,                   // ld a, [de]
                8'b01111110:                   // ld a, [hl]
                    ld_din_enable = `DIN_DIN0;
            endcase
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
                8'b0000010x:        // inc b or dec b
                    ld_reg_enable = `LD_REG_B | `LD_UPD_REG_F;
                8'b0000110x:        // inc c or dec c
                    ld_reg_enable = `LD_REG_C | `LD_UPD_REG_F;
                8'b00010011:        // inc de   (does not update any flags)
                    ld_reg_enable = `LD_REG_DE;
                8'b0001010x:        // inc d or dec d
                    ld_reg_enable = `LD_REG_D | `LD_UPD_REG_F;
                8'b0001110x:        // inc e or dec e
                    ld_reg_enable = `LD_REG_E | `LD_UPD_REG_F;
                8'b0010010x:        // inc h or dec h
                    ld_reg_enable = `LD_REG_H | `LD_UPD_REG_F;
                8'b0010110x:        // inc l or dec l
                    ld_reg_enable = `LD_REG_L | `LD_UPD_REG_F;
                8'b0011110x,        // inc a or dec a
                8'b10101111:        // xor a, a
                    ld_reg_enable = `LD_REG_A | `LD_UPD_REG_F;
                8'b01111000,        // ld a, b
                8'b01111001,        // ld a, c
                8'b01111010,        // ld a, d
                8'b01111011,        // ld a, e
                8'b01111100,        // ld a, h
                8'b01111101,        // ld a, l
                8'b01111111:        // ld a, a
                    ld_reg_enable = `LD_REG_A;
            endcase
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00100110:     // ld h,n8
                    ld_reg_enable = `LD_REG_H;
                8'b00101110:    // ld l,n8
                    ld_reg_enable = `LD_REG_L;
                8'b00111110:     // ld a,n8
                    ld_reg_enable = `LD_REG_A;
            endcase
        `DECODE_3:
            (* parallel_case *)
            casex (instr_reg)
                8'b00000001:           // ld bc, n16
                    ld_reg_enable = `LD_REG_BC;
                8'b00010001:           // ld de, n16
                    ld_reg_enable = `LD_REG_DE;
                8'b00100001:           // ld hl, n16
                    ld_reg_enable = `LD_REG_HL;
                8'b00110001:           // ld sp, n16
                    ld_reg_enable = `LD_REG_SP;
                8'b11000011:           // jp n16
                    ld_reg_enable = `LD_REG_PC;
            endcase
        `EXEC_1C:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011000,           // jr s8
                8'b00100000:           // jr nz, s8
                    ld_reg_enable = `LD_REG_PC;
                8'b00100010:           // ld [hli], a
                    ld_reg_enable = `LD_REG_HL;
            endcase
        `DONE:
            (* parallel_case *)
            casex (instr_reg)
                8'b00011010,           // ld a, [de]
                8'b01111110:           // ld a, [hl]
                    ld_reg_enable = `LD_REG_A;
            endcase
    endcase
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// control signals for z flag
always @*
begin
    z_flag_enable = 1'b0; // set the default
    
    (* parallel_case *)
    casex (state_reg)
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b0000010x,        // inc b or dec b
                8'b0000110x,        // inc c or dec c
                                    // inc de does not set any flags
                8'b0001010x,        // inc d or dec d
                8'b0001110x,        // inc e or dec e
                8'b0010010x,        // inc h or dec h
                8'b0010110x,        // inc l or dec l
                8'b0011110x,        // inc a or dec a
                8'b10101111:        // xor a, a
                    z_flag_enable = 1'b1;
            endcase
    endcase
end

endmodule
