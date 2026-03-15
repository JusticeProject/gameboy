/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** alu a input multiplexer module                                    Rev 0.0  07/24/2011 **/
/**                                                                                       **/
/*******************************************************************************************/
module aluamux (adda_in, alua_in, alua_reg, aa_reg_out, bit_mask, daa_out, hl_reg_out,
                pc_reg);

  input   [7:0] aa_reg_out;    /* a register output                                        */
  input   [7:0] bit_mask;      /* bit mask for bit operations                              */
  input   [7:0] daa_out;       /* daa constant                                             */
  input  [15:0] hl_reg_out;    /* hl register output                                       */
  input  [15:0] pc_reg;        /* pc register output                                       */
  input  [`ALUA_IDX:0] alua_reg;   /* pipelined alu input a mux control                    */
  output [15:0] adda_in;       /* address alu a input bus                                  */
  output [15:0] alua_in;       /* alu a input bus                                          */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  reg  [15:0] alua_in;
  reg  [15:0] alua_in_0,  alua_in_1,  alua_in_2,  alua_in_3,  alua_in_4,  alua_in_5;
  reg  [15:0] alua_in_6,  alua_in_7,  alua_in_8,  alua_in_9;

  wire [15:0] adda_in;
  wire [15:0] adda_in_0,  adda_in_1,  adda_in_2;

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu input a select                                                                    */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (alua_reg or aa_reg_out or bit_mask or daa_out or 
            hl_reg_out or pc_reg) begin
    alua_in_0  = 16'h0;
    alua_in_1  = 16'h0;
    alua_in_2  = 16'h0;
    alua_in_3  = 16'h0;
    alua_in_4  = 16'h0;
    alua_in_5  = 16'h0;
    alua_in_6  = 16'h0;
    alua_in_7  = 16'h0;
    alua_in_8  = 16'h0;
    alua_in_9  = 16'h0;
    if (alua_reg[`AA_ONE]) alua_in_0  = 16'h0001;
    if (alua_reg[`AA_M1])  alua_in_1  = 16'hffff;
    if (alua_reg[`AA_M2])  alua_in_2  = 16'hfffe;
    if (alua_reg[`AA_HL])  alua_in_3  = hl_reg_out;
    if (alua_reg[`AA_PC])  alua_in_6  = pc_reg;
    if (alua_reg[`AA_AA])  alua_in_7  = {8'h00, aa_reg_out};
    if (alua_reg[`AA_BIT]) alua_in_8  = {8'h00, bit_mask};
    if (alua_reg[`AA_DAA]) alua_in_9  = {8'h00, daa_out};
    end

  always @ (alua_in_0  or alua_in_1  or alua_in_2  or alua_in_3  or alua_in_4  or
            alua_in_5  or alua_in_6  or alua_in_7  or alua_in_8  or alua_in_9) begin
    alua_in = alua_in_0  | alua_in_1  | alua_in_2  | alua_in_3  | alua_in_4  |
              alua_in_5  | alua_in_6  | alua_in_7  | alua_in_8  | alua_in_9;
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* address alu input a select                                                            */
  /*                                                                                       */
  /*****************************************************************************************/
  assign adda_in_0  = (alua_reg[`AA_ONE]) ? 16'h0001           : 16'h0000;
  assign adda_in_1  = (alua_reg[`AA_M1])  ? 16'hffff           : 16'h0000;
  assign adda_in_2  = (alua_reg[`AA_M2])  ? 16'hfffe           : 16'h0000;

  assign adda_in = adda_in_0  | adda_in_1  | adda_in_2;

  endmodule







