`timescale 1ns/1ps

module tb_processor;
  reg clk   = 0;
  reg reset = 1;

  // ---------- DUT ----------
  processor u_dut (
    .clk   (clk),
    .reset (reset)
  );

  // 10ns 时钟
  always #5 clk = ~clk;

  // ---------- ISA 常量（数值位序） ----------
  localparam [5:0] OP_RTYPE = 6'b101010;
  localparam [5:0] OP_LD    = 6'b100000;
  localparam [5:0] OP_SD    = 6'b100001;
  localparam [5:0] OP_BEZ   = 6'b100010;
  localparam [5:0] OP_BNEZ  = 6'b100011;
  localparam [5:0] OP_NOP   = 6'b111100;

  localparam [5:0] F_AND  = 6'b000001;
  localparam [5:0] F_OR   = 6'b000010;
  localparam [5:0] F_XOR  = 6'b000011;
  localparam [5:0] F_NOT  = 6'b000100;
  localparam [5:0] F_MOV  = 6'b000101;
  localparam [5:0] F_ADD  = 6'b000110;
  localparam [5:0] F_SUB  = 6'b000111;

  // ---------- 小“汇编器”辅助：形参用数值位序 ----------
  function [0:31] ENC_R;
    input [5:0]  op;     // = OP_RTYPE（数值位序）
    input [4:0]  rD;
    input [4:0]  rA;
    input [4:0]  rB;
    input [1:0]  ww;
    input [5:0]  func;
    reg   [0:31] insn;   // 指令字段仍然按 [0:31] 大端填充
    begin
      insn         = 32'b0;
      insn[0:5]    = op;
      insn[6:10]   = rD;
      insn[11:15]  = rA;
      insn[16:20]  = rB;
      insn[21:23]  = 3'b000;
      insn[24:25]  = ww;
      insn[26:31]  = func;
      ENC_R        = insn;
    end
  endfunction

  function [0:31] ENC_I;
    input [5:0]  op;     // 数值位序
    input [4:0]  rD;
    input [15:0] imm16;  // 数值位序
    reg   [0:31] insn;
    begin
      insn         = 32'b0;
      insn[0:5]    = op;
      insn[6:10]   = rD;
      insn[11:15]  = 5'd0;
      insn[16:31]  = imm16;
      ENC_I        = insn;
    end
  endfunction

  // 便捷宏（形参同样用数值位序）
  function [0:31] R_ADD;  input [4:0] rd, ra, rb; begin R_ADD = ENC_R(OP_RTYPE, rd, ra, rb, 2'b11, F_ADD); end endfunction
  function [0:31] R_SUB;  input [4:0] rd, ra, rb; begin R_SUB = ENC_R(OP_RTYPE, rd, ra, rb, 2'b11, F_SUB); end endfunction
  function [0:31] R_MOV;  input [4:0] rd, ra;     begin R_MOV = ENC_R(OP_RTYPE, rd, ra, 5'd0, 2'b11, F_MOV); end endfunction
  function [0:31] I_LD;   input [4:0] rd; input [15:0] imm; begin I_LD   = ENC_I(OP_LD,   rd, imm); end endfunction
  function [0:31] I_SD;   input [4:0] rs; input [15:0] imm; begin I_SD   = ENC_I(OP_SD,   rs, imm); end endfunction
  function [0:31] I_BEZ;  input [4:0] rs; input [15:0] tgt; begin I_BEZ  = ENC_I(OP_BEZ,  rs, tgt); end endfunction
  function [0:31] I_BNEZ; input [4:0] rs; input [15:0] tgt; begin I_BNEZ = ENC_I(OP_BNEZ, rs, tgt); end endfunction
  function [0:31] I_NOP;  begin I_NOP = ENC_I(OP_NOP, 5'd0, 16'd0); end endfunction

  // ---------- 探针 WB 事件 ----------
  always @(posedge clk) if (!reset) begin
    if (u_dut.wb_writes_rD)
      $display("[%0t] WB: r%0d <= 0x%016h", $time, u_dut.wb_rD, u_dut.wb_data);
  end

  // 统计周期
  integer cyc;
  always @(posedge clk) begin
    if (reset) cyc <= 0;
    else       cyc <= cyc + 1;
  end

  // ---------- 便捷任务：直写 IMEM/DMEM ----------
  localparam IMEM_BASE = 8'd0;

  task write_imem;
    input [7:0]  addr;
    input [0:31] insn;
    begin
      u_dut.u_imem.MEM[addr] = insn;
      $display("  IMEM[%0d] = %b (0x%08h)", addr, insn, insn);
    end
  endtask

  task write_dmem64;
    input [7:0]  addr;
    input [63:0] data;
    begin
      u_dut.u_dmem.MEM[addr] = data;
      $display("  DMEM[%0d] <= 0x%016h", addr, data);
    end
  endtask

  task check_dmem_eq;
    input [7:0]  addr;
    input [63:0] exp;
    reg   [63:0] got;
    begin
      got = u_dut.u_dmem.MEM[addr];
      if (got !== exp) begin
        $display("ERROR: DMEM[%0d] expected 0x%016h, got 0x%016h", addr, exp, got);
        $fatal;
      end else begin
        $display("CHECK OK: DMEM[%0d] == 0x%016h", addr, got);
      end
    end
  endtask

  // ---------- 可选：调试 ADD 的两路操作数 ----------
  always @(posedge clk) if (!reset) begin
    if (u_dut.idex_op==OP_RTYPE && u_dut.idex_func==F_ADD) begin
      $display("[%0t] EX ADD: rS1=%0d rS2=%0d  alu_in_a=%h alu_in_b=%h  fwdA=%b fwdB=%b",
        $time, u_dut.idex_rS1, u_dut.idex_rS2, 
        (u_dut.fwdA_sel==2'b01)?u_dut.exmem_alu_out_r:(u_dut.fwdA_sel==2'b10)?u_dut.memwb_data_r:u_dut.idex_valA,
        (u_dut.fwdB_sel==2'b01)?u_dut.exmem_alu_out_r:(u_dut.fwdB_sel==2'b10)?u_dut.memwb_data_r:u_dut.idex_valB,
        u_dut.fwdA_sel, u_dut.fwdB_sel);
    end
  end

  // ---------- 测试程序 ----------
  initial begin
    // 预置 DMEM
    write_dmem64(8'd1, 64'd10);
    write_dmem64(8'd2, 64'd20);
    write_dmem64(8'd9,  64'd111);
    write_dmem64(8'd3,  64'd0);
    write_dmem64(8'd4,  64'd0);

    // 程序装载（绝对 PC：pc[24:31]）
    // 0: r1 = LD [1]
    write_imem(IMEM_BASE+0,  I_LD(5'd1, 16'd1));
    // 1: r2 = LD [2]
    write_imem(IMEM_BASE+1,  I_LD(5'd2, 16'd2));
    // 2: r3 = r1 + r2
    write_imem(IMEM_BASE+2,  R_ADD(5'd3, 5'd1, 5'd2));
    // 3: SD r3 -> [3]
    write_imem(IMEM_BASE+3,  I_SD(5'd3, 16'd3));
    // 4: BEZ r0, TGT=8  （必跳）
    write_imem(IMEM_BASE+4,  I_BEZ(5'd0, 16'd8));
    // 5: (被 flush) r31 = r1 + r2
    write_imem(IMEM_BASE+5,  R_ADD(5'd31, 5'd1, 5'd2));
    // 6: (被 flush) NOP
    write_imem(IMEM_BASE+6,  I_NOP());
    // 7: (被 flush) NOP
    write_imem(IMEM_BASE+7,  I_NOP());

    // 8: r4 = LD [3]   （期望读到 30）
    write_imem(IMEM_BASE+8,  I_LD(5'd4, 16'd3));
    // 9: r5 = r4 - r1  （30-10=20）
    write_imem(IMEM_BASE+9,  R_SUB(5'd5, 5'd4, 5'd1));
    // 10: r6 = r5 + r4 （20+30=50）
    write_imem(IMEM_BASE+10, R_ADD(5'd6, 5'd5, 5'd4));
    // 11: SD r6 -> [4]  （写 50）
    write_imem(IMEM_BASE+11, I_SD(5'd6, 16'd4));

    // 12: LD-use hazard：r7=LD[1] 紧跟 r8=r7+r1（应插 1 气泡）
    write_imem(IMEM_BASE+12, I_LD(5'd7, 16'd1));
    write_imem(IMEM_BASE+13, R_ADD(5'd8, 5'd7, 5'd1));

    // 14: BNEZ r8, TGT=18   （r8 != 0 -> 跳）
    write_imem(IMEM_BASE+14, I_BNEZ(5'd8, 16'd18));
    // 15: (若未跳会执行) r9 = r8 + r1  —— 预期被 flush
    write_imem(IMEM_BASE+15, R_ADD(5'd9, 5'd8, 5'd1));
    // 16: NOP
    write_imem(IMEM_BASE+16, I_NOP());
    // 17: NOP
    write_imem(IMEM_BASE+17, I_NOP());

    // 18: 终点：再 SD r8 -> [9]（观测跳转是否发生；应写 r8=20）
    write_imem(IMEM_BASE+18, I_SD(5'd8, 16'd9));
    // 19: NOP
    write_imem(IMEM_BASE+19, I_NOP());

    // 复位序列
    repeat (5) @(posedge clk);
    reset <= 0;
    $display("=== Deassert reset @ %0t ===", $time);

    // 跑一段时间
    repeat (120) @(posedge clk);

    // 检查 DMEM 结果
    check_dmem_eq(8'd3, 64'd30); // 10 + 20
    check_dmem_eq(8'd4, 64'd50); // 20 + 30
    check_dmem_eq(8'd9, 64'd20); // 跳到 18 后把 r8(=20) 存入 [9]

    $display("ALL CHECKS PASSED. Cycles=%0d", cyc);
    $finish;
  end
endmodule
