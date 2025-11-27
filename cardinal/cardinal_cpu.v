`timescale 1ns/1ps
module cardinal_cpu (
    input  wire        clk,
    input  wire        reset,

    // ===== IMEM (async, word-index) =====
    output wire [0:7]  imem_addr,
    input  wire [0:31] imem_data,

    // ===== DMEM (sync, 64-bit word) =====
    output reg         dmem_en,
    output reg         dmem_we,
    output reg  [0:7]  dmem_addr,
    output reg  [0:63] dmem_dout,
    input  wire [0:63] dmem_din,

    // =============== NIC (old interface) ===============
    output reg         nic_en,
    output reg         nic_enwr,
    output reg  [0:1]  nic_addr,
    output reg  [0:63] nic_dout,
    input  wire [0:63] nic_din
);
    // ===== ISA opcodes =====
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
    wire        stall_for_nic;
    wire [0:63] alu_in_a;

    // ---- NIC FSM states ----
    localparam [2:0] NIC_IDLE    = 3'd0;
    localparam [2:0] NIC_SD_POLL = 3'd1;
    localparam [2:0] NIC_SD_DATA = 3'd2;
    localparam [2:0] NIC_LD_POLL = 3'd3;
    localparam [2:0] NIC_LD_DATA = 3'd4;

    reg [2:0] nic_state;

    // ---- forward declarations ----
    wire need_stall_idex;
    wire stall_any;
    wire if_id_hold_any;
    wire id_ex_flush_any;
    wire do_branch_flush;

    pc u_pc (
        .clk          (clk),
        .reset        (reset),
        .en           (pc_en),
        .branch_taken (branch_taken_id),
        .imm16        (branch_imm16_id),
        .pc           (pc_curr)
    );
    // Debug PC
    always @(posedge clk) begin
        if (!reset)
            $display("[DBG][%0t] PC = %0d", $time, pc_curr);
    end
    // 取指地址：沿用你原来的切片
    assign imem_addr = pc_curr >> 2;

    // 指令直接来自外部 IMEM
    wire [0:31] if_instr = imem_data;

    // -------- IF/ID pipeline register --------
    reg  [0:31] ifid_instr;

    // from HDU
    wire hdu_stall;
    wire if_id_hold;
    wire id_ex_flush;

    always @(posedge clk) begin
        if (reset) begin
            ifid_instr <= 32'hF000_0000; // NOP after reset
        end else if (do_branch_flush) begin
            ifid_instr <= 32'hF000_0000; // flush -> NOP
        end else if (!if_id_hold_any) begin
            ifid_instr <= if_instr;
        end
        // else hold
    end

    // Debug IF/ID
    always @(posedge clk) begin
        if (!reset)
            $display("[DBG][%0t] IF/ID instr = %h", $time, ifid_instr);
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

    // Debug decode
    always @(posedge clk) begin
        if (!reset)
            $display("[DBG][%0t] ID stage op=%b rD=%d rA=%d rB=%d imm=%h LD=%b SD=%b",
                     $time, id_op, id_rD, id_rA, id_rB, id_imm16, id_is_ld, id_is_sd);
    end
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

    // Debug branch
    always @(posedge clk) begin
        if (!reset && id_is_branch)
            $display("[DBG][%0t] Branch detected, taken=%b imm=%h",
                     $time, branch_taken_id, branch_imm16_id);
    end
    // ================= HDU (stall/hold/flush) =================
    // WB view for HDU
    wire [0:4] wb_rD_hdu        = wb_rD;
    wire       wb_writes_rD_hdu = wb_writes_rD;

    // EX/MEM view for HDU
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

    // Debug HDU
    always @(posedge clk) begin
        if (!reset && (hdu_stall || if_id_hold || id_ex_flush))
            $display("[DBG][%0t] HDU STALL=%b HOLD=%b FLUSH=%b",
                     $time, hdu_stall, if_id_hold, id_ex_flush);
    end

    // ================ ID/EX pipeline regs =================
    reg [0:63] idex_valA, idex_valB;
    reg [0:4]  idex_rD, idex_rS1, idex_rS2;
    reg [0:1]  idex_ww;
    reg [0:5]  idex_func, idex_op;
    reg [0:15] idex_imm16;
    reg        idex_is_rtype, idex_is_ld, idex_is_sd;
    reg        idex_writes_rD;

    // ===== Additional: Local detection of load-use for ID/EX =====
    wire idex_hazard_s1 = id_uses_S1 && (idex_rD != 5'd0) && (idex_rD == id_srcA_eff);
    wire idex_hazard_s2 = id_uses_S2 && (idex_rD != 5'd0) && (idex_rD == id_rS2);
    assign need_stall_idex = idex_is_ld && (idex_hazard_s1 || idex_hazard_s2);

    assign stall_any       = hdu_stall   | need_stall_idex | stall_for_nic;
    assign if_id_hold_any  = if_id_hold  | need_stall_idex | stall_for_nic;
    assign id_ex_flush_any = id_ex_flush | need_stall_idex;

    // now can define branch flush and PC enable with combined stall
    assign do_branch_flush = branch_taken_id & ~stall_for_nic;
    assign pc_en           = ~stall_any;

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

    // Debug ID/EX
    always @(posedge clk) begin
        if (!reset)
            $display("[DBG][%0t] ID/EX: op=%b rD=%d A=%h B=%h imm=%h",
                     $time, idex_op, idex_rD, idex_valA, idex_valB, idex_imm16);
    end
    // ================ EX(+MEM): FU + ALU + DMEM =================
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
    assign      alu_in_a = (fwdA_sel==2'b01) ? exmem_alu_out_r :
                           (fwdA_sel==2'b10) ? memwb_data_r     : idex_valA;
    wire [0:63] alu_in_b = (fwdB_sel==2'b01) ? exmem_alu_out_r :
                           (fwdB_sel==2'b10) ? memwb_data_r     : idex_valB;

    // ALU
    wire [0:63] alu_out;

    ALU u_alu (
        .in_a (alu_in_a),
        .in_b (alu_in_b),
        .op   (idex_op),
        .ww   (idex_ww),
        .func (idex_func),
        .out  (alu_out)
    );
    // Debug ALU
    always @(posedge clk) begin
        if (!reset)
            $display("[DBG][%0t] ALU: A=%h B=%h OUT=%h", $time, alu_in_a, alu_in_b, alu_out);
    end
    // ---------- NIC interface ----------
    assign stall_for_nic = (nic_state != NIC_IDLE);

    always @(posedge clk) begin
        if (reset) begin
            nic_en    <= 1'b0;
            nic_enwr  <= 1'b0;
            nic_addr  <= 2'b00;
            nic_dout  <= 64'b0;
            nic_state <= NIC_IDLE;
        end else begin
            nic_en   <= 1'b0;
            nic_enwr <= 1'b0;

            case (nic_state)
                NIC_IDLE: begin
                    // imm[14:15] == 2'b11 → NIC 指令
                    if ((idex_op == OP_SD || idex_op == OP_LD) &&
                        (idex_imm16[14:15] == 2'b11)) begin
                        if (idex_op == OP_SD)
                            nic_state <= NIC_SD_POLL;
                        else
                            nic_state <= NIC_LD_POLL;
                    end
                end

                // SD：poll OUT_STATUS (addr = 2'b11)
                NIC_SD_POLL: begin
                    nic_en   <= 1'b1;
                    nic_enwr <= 1'b0; // read
                    nic_addr <= 2'b11;
                    if (nic_din == 64'b0) begin
                        nic_state <= NIC_SD_DATA;
                    end
                end

                // SD：写 OUT_DATA (addr = 2'b10)
                NIC_SD_DATA: begin
                    nic_en   <= 1'b1;
                    nic_enwr <= 1'b1;      // write
                    nic_addr <= 2'b10;     // OUT_DATA
                    nic_dout <= alu_in_a;  // store data
                    nic_state <= NIC_IDLE;
                end

                // LD：poll IN_STATUS (addr = 2'b01)
                NIC_LD_POLL: begin
                    nic_en   <= 1'b1;
                    nic_enwr <= 1'b0;      // read
                    nic_addr <= 2'b01;     // IN_STATUS
                    if (nic_din == 64'b1) begin
                        nic_state <= NIC_LD_DATA;
                    end
                end

                // LD：读 IN_DATA (addr = 2'b00)
                NIC_LD_DATA: begin
                    nic_en   <= 1'b1;
                    nic_enwr <= 1'b0;      // read
                    nic_addr <= 2'b00;     // IN_DATA
                    nic_state <= NIC_IDLE;
                end

                default: nic_state <= NIC_IDLE;
            endcase
        end
    end

    // ---------- DMEM interface（保持你原来的语义） ----------
    always @(posedge clk) begin
        if (reset) begin
            dmem_en    <= 1'b0;
            dmem_we    <= 1'b0;
            dmem_addr  <= 8'd0;
            dmem_dout  <= 64'd0;
        end else begin
            if (idex_imm16[14:15] != 2'b11) begin
                dmem_en    <= (idex_is_ld | idex_is_sd);
                dmem_we    <= idex_is_sd;
                dmem_addr  <= idex_imm16[8:15];
                dmem_dout  <= alu_in_a;
            end else begin
                // NIC 指令时，DMEM 不使能
                dmem_en    <= 1'b0;
                dmem_we    <= 1'b0;
            end
        end
    end
    // Debug DMEM
    always @(posedge clk) begin
        if (!reset && dmem_en)
            $display("[DBG][%0t] DMEM %s addr=%d data=%h",
                     $time, dmem_we?"WRITE":"READ", dmem_addr, dmem_dout);
    end

    // ---------- EX/MEM pipeline reg (for ALU/WB/HDU visibility) ----------
    reg [0:15] exmem_imm16;
    reg [0:5]  exmem_op;

    // ★ 修正点：不再在 stall_for_nic 时清零，只是“保持”
    always @(posedge clk) begin
        if (reset) begin
            exmem_alu_out_r   <= 64'b0;
            exmem_rD_r        <= 5'd0;
            exmem_writes_rD_r <= 1'b0;
            exmem_is_load_r   <= 1'b0;
            exmem_imm16       <= 16'b0;
            exmem_op          <= 6'b0;
        end else if (!stall_for_nic) begin
            exmem_alu_out_r   <= alu_out;       // R-type/SD bypass value
            exmem_rD_r        <= idex_rD;
            exmem_writes_rD_r <= idex_writes_rD;  // R-type/LD=1, SD=0
            exmem_is_load_r   <= idex_is_ld;
            exmem_imm16       <= idex_imm16;     // check exmem_imm16[0:1] to know NIC or DMEM
            exmem_op          <= idex_op;
        end
        // else: hold EX/MEM 寄存器内容，等待 NIC FSM 完成
    end

    // HDU taps EX/MEM
    assign exm_rD_hdu        = exmem_rD_r;
    assign exm_writes_rD_hdu = exmem_writes_rD_r;
    assign exm_is_load_hdu   = exmem_is_load_r;

    // =================== WB (align to dmem read latency) ===================
    reg [0:63] exmem_alu_out_d1;
    reg [0:4]  exmem_rD_d1;
    reg        exmem_writes_rD_d1;
    reg        exmem_is_load_d1;
    reg [0:15] exmem_imm16_d1;

    always @(posedge clk) begin
        if (reset) begin
            exmem_alu_out_d1   <= 64'b0;
            exmem_rD_d1        <= 5'd0;
            exmem_writes_rD_d1 <= 1'b0;
            exmem_is_load_d1   <= 1'b0;
            exmem_imm16_d1     <= 16'b0;
        end else begin
            exmem_alu_out_d1   <= exmem_alu_out_r;
            exmem_rD_d1        <= exmem_rD_r;
            exmem_writes_rD_d1 <= exmem_writes_rD_r;
            exmem_is_load_d1   <= exmem_is_load_r;
            exmem_imm16_d1     <= exmem_imm16;
        end
    end

    // WB register (feeds RF and FU preview)
    always @(posedge clk) begin
        if (reset) begin
            memwb_data_r      <= 64'b0;
            memwb_rD_r        <= 5'd0;
            memwb_writes_rD_r <= 1'b0;
        end else begin
            // LOAD：imm16[1:0]==2'b11 -> NIC；否则 DMEM；其他用 ALU 结果
            memwb_data_r      <= exmem_is_load_d1
                                 ? ((exmem_imm16_d1[14:15] == 2'b11) ? nic_din
                                                                  : dmem_din)
                                 : exmem_alu_out_d1;
            memwb_rD_r        <= exmem_rD_d1;
            memwb_writes_rD_r <= exmem_writes_rD_d1;
        end
    end
    // Debug WB
    always @(posedge clk) begin
        if (!reset && memwb_writes_rD_r)
            $display("[DBG][%0t] WB: r%d = %h", $time, memwb_rD_r, memwb_data_r);
    end

    // -------- WB -> RF --------
    assign wb_data      = memwb_data_r;
    assign wb_rD        = memwb_rD_r;
    assign wb_writes_rD = memwb_writes_rD_r;

endmodule
