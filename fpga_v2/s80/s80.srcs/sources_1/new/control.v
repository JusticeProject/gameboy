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
            casex (instr_reg)          // TODO: is this case necessary? should I always go to IDLE_1?
                8'b00000000,              // nop
                8'b00xxx100,              // inc r8 or inc [hl]
                8'b00xxx101,              // dec r8 or dec [hl]
                8'b00xxx110:              // ld r,n8 or ld [hl],n8
                    state_next = `sIDLE_1;
                default:
                    state_next = `sRESET_EXIT;
            endcase
        `IDLE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xxx110:              // ld r,n8 or ld [hl],n8
                    state_next = `sINSTR_FETCH_2A;
                default:
                    state_next = `sINSTR_FETCH_1A;
            endcase
        `INSTR_FETCH_2A:
            state_next = `sINSTR_FETCH_2B;
        `INSTR_FETCH_2B:
            state_next = `sDECODE_2;
        `DECODE_2:
            state_next = `sIDLE_2;
        `IDLE_2:
            (* parallel_case *)
            casex (instr_reg)
                default:
                    state_next = `sINSTR_FETCH_1A;
            endcase
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
        `IDLE_2:
            begin
                // send the pc out onto the mem_addr bus on the NEXT clock cycle
                pc_out_enable = 1'b1;
            end
        // TODO: should this be in the DECODE state?
        `WRITE_RAM_1A:
            begin
                // send the hl register onto the mem_addr bus
                hl_out_enable = 1'b1;
            end
    endcase
end

//*************************************************************************************************

// output control signals for data out
always @*
begin
    // TODO: will need a bus for all of the signals
    
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

// control signals for ALU A mux
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A,
        `INSTR_FETCH_2A:
            alu_a_mux_sel = `ALU_A_PC; // increment pc
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b0011110x:        // inc a or dec a
                    alu_a_mux_sel = `ALU_A_A;
                default:
                    alu_a_mux_sel = `ALU_A_NONE;
            endcase
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xxx110:                  // ld r,n8, TODO: what if it's ld [hl],n8?
                    alu_a_mux_sel = `ALU_A_DIN;
                default:
                    alu_a_mux_sel = `ALU_A_NONE;
            endcase
        default:
            alu_a_mux_sel = `ALU_A_NONE;
    endcase
end

//*************************************************************************************************

// control signals for ALU B mux
always @*
begin
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
                default:
                    alu_b_mux_sel = `ALU_B_ZERO;
            endcase
        default:
            alu_b_mux_sel = `ALU_B_ZERO;
    endcase
end

//*************************************************************************************************

// control signals for ALU operation
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A,
        `INSTR_FETCH_2A:
            alu_op_sel = `ALU_ADD; // increment pc
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xxx100:
                    alu_op_sel = `ALU_ADD;
                8'b00xxx101:
                    alu_op_sel = `ALU_SUB;
                default:
                    alu_op_sel = `ALU_A_PASS;
            endcase
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00xxx110:                   // ld r,n8, TODO: what if it's ld [hl],n8?
                    alu_op_sel = `ALU_A_PASS;
                default:
                    alu_op_sel = `ALU_A_PASS;
            endcase
        default:
            alu_op_sel = `ALU_A_PASS;
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
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_2B:
            (* parallel_case *)
            casex (instr_reg)
                    8'b00xxx110:                   // ld r,n8, TODO: what if it's ld [hl],n8?
                    ld_din_enable = `DIN_BOTH;
                default:
                    ld_din_enable = `DIN_NONE;
            endcase
        // TODO: for ld a,[hl] should I load [hl] into both din0 and din1, followed by moving alu_out_bus to a?
        `READ_RAM_1A:
            ld_din_enable = `DIN_DIN1;
        default:
            ld_din_enable = `DIN_NONE;
    endcase
end

//*************************************************************************************************

// control signals for load registers
always @*
begin
    (* parallel_case *)
    casex (state_reg)
        `INSTR_FETCH_1A,
        `INSTR_FETCH_2A:
            ld_reg_enable = `LD_REG_PC;  // increment pc
        `DECODE_1:
            (* parallel_case *)
            casex (instr_reg)
                8'b0011110x:        // inc a or dec a
                    ld_reg_enable = `LD_REG_A;
                default:
                    ld_reg_enable = `LD_REG_NONE;
            endcase
        `DECODE_2:
            (* parallel_case *)
            casex (instr_reg)
                8'b00111110:     // ld a,n8
                    ld_reg_enable = `LD_REG_A;
                //8'b00100001:     // ld hl,n16
                //    ld_reg_enable = `LD_REG_HL;
                default:
                    ld_reg_enable = `LD_REG_NONE;
            endcase
        default:
            begin
                ld_reg_enable = `LD_REG_NONE;
            end
    endcase
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************



endmodule
