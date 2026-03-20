// state register will be [31:0]
`define STATE_SIZE 31

// State machine states, used for next state transition
`define sRESET           32'b00000000000000000000000000000000   // reset
`define sINSTR_FETCH_1A  32'b00000000000000000000000000000011   // fetch 1st instr (A)     // 00000003
`define sINSTR_FETCH_1B  32'b00000000000000000000000000000101   // fetch 1st instr (B)     // 00000005
`define sDECODE_1        32'b00000000000000000000000000001001   // decode 1st byte         // 00000009
`define sIDLE_1          32'b00000000000000000000000000010001   // idle (1)                // 00000011
`define sINSTR_FETCH_2A  32'b00000000000000000000000000100001   // fetch 2nd instr (A)     // 00000021
`define sINSTR_FETCH_2B  32'b00000000000000000000000001000001   // fetch 2nd instr (B)     // 00000041
`define sDECODE_2        32'b00000000000000000000000010000001   // decode 2nd byte         // 00000081
`define sIDLE_2          32'b00000000000000000000000100000001   // idle (2)                // 00000101
`define sREAD_RAM_1A     32'b00000000000000000000100000000001   // read byte from RAM (A)  // 00000801
`define sWRITE_RAM_1A    32'b00000000000000000010000000000001   // write byte to RAM (A)   // 00002001
`define sRESET_EXIT      32'b10000000000000000000000000000001   // reset exit              // 80000001

// State machine states, used for determining current state
`define  RESET           32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0   // reset
`define  INSTR_FETCH_1A  32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx11   // fetch 1st instr (A)
`define  INSTR_FETCH_1B  32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1x1   // fetch 1st instr (B)
`define  DECODE_1        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xx1   // decode 1st byte
`define  IDLE_1          32'bxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxx1   // idle (1)
`define  INSTR_FETCH_2A  32'bxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxx1   // fetch 2nd instr (A)
`define  INSTR_FETCH_2B  32'bxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxx1   // fetch 2nd instr (B)
`define  DECODE_2        32'bxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxx1   // decode 2nd byte
`define  IDLE_2          32'bxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxx1   // idle (2)
`define  READ_RAM_1A     32'bxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxx1   // read byte from RAM (A)
`define  WRITE_RAM_1A    32'bxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxx1   // write byte to RAM (A)
`define  RESET_EXIT      32'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1   // reset exit

//*************************************************************************************************

// data input control
`define DIN_NONE      2'b00            // No load
`define DIN_DIN0      2'b01            // Load din0
`define DIN_DIN1      2'b10            // Load din1
`define DIN_BOTH      2'b11            // Load both din0 and din1

//*************************************************************************************************

// ALU A Mux selector
`define ALU_A_IDX 3
`define ALU_A_NONE        4'h0
`define ALU_A_A           4'h1
`define ALU_A_HL          4'h2
`define ALU_A_DIN         4'h4
`define ALU_A_PC          4'h8

// ALU B Mux selector
`define ALU_B_IDX 3
`define ALU_B_ZERO        4'h0
`define ALU_B_ONE_LOW     4'h1
`define ALU_B_ONE_HIGH    4'h2

//*************************************************************************************************

// ALU Math operations
`define ALU_OP_IDX 3
`define ALU_A_PASS       4'h0
`define ALU_B_PASS       4'h1
`define ALU_ADD          4'h2
`define ALU_SUB          4'h4

//*************************************************************************************************

// Load register control
// TODO: could move PC to have its own signal
`define LD_REG_IDX 2
`define LD_REG_NONE   3'h0
`define LD_REG_A      3'h1
`define LD_REG_HL     3'h2
`define LD_REG_PC     3'h4

`define LD_A          0
`define LD_HL         1
`define LD_PC         2

//*************************************************************************************************

