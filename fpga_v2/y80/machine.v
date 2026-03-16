/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** state machine module                                              Rev 0.0  07/01/2011 **/
/**                                                                                       **/
/*******************************************************************************************/
module machine (ld_ctrl, state_reg, wait_st, clkc, ld_wait,
                resetb, state_nxt);

  input         clkc;          /* main cpu clock                                           */
  input         ld_wait;       /* load wait request                                        */
  input         resetb;        /* internal reset                                           */
  input   [`STATE_IDX:0] state_nxt;   /* next processor state                              */
  output        ld_ctrl;       /* load control register                                    */
  output        wait_st;       /* wait state identifier                                    */
  output  [`STATE_IDX:0] state_reg;   /* current processor state                           */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  wire         ld_ctrl;                                    /* advance state                */

  reg          wait_st;                                    /* wait state - inhibit op      */
  reg  [`STATE_IDX:0] state_reg;                           /* current processor state      */

  /*****************************************************************************************/
  /*                                                                                       */
  /* processor state machine                                                               */
  /*                                                                                       */
  /*****************************************************************************************/
  assign ld_ctrl = !ld_wait;

  always @ (posedge clkc or negedge resetb) begin
    if (!resetb) wait_st   <= 1'b0;
    else         wait_st   <= !ld_ctrl;
    end

  always @ (posedge clkc or negedge resetb) begin
    if      (!resetb) state_reg <= `sRST;
    else if (ld_ctrl) state_reg <= state_nxt;
    end

  endmodule





