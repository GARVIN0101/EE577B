`timescale 1ns/1ps
module processor (
    input  wire clk,
    input  wire reset
);
    // ===== ISA opcodes (consistent with decoder) =====
    localparam [0:5] OP_RTYPE = 6'b101010;
    localparam [0:5] OP_LD    = 6'b100000;
    localparam [0:5] OP_SD    = 6'b100001;
    localparam [0:5] OP_BEZ   = 6'b100010;
    localparam [0:5] OP_BNEZ  = 6'b100011;
    localparam [0:5] OP_NOP   = 6'b111100;

    // ================= IF: PC + IMEM =================
    wire        pc_en;
    wire        branch_taken_id;
    wire [0:15] branch_imm16_id;
    wire [0:31] pc_curr;

    pc u_pc (
        .clk          (clk),
        .reset        (reset),
        .en           (pc_en),
        .branch_taken (branch_taken_id),
        .imm16        (branch_imm16_id),
        .pc           (pc_curr)
    );

    wire [0:7]  imem_addr = pc_curr[24:31];
    wire [0:31] if_instr;

    imem u_imem (
        .memAddr (imem_addr),
        .dataOut (if_instr)
    );

    // -------- IF/ID pipeline register --------
    reg  [0:31] ifid_instr;

    // from HDU
    wire hdu_stall;
    wire if_id_hold;
    wire id_ex_flush;

    // branch flush from ID (use combined stall_any later; declared below)
    wire do_branch_flush;

    always @(posedge clk) begin
        if (reset) begin
            ifid_instr <= 32'b0; // NOP after reset
        end else if (do_branch_flush) begin
            ifid_instr <= 32'b0; // flush -> NOP
        end else if (!if_id_hold_any) begin
            ifid_instr <= if_instr;
        end
        // else hold
    end

    // ================= ID: Decode + RF + Branch =================
    wire [0:5]  id_op;
    wire [0:4]  id_rD, id_rA, id_rB;
    wire [0:1]  id_ww;
    wire [0:5]  id_func;
    wire [0:15] id_imm16;
    wire        id_is_rtype, id_is_ld, id_is_sd, id_is_bez, id_is_bnez, id_is_nop;
    wire        id_writes_rD;
    wire [0:4]  id_rS1, id_rS2;
    wire        id_uses_S1, id_uses_S2;

    decoder_cardinal u_dec (
        .instr     (ifid_instr),
        .op        (id_op),
        .rD        (id_rD),
        .rA        (id_rA),
        .rB        (id_rB),
        .ww        (id_ww),
        .func      (id_func),
        .imm16     (id_imm16),
        .is_rtype  (id_is_rtype),
        .is_ld     (id_is_ld),
        .is_sd     (id_is_sd),
        .is_bez    (id_is_bez),
        .is_bnez   (id_is_bnez),
        .is_nop    (id_is_nop),
        .writes_rD (id_writes_rD),
        .rS1       (id_rS1),
        .rS2       (id_rS2),
        .uses_S1   (id_uses_S1),
        .uses_S2   (id_uses_S2)
    );

    // Register file
    wire [0:63] rf_out_a, rf_out_b;
    wire [0:63] wb_data;
    wire [0:4]  wb_rD;
    wire        wb_writes_rD;
    wire [0:4]  id_srcA_eff = id_is_sd ? id_rD : id_rS1;

    reg_file u_rf (
        .clk   (clk),
        .rst   (reset),
        .wrEn  (wb_writes_rD),
        .WA    (wb_rD),
        .RA_a  (id_srcA_eff),
        .RA_b  (id_rS2),
        .WD    (wb_data),
        .out_a (rf_out_a),
        .out_b (rf_out_b)
    );

    // ---------- WB -> ID Direct bypass ----------
    wire [0:63] id_valA_pre = rf_out_a;
    wire [0:63] id_valB_pre = rf_out_b;

    wire        wb_hits_A = wb_writes_rD && (wb_rD != 5'd0) && (wb_rD == id_srcA_eff);
    wire        wb_hits_B = wb_writes_rD && (wb_rD != 5'd0) && (wb_rD == id_rS2);

    wire [0:63] id_valA = wb_hits_A ? wb_data : id_valA_pre;
    wire [0:63] id_valB = wb_hits_B ? wb_data : id_valB_pre;

    // Branch decision in ID (use bypassed value)
    wire id_cond_is_zero = (id_valA == 64'b0);
    assign branch_taken_id = (id_is_bez  &&  id_cond_is_zero) ||
                             (id_is_bnez && !id_cond_is_zero);
    assign branch_imm16_id = id_imm16;
    wire  id_is_branch     = id_is_bez | id_is_bnez;

    // ================= HDU (stall/hold/flush) =================
    // WB view for HDU
    wire [0:4] wb_rD_hdu        = wb_rD;
    wire       wb_writes_rD_hdu = wb_writes_rD;

    // EX/MEM view for HDU (keep EX/MEM tap; we will OR with ID/EX local check)
    wire [0:4] exm_rD_hdu;
    wire       exm_writes_rD_hdu;
    wire       exm_is_load_hdu;

    hdu u_hdu (
        .id_rS1       (id_srcA_eff),
        .id_rS2       (id_rS2),
        .id_uses_S1   (id_uses_S1),
        .id_uses_S2   (id_uses_S2),
        .id_is_branch (id_is_branch),

        .exm_rD       (exm_rD_hdu),
        .exm_writes_rD(exm_writes_rD_hdu),
        .exm_is_load  (exm_is_load_hdu),

        .wb_rD        (wb_rD_hdu),
        .wb_writes_rD (wb_writes_rD_hdu),

        .stall        (hdu_stall),
        .if_id_hold   (if_id_hold),
        .id_ex_flush  (id_ex_flush)
    );

    // ================ ID/EX pipeline regs =================
    reg [0:63] idex_valA, idex_valB;
    reg [0:4]  idex_rD, idex_rS1, idex_rS2;
    reg [0:1]  idex_ww;
    reg [0:5]  idex_func, idex_op;
    reg [0:15] idex_imm16;
    reg        idex_is_rtype, idex_is_ld, idex_is_sd;
    reg        idex_writes_rD;

    // ===== Additional: Local detection of load-use for ID/EX (parallel to the EX/MEM detection of hdu) =====
    wire idex_hazard_s1 = id_uses_S1 && (idex_rD != 5'd0) && (idex_rD == id_srcA_eff);
    wire idex_hazard_s2 = id_uses_S2 && (idex_rD != 5'd0) && (idex_rD == id_rS2);
    wire need_stall_idex = idex_is_ld && (idex_hazard_s1 || idex_hazard_s2);

    wire stall_any;
    wire if_id_hold_any;
    wire id_ex_flush_any;

    assign stall_any       = hdu_stall   | need_stall_idex;
    assign if_id_hold_any  = if_id_hold  | need_stall_idex;
    assign id_ex_flush_any = id_ex_flush | need_stall_idex;

    // now can define branch flush and PC enable with combined stall
    assign do_branch_flush = branch_taken_id & ~stall_any;
    assign pc_en = (~stall_any) | do_branch_flush;

    always @(posedge clk) begin
        if (reset || id_ex_flush_any) begin
            idex_valA      <= 64'b0;
            idex_valB      <= 64'b0;
            idex_rD        <= 5'd0;
            idex_rS1       <= 5'd0;
            idex_rS2       <= 5'd0;
            idex_ww        <= 2'b00;
            idex_func      <= 6'b0;
            idex_op        <= OP_NOP;
            idex_imm16     <= 16'b0;
            idex_is_rtype  <= 1'b0;
            idex_is_ld     <= 1'b0;
            idex_is_sd     <= 1'b0;
            idex_writes_rD <= 1'b0;
        end else if (!stall_any) begin
            // Use the value from the WB->ID bypass.
            idex_valA      <= id_valA;
            idex_valB      <= id_valB;
            idex_rD        <= id_rD;
            idex_rS1       <= id_srcA_eff;
            idex_rS2       <= id_rS2;
            idex_ww        <= id_ww;
            idex_func      <= id_func;
            idex_op        <= id_op;
            idex_imm16     <= id_imm16;
            idex_is_rtype  <= id_is_rtype;
            idex_is_ld     <= id_is_ld;
            idex_is_sd     <= id_is_sd;
            idex_writes_rD <= id_writes_rD; // (= is_rtype | is_ld)
        end
    end

    // ================ EX(+MEM): FU + ALU + DMEM =================
    // Forwarding Unit (compare ID/EX sources with EX/MEM + WB)
    wire [1:0] fwdA_sel, fwdB_sel;

    // EX/MEM pipeline (registered) preview to FU/WB
    reg [0:63] exmem_alu_out_r;
    reg [0:4]  exmem_rD_r;
    reg        exmem_writes_rD_r;
    reg        exmem_is_load_r;

    // WB (registered) preview to FU
    reg [0:63] memwb_data_r;
    reg [0:4]  memwb_rD_r;
    reg        memwb_writes_rD_r;

    fu u_fu (
        .ex_srcA       (idex_rS1),
        .ex_srcB       (idex_rS2),
        .exm_rD        (exmem_rD_r),
        .exm_writes_rD (exmem_writes_rD_r),
        .exm_is_load   (exmem_is_load_r),
        .wb_rD         (memwb_rD_r),
        .wb_writes_rD  (memwb_writes_rD_r),
        .fwdA_sel      (fwdA_sel),
        .fwdB_sel      (fwdB_sel)
    );

    // ALU operand muxes with forwarding
    wire [0:63] alu_in_a = (fwdA_sel==2'b01) ? exmem_alu_out_r : (fwdA_sel==2'b10) ? memwb_data_r : idex_valA;
    wire [0:63] alu_in_b = (fwdB_sel==2'b01) ? exmem_alu_out_r : (fwdB_sel==2'b10) ? memwb_data_r : idex_valB;

    // ALU
    wire [0:63] alu_out;

    ALU u_alu (
        .clk  (clk),
        .rst  (reset),
        .in_a (alu_in_a),
        .in_b (alu_in_b),
        .op   (idex_op),
        .ww   (idex_ww),
        .func (idex_func),
        .out  (alu_out)
    );

    // ---------- DMEM interface must use EX/MEM-registered signals ----------
    // These align the "EX+MEM in one stage" with dmem's clocked behavior
    reg        exmem_memEn, exmem_memWrEn;
    reg [0:7]  exmem_addr;
    reg [63:0] exmem_store_data;

    always @(posedge clk) begin
        if (reset) begin
            exmem_memEn      <= 1'b0;
            exmem_memWrEn    <= 1'b0;
            exmem_addr       <= 8'd0;
            exmem_store_data <= 64'd0;
        end else begin
            exmem_memEn      <= (idex_is_ld | idex_is_sd);
            exmem_memWrEn    <= idex_is_sd;
            exmem_addr       <= idex_imm16[8:15]; // absolute byte addr low 8 bits
            exmem_store_data <= alu_in_a;        // store data = A (after forwarding)
        end
    end

    wire [0:63] dmem_rd_data;

    dmem u_dmem (
        .clk     (clk),
        .memEn   (exmem_memEn),
        .memWrEn (exmem_memWrEn),
        .memAddr (exmem_addr),
        .dataIn  (exmem_store_data),
        .dataOut (dmem_rd_data)  // 1-cycle read latency (via r_memEn/r_memAddr inside)
    );

    // ---------- EX/MEM pipeline reg (for ALU/WB/HDU visibility) ----------
    always @(posedge clk) begin
        if (reset) begin
            exmem_alu_out_r   <= 64'b0;
            exmem_rD_r        <= 5'd0;
            exmem_writes_rD_r <= 1'b0;
            exmem_is_load_r   <= 1'b0;
        end else begin
            exmem_alu_out_r   <= alu_out;       // R-type/SD bypass value
            exmem_rD_r        <= idex_rD;
            exmem_writes_rD_r <= idex_writes_rD;  // R-type/LD=1, SD=0
            exmem_is_load_r   <= idex_is_ld;
        end
    end

    // HDU taps EX/MEM (keep as EX/MEM; local ID/EX hazard is ORed above)
    assign exm_rD_hdu        = exmem_rD_r;
    assign exm_writes_rD_hdu = exmem_writes_rD_r;
    assign exm_is_load_hdu   = exmem_is_load_r;

    // =================== WB (align to dmem read latency) ===================
    // dmem has 1-cycle read latency -> align EX/MEM info by one cycle
    reg [0:63] exmem_alu_out_d1;
    reg [0:4]  exmem_rD_d1;
    reg        exmem_writes_rD_d1;
    reg        exmem_is_load_d1;

    always @(posedge clk) begin
        if (reset) begin
            exmem_alu_out_d1   <= 64'b0;
            exmem_rD_d1        <= 5'd0;
            exmem_writes_rD_d1 <= 1'b0;
            exmem_is_load_d1   <= 1'b0;
        end else begin
            exmem_alu_out_d1   <= exmem_alu_out_r;
            exmem_rD_d1        <= exmem_rD_r;
            exmem_writes_rD_d1 <= exmem_writes_rD_r;
            exmem_is_load_d1   <= exmem_is_load_r;
        end
    end

    // WB register (feeds RF and FU preview)
    always @(posedge clk) begin
        if (reset) begin
            memwb_data_r      <= 64'b0;
            memwb_rD_r        <= 5'd0;
            memwb_writes_rD_r <= 1'b0;
        end else begin
            // If last cycle was a LOAD, dmem_rd_data is now valid; else take ALU result
            memwb_data_r      <= exmem_is_load_d1 ? dmem_rd_data : exmem_alu_out_d1;
            memwb_rD_r        <= exmem_rD_d1;
            memwb_writes_rD_r <= exmem_writes_rD_d1;
        end
    end

    // -------- WB -> RF --------
    assign wb_data      = memwb_data_r;
    assign wb_rD        = memwb_rD_r;
    assign wb_writes_rD = memwb_writes_rD_r;

endmodule
