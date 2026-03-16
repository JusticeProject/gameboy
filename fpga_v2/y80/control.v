/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** control module                                                   Rev  0.0  08/22/2011 **/
/**                                                                                       **/
/*******************************************************************************************/
module control (add_sel, alua_sel, alub_sel, aluop_sel, cflg_en, di_ctl, do_ctl, ex_af_pls,
                ex_bank_pls, ex_dehl_inst, hflg_ctl, if_frst,
                ld_inst, ld_page, nflg_ctl, output_inh,
                page_sel, pc_sel, rd_frst, sflg_en, state_nxt,
                tran_sel, wr_addr, wr_frst, zflg_en, carry_bit, inst_reg,
                page_reg, par_bit, sign_bit, state_reg, zero_bit);

  input         carry_bit;     /* carry flag                                               */
  input         par_bit;       /* parity flag                                              */
  input         sign_bit;      /* sign flag                                                */
  input         zero_bit;      /* zero flag                                                */
  input   [3:0] page_reg;      /* instruction decode "page"                                */
  input   [7:0] inst_reg;      /* instruction register                                     */
  input   [`STATE_IDX:0] state_reg;     /* current processor state                         */
  output        cflg_en;       /* carry flag control                                       */
  output        ex_af_pls;     /* exchange af,af'                                          */
  output        ex_bank_pls;   /* exchange register bank                                   */
  output        ex_dehl_inst;  /* exchange de,hl                                           */
  output        if_frst;       /* ifetch first cycle                                       */
  output        ld_inst;       /* load instruction register                                */
  output        ld_page;       /* load page register                                       */
  output        output_inh;    /* disable cpu outputs                                      */
  output        rd_frst;       /* read first cycle                                         */
  output        sflg_en;       /* sign flag control                                        */
  output        wr_frst;       /* write first cycle                                        */
  output        zflg_en;       /* zero flag control                                        */
  output  [3:0] page_sel;      /* instruction decode "page" control                        */
  output [`ADCTL_IDX:0] add_sel;     /* address output mux control                         */
  output  [`ALUA_IDX:0] alua_sel;    /* alu input a mux control                            */
  output  [`ALUB_IDX:0] alub_sel;    /* alu input b mux control                            */
  output [`ALUOP_IDX:0] aluop_sel;   /* alu operation control                              */
  output    [`DI_IDX:0] di_ctl;      /* data input control                                 */
  output    [`DO_IDX:0] do_ctl;      /* data output control                                */
  output  [`HFLG_IDX:0] hflg_ctl;    /* half-carry flag control                            */
  output  [`NFLG_IDX:0] nflg_ctl;    /* negate flag control                                */
  output [`PCCTL_IDX:0] pc_sel;      /* program counter source control                     */
  output [`STATE_IDX:0] state_nxt;   /* next processor state                               */
  output [`TTYPE_IDX:0] tran_sel;    /* transaction type select                            */
  output  [`WREG_IDX:0] wr_addr;     /* register write address bus                         */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  reg           cflg_en;                                   /* carry flag control           */
  reg           ex_af_pls;                                 /* exchange af,af'              */
  reg           ex_bank_pls;                               /* exchange register bank       */
  reg           ex_dehl_inst;                              /* exchange de,hl               */
  reg           if_frst;                                   /* first clock if ifetch        */
  reg           ld_inst;                                   /* load instruction register    */
  reg           ld_page;                                   /* load page register           */
  reg           output_inh;                                /* disable cpu outputs          */
  reg           rd_frst;                                   /* first clock of read          */
  reg           sflg_en;                                   /* sign flag control            */
  reg           wr_frst;                                   /* first clock of write         */
  reg           zflg_en;                                   /* zero flag control            */
  reg     [3:0] page_sel;                                  /* inst decode page control     */
  reg   [`ADCTL_IDX:0] add_sel;                            /* address output mux control   */
  reg    [`ALUA_IDX:0] alua_sel;                           /* alu input a mux control      */
  reg    [`ALUB_IDX:0] alub_sel;                           /* alu input b mux control      */
  reg   [`ALUOP_IDX:0] aluop_sel;                          /* alu operation control        */
  reg      [`DI_IDX:0] di_ctl;                             /* data input control           */
  reg      [`DO_IDX:0] do_ctl;                             /* data output control          */
  reg    [`HFLG_IDX:0] hflg_ctl;                           /* half-carry flag control      */
  reg    [`NFLG_IDX:0] nflg_ctl;                           /* negate flag control          */
  reg   [`PCCTL_IDX:0] pc_sel;                             /* pc source control            */
  reg   [`STATE_IDX:0] state_nxt;                          /* machine state                */
  reg   [`TTYPE_IDX:0] tran_sel;                           /* transaction type             */
  reg    [`WREG_IDX:0] wr_addr;                            /* register write address bus   */

  /*****************************************************************************************/
  /*                                                                                       */
  /* exchange instruction control                                                          */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `IF1B: begin
        case ({page_reg, inst_reg})
          12'b000000001000: ex_af_pls = 1'b1;
          default:          ex_af_pls = 1'b0;
          endcase
        end
      default:              ex_af_pls = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `IF1B: begin
        case ({page_reg, inst_reg})
          12'b000011011001: ex_bank_pls = 1'b1;
          default:          ex_bank_pls = 1'b0;
          endcase
        end
      default:              ex_bank_pls = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `DEC1: begin
        case (inst_reg)
          8'b11101011:      ex_dehl_inst = 1'b1;
          default:          ex_dehl_inst = 1'b0;
          endcase
        end
      default:              ex_dehl_inst = 1'b0;
      endcase
    end



  /*****************************************************************************************/
  /*                                                                                       */
  /* identifiers to create timing signals                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1,
      `DEC2,
      `OF2A,
      `IF3A,
      `IF1A:                if_frst = 1'b1;
      default:              if_frst = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `RD1A,
      `RD2A:                rd_frst = 1'b1;
      default:              rd_frst = 1'b0;
      endcase
    end

  always @ (state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR1A,
      `WR2A:                wr_frst = 1'b1;
      default:              wr_frst = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* instruction register and page register control                                        */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `IF2B,
      `IF3B,
      `IF1B:                ld_inst = 1'b1;
      default:              ld_inst = 1'b0;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `DEC1: begin
        case (inst_reg)
          8'b11001011:      page_sel = `CB_PAGE;
          default:          page_sel = `MAIN_PG;
          endcase
        end
      `DEC2: begin
        casex ({page_reg, inst_reg})
          default:          page_sel = `MAIN_PG;
          endcase
        end
      default:              page_sel = `MAIN_PG;
      endcase
    end

  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1:                ld_page = 1'b1;
      `DEC2: begin
        casex ({page_reg, inst_reg})
          12'bx10x11001011: ld_page = 1'b1;
          default:          ld_page = 1'b0;
          endcase
        end
      default:              ld_page = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  next state control                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or
            par_bit or sign_bit or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00xxx110,                               // LD A,n8
          8'b11000011:      state_nxt = `sOF1B;      // JP n16
          8'b01110110:      state_nxt = `sPCO;       // HALT
          default:          state_nxt = `sIF1B;
          endcase
        end
      `PCA:                 state_nxt = `sPCO;
      `PCO: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000001110110: state_nxt = `sHLTA;
          default:          state_nxt = `sIF1A;
          endcase
        end
      `HLTA:                state_nxt = `sHLTB;
      `HLTB:                state_nxt = `sHLTA;
      `IF1A:                state_nxt = `sIF1B;
      `IF1B:                state_nxt = `sDEC1;
      `RSTE:                state_nxt = `sIF1A;
      default:              state_nxt = `sRSTE;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  transaction type control                                                             */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or
            par_bit or sign_bit or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `IF2B:                tran_sel = `TRAN_IF;
      `OF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          default:          tran_sel = `TRAN_IF;
          endcase
        end
      `PCO: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          default:          tran_sel = `TRAN_IF;
          endcase
        end
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          default:          tran_sel = `TRAN_IF;
          endcase
        end
      `HLTB:                tran_sel = `TRAN_IDL;
      `RSTE:                tran_sel = `TRAN_IF;
      default:              tran_sel = `TRAN_RSTVAL;
      endcase
    end


  /*****************************************************************************************/
  /*                                                                                       */
  /*  output inhibit                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg)
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b000011110011,
          12'b0001xxxxxxxx: output_inh = 1'b0;
          default:          output_inh = 1'b1;
          endcase
        end
      `PCO,
      `HLTB: begin
        casex ({page_reg, inst_reg})
          default:          output_inh = 1'b0;
          endcase
        end
      default:              output_inh = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  address output control                                                               */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or
            zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00000010,
          8'b00001010,
          8'b00010010,
          8'b00011010,
          8'b11101001,
          8'b11xx0101,
          8'b11xxx111:      add_sel = `ADD_ALU;
          8'b00110100,
          8'b00110101,
          8'b00110110,
          8'b011100xx,
          8'b0111010x,
          8'b01110111,
          8'b010xx110,
          8'b0110x110,
          8'b01111110,
          8'b10000110,
          8'b10001110,
          8'b10010110,
          8'b10011110,
          8'b10100110,
          8'b10101110,
          8'b10110110,
          8'b10111110:      add_sel = `ADD_HL;
          8'b11000000:      add_sel = ( !zero_bit) ? `ADD_SP : `ADD_PC;
          8'b11001000:      add_sel = (  zero_bit) ? `ADD_SP : `ADD_PC;
          8'b11010000:      add_sel = (!carry_bit) ? `ADD_SP : `ADD_PC;
          8'b11011000:      add_sel = ( carry_bit) ? `ADD_SP : `ADD_PC;
          8'b11100000:      add_sel = (  !par_bit) ? `ADD_SP : `ADD_PC;
          8'b11101000:      add_sel = (   par_bit) ? `ADD_SP : `ADD_PC;
          8'b11110000:      add_sel = ( !sign_bit) ? `ADD_SP : `ADD_PC;
          8'b11111000:      add_sel = (  sign_bit) ? `ADD_SP : `ADD_PC;
          8'b11xx0001,
          8'b11100011,
          8'b11001001:      add_sel = `ADD_SP;
          default:          add_sel = `ADD_PC;
          endcase
        end
      `IF1A:                add_sel = `ADD_PC;
      default:              add_sel = `ADD_RSTVAL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  program counter control                                                              */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00000000,
          8'b00000111,
          8'b00001000,
          8'b00001111,
          8'b00010111,
          8'b00011111,
          8'b00100111,
          8'b00101111,
          8'b00110111,
          8'b00111111,
          8'b000xx10x,
          8'b0010x10x,
          8'b0011110x,
          8'b00xx0011,
          8'b00xx1001,
          8'b00xx1011,
          8'b010xx0xx,
          8'b0110x0xx,
          8'b011110xx,
          8'b010xx10x,
          8'b0110x10x,
          8'b0111110x,
          8'b010xx111,
          8'b0110x111,
          8'b01111111,
          8'b10xxx0xx,
          8'b10xxx10x,
          8'b10xxx111,
          8'b11011001,
          8'b11101011,
          8'b11111001,
          8'b11111011:      pc_sel = `PC_NILD;
          8'b01110110,
          8'b11xxx111:      pc_sel = `PC_NUL;
          8'b00000010,
          8'b00001010,
          8'b00010010,
          8'b00011010,
          8'b00110100,
          8'b00110101,
          8'b011100xx,
          8'b0111010x,
          8'b01110111,
          8'b010xx110,
          8'b0110x110,
          8'b01111110,
          8'b10000110,
          8'b10001110,
          8'b10010110,
          8'b10011110,
          8'b10100110,
          8'b10101110,
          8'b10110110,
          8'b10111110,
          8'b11xx0001,
          8'b11xx0101,
          8'b11100011:      pc_sel = `PC_NUL;
          default:          pc_sel = `PC_LD;
          endcase
        end
      `IF1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b0001xxxxxxxx: pc_sel = `PC_LD;
          12'b1xxx10110000,
          12'b1xxx10110001,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111000,
          12'b1xxx10111001,
          12'b1xxx10111010,
          12'b1xxx10111011: pc_sel = `PC_NILD2;
          default:          pc_sel = `PC_NILD;
          endcase
        end
      default:              pc_sel = `PC_NUL;
      endcase
    end


  /*****************************************************************************************/
  /*                                                                                       */
  /*  data input register control                                                          */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `OF1B:                di_ctl = `DI_DI10;
      `OF2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b010000110110,
          12'b010100110110: di_ctl = `DI_DI0;
          default:          di_ctl = `DI_DI1;
          endcase
        end
      `RD1B:                di_ctl = `DI_DI0;
      `RD2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000101010,
          12'b000011001001,
          12'b010x00101010,
          12'b010x11100001,
          12'b010x11100011,
          12'b000011100011,
          12'b1xxx01000101,
          12'b1xxx01001101,
          12'b1xxx01xx1011,
          12'b000011xxx000,
          12'b000011xx0001,
          12'b0001xxxxxxxx: di_ctl = `DI_DI1;
          default:          di_ctl = `DI_DI0;
          endcase
        end
      default:              di_ctl = `DI_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  data output register control                                                         */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001101,
          12'b010x11100101,
          12'b000011xxx100,
          12'b000011xx0101,
          12'b000011xxx111,
          12'b0001xxxxxxxx: do_ctl = `DO_MSB;
          default:          do_ctl = `DO_LSB;
          endcase
        end
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000100010,
          12'b010x00100010,
          12'b010x11100011,
          12'b000011100011,
          12'b1xxx01xx0011: do_ctl = `DO_MSB;
          default:          do_ctl = `DO_LSB;
          endcase
        end
      default:              do_ctl = `DO_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  alu operation control                                                                */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or
            zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00xxx100:      aluop_sel = `ALUOP_BADD;           // INC A
          default:          aluop_sel = `ALUOP_PASS;
          endcase
        end
      `IF1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          default:          aluop_sel = `ALUOP_PASS;
          endcase
        end
      default:              aluop_sel = `ALUOP_ADD;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  alu a input control                                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b10000xxx,
          8'b10001xxx,
          8'b10010xxx,
          8'b10011xxx,
          8'b10100xxx,
          8'b10101xxx,
          8'b10110xxx,
          8'b10111xxx:      alua_sel = `ALUA_AA;
          8'b00100111:      alua_sel = `ALUA_DAA;
          8'b00xx1001:      alua_sel = `ALUA_HL;
          8'b00010000,
          8'b00101111,
          8'b00xxx101,
          8'b00xx1011,
          8'b11xx0101,
          8'b11xxx111:      alua_sel = `ALUA_M1;
          default:          alua_sel = `ALUA_ONE;
          endcase
        end
      `IF1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b001001xxxxxx,
          12'b011x01xxx110: alua_sel = `ALUA_BIT;
          12'b1xxx01xxx000,
          12'b1xxx10100011,
          12'b1xxx10101000,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111000,
          12'b1xxx10111010,
          12'b1xxx10111011: alua_sel = `ALUA_M1;
          12'b1xxx10100000,
          12'b1xxx10100010,
          12'b1xxx10110000,
          12'b1xxx10110010: alua_sel = `ALUA_ONE;
          default:          alua_sel = `ALUA_AA;
          endcase
        end
      default:              alua_sel = `ALUA_ONE;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  alu b input control                                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or
            zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `DEC1: begin
        casex (inst_reg) //synopsys parallel_case
          8'b00000111,
          8'b00001111,
          8'b00010111,
          8'b00011111,
          8'b00100111,
          8'b00101111:      alub_sel = `ALUB_AA;
          8'b00010000:      alub_sel = `ALUB_BB;
          8'b00000010,
          8'b00001010:      alub_sel = `ALUB_BC;
          8'b00010010,
          8'b00011010,
          8'b11101011:      alub_sel = `ALUB_DE;
          8'b11101001,
          8'b11111001:      alub_sel = `ALUB_HL;
          8'b01xxx000,
          8'b10xxx000:      alub_sel = `ALUB_BB;
          8'b01xxx001,
          8'b10xxx001:      alub_sel = `ALUB_CC;
          8'b01xxx010,
          8'b10xxx010:      alub_sel = `ALUB_DD;
          8'b01xxx011,
          8'b10xxx011:      alub_sel = `ALUB_EE;
          8'b01xxx100,
          8'b10xxx100:      alub_sel = `ALUB_HH;
          8'b01xxx101,
          8'b10xxx101:      alub_sel = `ALUB_LL;
          8'b01xxx111,
          8'b10xxx111:      alub_sel = `ALUB_AA;
          8'b0000010x:      alub_sel = `ALUB_BB;
          8'b0000110x:      alub_sel = `ALUB_CC;
          8'b0001010x:      alub_sel = `ALUB_DD;
          8'b0001110x:      alub_sel = `ALUB_EE;
          8'b0010010x:      alub_sel = `ALUB_HH;
          8'b0010110x:      alub_sel = `ALUB_LL;
          8'b0011110x:      alub_sel = `ALUB_AA;
          8'b00000011,
          8'b00001001,
          8'b00001011:      alub_sel = `ALUB_BC;
          8'b00010011,
          8'b00011001,
          8'b00011011:      alub_sel = `ALUB_DE;
          8'b00100011,
          8'b00101001,
          8'b00101011:      alub_sel = `ALUB_HL;
          8'b00110011,
          8'b00111001,
          8'b00111011:      alub_sel = `ALUB_SP;
          8'b11xx0101,
          8'b11xxx111:      alub_sel = `ALUB_SP;
          default:          alub_sel = `ALUB_PC;
          endcase
        end
      `IF1A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111011: alub_sel = `ALUB_BB;
          12'b1xxx10100000,
          12'b1xxx10101000,
          12'b1xxx10110000,
          12'b1xxx10111000: alub_sel = `ALUB_DE;
          12'b1xxx10101010,
          12'b1xxx10111010,
          12'b1xxx10100010,
          12'b1xxx10110010: alub_sel = `ALUB_HL;
          default:          alub_sel = `ALUB_DIN;
          endcase
        end
      default:              alub_sel = `ALUB_PC;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  register write control                                                               */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg or carry_bit or par_bit or sign_bit or
            zero_bit) begin
    casex (state_reg) //synopsys parallel_case
      `OF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000010000: wr_addr = `WREG_BB;
          default:          wr_addr = `WREG_NUL;
          endcase
        end
      `OF2B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000011001101: wr_addr = `WREG_SP;
          12'b000011000100: wr_addr = ( !zero_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011001100: wr_addr = (  zero_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011010100: wr_addr = (!carry_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011011100: wr_addr = ( carry_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011100100: wr_addr = (  !par_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011101100: wr_addr = (   par_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011110100: wr_addr = ( !sign_bit) ? `WREG_SP : `WREG_NUL;
          12'b000011111100: wr_addr = (  sign_bit) ? `WREG_SP : `WREG_NUL;
          default:          wr_addr = `WREG_NUL;
          endcase
        end
      `IF3B:                wr_addr = `WREG_TMP;
      `IF1B: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000000111,
          12'b000000001010,
          12'b000000001111,
          12'b000000010111,
          12'b000000011010,
          12'b000000011111,
          12'b000000100111,
          12'b000000101111,
          12'b000000111010,
          12'b000010000xxx,
          12'b000010001xxx,
          12'b000010010xxx,
          12'b000010011xxx,
          12'b000010100xxx,
          12'b000010101xxx,
          12'b000010110xxx,
          12'b000011000110,
          12'b000011001110,
          12'b000011010110,
          12'b000011011011,
          12'b010x10000110,
          12'b010x10001110,
          12'b010x10010110,
          12'b010x10011110,
          12'b010x10100110,
          12'b010x10101110,
          12'b010x10110110,
          12'b000011011110,
          12'b000011100110,
          12'b1xxx01000100,
          12'b1xxx01010111,
          12'b1xxx01011111,
          12'b1xxx01100111,
          12'b1xxx01101111,
          12'b000011101110,
          12'b000011110110: wr_addr = `WREG_AA;
          12'b1xxx10100011,
          12'b1xxx10101011,
          12'b1xxx10110011,
          12'b1xxx10111011: wr_addr = `WREG_BB;
          12'b000000000001,
          12'b1xxx01001011: wr_addr = `WREG_BC;
          12'b000000010001,
          12'b1xxx01011011: wr_addr = `WREG_DE;
          12'b000000100001,
          12'b1xxx01101011: wr_addr = `WREG_HL;
          12'b000000110001,
          12'b1xxx01111011: wr_addr = `WREG_SP;
          12'b1xxx10100000,
          12'b1xxx10101000,
          12'b1xxx10110000,
          12'b1xxx10111000: wr_addr = `WREG_DE;
          12'b000011101011: wr_addr = `WREG_DEHL;
          12'b000000101010,
          12'b000000xx1001,
          12'b000011100011,
          12'b1xxx01xx0010,
          12'b1xxx01xx1010,
          12'b1xxx10100010,
          12'b1xxx10101010,
          12'b1xxx10110010,
          12'b1xxx10111010: wr_addr = `WREG_HL;
          12'b0010000xx000,
          12'b00100010x000,
          12'b001000111000,
          12'b00101xxxx000: wr_addr = `WREG_BB;
          12'b0010000xx001,
          12'b00100010x001,
          12'b001000111001,
          12'b00101xxxx001: wr_addr = `WREG_CC;
          12'b0010000xx010,
          12'b00100010x010,
          12'b001000111010,
          12'b00101xxxx010: wr_addr = `WREG_DD;
          12'b0010000xx011,
          12'b00100010x011,
          12'b001000111011,
          12'b00101xxxx011: wr_addr = `WREG_EE;
          12'b0010000xx100,
          12'b00100010x100,
          12'b001000111100,
          12'b00101xxxx100: wr_addr = `WREG_HH;
          12'b0010000xx101,
          12'b00100010x101,
          12'b001000111101,
          12'b00101xxxx101: wr_addr = `WREG_LL;
          12'b0010000xx111,
          12'b00100010x111,
          12'b001000111111,
          12'b00101xxxx111: wr_addr = `WREG_AA;
          12'b00000000010x,
          12'b000000000110,
          12'b000001000xxx,
          12'b010x01000110,
          12'b1xxx0x000000: wr_addr = `WREG_BB;
          12'b00000000110x,
          12'b000000001110,
          12'b000001001xxx,
          12'b010x01001110,
          12'b1xxx0x001000: wr_addr = `WREG_CC;
          12'b00000001010x,
          12'b000000010110,
          12'b000001010xxx,
          12'b010x01010110,
          12'b1xxx0x010000: wr_addr = `WREG_DD;
          12'b00000001110x,
          12'b000000011110,
          12'b000001011xxx,
          12'b010x01011110,
          12'b1xxx0x011000: wr_addr = `WREG_EE;
          12'b00000010010x,
          12'b000000100110,
          12'b000001100xxx,
          12'b010x01100110,
          12'b1xxx0x100000: wr_addr = `WREG_HH;
          12'b00000010110x,
          12'b000000101110,
          12'b000001101xxx,
          12'b010x01101110,
          12'b1xxx0x101000: wr_addr = `WREG_LL;
          12'b00000011110x,
          12'b000000111110,
          12'b000001111xxx,
          12'b010x01111110,
          12'b1xxx0x111000: wr_addr = `WREG_AA;
          12'b00000000x011: wr_addr = `WREG_BC;
          12'b00000001x011: wr_addr = `WREG_DE;
          12'b00000010x011: wr_addr = `WREG_HL;
          12'b00000011x011: wr_addr = `WREG_SP;
          12'b010x11111001,
          12'b000011111001: wr_addr = `WREG_SP;
          12'b000011000001: wr_addr = `WREG_BC;
          12'b000011010001: wr_addr = `WREG_DE;
          12'b000011100001: wr_addr = `WREG_HL;
          12'b000011110001: wr_addr = `WREG_AF;
          default:          wr_addr = `WREG_NUL;
          endcase
        end
      default:              wr_addr = `WREG_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  s flag control                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b000000110100,
          12'b000000110101,
          12'b001000000xxx,
          12'b001000001xxx,
          12'b001000010xxx,
          12'b001000011xxx,
          12'b001000100xxx,
          12'b001000101xxx,
          12'b001000111xxx,
          12'b010x00110100,
          12'b010x00110101,
          12'b011x00010110,
          12'b011x00000110,
          12'b011x00011110,
          12'b011x00001110,
          12'b011x00100110,
          12'b011x00101110,
          12'b011x00111110: sflg_en = 1'b1;
          default:          sflg_en = 1'b0;
          endcase
        end
      default:              sflg_en = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  z flag control                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `RD1A,
      `RD2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: zflg_en = 1'b1;
          default:          zflg_en = 1'b0;
          endcase
        end
      default:              zflg_en = 1'b0;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  h flag control                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b001000000xxx,
          12'b001000001xxx,
          12'b001000010xxx,
          12'b001000011xxx,
          12'b001000100xxx,
          12'b001000101xxx,
          12'b001000111xxx,
          12'b011x00010110,
          12'b011x00000110,
          12'b011x00011110,
          12'b011x00001110,
          12'b011x00100110,
          12'b011x00101110,
          12'b011x00111110,
          12'b1xxx01100111,
          12'b1xxx01101111: hflg_ctl = `HFLG_0;
          12'b000000110100,
          12'b000000110101,
          12'b010x00110100,
          12'b010x00110101: hflg_ctl = `HFLG_H;
          default:          hflg_ctl = `HFLG_NUL;
          endcase
        end
      default:              hflg_ctl = `HFLG_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  n flag control                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR1A,
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b1xxx10100010,
          12'b1xxx10100011,
          12'b1xxx10101010,
          12'b1xxx10101011,
          12'b1xxx10110010,
          12'b1xxx10110011,
          12'b1xxx10111010,
          12'b1xxx10111011: nflg_ctl = `NFLG_S;
          default:          nflg_ctl = `NFLG_NUL;
          endcase
        end
      default:              nflg_ctl = `NFLG_NUL;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /*  c flag control                                                                       */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (inst_reg or page_reg or state_reg) begin
    casex (state_reg) //synopsys parallel_case
      `WR2A: begin
        casex ({page_reg, inst_reg}) //synopsys parallel_case
          12'b001000000xxx,
          12'b001000001xxx,
          12'b001000010xxx,
          12'b001000011xxx,
          12'b001000100xxx,
          12'b001000101xxx,
          12'b001000111xxx,
          12'b011x00000110,
          12'b011x00001110,
          12'b011x00010110,
          12'b011x00011110,
          12'b011x00100110,
          12'b011x00101110,
          12'b011x00111110: cflg_en = 1'b1;
          default:          cflg_en = 1'b0;
          endcase
        end
      default:              cflg_en = 1'b0;
      endcase
    end

  endmodule





