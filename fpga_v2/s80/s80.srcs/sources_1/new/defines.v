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

`define sINSTR_FETCH_3A  32'b00000000000000000000001000000001   // fetch 3rd instr (A)     // 00000201
`define sINSTR_FETCH_3B  32'b00000000000000000000010000000001   // fetch 3rd instr (B)     // 00000401
`define sDECODE_3        32'b00000000000000000000100000000001   // decode 3rd byte         // 00000801
`define sIDLE_3          32'b00000000000000000001000000000001   // idle (3)                // 00001001

`define sEXEC_1A         32'b00000000000000000010000000000001   // execute 1 (A)           // 00002001
`define sEXEC_1B         32'b00000000000000000100000000000001   // execute 1 (B)           // 00004001
`define sEXEC_1C         32'b00000000000000001000000000000001   // execute 1 (C)           // 00008001

`define sEXEC_2A         32'b00000000000000010000000000000001   // execute 2 (A)           // 00010001
`define sEXEC_2B         32'b00000000000000100000000000000001   // execute 2 (B)           // 00020001
`define sEXEC_2C         32'b00000000000001000000000000000001   // execute 2 (C)           // 00040001

`define sEXEC_3A         32'b00000000000010000000000000000001   // execute 3 (A)           // 00080001
`define sEXEC_3B         32'b00000000000100000000000000000001   // execute 3 (B)           // 00100001
`define sEXEC_3C         32'b00000000001000000000000000000001   // execute 3 (C)           // 00200001

`define sIDLE_4          32'b00000000010000000000000000000001   // idle (4)                // 00400001
`define sIDLE_5          32'b00000000100000000000000000000001   // idle (5)                // 00800001

`define sDONE            32'b01000000000000000000000000000001   // done with instruction   // 04000001

`define sRESET_EXIT      32'b10000000000000000000000000000001   // reset exit              // 80000001

//*************************************************************************************************

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

`define  INSTR_FETCH_3A  32'bxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxx1   // fetch 3rd instr (A)
`define  INSTR_FETCH_3B  32'bxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxx1   // fetch 3rd instr (B)
`define  DECODE_3        32'bxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxx1   // decode 3rd byte
`define  IDLE_3          32'bxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxx1   // idle (3)

`define  EXEC_1A         32'bxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxx1   // execute 1 (A)
`define  EXEC_1B         32'bxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxx1   // execute 1 (B)
`define  EXEC_1C         32'bxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxx1   // execute 1 (C)

`define  EXEC_2A         32'bxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx1   // execute 2 (A)
`define  EXEC_2B         32'bxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxx1   // execute 2 (B)
`define  EXEC_2C         32'bxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxx1   // execute 2 (C)

`define  EXEC_3A         32'bxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxx1   // execute 3 (A)
`define  EXEC_3B         32'bxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxx1   // execute 3 (B)
`define  EXEC_3C         32'bxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxx1   // execute 3 (C)

`define  IDLE_4          32'bxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxx1   // idle (4)
`define  IDLE_5          32'bxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxx1   // idle (5)

`define  DONE            32'bx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx1   // done with instruction

`define  RESET_EXIT      32'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1   // reset exit

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// data input control
`define DIN_NONE      2'b00            // No load
`define DIN_DIN0      2'b01            // Load din0
`define DIN_DIN1      2'b10            // Load din1
`define DIN_BOTH      2'b11            // Load both din0 and din1

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// ALU A Mux selector
`define ALU_A_IDX 3
`define ALU_A_NONE           4'h0
`define ALU_A_A              4'h1
`define ALU_A_HL             4'h2
`define ALU_A_DIN            4'h4
`define ALU_A_PC             4'h8

// ALU B Mux selector
`define ALU_B_IDX 3
`define ALU_B_ZERO           4'h0
`define ALU_B_ONE_LOW        4'h1
`define ALU_B_ONE_HIGH       4'h2
`define ALU_B_DIN            4'h4
`define ALU_B_DIN0_SIGN_EXT  4'h8

//*************************************************************************************************

// ALU Math operations
`define ALU_OP_IDX 6
`define ALU_A_PASS       7'h00
`define ALU_B_PASS       7'h01
`define ALU_ADD_WORD     7'h02
`define ALU_ADD_LO_BYTE  7'h04
`define ALU_ADD_HI_BYTE  7'h08
`define ALU_SUB_WORD     7'h10
`define ALU_SUB_LO_BYTE  7'h20
`define ALU_SUB_HI_BYTE  7'h40

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// Load register control
// TODO: could move PC to have its own signal
`define LD_REG_IDX 3
`define LD_REG_NONE   4'b0000
`define LD_REG_A      4'b0001
`define LD_REG_H      4'b0010
`define LD_REG_L      4'b0100
`define LD_REG_HL     4'b0110
`define LD_REG_PC     4'b1000

`define LD_A          0
`define LD_H          1
`define LD_L          2
`define LD_PC         3

//*************************************************************************************************

