`timescale 1ns/1ps
module tb_cardinal_cmp;

    // ========================================
    // Clock / Reset
    // ========================================
    reg clk = 0;
    always #2 clk = ~clk;   // 4ns period

    reg reset = 1;

    // ========================================
    // DMEM write counters (for finish detection)
    // ========================================
    integer dm_writes[0:33];

    initial begin
        integer i;
        for (i = 0; i < 34; i = i+1)
            dm_writes[i] = 0;
    end


    // ========================================
    // Declare all IMEM/DMEM wires (16 nodes)
    // ========================================

    // 00
    wire [0:7]  node00_imem_addr;
    wire [0:31] node00_imem_data;
    wire        node00_dmem_en, node00_dmem_we;
    wire [0:7]  node00_dmem_addr;
    wire [0:63] node00_dmem_dout, node00_dmem_din;

    // 01
    wire [0:7]  node01_imem_addr;
    wire [0:31] node01_imem_data;
    wire        node01_dmem_en, node01_dmem_we;
    wire [0:7]  node01_dmem_addr;
    wire [0:63] node01_dmem_dout, node01_dmem_din;

    // 02
    wire [0:7]  node02_imem_addr;
    wire [0:31] node02_imem_data;
    wire        node02_dmem_en, node02_dmem_we;
    wire [0:7]  node02_dmem_addr;
    wire [0:63] node02_dmem_dout, node02_dmem_din;

    // 03
    wire [0:7]  node03_imem_addr;
    wire [0:31] node03_imem_data;
    wire        node03_dmem_en, node03_dmem_we;
    wire [0:7]  node03_dmem_addr;
    wire [0:63] node03_dmem_dout, node03_dmem_din;

    // 10
    wire [0:7]  node10_imem_addr;
    wire [0:31] node10_imem_data;
    wire        node10_dmem_en, node10_dmem_we;
    wire [0:7]  node10_dmem_addr;
    wire [0:63] node10_dmem_dout, node10_dmem_din;

    // 11
    wire [0:7]  node11_imem_addr;
    wire [0:31] node11_imem_data;
    wire        node11_dmem_en, node11_dmem_we;
    wire [0:7]  node11_dmem_addr;
    wire [0:63] node11_dmem_dout, node11_dmem_din;

    // 12
    wire [0:7]  node12_imem_addr;
    wire [0:31] node12_imem_data;
    wire        node12_dmem_en, node12_dmem_we;
    wire [0:7]  node12_dmem_addr;
    wire [0:63] node12_dmem_dout, node12_dmem_din;

    // 13
    wire [0:7]  node13_imem_addr;
    wire [0:31] node13_imem_data;
    wire        node13_dmem_en, node13_dmem_we;
    wire [0:7]  node13_dmem_addr;
    wire [0:63] node13_dmem_dout, node13_dmem_din;

    // 20
    wire [0:7]  node20_imem_addr;
    wire [0:31] node20_imem_data;
    wire        node20_dmem_en, node20_dmem_we;
    wire [0:7]  node20_dmem_addr;
    wire [0:63] node20_dmem_dout, node20_dmem_din;

    // 21
    wire [0:7]  node21_imem_addr;
    wire [0:31] node21_imem_data;
    wire        node21_dmem_en, node21_dmem_we;
    wire [0:7]  node21_dmem_addr;
    wire [0:63] node21_dmem_dout, node21_dmem_din;

    // 22
    wire [0:7]  node22_imem_addr;
    wire [0:31] node22_imem_data;
    wire        node22_dmem_en, node22_dmem_we;
    wire [0:7]  node22_dmem_addr;
    wire [0:63] node22_dmem_dout, node22_dmem_din;

    // 23
    wire [0:7]  node23_imem_addr;
    wire [0:31] node23_imem_data;
    wire        node23_dmem_en, node23_dmem_we;
    wire [0:7]  node23_dmem_addr;
    wire [0:63] node23_dmem_dout, node23_dmem_din;

    // 30
    wire [0:7]  node30_imem_addr;
    wire [0:31] node30_imem_data;
    wire        node30_dmem_en, node30_dmem_we;
    wire [0:7]  node30_dmem_addr;
    wire [0:63] node30_dmem_dout, node30_dmem_din;

    // 31
    wire [0:7]  node31_imem_addr;
    wire [0:31] node31_imem_data;
    wire        node31_dmem_en, node31_dmem_we;
    wire [0:7]  node31_dmem_addr;
    wire [0:63] node31_dmem_dout, node31_dmem_din;

    // 32
    wire [0:7]  node32_imem_addr;
    wire [0:31] node32_imem_data;
    wire        node32_dmem_en, node32_dmem_we;
    wire [0:7]  node32_dmem_addr;
    wire [0:63] node32_dmem_dout, node32_dmem_din;

    // 33
    wire [0:7]  node33_imem_addr;
    wire [0:31] node33_imem_data;
    wire        node33_dmem_en, node33_dmem_we;
    wire [0:7]  node33_dmem_addr;
    wire [0:63] node33_dmem_dout, node33_dmem_din;


    // ============================================================
    // Instantiate CMP
    // ============================================================
    cardinal_cmp dut (
        .clk(clk),
        .reset(reset),

        .node00_imem_addr(node00_imem_addr), .node00_imem_data(node00_imem_data),
        .node00_dmem_en(node00_dmem_en), .node00_dmem_we(node00_dmem_we),
        .node00_dmem_addr(node00_dmem_addr), .node00_dmem_dout(node00_dmem_dout),
        .node00_dmem_din(node00_dmem_din),

        .node01_imem_addr(node01_imem_addr), .node01_imem_data(node01_imem_data),
        .node01_dmem_en(node01_dmem_en), .node01_dmem_we(node01_dmem_we),
        .node01_dmem_addr(node01_dmem_addr), .node01_dmem_dout(node01_dmem_dout),
        .node01_dmem_din(node01_dmem_din),

        .node02_imem_addr(node02_imem_addr), .node02_imem_data(node02_imem_data),
        .node02_dmem_en(node02_dmem_en), .node02_dmem_we(node02_dmem_we),
        .node02_dmem_addr(node02_dmem_addr), .node02_dmem_dout(node02_dmem_dout),
        .node02_dmem_din(node02_dmem_din),

        .node03_imem_addr(node03_imem_addr), .node03_imem_data(node03_imem_data),
        .node03_dmem_en(node03_dmem_en), .node03_dmem_we(node03_dmem_we),
        .node03_dmem_addr(node03_dmem_addr), .node03_dmem_dout(node03_dmem_dout),
        .node03_dmem_din(node03_dmem_din),

        .node10_imem_addr(node10_imem_addr), .node10_imem_data(node10_imem_data),
        .node10_dmem_en(node10_dmem_en), .node10_dmem_we(node10_dmem_we),
        .node10_dmem_addr(node10_dmem_addr), .node10_dmem_dout(node10_dmem_dout),
        .node10_dmem_din(node10_dmem_din),

        .node11_imem_addr(node11_imem_addr), .node11_imem_data(node11_imem_data),
        .node11_dmem_en(node11_dmem_en), .node11_dmem_we(node11_dmem_we),
        .node11_dmem_addr(node11_dmem_addr), .node11_dmem_dout(node11_dmem_dout),
        .node11_dmem_din(node11_dmem_din),

        .node12_imem_addr(node12_imem_addr), .node12_imem_data(node12_imem_data),
        .node12_dmem_en(node12_dmem_en), .node12_dmem_we(node12_dmem_we),
        .node12_dmem_addr(node12_dmem_addr), .node12_dmem_dout(node12_dmem_dout),
        .node12_dmem_din(node12_dmem_din),

        .node13_imem_addr(node13_imem_addr), .node13_imem_data(node13_imem_data),
        .node13_dmem_en(node13_dmem_en), .node13_dmem_we(node13_dmem_we),
        .node13_dmem_addr(node13_dmem_addr), .node13_dmem_dout(node13_dmem_dout),
        .node13_dmem_din(node13_dmem_din),

        .node20_imem_addr(node20_imem_addr), .node20_imem_data(node20_imem_data),
        .node20_dmem_en(node20_dmem_en), .node20_dmem_we(node20_dmem_we),
        .node20_dmem_addr(node20_dmem_addr), .node20_dmem_dout(node20_dmem_dout),
        .node20_dmem_din(node20_dmem_din),

        .node21_imem_addr(node21_imem_addr), .node21_imem_data(node21_imem_data),
        .node21_dmem_en(node21_dmem_en), .node21_dmem_we(node21_dmem_we),
        .node21_dmem_addr(node21_dmem_addr), .node21_dmem_dout(node21_dmem_dout),
        .node21_dmem_din(node21_dmem_din),

        .node22_imem_addr(node22_imem_addr), .node22_imem_data(node22_imem_data),
        .node22_dmem_en(node22_dmem_en), .node22_dmem_we(node22_dmem_we),
        .node22_dmem_addr(node22_dmem_addr), .node22_dmem_dout(node22_dmem_dout),
        .node22_dmem_din(node22_dmem_din),

        .node23_imem_addr(node23_imem_addr), .node23_imem_data(node23_imem_data),
        .node23_dmem_en(node23_dmem_en), .node23_dmem_we(node23_dmem_we),
        .node23_dmem_addr(node23_dmem_addr), .node23_dmem_dout(node23_dmem_dout),
        .node23_dmem_din(node23_dmem_din),

        .node30_imem_addr(node30_imem_addr), .node30_imem_data(node30_imem_data),
        .node30_dmem_en(node30_dmem_en), .node30_dmem_we(node30_dmem_we),
        .node30_dmem_addr(node30_dmem_addr), .node30_dmem_dout(node30_dmem_dout),
        .node30_dmem_din(node30_dmem_din),

        .node31_imem_addr(node31_imem_addr), .node31_imem_data(node31_imem_data),
        .node31_dmem_en(node31_dmem_en), .node31_dmem_we(node31_dmem_we),
        .node31_dmem_addr(node31_dmem_addr), .node31_dmem_dout(node31_dmem_dout),
        .node31_dmem_din(node31_dmem_din),

        .node32_imem_addr(node32_imem_addr), .node32_imem_data(node32_imem_data),
        .node32_dmem_en(node32_dmem_en), .node32_dmem_we(node32_dmem_we),
        .node32_dmem_addr(node32_dmem_addr), .node32_dmem_dout(node32_dmem_dout),
        .node32_dmem_din(node32_dmem_din),

        .node33_imem_addr(node33_imem_addr), .node33_imem_data(node33_imem_data),
        .node33_dmem_en(node33_dmem_en), .node33_dmem_we(node33_dmem_we),
        .node33_dmem_addr(node33_dmem_addr), .node33_dmem_dout(node33_dmem_dout),
        .node33_dmem_din(node33_dmem_din)
    );



    // ============================================================
    // IMEM/DMEM instantiation macros
    // ============================================================
    `define GEN_NODE(NN) \
        imem IMEM_``NN`` ( \
            .memAddr(node``NN``_imem_addr), \
            .dataOut(node``NN``_imem_data) \
        ); \
        initial $readmemh($sformatf("cmp_test.imem.%02d.fill", NN), IMEM_``NN``.MEM); \
        \
        dmem DMEM_``NN`` ( \
            .clk(clk), \
            .memEn(node``NN``_dmem_en), \
            .memWrEn(node``NN``_dmem_we), \
            .memAddr(node``NN``_dmem_addr), \
            .dataIn(node``NN``_dmem_dout), \
            .dataOut(node``NN``_dmem_din) \
        ); \
        initial $readmemh($sformatf("cmp_test.dmem.%02d.fill", NN), DMEM_``NN``.MEM);

    // 16 nodes
    `GEN_NODE(00)
    `GEN_NODE(01)
    `GEN_NODE(02)
    `GEN_NODE(03)
    `GEN_NODE(10)
    `GEN_NODE(11)
    `GEN_NODE(12)
    `GEN_NODE(13)
    `GEN_NODE(20)
    `GEN_NODE(21)
    `GEN_NODE(22)
    `GEN_NODE(23)
    `GEN_NODE(30)
    `GEN_NODE(31)
    `GEN_NODE(32)
    `GEN_NODE(33)


    // ============================================================
    // DMEM write-count logic
    // ============================================================
    always @(posedge clk) begin
        if (node00_dmem_en && node00_dmem_we) dm_writes[0]  <= dm_writes[0]  + 1;
        if (node01_dmem_en && node01_dmem_we) dm_writes[1]  <= dm_writes[1]  + 1;
        if (node02_dmem_en && node02_dmem_we) dm_writes[2]  <= dm_writes[2]  + 1;
        if (node03_dmem_en && node03_dmem_we) dm_writes[3]  <= dm_writes[3]  + 1;

        if (node10_dmem_en && node10_dmem_we) dm_writes[10] <= dm_writes[10] + 1;
        if (node11_dmem_en && node11_dmem_we) dm_writes[11] <= dm_writes[11] + 1;
        if (node12_dmem_en && node12_dmem_we) dm_writes[12] <= dm_writes[12] + 1;
        if (node13_dmem_en && node13_dmem_we) dm_writes[13] <= dm_writes[13] + 1;

        if (node20_dmem_en && node20_dmem_we) dm_writes[20] <= dm_writes[20] + 1;
        if (node21_dmem_en && node21_dmem_we) dm_writes[21] <= dm_writes[21] + 1;
        if (node22_dmem_en && node22_dmem_we) dm_writes[22] <= dm_writes[22] + 1;
        if (node23_dmem_en && node23_dmem_we) dm_writes[23] <= dm_writes[23] + 1;

        if (node30_dmem_en && node30_dmem_we) dm_writes[30] <= dm_writes[30] + 1;
        if (node31_dmem_en && node31_dmem_we) dm_writes[31] <= dm_writes[31] + 1;
        if (node32_dmem_en && node32_dmem_we) dm_writes[32] <= dm_writes[32] + 1;
        if (node33_dmem_en && node33_dmem_we) dm_writes[33] <= dm_writes[33] + 1;
    end


    // ============================================================
    // Dump tasks
    // ============================================================
    task dump_node;
        input integer NN;
        integer a;
        begin
            $display("========= NODE %0d =========", NN);
            for (a=0;a<32;a=a+1) begin
                case(NN)
                    0:  $display("%0d: %h", a, DMEM_00.MEM[a]);
                    1:  $display("%0d: %h", a, DMEM_01.MEM[a]);
                    2:  $display("%0d: %h", a, DMEM_02.MEM[a]);
                    3:  $display("%0d: %h", a, DMEM_03.MEM[a]);
                    10: $display("%0d: %h", a, DMEM_10.MEM[a]);
                    11: $display("%0d: %h", a, DMEM_11.MEM[a]);
                    12: $display("%0d: %h", a, DMEM_12.MEM[a]);
                    13: $display("%0d: %h", a, DMEM_13.MEM[a]);
                    20: $display("%0d: %h", a, DMEM_20.MEM[a]);
                    21: $display("%0d: %h", a, DMEM_21.MEM[a]);
                    22: $display("%0d: %h", a, DMEM_22.MEM[a]);
                    23: $display("%0d: %h", a, DMEM_23.MEM[a]);
                    30: $display("%0d: %h", a, DMEM_30.MEM[a]);
                    31: $display("%0d: %h", a, DMEM_31.MEM[a]);
                    32: $display("%0d: %h", a, DMEM_32.MEM[a]);
                    33: $display("%0d: %h", a, DMEM_33.MEM[a]);
                endcase
            end
        end
    endtask

    task verify_node;
        input integer NN;
        reg [63:0] expected [0:31];
        integer a;
        reg [63:0] got;
        begin
            $readmemh($sformatf("cmp_test.dmem.%02d.dump", NN), expected);

            for (a = 0; a < 32; a = a + 1) begin

                // manually read DMEM depending on NN
                case (NN)
                    0:  got = DMEM_00.MEM[a];
                    1:  got = DMEM_01.MEM[a];
                    2:  got = DMEM_02.MEM[a];
                    3:  got = DMEM_03.MEM[a];

                    10: got = DMEM_10.MEM[a];
                    11: got = DMEM_11.MEM[a];
                    12: got = DMEM_12.MEM[a];
                    13: got = DMEM_13.MEM[a];

                    20: got = DMEM_20.MEM[a];
                    21: got = DMEM_21.MEM[a];
                    22: got = DMEM_22.MEM[a];
                    23: got = DMEM_23.MEM[a];

                    30: got = DMEM_30.MEM[a];
                    31: got = DMEM_31.MEM[a];
                    32: got = DMEM_32.MEM[a];
                    33: got = DMEM_33.MEM[a];

                    default: got = 64'h0;
                endcase

                // compare now
                if (got !== expected[a]) begin
                    $display("Mismatch N%0d addr %0d  expected=%h  got=%h",
                             NN, a, expected[a], got);
                end
            end
        end
    endtask


    // ============================================================
    // FINISH CHECK (auto PASS)
    // ============================================================
    always @(posedge clk) begin
        if (!reset) begin
            if (
                dm_writes[0]  == 30 && dm_writes[1]  == 30 &&
                dm_writes[2]  == 30 && dm_writes[3]  == 30 &&
                dm_writes[10] == 30 && dm_writes[11] == 30 &&
                dm_writes[12] == 30 && dm_writes[13] == 30 &&
                dm_writes[20] == 30 && dm_writes[21] == 30 &&
                dm_writes[22] == 30 && dm_writes[23] == 30 &&
                dm_writes[30] == 30 && dm_writes[31] == 30 &&
                dm_writes[32] == 30 && dm_writes[33] == 30
            ) begin
                $display("[TB] ======================================");
                $display("[TB] All nodes finished CMP operations");
                $display("[TB] Dumping DMEM...");
                
                dump_node(0);  dump_node(1);  dump_node(2);  dump_node(3);
                dump_node(10); dump_node(11); dump_node(12); dump_node(13);
                dump_node(20); dump_node(21); dump_node(22); dump_node(23);
                dump_node(30); dump_node(31); dump_node(32); dump_node(33);

                $display("[TB] Verifying...");
                verify_node(0);  verify_node(1);  verify_node(2);  verify_node(3);
                verify_node(10); verify_node(11); verify_node(12); verify_node(13);
                verify_node(20); verify_node(21); verify_node(22); verify_node(23);
                verify_node(30); verify_node(31); verify_node(32); verify_node(33);

                $display("[TB] TEST PASS ");
                $display("[TB] ======================================");
                $finish;
            end
        end
    end


    // ============================================================
    // Simulation start
    // ============================================================
    initial begin
        $display("[TB] Start CMP Testbench");
        #10 reset = 0;
    end

endmodule
