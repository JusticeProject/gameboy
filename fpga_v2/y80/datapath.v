/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** data path module                                                  Rev 0.0  08/22/2010 **/
/**                                                                                       **/
/*******************************************************************************************/
module datapath (addr_reg_in, carry_bit, dout_mem_reg, inst_reg,
                 page_reg, par_bit, sign_bit, xhlt_reg,
                 zero_bit, add_sel, alua_sel, alub_sel, aluop_sel, clearb, clkc, cflg_en,
                 data_in, di_ctl, do_ctl, ex_af_pls, ex_bank_pls, ex_dehl_inst,
                 hflg_ctl, ld_ctrl, ld_inst, ld_page,
                 nflg_ctl, nmi_req, page_sel, pc_sel, resetb, sflg_en,
                 wait_st, wr_addr, zflg_en);

  input         cflg_en;       /* carry flag control                                       */
  input         clearb;        /* master (testing) reset                                   */
  input         clkc;          /* main cpu clock                                           */
  input         ex_af_pls;     /* exchange af,af'                                          */
  input         ex_bank_pls;   /* exchange register bank                                   */
  input         ex_dehl_inst;  /* exchange de,hl                                           */
  input         ld_ctrl;       /* load control register                                    */
  input         ld_inst;       /* load instruction register                                */
  input         ld_page;       /* load page register                                       */
  input         nmi_req;       /* nmi request                                              */
  input         resetb;        /* internal (user) reset                                    */
  input         sflg_en;       /* sign flag control                                        */
  input         wait_st;       /* wait state identifier                                    */
  input         zflg_en;       /* zero flag control                                        */
  input   [3:0] page_sel;      /* instruction decode "page" control                        */
  input   [7:0] data_in;       /* read data bus                                            */
  input  [`ADCTL_IDX:0] add_sel;     /* address output mux control                         */
  input   [`ALUA_IDX:0] alua_sel;    /* alu input a mux control                            */
  input   [`ALUB_IDX:0] alub_sel;    /* alu input b mux control                            */
  input  [`ALUOP_IDX:0] aluop_sel;   /* alu operation control                              */
  input     [`DI_IDX:0] di_ctl;      /* data input control                                 */
  input     [`DO_IDX:0] do_ctl;      /* data output control                                */
  input   [`HFLG_IDX:0] hflg_ctl;    /* half-carry flag control                            */
  input   [`NFLG_IDX:0] nflg_ctl;    /* negate flag control                                */
  input  [`PCCTL_IDX:0] pc_sel;      /* program counter source control                     */
  input   [`WREG_IDX:0] wr_addr;     /* register write address bus                         */
  output        carry_bit;     /* carry flag                                               */
  output        par_bit;       /* parity flag                                              */
  output        sign_bit;      /* sign flag                                                */
  output        xhlt_reg;      /* halt exit                                                */
  output        zero_bit;      /* zero flag                                                */
  output  [3:0] page_reg;      /* instruction decode "page"                                */
  output  [7:0] inst_reg;      /* instruction register                                     */
  output  [7:0] dout_mem_reg;  /* memory write data bus                                    */
  output [15:0] addr_reg_in;   /* processor address bus                                    */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  wire         adder_c;                                    /* math carry                   */
  wire         adder_hc;                                   /* math half-carry              */
  wire         adder_ov;                                   /* math overflow result         */
  wire         alu_carry;                                  /* final carry                  */
  wire         alu_hcar;                                   /* final half-carry             */
  wire         alu_neg;                                    /* final negate                 */
  wire         alu_one;                                    /* final one                    */
  wire         alu_sign;                                   /* final sign                   */
  wire         alu_zero;                                   /* final zero                   */
  wire         bit7, bit6, bit5, bit4;                     /* bit decode                   */
  wire         bit3, bit2, bit1, bit0;
  wire         carry_bit;                                  /* carry flag                   */
  wire         carry_daa;                                  /* daa carry                    */
  wire         cry_nxt;                                    /* combined carry               */
  wire         daa_l1, daa_l2, daa_l3, daa_l4;             /* decimal adjust               */
  wire         daa_l5, daa_h1, daa_h2, daa_h3;
  wire         daa_h4, daa_h5, daa_h6, daa_h7;
  wire         daa1, daa2, daa3, daa4, daa5;
  wire         daa6, daa7;
  wire         hcar_nxt;                                   /* combined half-carry          */
  wire         hi_byte;                                    /* replicate data byte          */
  wire         ld_m_aa, ld_m_ff, ld_m_bb, ld_m_cc;         /* register loads               */
  wire         ld_m_dd, ld_m_ee, ld_m_hh, ld_m_ll;
  wire         ld_a_aa, ld_a_ff, ld_a_bb, ld_a_cc;
  wire         ld_a_dd, ld_a_ee, ld_a_hh, ld_a_ll;
  wire         ld_sp;
  wire         ld_tmp;
  wire         ld_dout_mem;                    /* load data out                */
  wire         ld_flag;                                    /* load flags                   */
  wire         ld_regf;                                    /* load register file           */
  wire         logic_c;                                    /* logic carry                  */
  wire         logic_hc;                                   /* logic half-carry             */
  wire         one_nxt;                                    /* combined one                 */
  wire         par_bit;                                    /* parity flag                  */
  wire         par_nxt;                                    /* combined parity              */
  wire         sign_bit;                                   /* sign flag                    */
  wire         sign_nxt;                                   /* combined sign                */
  wire         zero_bit;                                   /* zero flag                    */
  wire         zero_nxt;                                   /* combined zero                */
  wire   [7:0] bit_mask;                                   /* mask for bit inst            */
  wire   [7:0] daa_out;                                    /* daa result                   */
  wire   [7:0] ff_reg_in;                                  /* register input               */
  wire   [7:0] aa_reg_out, ff_reg_out;                     /* register outputs             */
  wire   [7:0] new_flags;                                  /* new flag byte                */
  wire  [15:8] bsign_ext;                                  /* address alu b sign extend    */
  wire  [15:0] adda_in, addb_in;                           /* address alu inputs           */
  wire  [15:0] adder_out;                                  /* math result                  */
  wire  [15:0] addr_alu, addr_hl, addr_pc, addr_sp;        /* address mux terms            */
  wire  [15:0] addr_reg_in;                                /* address register input       */
  wire  [15:0] alua_in, alub_in;                           /* alu inputs                   */
  wire  [15:0] data_bus;                                   /* alu output                   */
  wire  [15:0] de_reg_in;                                  /* register inputs              */
  wire  [15:0] af_reg_out, bc_reg_out;                     /* register outputs             */
  wire  [15:0] de_reg_out, hl_reg_out;
  wire  [15:0] logic_out;                                  /* logic result                 */

  reg          alt_af_reg, alt_bnk_reg;                    /* main/alt select              */
  reg          alu_ovflo;                                  /* final ov                     */
  reg          daa_sel, daa_op;                            /* daa operation                */
  reg          decr_sel, decr_op;                          /* decrement operation          */
  reg          ex_dehl_reg;                                /* special exchange             */
  reg          ld_pc;                                      /* load pc                      */
  reg          nmi_hld;                                    /* nmi edge tracker             */
  reg          nmi_reg;                                    /* latched nmi req              */
  reg          valid_nmi, valid_xhlt;           /* valid int request            */
  reg          word_sel, word_op;                          /* 16-bit operation             */
  reg          xhlt_reg;                                   /* halt exit                    */
  reg    [3:0] page_reg /* synthesis syn_preserve=1 */;
  reg    [7:0] inst_reg;                                   /* instruction register         */
  reg    [7:0] m_aa_reg, m_ff_reg, m_bb_reg, m_cc_reg;     /* individual registers         */
  reg    [7:0] m_dd_reg, m_ee_reg, m_hh_reg, m_ll_reg;
  reg    [7:0] a_aa_reg, a_ff_reg, a_bb_reg, a_cc_reg;
  reg    [7:0] a_dd_reg, a_ee_reg, a_hh_reg, a_ll_reg;
  reg    [7:0] din0_reg, din1_reg;                         /* data input registers         */
  reg    [7:0] dout_mem_reg;                  /* data output registers        */
  reg   [15:0] adda_out;                                   /* address alu out              */
  reg   [15:0] pc_reg;                                     /* program counter              */
  reg   [15:0] sp_reg;                                     /* stack pointer                */
  reg   [15:0] tmp_reg;                                    /* temporary register           */
  reg [`ADCTL_IDX:0] addsel_reg  /* synthesis syn_preserve=1 */;
  reg  [`ALUA_IDX:0] alua_reg    /* synthesis syn_preserve=1 */;
  reg  [`ALUB_IDX:0] alub_reg    /* synthesis syn_preserve=1 */;
  reg [`ALUOP_IDX:0] aluop_reg   /* synthesis syn_preserve=1 */;

  /*****************************************************************************************/
  /*                                                                                       */
  /* input synchronization                                                                 */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (posedge clkc or negedge resetb) begin
    if (!resetb) begin
      nmi_hld    <= 1'b0;
      valid_nmi  <= 1'b0;
      valid_xhlt <= 1'b0;
      end
    else begin
      nmi_hld    <= (nmi_req && !valid_nmi) || (!(nmi_reg) && nmi_hld);
      valid_nmi  <= nmi_req || nmi_hld;
      valid_xhlt <= (nmi_req || nmi_hld);
      end
    end



  always @ (posedge clkc or negedge resetb) begin
    if (!resetb) begin
      nmi_reg  <= 1'b0;
      xhlt_reg <= 1'b0;
      end
    else begin
      nmi_reg  <= valid_nmi;
      xhlt_reg <= valid_xhlt;
      end
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* register control                                                                      */
  /*                                                                                       */
  /*****************************************************************************************/
  always @* begin
    case (pc_sel)
      `PC_LD:    ld_pc = !wait_st;                         /* load PC unconditionally      */
      `PC_NILD:  ld_pc = !(valid_nmi) && !wait_st;
      `PC_NILD2: ld_pc = !wait_st;     /* if no latched int     */
      default:   ld_pc = 1'b0;
      endcase
    end

  always @ (posedge clkc or negedge resetb) begin
    if (!resetb) begin
      alt_af_reg  <= 1'b0;
      alt_bnk_reg <= 1'b0;
      ex_dehl_reg <= 1'b0;
      end
    else begin
      alt_af_reg  <= ex_af_pls   ^ alt_af_reg;
      alt_bnk_reg <= ex_bank_pls ^ alt_bnk_reg;
      ex_dehl_reg <= ex_dehl_inst && ld_ctrl;
      end
    end

  assign ld_flag = (sflg_en || zflg_en || |hflg_ctl || |nflg_ctl ||
                    cflg_en) && !wait_st;
  assign ld_regf = wr_addr[`WR_REG] && !wait_st;

  /*****************************************************************************************/
  /*                                                                                       */
  /* cpu register interface                                                                */
  /*                                                                                       */
  /*****************************************************************************************/
  assign ff_reg_in    = (ld_flag)     ? new_flags : data_bus[7:0];
  assign de_reg_in    = (ex_dehl_reg) ? hl_reg_out : data_bus;

  assign ld_m_aa =   ld_regf && wr_addr[`WR_AA] && !alt_af_reg;
  assign ld_m_ff = ((ld_regf && wr_addr[`WR_FF]) || ld_flag) && !alt_af_reg;
  assign ld_m_bb =   ld_regf && wr_addr[`WR_BB] && !alt_bnk_reg;
  assign ld_m_cc =   ld_regf && wr_addr[`WR_CC] && !alt_bnk_reg;
  assign ld_m_dd =   ld_regf && wr_addr[`WR_DD] && !alt_bnk_reg;
  assign ld_m_ee =   ld_regf && wr_addr[`WR_EE] && !alt_bnk_reg;
  assign ld_m_hh =   ld_regf && wr_addr[`WR_HH] && !alt_bnk_reg;
  assign ld_m_ll =   ld_regf && wr_addr[`WR_LL] && !alt_bnk_reg;
  assign ld_a_aa =   ld_regf && wr_addr[`WR_AA] &&  alt_af_reg;
  assign ld_a_ff = ((ld_regf && wr_addr[`WR_FF]) || ld_flag) &&  alt_af_reg;
  assign ld_a_bb =   ld_regf && wr_addr[`WR_BB] &&  alt_bnk_reg;
  assign ld_a_cc =   ld_regf && wr_addr[`WR_CC] &&  alt_bnk_reg;
  assign ld_a_dd =   ld_regf && wr_addr[`WR_DD] &&  alt_bnk_reg;
  assign ld_a_ee =   ld_regf && wr_addr[`WR_EE] &&  alt_bnk_reg;
  assign ld_a_hh =   ld_regf && wr_addr[`WR_HH] &&  alt_bnk_reg;
  assign ld_a_ll =   ld_regf && wr_addr[`WR_LL] &&  alt_bnk_reg;
  assign ld_sp   =   ld_regf && wr_addr[`WR_SP];
  assign ld_tmp  =   ld_regf && wr_addr[`WR_TMP];

  assign af_reg_out = (alt_af_reg)  ? {a_aa_reg, a_ff_reg} : {m_aa_reg, m_ff_reg};
  assign bc_reg_out = (alt_bnk_reg) ? {a_bb_reg, a_cc_reg} : {m_bb_reg, m_cc_reg};
  assign de_reg_out = (alt_bnk_reg) ? {a_dd_reg, a_ee_reg} : {m_dd_reg, m_ee_reg};
  assign hl_reg_out = (alt_bnk_reg) ? {a_hh_reg, a_ll_reg} : {m_hh_reg, m_ll_reg};
  assign aa_reg_out = af_reg_out[15:8];
  assign ff_reg_out = af_reg_out[7:0];
  assign carry_bit  = af_reg_out[0];
  assign par_bit    = af_reg_out[2];
  assign sign_bit   = af_reg_out[7];
  assign zero_bit   = af_reg_out[6];
  assign hi_byte    = (wr_addr[`WR_AA] && !wr_addr[`WR_FF]) ||
                      (wr_addr[`WR_BB] && !wr_addr[`WR_CC]) ||
                      (wr_addr[`WR_DD] && !wr_addr[`WR_EE]) ||
                      (wr_addr[`WR_HH] && !wr_addr[`WR_LL]);

  /*****************************************************************************************/
  /*                                                                                       */
  /* cpu registers                                                                         */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (posedge clkc or negedge clearb) begin
    if (!clearb) begin
      m_aa_reg <= 8'h00;
      m_ff_reg <= 8'h00;
      m_bb_reg <= 8'h00;
      m_cc_reg <= 8'h00;
      m_dd_reg <= 8'h00;
      m_ee_reg <= 8'h00;
      m_hh_reg <= 8'h00;
      m_ll_reg <= 8'h00;
      a_aa_reg <= 8'h00;
      a_ff_reg <= 8'h00;
      a_bb_reg <= 8'h00;
      a_cc_reg <= 8'h00;
      a_dd_reg <= 8'h00;
      a_ee_reg <= 8'h00;
      a_hh_reg <= 8'h00;
      a_ll_reg <= 8'h00;
      end
    else begin
      if (ld_m_aa) m_aa_reg <= data_bus[15:8];
      if (ld_m_ff) m_ff_reg <= ff_reg_in;
      if (ld_m_bb) m_bb_reg <= data_bus[15:8];
      if (ld_m_cc) m_cc_reg <= data_bus[7:0];
      if (ld_m_dd) m_dd_reg <= de_reg_in[15:8];
      if (ld_m_ee) m_ee_reg <= de_reg_in[7:0];
      if (ld_m_hh) m_hh_reg <= data_bus[15:8];
      if (ld_m_ll) m_ll_reg <= data_bus[7:0];
      if (ld_a_aa) a_aa_reg <= data_bus[15:8];
      if (ld_a_ff) a_ff_reg <= ff_reg_in;
      if (ld_a_bb) a_bb_reg <= data_bus[15:8];
      if (ld_a_cc) a_cc_reg <= data_bus[7:0];
      if (ld_a_dd) a_dd_reg <= de_reg_in[15:8];
      if (ld_a_ee) a_ee_reg <= de_reg_in[7:0];
      if (ld_a_hh) a_hh_reg <= data_bus[15:8];
      if (ld_a_ll) a_ll_reg <= data_bus[7:0];
      end
    end

  always @ (posedge clkc or negedge resetb) begin
    if (!resetb) begin
      pc_reg  <= 16'h0000;
      sp_reg  <= 16'h0000;
      tmp_reg <= 16'h0000;
      end
    else begin
      if (ld_pc)  pc_reg  <= data_bus;
      if (ld_sp)  sp_reg  <= data_bus;
      if (ld_tmp) tmp_reg <= data_bus;
      end
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* data input and data output registers                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  assign ld_dout_mem  = do_ctl[1] && !wait_st;

  always @ (posedge clkc or negedge resetb) begin
    if (!resetb) begin
      din0_reg     <= 8'h00;
      din1_reg     <= 8'h00;
      dout_mem_reg <= 8'h00;
      end
    else begin
      if (di_ctl[0])   din0_reg     <= data_in;
      if (di_ctl[1])   din1_reg     <= data_in;
      if (ld_dout_mem) dout_mem_reg <= (do_ctl[0]) ? data_bus[15:8] : data_bus[7:0];
      end
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* instruction and page registers                                                        */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (posedge clkc or negedge resetb) begin
    if      (!resetb) inst_reg <= 8'h00;
    else if (ld_inst) inst_reg <= data_in;
    end

  always @ (posedge clkc or negedge resetb) begin
    if                 (!resetb) page_reg <= 4'b0000;
    else if (ld_page && ld_ctrl) page_reg <= page_sel;
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu control pipeline registers                                                        */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (aluop_sel) begin
    case (aluop_sel) //synopsys parallel_case
      `ALUOP_DAA:  daa_sel = 1'b1;
      default:     daa_sel = 1'b0;
      endcase
    end

  always @ (aluop_sel) begin
    case (aluop_sel) //synopsys parallel_case
      `ALUOP_BDEC: decr_sel = 1'b1;
      default:     decr_sel = 1'b0;
      endcase
    end

  always @ (aluop_sel) begin
    case (aluop_sel) //synopsys parallel_case
      `ALUOP_ADC,
      `ALUOP_ADD,
      `ALUOP_PASS,
      `ALUOP_SBC,
      `ALUOP_SUB:  word_sel = 1'b1;
      default:     word_sel = 1'b0;
      endcase
    end

  always @ (posedge clkc or negedge resetb) begin
    if (!resetb) begin
      addsel_reg <= `ADD_RSTVAL;
      alua_reg   <= `ALUA_RSTVAL;
      alub_reg   <= `ALUB_RSTVAL;
      aluop_reg  <= `ALUOP_RSTVAL;
      daa_op     <= 1'b0;
      decr_op    <= 1'b0;
      word_op    <= 1'b0;
      end
    else if (ld_ctrl) begin
      addsel_reg <= add_sel;
      alua_reg   <= alua_sel;
      alub_reg   <= alub_sel;
      aluop_reg  <= aluop_sel;
      daa_op     <= daa_sel;
      decr_op    <= decr_sel;
      word_op    <= word_sel;
      end
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* bit manipulation constant generator                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  assign bit7     = (inst_reg[7] && !inst_reg[6]) ^ (inst_reg[5:3] == 3'b111);
  assign bit6     = (inst_reg[7] && !inst_reg[6]) ^ (inst_reg[5:3] == 3'b110);
  assign bit5     = (inst_reg[7] && !inst_reg[6]) ^ (inst_reg[5:3] == 3'b101);
  assign bit4     = (inst_reg[7] && !inst_reg[6]) ^ (inst_reg[5:3] == 3'b100);
  assign bit3     = (inst_reg[7] && !inst_reg[6]) ^ (inst_reg[5:3] == 3'b011);
  assign bit2     = (inst_reg[7] && !inst_reg[6]) ^ (inst_reg[5:3] == 3'b010);
  assign bit1     = (inst_reg[7] && !inst_reg[6]) ^ (inst_reg[5:3] == 3'b001);
  assign bit0     = (inst_reg[7] && !inst_reg[6]) ^ (inst_reg[5:3] == 3'b000);
  assign bit_mask = {bit7, bit6, bit5, bit4, bit3, bit2, bit1, bit0};

  /*****************************************************************************************/
  /*                                                                                       */
  /* decimal adjust accumulator constant generator                                         */
  /*                                                                                       */
  /*****************************************************************************************/
  assign daa_l1 = !ff_reg_out[1] && !ff_reg_out[4] &&
                  (!aa_reg_out[3] || (aa_reg_out[3] && !aa_reg_out[2] && !aa_reg_out[1]));
  assign daa_l2 = !ff_reg_out[1] && !ff_reg_out[4] &&
                  (aa_reg_out[3] && (aa_reg_out[2] || aa_reg_out[1]));
  assign daa_l3 = !ff_reg_out[1] &&  ff_reg_out[4] && (!aa_reg_out[3] && !aa_reg_out[2]);
  assign daa_l4 =  ff_reg_out[1] && !ff_reg_out[4] &&
                  (!aa_reg_out[3] || (aa_reg_out[3] && !aa_reg_out[2] && !aa_reg_out[1]));
  assign daa_l5 =  ff_reg_out[1] &&  ff_reg_out[4] &&
                  ((!aa_reg_out[3] && aa_reg_out[2] && aa_reg_out[1]) || aa_reg_out[3]);
  assign daa_h1 = !ff_reg_out[0] && (aa_reg_out[7] && (aa_reg_out[6] || aa_reg_out[5]));
  assign daa_h2 =  ff_reg_out[0] &&
                  (!aa_reg_out[7] && !aa_reg_out[6] && (!aa_reg_out[5] || !aa_reg_out[4]));
  assign daa_h3 = !ff_reg_out[0] &&
                  (aa_reg_out[7] && (aa_reg_out[6] || aa_reg_out[5] || aa_reg_out[4]));
  assign daa_h4 =  ff_reg_out[0] && (!aa_reg_out[7] && !aa_reg_out[6]);
  assign daa_h5 =  ff_reg_out[0] &&
                  ((aa_reg_out[6] && aa_reg_out[5] && aa_reg_out[4]) || aa_reg_out[7]);
  assign daa_h6 = !ff_reg_out[0] &&
                  ((!aa_reg_out[6] && !aa_reg_out[5] && !aa_reg_out[4]) || !aa_reg_out[7]);
  assign daa_h7 =  ff_reg_out[0] && ((aa_reg_out[6] && aa_reg_out[5]) || aa_reg_out[7]);

  assign daa1   = daa_l2 || daa_l3 || daa_l5;
  assign daa2   = daa_l2 || daa_l3;
  assign daa3   = daa_l5;
  assign daa4   = daa_l5 && (daa_h6 || daa_h7);
  assign daa5   = (daa_l1 && (daa_h1 || daa_h2)) || (daa_l2 && (daa_h2 || daa_h3)) ||
                  (daa_l3 && (daa_h1 || daa_h4)) || (daa_l4 && daa_h5) ||
                  (daa_l5 && daa_h6);
  assign daa6   = (daa_l1 && (daa_h1 || daa_h2)) || (daa_l2 && (daa_h2 || daa_h3)) ||
                  (daa_l3 && (daa_h1 || daa_h4)) || (daa_l5 && daa_h6);
  assign daa7   = (daa_l4 && daa_h5) || (daa_l5 && (daa_h6 || daa_h7));

  assign daa_out   = {daa7, daa6, daa5, daa4, daa3, daa2, daa1, 1'b0};
  assign carry_daa = (daa_l1 && (daa_h1 || daa_h2)) || (daa_l2 && (daa_h2 || daa_h3)) ||
                     (daa_l3 && (daa_h1 || daa_h4)) || (daa_l4 && daa_h5) ||
                     (daa_l5 && daa_h7);


  /*****************************************************************************************/
  /*                                                                                       */
  /* alu input selects                                                                     */
  /*                                                                                       */
  /*****************************************************************************************/
  aluamux AMUX ( .adda_in(adda_in), .alua_in(alua_in), .alua_reg(alua_reg),
                 .aa_reg_out(aa_reg_out), .bit_mask(bit_mask), .daa_out(daa_out),
                 .hl_reg_out(hl_reg_out),
                 .pc_reg(pc_reg) );

  alubmux BMUX ( .addb_in(addb_in), .alub_in(alub_in), .alub_reg(alub_reg),
                 .af_reg_out(af_reg_out), .bc_reg_out(bc_reg_out), .de_reg_out(de_reg_out),
                 .din0_reg(din0_reg), .din1_reg(din1_reg), .hl_reg_out(hl_reg_out),
                 .pc_reg(pc_reg), .sp_reg(sp_reg),
                 .tmp_reg(tmp_reg) );

  /*****************************************************************************************/
  /*                                                                                       */
  /* function units                                                                        */
  /*                                                                                       */
  /*****************************************************************************************/
  alu_log  ALULOG  ( .logic_c(logic_c), .logic_hc(logic_hc), .logic_out(logic_out),
                     .alua_in(alua_in), .alub_in(alub_in), .aluop_reg(aluop_reg[`AOP_IDX:0]),
                     .carry_bit(carry_bit) );

  alu_math ALUMATH ( .adder_c(adder_c), .adder_hc(adder_hc), .adder_out(adder_out),
                     .adder_ov(adder_ov), .alua_in(alua_in), .alub_in(alub_in),
                     .aluop_reg(aluop_reg[`AOP_IDX:0]), .carry_bit(carry_bit),
                     .carry_daa(carry_daa), .daa_op(daa_op), .word_op(word_op) );


  aluout   ALUOUT  ( .cry_nxt(cry_nxt), .data_bus(data_bus), .hcar_nxt(hcar_nxt),
                     .one_nxt(one_nxt), .par_nxt(par_nxt), .sign_nxt(sign_nxt),
                     .zero_nxt(zero_nxt), .adder_c(adder_c), .adder_hc(adder_hc),
                     .adder_out(adder_out), .hi_byte(hi_byte), .logic_c(logic_c),
                     .logic_hc(logic_hc), .logic_out(logic_out),
                     .unit_sel(aluop_reg[7:6]), .word_op(word_op) );

  /*****************************************************************************************/
  /*                                                                                       */
  /* flag generation                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  assign alu_carry = decr_op ^ cry_nxt;
  assign alu_hcar  = (hflg_ctl[1]) ? hflg_ctl[0] : (decr_op ^ hcar_nxt);
  assign alu_neg   = (nflg_ctl[1]) ? nflg_ctl[0] : sign_nxt;
  assign alu_one   = one_nxt;
  assign alu_sign  = sign_nxt;
  assign alu_zero  = zero_nxt;

  assign new_flags[7] = (sflg_en)   ? alu_sign  : ff_reg_out[7];
  assign new_flags[6] = (zflg_en)   ? alu_zero  : ff_reg_out[6];
  assign new_flags[5] =                           ff_reg_out[5];
  assign new_flags[4] = (|hflg_ctl) ? alu_hcar  : ff_reg_out[4];
  assign new_flags[3] =                           ff_reg_out[3];
  assign new_flags[1] = (|nflg_ctl) ? alu_neg   : ff_reg_out[1];
  assign new_flags[0] = (cflg_en)   ? alu_carry : ff_reg_out[0];

  /*****************************************************************************************/
  /*                                                                                       */
  /* address alu                                                                           */
  /*                                                                                       */
  /*****************************************************************************************/
  assign bsign_ext = {addb_in[7],  addb_in[7],  addb_in[7],  addb_in[7],
                      addb_in[7],  addb_in[7],  addb_in[7],  addb_in[7]};

  always @ (aluop_reg or adda_in or addb_in or bsign_ext) begin
    case (aluop_reg)
      `ALUOP_ADS:  adda_out = adda_in + {bsign_ext[15:8], addb_in[7:0]};
      `ALUOP_ADD:  adda_out = adda_in + addb_in;
      `ALUOP_APAS: adda_out = adda_in;
      default:     adda_out = addb_in;
      endcase
    end

  assign addr_alu = (addsel_reg[`AD_ALU]) ? adda_out   : 16'h0000;
  assign addr_hl  = (addsel_reg[`AD_HL])  ? hl_reg_out : 16'h0000;
  assign addr_pc  = (addsel_reg[`AD_PC])  ? pc_reg     : 16'h0000;
  assign addr_sp  = (addsel_reg[`AD_SP])  ? sp_reg     : 16'h0000;

  assign addr_reg_in = addr_alu | addr_hl | addr_pc | addr_sp;

  endmodule











