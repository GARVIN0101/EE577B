`timescale 1ns/1ps
module tb_processor;
  // ===== Clock / Reset =====
  reg clk = 0;
  reg reset = 1;
  always #20 clk = ~clk;   // toggle every 20 ns

  // ===== DUT =====
  processor u_dut (
    .clk   (clk),
    .reset (reset)
  );

  // ===== Config (Verilog-2001 friendly) =====
  reg [1023:0] BASE;
  integer      case_id;
  reg [1023:0] imem_file;
  reg [1023:0] dmem_file;
  reg [1023:0] expected_file;

  // ===== For comparison =====
  reg [63:0] expected [0:255];
  integer i, mismatches;

  // ---------- helpers ----------
  task readhex_or_die;
    input [1023:0] fname;
    input [127:0]  what;
    begin
      if (what == "IMEM")
        $readmemh(fname, u_dut.u_imem.MEM);
      else if (what == "DMEM")
        $readmemh(fname, u_dut.u_dmem.MEM);
      $display("[TB] Loaded %0s from '%0s'", what, fname);
    end
  endtask

  // Parse expected dump (supports multiple line formats)
  task load_expected_dump;
    input [1023:0] fname;
    integer fd, lineno, n, idx;
    reg [8*256-1:0] line;
    reg [63:0] val;
    begin
      for (i = 0; i < 256; i = i + 1) expected[i] = 64'hX; // sparse compare
      fd = $fopen(fname, "r");
      if (fd == 0) begin
        $display("ERROR: cannot open expected dump '%0s'", fname);
        $fatal;
      end
      lineno = 0;
      while (!$feof(fd)) begin
        line = {8*256{1'b0}};
        n = $fgets(line, fd);
        if (n != 0) begin
          lineno = lineno + 1;
          if ($sscanf(line, "DMEM[%d] = %h", idx, val) == 2 ||
              $sscanf(line, "MEM[%d] = %h",  idx, val) == 2 ||
              $sscanf(line, "%d : %h",       idx, val) == 2 ||
              $sscanf(line, "@%d %h",        idx, val) == 2) begin
            if (idx >= 0 && idx < 256) expected[idx] = val;
          end
        end
      end
      $fclose(fd);
      $display("[TB] Parsed EXPECTED from '%0s' (lines=%0d)", fname, lineno);
    end
  endtask

  // ===== Trace: optional, print each register write-back =====
  always @(posedge clk) if (!reset) begin
    if (u_dut.wb_writes_rD)
      $display("[%0t] WB: r%0d <= 0x%016h",
               $time, u_dut.wb_rD, u_dut.wb_data);
  end

  // ===== Main flow =====
  initial begin
    // — All declarations must be at the top (fixes your syntax error source) —
    integer CYCLES;
    integer stop_flag;

    // Default config
    BASE = "test_cases";
    case_id = 1;
    CYCLES = 2000;
    stop_flag = 0;

    // plusargs
    if ($value$plusargs("BASE=%s", BASE)) ;
    if ($value$plusargs("CASE=%d", case_id)) ;
    if ($value$plusargs("CYCLES=%d", CYCLES)) ;

    // Compose file names
    $sformat(imem_file,     "%0s/imem_%0d.fill",          BASE, case_id);
    $sformat(dmem_file,     "%0s/dmem.fill",              BASE);
    $sformat(expected_file, "%0s/expected_dmem_%0d.dump", BASE, case_id);

    $display("[TB] BASE=%0s  CASE=%0d", BASE, case_id);
    $display("[TB] IMEM='%0s'", imem_file);
    $display("[TB] DMEM='%0s'", dmem_file);
    $display("[TB] EXP ='%0s'", expected_file);

    // Load IMEM/DMEM first
    readhex_or_die(imem_file, "IMEM");
    readhex_or_die(dmem_file, "DMEM");

    // Deassert reset
    repeat (5) @(posedge clk);
    reset <= 1'b0;
    $display("=== Deassert reset @ %0t ===", $time);

    // Run
    repeat (CYCLES) @(posedge clk);

    // Parse and compare expected DMEM
    load_expected_dump(expected_file);

    mismatches = 0;
    stop_flag  = 0;
    for (i = 0; i < 256; i = i + 1) begin
      if (!stop_flag) begin
        if (expected[i] !== 64'hX) begin
          if (u_dut.u_dmem.MEM[i] !== expected[i]) begin
            $display("ERROR: DMEM[%0d] exp=0x%016h got=0x%016h",
                     i, expected[i], u_dut.u_dmem.MEM[i]);
            mismatches = mismatches + 1;
            if (mismatches >= 20) begin
              $display("... (too many mismatches, stopping compare)");
              stop_flag = 1;
            end
          end
        end
      end
    end

    if (mismatches == 0) begin
      $display("PASS: DMEM matches expected (sparse compare).");
    end else begin
      $display("FAIL: %0d mismatches found.", mismatches);
      $fatal;
    end

    $finish;
  end
endmodule
