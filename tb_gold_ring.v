`timescale 1ns/1ps
module tb_gold_ring;

    // ---------------- Clock & Reset ----------------
    localparam CLK_PER = 20;   // 250 MHz clock
    reg clk = 0; always #(CLK_PER/2) clk = ~clk;
    reg reset;

    // ---------------- DUT I/O ----------------
    wire [15:0] peri;
    reg  [15:0] pesi;
    reg  [1023:0] pedi;

    wire [15:0] peso;
    reg  [15:0] pero;
    wire [1023:0] pedo;

    wire [15:0] polarity;

    // ---------------- DUT Instantiation ----------------
    gold_ring dut (
        .clk(clk), .reset(reset),
        .pesi(pesi), .peri(peri),
        .pedi(pedi), .peso(peso),
        .pero(pero), .pedo(pedo),
        .polarity(polarity)
    );

    // ---------------- Index Helpers ----------------
    function integer idx; input integer x, y; begin idx = y*4 + x; end endfunction
    function integer lo;  input integer id; begin lo = id*64; end endfunction

    // ---------------- Packet Field Extractors ----------------
    function get_sx; input [63:0] pkt; begin get_sx = pkt[62]; end endfunction
    function get_sy; input [63:0] pkt; begin get_sy = pkt[61]; end endfunction
    function [3:0] get_dx; input [63:0] pkt; begin get_dx = pkt[55:52]; end endfunction
    function [3:0] get_dy; input [63:0] pkt; begin get_dy = pkt[51:48]; end endfunction
    // Source ID located at bits [47:32]
    function [15:0] get_src_id; input [63:0] pkt; begin get_src_id = pkt[47:32]; end endfunction

    // ---------------- Packet Builder ----------------
    function [63:0] build_pkt_xy;
        input [0:0]  sx;       // 0:E, 1:W
        input [3:0]  dx;       // hops in X
        input [0:0]  sy;       // 0:N, 1:S
        input [3:0]  dy;       // hops in Y
        input [15:0] src_id;
        input [31:0] payload;
        begin
            // Format: {1’b0, sx, sy, 5’b0, dx, dy, src_id, payload}
            build_pkt_xy = {1'b0, sx[0], sy[0], 5'b0, dx[3:0], dy[3:0], src_id, payload};
        end
    endfunction

    function [63:0] pkt_xy; 
        input integer sx, dx, sy, dy, src_id, payload;
        begin
            pkt_xy = build_pkt_xy(sx?1'b1:1'b0, dx[3:0], sy?1'b1:1'b0, dy[3:0],
                                  src_id[15:0], payload[31:0]);
        end
    endfunction

    // Testbench Logging
    integer flog [0:15];
    integer fphase;
    reg [15:0] peso_q;
    reg phase_prev, phase_cur;
    time phase_start_t;

    function [15:0] get_dst_id; input integer k; begin get_dst_id = k[15:0]; end endfunction

    // open files
    initial begin
        integer k; string fname;
        for (k = 0; k < 16; k = k + 1) begin
            $sformat(fname, "gather_phase%0d.res", k);
            flog[k] = $fopen(fname, "w");
            if (flog[k] == 0) $fatal(1,"Cannot open %s", fname);
        end
        fphase = $fopen("start_end_time.out", "w");
        if (fphase == 0) $fatal(1,"Cannot open start_end_time.out");
        peso_q        = '0;
        phase_prev    = 1'b0;
        phase_cur     = 1'b0;
        phase_start_t = 0;
    end

    // phase start when reset deasserts (use external VC phase = ~polarity[0])
    always @(negedge reset) begin
        phase_prev    = ~polarity[0];
        phase_cur     = phase_prev;
        phase_start_t = $time;
        $fdisplay(fphase, "Phase=%0d START Time=%0t", phase_cur, phase_start_t);
    end

    // detect phase flips and mark END/START
    always @(posedge clk) if (!reset) begin
        phase_cur = ~polarity[0];
        if (phase_cur !== phase_prev) begin
            $fdisplay(fphase, "Phase=%0d END   Time=%0t", phase_prev, $time);
            $fdisplay(fphase, "Phase=%0d START Time=%0t", phase_cur,  $time);
            phase_prev    = phase_cur;
            phase_start_t = $time;
        end
    end

    // per-PE arrival logging (peso rising edge)
    integer kk;
    always @(posedge clk) begin
        if (reset) begin
            peso_q <= '0;
        end else begin
            for (kk = 0; kk < 16; kk = kk + 1) begin
                if (peso[kk] && !peso_q[kk]) begin
                    $fdisplay(flog[kk],
                        "Phase=%0d, Time=%0t, Destination=%0d, Source=%0d, Packet Value=%h",
                        (~polarity[kk]),
                        $time,
                        kk[3:0],
                        get_src_id(pedo[lo(kk) +: 64]),
                        pedo[lo(kk) +: 64]
                    );
                end
            end
            peso_q <= peso;
        end
    end

    // close
    final begin
        integer k;
        if (!reset) $fdisplay(fphase, "Phase=%0d END   Time=%0t", (~polarity[0]), $time);
        for (k = 0; k < 16; k = k + 1) if (flog[k]) $fclose(flog[k]);
        if (fphase) $fclose(fphase);
    end


    // ---------------- Send & Receive Tasks ----------------
    task pe_send;
        input integer x, y;
        input [63:0] pkt;
        integer id, base;
        begin
            id = idx(x,y);
            base = lo(id);
            @(negedge clk);
            while (reset) @(negedge clk);
            while (!peri[id]) @(negedge clk);
            pesi[id] <= 1'b1;
            pedi[base +: 64] <= pkt;
            @(posedge clk);
            @(negedge clk);
            pesi[id] <= 1'b0;
            pedi[base +: 64] <= 64'b0;
            $display("[%0t] SEND (%0d,%0d) : %h", $time, x, y, pkt);
        end
    endtask

    // === Send aligned to external VC phase (~polarity) ===
    task pe_send_vc_aligned;
        input integer x, y;
        input [63:0] pkt;
        input [0:0]  vc_ext; // 0=even VC, 1=odd VC
        integer id, base;
        begin
            id   = idx(x,y);
            base = lo(id);
            @(negedge clk);
            while (reset) @(negedge clk);
            while (!( peri[id] && ((~polarity[id]) === vc_ext) )) @(negedge clk);
            pesi[id] <= 1'b1;
            pedi[base +: 64] <= pkt;
            @(posedge clk);
            @(negedge clk);
            pesi[id] <= 1'b0;
            pedi[base +: 64] <= 64'b0;
            $display("[%0t] SEND(aligned vc=%0d) (%0d,%0d) : %h", $time, vc_ext, x, y, pkt);
        end
    endtask

    task pe_wait_recv;
        input integer x, y;
        output [63:0] pkt;
        input integer timeout;
        integer t, id, base;
        reg done;
        begin
            id = idx(x,y);
            base = lo(id);
            pkt = 64'b0;
            t = 0;
            done = 0;
            while (!done) begin
                @(posedge clk);
                if (peso[id] && pero[id]) begin
                    pkt = pedo[base +: 64];
                    $display("[%0t] RECV (%0d,%0d): %h (src=%0d)", $time, x, y, pkt, get_src_id(pkt));
                    done = 1;   
                end
                t = t + 1;
                if (t >= timeout) begin
                    $display("[%0t] TIMEOUT waiting PE(%0d,%0d)", $time, x, y);
                    $fatal;
                end
            end
        end
    endtask

    task pe_dual_send_aligned;
        input integer x1,y1,x2,y2;
        input [63:0] p1, p2;
        input [0:0]  vc_ext;  // external VC phase (0=even, 1=odd)
        integer id1,id2,b1,b2;
        begin
            id1=idx(x1,y1); b1=lo(id1);
            id2=idx(x2,y2); b2=lo(id2);
            @(negedge clk);
            while (reset) @(negedge clk);
            while (!( peri[id1] && peri[id2] &&
                    ( (~polarity[id1]) === vc_ext ) &&
                    ( (~polarity[id2]) === vc_ext ) )) @(negedge clk);
            pesi[id1] <= 1'b1; pedi[b1 +: 64] <= p1;
            pesi[id2] <= 1'b1; pedi[b2 +: 64] <= p2;
            @(posedge clk);
            @(negedge clk);
            pesi[id1] <= 1'b0; pedi[b1 +: 64] <= 64'b0;
            pesi[id2] <= 1'b0; pedi[b2 +: 64] <= 64'b0;
            $display("[%0t] DUAL SEND ALIGNED(ext_vc=%0d) (%0d,%0d) & (%0d,%0d)",
                    $time, vc_ext, x1,y1,x2,y2);
        end
    endtask

    // ---------------- Expectation Helpers ----------------
    task expect_eq; input [127:0] what; input [3:0] got, exp;
        begin
            if (got !== exp) begin
                $display("[%0t] EXPECT %0s = %0d, GOT = %0d", $time, what, exp, got);
                $fatal;
            end
        end
    endtask

    task expect_true; input [127:0] msg; input cond;
        begin
            if (!cond) begin
                $display("[%0t] EXPECT TRUE: %0s", $time, msg);
                $fatal;
            end
        end
    endtask

    // ---------------- Hotspot Temporary Arrays ----------------
    reg [31:0] hs_sx_list [0:14];  // 0:E,1:W
    reg [31:0] hs_sy_list [0:14];  // 0:N,1:S
    reg [31:0] hs_dxh     [0:14];  // hops in X
    reg [31:0] hs_dyh     [0:14];  // hops in Y
    reg [31:0] hs_srcx    [0:14];
    reg [31:0] hs_srcy    [0:14];
    reg [31:0] hs_sid     [0:14];
    reg [31:0] hs_dist    [0:14];  // Manhattan distance

    // ---------------- HOTSPOT (distance-batched, jittered, throttled) ----------------
    task automatic hotspot_many_to_one;
        input integer tx, ty;
        input integer timeout_each;
        input integer max_inflight;

        integer n, x, y, i, d;
        integer inflight, recv_cnt;
        reg [63:0] pk;

        integer lx, ly;
        reg [0:0]  lsx, lsy;
        reg [3:0]  ldx, ldy;
        reg [15:0] lsid;
        integer    r;

    begin
        // Build source list (exclude the target tile)
        n = 0;
        for (y=0; y<4; y=y+1) begin
            for (x=0; x<4; x=x+1) begin
                if (!(x==tx && y==ty)) begin
                    hs_srcx[n] = x;  hs_srcy[n] = y;  hs_sid[n] = y*4 + x;
                    hs_sx_list[n] = (tx < x) ? 1 : 0;                      // 1:W, 0:E
                    hs_dxh[n]     = (tx < x) ? (x - tx) : (tx - x);
                    hs_sy_list[n] = (ty < y) ? 0 : 1;                      // 0:N, 1:S
                    hs_dyh[n]     = (ty < y) ? (y - ty) : (ty - y);
                    hs_dist[n]    = hs_dxh[n] + hs_dyh[n];
                    n = n + 1;
                end
            end
        end

        $display("[%0t] === HOTSPOT start (batched): ->(%0d,%0d), cap=%0d ===",
                 $time, tx, ty, max_inflight);

        inflight = 0;
        recv_cnt = 0;

        // Launch waves from farthest (6) to nearest (1)
        for (d = 6; d >= 1; d = d - 1) begin : DIST_WAVE
            integer any_in_this_wave;
            any_in_this_wave = 0;

            // Launch all sources in this distance class (with throttle)
            for (i = 0; i < n; i = i + 1) begin
                if (hs_dist[i] == d) begin
                    any_in_this_wave = 1;

                    // Throttle: keep at most 'max_inflight' in-flight
                    while (inflight >= max_inflight) begin
                        pe_wait_recv(tx, ty, pk, timeout_each);
                        if (get_dx(pk)!==4'd0 || get_dy(pk)!==4'd0) begin
                            $display("[%0t] HOTSPOT FAIL dx,dy pkt=%h", $time, pk); $fatal;
                        end
                        recv_cnt = recv_cnt + 1;
                        if (inflight>0) inflight = inflight - 1;
                        $display("[%0t] HOTSPOT recv[%0d/15] (inflight=%0d)",
                                 $time, recv_cnt, inflight);
                    end

                    // Local copies + small random jitter (0–15 cycles)
                    lx   = hs_srcx[i];
                    ly   = hs_srcy[i];
                    lsx  = hs_sx_list[i][0];
                    ldx  = hs_dxh[i][3:0];
                    lsy  = hs_sy_list[i][0];
                    ldy  = hs_dyh[i][3:0];
                    lsid = hs_sid[i][15:0];

                    r = $urandom;
                    repeat (r[3:0]) @(negedge clk);

                    // Key: split VC by source-id LSB and align to that external VC phase
                    pe_send_vc_aligned(
                        lx, ly,
                        pkt_xy(lsx, ldx, lsy, ldy, lsid, {8'h48,8'h53,lx[3:0],ly[3:0]}), // "HSxy"
                        lsid[0] ? 1'b1 : 1'b0
                    );

                    inflight = inflight + 1;
                end
            end

            // Drain this distance class completely before moving on
            if (any_in_this_wave) begin
                while (inflight > 0) begin
                    pe_wait_recv(tx, ty, pk, timeout_each);
                    if (get_dx(pk)!==4'd0 || get_dy(pk)!==4'd0) begin
                        $display("[%0t] HOTSPOT FAIL dx,dy pkt=%h", $time, pk); $fatal;
                    end
                    recv_cnt = recv_cnt + 1;
                    inflight = inflight - 1;
                    $display("[%0t] HOTSPOT recv[%0d/15] (inflight=%0d)",
                             $time, recv_cnt, inflight);
                end
            end
        end

        if (recv_cnt != 15) begin
            $display("[%0t] HOTSPOT ERROR: expected 15 received, got %0d", $time, recv_cnt);
            $fatal;
        end
        $display("[%0t] === HOTSPOT done: %0d/15 ===", $time, recv_cnt);
    end
    endtask

    // ---------------- Row/Column Saturation Helpers ----------------
    task saturate_row_to_right; // all (x, ry) -> (3, ry)
        input integer ry;
        input integer timeout_each;
        integer x; reg [63:0] pk;
    begin
        fork
            for (x=0; x<3; x=x+1) begin
                pe_send(x, ry, pkt_xy(0, 3-x, 1, 0, idx(x,ry), 32'h525F5257)); // "R_RW"
            end
        join
        repeat (3) pe_wait_recv(3, ry, pk, timeout_each);
    end
    endtask

    task saturate_col_to_bottom; // all (cx, y) -> (cx, 3)
        input integer cx;
        input integer timeout_each;
        integer y; reg [63:0] pk;
    begin
        fork
            for (y=0; y<3; y=y+1) begin
                pe_send(cx, y, pkt_xy(1, 0, 1, 3-y, idx(cx,y), 32'h435F4353)); // "C_CS"
            end
        join
        repeat (3) pe_wait_recv(cx, 3, pk, timeout_each);
    end
    endtask

    // ---------------- Initialization ----------------
    integer i;
    initial begin
        pesi = 16'b0;
        pedi = {1024{1'b0}};
        pero = 16'hFFFF;   // all outputs ready by default
        reset = 1;
        repeat (8) @(posedge clk);
        reset = 0;
        $display("[%0t] RESET.", $time);
    end

    // ---------------- Test Sequences ----------------
    reg [63:0] pk;

    initial begin
        @(negedge reset);
        repeat (3) @(posedge clk);

        // 1) Single-hop adjacency
        // E: dx=1, sx=0
        pe_send(1,1, pkt_xy(0,1, 0,0, idx(1,1), 32'h45_30_30_31));
        pe_wait_recv(2,1, pk, 2000);
        expect_eq("E.dx'", get_dx(pk), 0);
        expect_eq("E.dy'", get_dy(pk), 0);
        expect_true("E.sx==0", get_sx(pk)==0);

        // W: dx=1, sx=1
        pe_send(1,1, pkt_xy(1,1, 0,0, idx(1,1), 32'h57_30_30_31));
        pe_wait_recv(0,1, pk, 2000);
        expect_eq("W.dx'", get_dx(pk), 0);
        expect_true("W.sx==1", get_sx(pk)==1);

        // N: dy=1, sy=0
        pe_send(1,1, pkt_xy(0,0, 0,1, idx(1,1), 32'h4E_30_30_31));
        pe_wait_recv(1,0, pk, 2000);
        expect_eq("N.dy'", get_dy(pk), 0);
        expect_true("N.sy==0", get_sy(pk)==0);

        // S: dy=1, sy=1
        pe_send(1,1, pkt_xy(0,0, 1,1, idx(1,1), 32'h53_30_30_31));
        pe_wait_recv(1,2, pk, 2000);
        expect_eq("S.dy'", get_dy(pk), 0);
        expect_true("S.sy==1", get_sy(pk)==1);

        // 2) Multi-hop diagonal (0,0)->(3,3)
        pe_send(0,0, pkt_xy(0,3, 1,3, idx(0,0), 32'h44_31_41_33)); 
        pe_wait_recv(3,3, pk, 6000);
        expect_eq("diag.dx'", get_dx(pk), 0);
        expect_eq("diag.dy'", get_dy(pk), 0);

        // 3) Backpressure: target not ready
        pero[idx(3,0)] <= 1'b0;
        pe_send(0,0, pkt_xy(0,3, 0,0, idx(0,0), 32'h42_31_30_43));
        repeat (10) @(posedge clk);
        if (peso[idx(3,0)] && pero[idx(3,0)]) begin
            $display("[%0t] Backpressure FAIL: recv while pero=0", $time); $fatal;
        end
        pero[idx(3,0)] <= 1'b1;
        pe_wait_recv(3,0, pk, 4000);
        expect_eq("bp.dx'", get_dx(pk), 0);

        // 4) Dual aligned injection to the same column
        pe_dual_send_aligned(0,1, 1,1,
            pkt_xy(0,3, 0,0, idx(0,1), 32'h57_32_45_31),   // (0,1)->(3,1)
            pkt_xy(0,2, 0,0, idx(1,1), 32'h50_32_45_31),   // (1,1)->(3,1)
            1'b0 // target external VC phase
        );
        pe_wait_recv(3,1, pk, 6000);
        pe_wait_recv(3,1, pk, 6000);

        // 5) HOTSPOT stress: all -> (2,2)
        hotspot_many_to_one(2, 2, /*timeout_each*/ 20000, /*max_inflight*/ 1);

        // 6) Edge behavior (place after hotspot)
        pe_send(3,3, pkt_xy(0,1, 0,0, idx(3,3), 32'h45_44_47_45));
        repeat (10) @(posedge clk);
        if (peso[idx(0,3)] && pero[idx(0,3)]) begin $display("Edge test: unexpected recv at (0,3)"); $fatal; end
        if (peso[idx(3,2)] && pero[idx(3,2)]) begin $display("Edge test: unexpected recv at (3,2)"); $fatal; end

        // Optional saturation exercises
        saturate_row_to_right(1, 6000);
        saturate_col_to_bottom(2, 6000);

        repeat (10) @(posedge clk);
        $display("=== ALL MESH TESTS PASSED ===");
        $finish;
    end
endmodule
