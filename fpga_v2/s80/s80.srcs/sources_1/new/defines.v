// state register will be [31:0]
`define STATE_SIZE 31

// State machine states, used for next state transition
`define sRESET           32'b00000000000000000000000000000000   // reset
`define sDECODE_1        32'b00000000000000000000000000000011   // decode 1st opcode       // 00000003
`define sEXEC            32'b00000000000000000000000000000101   // execute                 // 00000005
`define sREAD_RAM_1A     32'b00000000000000000000100000000001   // read byte from RAM (1)  // 00000801
`define sWRITE_RAM_1A    32'b00000000000000000010000000000001   // write byte to RAM (1)   // 00002001






`define sINSTR_FETCH_1A  32'b00000000100000000000000000000001   // fetch 1st opcode (1)    // 00800001
`define sINSTR_FETCH_1B  32'b00000001000000000000000000000001   // fetch 1st opcode (2)    // 01000001
`define sRESET_EXIT      32'b10000000000000000000000000000001   // reset exit              // 80000001

// State machine states, used for determining current state
`define  RESET           32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0   // reset
`define  DECODE_1        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx11   // decode 1st opcode
`define  EXEC            32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1x1   // execute
`define  READ_RAM_1A     32'bxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxx1   // read byte from RAM (1)
`define  WRITE_RAM_1A    32'bxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxx1   // write byte to RAM (1)




`define  INSTR_FETCH_1A  32'bxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxx1   // fetch 1st opcode (1)
`define  INSTR_FETCH_1B  32'bxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxx1   // fetch 1st opcode (2)
`define  RESET_EXIT      32'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1   // reset exit


// data input control
`define DIN_NONE      2'b00            // No load
`define DIN_DIN0      2'b01            // Load din0
`define DIN_DIN1      2'b10            // Load din1
`define DIN_BOTH      2'b11            // Load both din0 and din1