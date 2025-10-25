`timescale 1ns/1ps
module tb_gold_router;
    // ---------------- Clock & Reset ----------------
    localparam CLK_PER = 20;   // 250 MHz
    reg clk = 0; always #(CLK_PER/2) clk = ~clk;
    reg reset;

    // ---------------- DUT I/O ----------------
    // PE
    reg  pesi; wire peri; reg  [63:0] pedi;
    wire peso; reg  pero; wire [63:0] pedo;
    // N
    reg  nsi;  wire nri;  reg  [63:0] ndi;
    wire nso;  reg  nro;  wire [63:0] ndo;
    // E
    reg  esi;  wire eri;  reg  [63:0] edi;
    wire eso;  reg  ero;  wire [63:0] edo;
    // S
    reg  ssi;  wire sri;  reg  [63:0] sdi;
    wire sso;  reg  sro;  wire [63:0] sdo;
    // W
    reg  wsi;  wire wri;  reg  [63:0] wdi;
    wire wso;  reg  wro;  wire [63:0] wdo;

    wire polarity;

    // ---------------- Packet helpers (pure Verilog) ----------------
    function get_sx; input [63:0] pkt; begin get_sx = pkt[62]; end endfunction // 1-bit
    function get_sy; input [63:0] pkt; begin get_sy = pkt[61]; end endfunction // 1-bit
    function [3:0] get_dx; input [63:0] pkt; begin get_dx = pkt[55:52]; end endfunction
    function [3:0] get_dy; input [63:0] pkt; begin get_dy = pkt[51:48]; end endfunction

    function [63:0] build_pkt_xy;
        input [0:0]  sx;
        input [3:0]  dx;
        input [0:0]  sy;
        input [3:0]  dy;
        input [15:0] src_id;
        input [31:0] payload;
        begin
            build_pkt_xy = {1'b0, sx[0], sy[0], 5'b0, dx[3:0], dy[3:0], src_id, payload};
        end
    endfunction

    function [63:0] pkt_xy;
        input integer sx, dx, sy, dy, payload;
        begin
            pkt_xy = build_pkt_xy(sx?1'b1:1'b0, dx[3:0], sy?1'b1:1'b0, dy[3:0], 16'd0, payload[31:0]);
        end
    endfunction

    // ---------------- DUT ----------------
    gold_router dut (
        .clk(clk), .reset(reset), .polarity(polarity),

        .pesi(pesi), .peri(peri), .pedi(pedi),
        .peso(peso), .pero(pero), .pedo(pedo),

        .nsi(nsi), .nri(nri), .ndi(ndi),
        .nso(nso), .nro(nro), .ndo(ndo),

        .esi(esi), .eri(eri), .edi(edi),
        .eso(eso), .ero(ero), .edo(edo),

        .ssi(ssi), .sri(sri), .sdi(sdi),
        .sso(sso), .sro(sro), .sdo(sdo),

        .wsi(wsi), .wri(wri), .wdi(wdi),
        .wso(wso), .wro(wro), .wdo(wdo)
    );

    // ---------------- Init ----------------
    initial begin
        pesi=0; pedi=64'b0;
        nsi =0; ndi =64'b0;
        esi =0; edi =64'b0;
        ssi =0; sdi =64'b0;
        wsi =0; wdi =64'b0;

        // downstream ready high by default
        pero = 1'b1; nro = 1'b1; ero = 1'b1; sro = 1'b1; wro = 1'b1;

        reset = 1;
        repeat (5) @(posedge clk);
        reset = 0;
        $display("[%0t] reset deasserted.", $time);
    end

    // ---------------- Send tasks (align to DUT posedge sampling) ----------------
    task send_on_PE; input [63:0] pkt;
        begin
            @(negedge clk);
            while (reset) @(negedge clk);
            while (!peri) @(negedge clk);
            pesi <= 1'b1; pedi <= pkt;
            @(posedge clk);          // sampled by DUT
            @(negedge clk);
            pesi <= 1'b0; pedi <= 64'b0;
            $display("[%0t] TB SEND PE: %h", $time, pkt);
        end
    endtask

    task send_on_N; input [63:0] pkt;
        begin
            @(negedge clk);
            while (reset) @(negedge clk);
            while (!nri) @(negedge clk);
            nsi <= 1'b1; ndi <= pkt;
            @(posedge clk);
            @(negedge clk);
            nsi <= 1'b0; ndi <= 64'b0;
            $display("[%0t] TB SEND N : %h", $time, pkt);
        end
    endtask

    task send_on_E; input [63:0] pkt;
        begin
            @(negedge clk);
            while (reset) @(negedge clk);
            while (!eri) @(negedge clk);
            esi <= 1'b1; edi <= pkt;
            @(posedge clk);
            @(negedge clk);
            esi <= 1'b0; edi <= 64'b0;
            $display("[%0t] TB SEND E : %h", $time, pkt);
        end
    endtask

    task send_on_S; input [63:0] pkt;
        begin
            @(negedge clk);
            while (reset) @(negedge clk);
            while (!sri) @(negedge clk);
            ssi <= 1'b1; sdi <= pkt;
            @(posedge clk);
            @(negedge clk);
            ssi <= 1'b0; sdi <= 64'b0;
            $display("[%0t] TB SEND S : %h", $time, pkt);
        end
    endtask

    task send_on_W; input [63:0] pkt;
        begin
            @(negedge clk);
            while (reset) @(negedge clk);
            while (!wri) @(negedge clk);
            wsi <= 1'b1; wdi <= pkt;
            @(posedge clk);
            @(negedge clk);
            wsi <= 1'b0; wdi <= 64'b0;
            $display("[%0t] TB SEND W : %h", $time, pkt);
        end
    endtask

    // Simultaneous injection from PE and W towards E; vc_target selects ext_vc (0/1)
    task dual_inject_PE_W_to_E; input [0:0] vc_target; input [63:0] pkt_pe, pkt_w;
        begin
            @(negedge clk);
            while (reset) @(negedge clk);
            // ext_vc = ~polarity; wait for desired ext_vc
            while (polarity !== ~vc_target) @(negedge clk);
            while (!(peri && wri)) @(negedge clk);
            pesi <= 1'b1; pedi <= pkt_pe;
            wsi  <= 1'b1; wdi  <= pkt_w;
            @(posedge clk);
            @(negedge clk);
            pesi <= 1'b0; pedi <= 64'b0;
            wsi  <= 1'b0; wdi  <= 64'b0;
            $display("[%0t] TB DUAL-INJ(ext_vc=%0d): PE=%h  W=%h", $time, vc_target, pkt_pe, pkt_w);
        end
    endtask

    // ---------------- Wait output tasks (no labels, no SV) ----------------
    task wait_out_PE; output [63:0] pkt; input integer timeout;
        integer t; begin : WAIT_PE
            pkt = 64'b0; t = 0;
            forever begin
                @(posedge clk);
                if (peso && pero) begin pkt = pedo; disable WAIT_PE; end
                t = t + 1;
                if (t >= timeout) begin $display("TIMEOUT waiting PE"); $fatal; end
            end
        end
    endtask

    task wait_out_N; output [63:0] pkt; input integer timeout;
        integer t; begin : WAIT_N
            pkt = 64'b0; t = 0;
            forever begin
                @(posedge clk);
                if (nso && nro) begin pkt = ndo; disable WAIT_N; end
                t = t + 1;
                if (t >= timeout) begin $display("TIMEOUT waiting N"); $fatal; end
            end
        end
    endtask

    task wait_out_E; output [63:0] pkt; input integer timeout;
        integer t; begin : WAIT_E
            pkt = 64'b0; t = 0;
            forever begin
                @(posedge clk);
                if (eso && ero) begin pkt = edo; disable WAIT_E; end
                t = t + 1;
                if (t >= timeout) begin $display("TIMEOUT waiting E"); $fatal; end
            end
        end
    endtask

    task wait_out_S; output [63:0] pkt; input integer timeout;
        integer t; begin : WAIT_S
            pkt = 64'b0; t = 0;
            forever begin
                @(posedge clk);
                if (sso && sro) begin pkt = sdo; disable WAIT_S; end
                t = t + 1;
                if (t >= timeout) begin $display("TIMEOUT waiting S"); $fatal; end
            end
        end
    endtask

    task wait_out_W; output [63:0] pkt; input integer timeout;
        integer t; begin : WAIT_W
            pkt = 64'b0; t = 0;
            forever begin
                @(posedge clk);
                if (wso && wro) begin pkt = wdo; disable WAIT_W; end
                t = t + 1;
                if (t >= timeout) begin $display("TIMEOUT waiting W"); $fatal; end
            end
        end
    endtask

    // ---------------- Expect helper ----------------
    task expect_equal; input [127:0] what; input integer got, exp;
        begin
            if (got !== exp) begin
                $display("[%0t] EXPECT %0s = %0d, GOT = %0d", $time, what, exp, got);
                $fatal;
            end
        end
    endtask

    // ---------------- Tests ----------------
    localparam [31:0] PAY_W1 = 32'h57_00_00_01; // 'W', 1
    localparam [31:0] PAY_P1 = 32'h50_00_00_01; // 'P', 1
    localparam [31:0] PAY_W2 = 32'h57_00_00_02; // 'W', 2
    localparam [31:0] PAY_P2 = 32'h50_00_00_02; // 'P', 2

    reg [63:0] pk, e_out1, e_out2, e_out3, e_out4;
    reg [63:0] pktW1, pktP1, pktW2, pktP2;
    reg first_is_W, first_is_P;
    reg [0:0] vc_used;

    initial begin
        @(negedge reset);
        repeat (2) @(posedge clk);

        // 1) E/W routing
        send_on_PE(pkt_xy(0,3, 0,0, 32'hA001)); // -> E, dx 3->2
        wait_out_E(pk, 2000);
        expect_equal("dir(E) dx'", get_dx(pk), 2);
        expect_equal("dir(E) dy'", get_dy(pk), 0);
        expect_equal("dir(E) sx",  get_sx(pk), 0);

        send_on_PE(pkt_xy(1,2, 0,0, 32'hA002)); // -> W, dx 2->1
        wait_out_W(pk, 2000);
        expect_equal("dir(W) dx'", get_dx(pk), 1);
        expect_equal("dir(W) dy'", get_dy(pk), 0);
        expect_equal("dir(W) sx",  get_sx(pk), 1);

        send_on_PE(pkt_xy(0,0, 0,2, 32'hA003)); // -> N, dy 2->1
        wait_out_N(pk, 2000);
        expect_equal("dir(N) dx'", get_dx(pk), 0);
        expect_equal("dir(N) dy'", get_dy(pk), 1);
        expect_equal("dir(N) sy",  get_sy(pk), 0);

        send_on_PE(pkt_xy(0,0, 1,1, 32'hA004)); // -> S, dy 1->0
        wait_out_S(pk, 2000);
        expect_equal("dir(S) dx'", get_dx(pk), 0);
        expect_equal("dir(S) dy'", get_dy(pk), 0);
        expect_equal("dir(S) sy",  get_sy(pk), 1);

        // From W to E
        send_on_W(pkt_xy(0,1, 0,0, 32'hB010));
        wait_out_E(pk, 2000);
        expect_equal("W->E dx'", get_dx(pk), 0);

        // Block E test
        ero <= 1'b0;
        send_on_PE(pkt_xy(0,1, 0,0, 32'hC0DE));
        repeat (5) @(posedge clk);
        if (eso) begin $display("Blocked E should not assert so."); $fatal; end
        ero <= 1'b1;
        wait_out_E(pk, 2000);
        expect_equal("unblock E dx'", get_dx(pk), 0);

        // Simple RR: PE & W to E
        pktW1 = pkt_xy(0,2, 0,0, PAY_W1);
        pktP1 = pkt_xy(0,1, 0,0, PAY_P1);
        pktW2 = pkt_xy(0,2, 0,0, PAY_W2);
        pktP2 = pkt_xy(0,1, 0,0, PAY_P2);

        // Round 1 with ext_vc=0
        vc_used = 1'b0;
        dual_inject_PE_W_to_E(vc_used, pktP1, pktW1);
        wait_out_E(e_out1, 4000);
        wait_out_E(e_out2, 4000);
        first_is_W = (e_out1[31:0] === PAY_W1);
        first_is_P = (e_out1[31:0] === PAY_P1);
        if (!(first_is_W || first_is_P)) begin
            $display("Round1: unexpected first payload on E: 0x%08h", e_out1[31:0]); 
            $fatal;
        end
        $display("[%0t] RR Round1 order: first=%s", $time, first_is_W?"W":"PE");

        // Wait until E becomes idle
        @(posedge clk);
        while (eso) @(posedge clk);

        // Round 2, should flip order
        dual_inject_PE_W_to_E(vc_used, pktP2, pktW2);
        wait_out_E(e_out3, 4000);
        wait_out_E(e_out4, 4000);
        if (first_is_W) begin
            if (e_out3[31:0] !== PAY_P2 || e_out4[31:0] !== PAY_W2) begin
                $display("RR FAIL: expected PE then W in Round2, got first=0x%08h second=0x%08h",
                         e_out3[31:0], e_out4[31:0]);
                $fatal;
            end
        end else begin
            if (e_out3[31:0] !== PAY_W2 || e_out4[31:0] !== PAY_P2) begin
                $display("RR FAIL: expected W then PE in Round2, got first=0x%08h second=0x%08h",
                         e_out3[31:0], e_out4[31:0]);
                $fatal;
            end
        end
        $display("[%0t] RR Round2 order flipped OK.", $time);

        // To-PE delivery keeps dx/dy = 0
        send_on_N(pkt_xy(0,0, 0,0, 32'hEE00));
        wait_out_PE(pk, 2000);
        if (get_dx(pk)!=0 || get_dy(pk)!=0) begin
            $display("To-PE packet should preserve dx/dy=0.");
            $fatal;
        end

        repeat (10) @(posedge clk);
        $display("=== ALL TESTS PASSED ===");
        $finish;
    end
endmodule
