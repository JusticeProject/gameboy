// state register will be [31:0]
`define STATE_SIZE 31

// State machine states, used for next state transition
`define sRESET           32'b00000000000000000000000000000000   // reset
`define sDECODE_1        32'b00000000000000000000000000000011   // decode 1st opcode       // 00000003
`define sEXEC            32'b00000000000000000000000000000101   // execute                 // 00000005






`define sINSTR_FETCH_1A  32'b00000000100000000000000000000001   // fetch 1st opcode (1)    // 00800001
`define sINSTR_FETCH_1B  32'b00000001000000000000000000000001   // fetch 1st opcode (2)    // 01000001
`define sRESET_EXIT      32'b10000000000000000000000000000001   // reset exit              // 80000001

// State machine states, used for determining current state
`define  RESET           32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0   // reset
`define  DECODE_1        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx11   // decode 1st opcode
`define  EXEC            32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1x1   // execute




`define  INSTR_FETCH_1A  32'bxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxx1   // fetch 1st opcode (1)
`define  INSTR_FETCH_1B  32'bxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxx1   // fetch 1st opcode (2)
`define  RESET_EXIT      32'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1   // reset exit
