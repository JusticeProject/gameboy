/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** state machine module                                              Rev 0.0  07/01/2011 **/
/**                                                                                       **/
/*******************************************************************************************/
module machine (ld_ctrl, state_reg, clkc, resetb, state_nxt);

  input         clkc;          /* main cpu clock                                           */
  input         resetb;        /* internal reset                                           */
  input   [`STATE_IDX:0] state_nxt;   /* next processor state                              */
  output        ld_ctrl;       /* load control register                                    */
  output  [`STATE_IDX:0] state_reg;   /* current processor state                           */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  wire         ld_ctrl;                                    /* advance state                */

  reg  [`STATE_IDX:0] state_reg;                           /* current processor state      */

  /*****************************************************************************************/
  /*                                                                                       */
  /* processor state machine                                                               */
  /*                                                                                       */
  /*****************************************************************************************/
  assign ld_ctrl = 1'b1;

  always @ (posedge clkc or negedge resetb) begin
    if      (!resetb) state_reg <= `sRST;
    else if (ld_ctrl) state_reg <= state_nxt;
    end

  endmodule





