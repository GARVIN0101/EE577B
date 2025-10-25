// - 64-bit fixed packets; s/r handshake on each uni-directional channel
// - Two VCs (even/odd) with 1-deep buffers per input/output VC
// - polarity: even(0)/odd(1); internal forwarding on current VC,
// - Round-robin arbitration per OUTPUT per VC
`timescale 1ns/1ps
module gold_router
(
    input wire clk,
    input wire reset,       // synchronous, active-high
    output reg polarity,    // 0-even, 1-odd (defined even during reset)
    // ----- PE -----
    input  wire        pesi,
    output wire        peri,
    input  wire [63:0] pedi,
    output wire        peso,
    input  wire        pero,
    output wire [63:0] pedo,
    // ----- N -----
    input  wire        nsi,
    output wire        nri,
    input  wire [63:0] ndi,
    output wire        nso,
    input  wire        nro,
    output wire [63:0] ndo,
    // ----- E -----
    input  wire        esi,
    output wire        eri,
    input  wire [63:0] edi,
    output wire        eso,
    input  wire        ero,
    output wire [63:0] edo,
    // ----- S -----
    input  wire        ssi,
    output wire        sri,
    input  wire [63:0] sdi,
    output wire        sso,
    input  wire        sro,
    output wire [63:0] sdo,
    // ----- W -----
    input  wire        wsi,
    output wire        wri,
    input  wire [63:0] wdi,
    output wire        wso,
    input  wire        wro,
    output wire [63:0] wdo
);
    parameter PORTS = 5; // 0:PE, 1:N, 2:E, 3:S, 4:W
    localparam P_PE=0, P_N=1, P_E=2, P_S=3, P_W=4;  // port encoding
    
    // current externally-active VC
    wire int_vc = polarity;    
    wire ext_vc = ~polarity;
    // ---------------- Hop function ----------------
    function get_sx; // 0:E,1:W
        input [63:0] pkt;
        begin get_sx = pkt[62]; end
    endfunction
    function get_sy; // 0:N,1:S
        input [63:0] pkt;
        begin get_sy = pkt[61]; end
    endfunction
    function [3:0] get_dx;
        input [63:0] pkt;
        begin get_dx = pkt[55:52]; end
    endfunction
    function [3:0] get_dy;
        input [63:0] pkt;
        begin get_dy = pkt[51:48]; end
    endfunction
    function [63:0] set_dx;
        input [63:0] pkt; input [3:0] dx;
        begin set_dx = {pkt[63:56], dx, pkt[51:0]}; end
    endfunction
    function [63:0] set_dy;
        input [63:0] pkt; input [3:0] dy;
        begin set_dy = {pkt[63:52], dy, pkt[47:0]}; end
    endfunction

    // ---------------- XY routing choice ----------------
    // 0=PE, 1=N, 2=E, 3=S, 4=W
    function [2:0] choose_dir;
        input [63:0] pkt;
        reg [3:0] dx, dy;
        begin
            dx = get_dx(pkt);
            dy = get_dy(pkt);
            if (dx != 0) begin
                if (get_sx(pkt)==1'b0)
                    choose_dir = 3'd2; // E
                else
                    choose_dir = 3'd4; // W
            end
            else if (dy != 0) begin
                if (get_sy(pkt)==1'b0)
                    choose_dir = 3'd1; // N
                else
                    choose_dir = 3'd3; // S
            end
            else
                choose_dir = 3'd0;   // to PE
        end
    endfunction
    function [63:0] dec_xy; // decrement distance
        input [63:0] pkt;
        reg [3:0] dx, dy;
        begin
            dx = get_dx(pkt);
            dy = get_dy(pkt);
            if (dx != 0)      dec_xy = set_dx(pkt, dx-1);
            else if (dy != 0) dec_xy = set_dy(pkt, dy-1);
            else              dec_xy = pkt; // to PE
        end
    endfunction
    
    // ---------------- Buffers: per-port, per-VC (2 VCs) ----------------
    // IN
    reg [63:0] in_buf0 [0:PORTS-1];
    reg [63:0] in_buf1 [0:PORTS-1];
    reg        in_full0[0:PORTS-1];
    reg        in_full1[0:PORTS-1];
    // OUT
    reg [63:0] out_buf0 [0:PORTS-1];
    reg [63:0] out_buf1 [0:PORTS-1];
    reg        out_full0[0:PORTS-1];
    reg        out_full1[0:PORTS-1];

    function [63:0] rd_in_buf;
        input vc; input [2:0] port;
        begin rd_in_buf = (vc==1'b0) ? in_buf0[port] : in_buf1[port]; end
    endfunction
    function rd_in_full;
        input vc; input [2:0] port;
        begin rd_in_full = (vc==1'b0) ? in_full0[port] : in_full1[port]; end
    endfunction
    function [63:0] rd_out_buf;
        input vc; input [2:0] port;
        begin rd_out_buf = (vc==1'b0) ? out_buf0[port] : out_buf1[port]; end
    endfunction
    function rd_out_full;
        input vc; input [2:0] port;
        begin rd_out_full = (vc==1'b0) ? out_full0[port] : out_full1[port]; end
    endfunction
    
    // ---------------- Ready inputs (for ext_vc) ----------------
    assign peri = ~rd_in_full(ext_vc, P_PE);
    assign nri = ~rd_in_full(ext_vc, P_N);
    assign eri = ~rd_in_full(ext_vc, P_E);
    assign sri = ~rd_in_full(ext_vc, P_S);
    assign wri = ~rd_in_full(ext_vc, P_W);
    // ---------------- Drive outputs (for ext_vc) ----------------
    assign pedo = rd_out_buf(ext_vc, P_PE);
    assign ndo = rd_out_buf(ext_vc, P_N);
    assign edo = rd_out_buf(ext_vc, P_E);
    assign sdo = rd_out_buf(ext_vc, P_S);
    assign wdo = rd_out_buf(ext_vc, P_W);

    assign peso = rd_out_full(ext_vc, P_PE) & pero;
    assign nso = rd_out_full(ext_vc, P_N) & nro;
    assign eso = rd_out_full(ext_vc, P_E) & ero;
    assign sso = rd_out_full(ext_vc, P_S) & sro;
    assign wso = rd_out_full(ext_vc, P_W) & wro;

     // ----------------- request for int_vc -----------------
    reg [PORTS-1:0] req_mask [0:PORTS-1]; // req_mask[out][in]=1 input port in want output to out
    reg [63:0] in_pkt [0:PORTS-1];
    reg in_has [0:PORTS-1];
    integer i;
    always @* begin
        for (i = 0; i < PORTS; i = i + 1) begin
            req_mask[i] = {PORTS{1'b0}};
            in_pkt[i] = rd_in_buf (int_vc, i);
            in_has[i] = rd_in_full(int_vc, i);
        end
        for (i = 0;i < PORTS; i = i + 1) begin
            if (in_has[i]) begin
                case (choose_dir(in_pkt[i]))
                    3'd0: req_mask[P_PE][i] = 1'b1;
                    3'd1: req_mask[P_N][i] = 1'b1;
                    3'd2: req_mask[P_E][i] = 1'b1;
                    3'd3: req_mask[P_S][i] = 1'b1;
                    3'd4: req_mask[P_W][i] = 1'b1;
                    default: ;
                endcase
            end
        end
    end
    // ---------- round-robin ----------
    reg [2:0] rr_ptr0 [0:PORTS-1];  // per OUT, for VC0
    reg [2:0] rr_ptr1 [0:PORTS-1];  // per OUT, for VC1
    wire out_empty_PE = ~rd_out_full(int_vc, P_PE);
    wire out_empty_N  = ~rd_out_full(int_vc, P_N);
    wire out_empty_E  = ~rd_out_full(int_vc, P_E);
    wire out_empty_S  = ~rd_out_full(int_vc, P_S);
    wire out_empty_W  = ~rd_out_full(int_vc, P_W);
    reg [PORTS-1:0] grant [0:PORTS-1]; // grant[out][in]
    reg [PORTS-1:0] conflict_vec;

    function integer count_ones;
        input [PORTS-1:0] v;
        integer t, c;
        begin
            c = 0;
            for (t = 0; t < PORTS; t = t + 1) if (v[t]) c = c + 1;
            count_ones = c;
        end
    endfunction
    
    function integer pick_rr;
        input [PORTS-1:0] mask;
        input [2:0]       ptr;
        integer k, idx;
        reg found;
        begin
            pick_rr = -1;
            found   = 1'b0;
            for (k = 0; k < PORTS; k = k + 1) begin
                idx = (ptr + k) % PORTS;
                if (!found && mask[idx]) begin
                    pick_rr = idx;
                    found   = 1'b1;
                end
            end
        end
    endfunction

    function [2:0] rr_ptr_rd;
        input vc; 
        input [2:0] outp;
        begin 
            rr_ptr_rd = (vc==1'b0) ? rr_ptr0[outp] : rr_ptr1[outp]; 
        end
    endfunction

    integer out, in_sel, cnt;
    always @* begin
        // clear
        for (out = 0; out < PORTS; out = out + 1) begin
            grant[out] = {PORTS{1'b0}};
        end
        conflict_vec = {PORTS{1'b0}};
        // PE
        if (out_empty_PE) begin
            cnt   = count_ones(req_mask[P_PE]);
            in_sel = -1;
            if (cnt > 1) begin
                conflict_vec[P_PE] = 1'b1;
                in_sel = pick_rr(req_mask[P_PE], rr_ptr_rd(int_vc, P_PE));
            end 
            else if (cnt == 1) begin
                in_sel = pick_rr(req_mask[P_PE], rr_ptr_rd(int_vc, P_PE));
            end
            if (in_sel != -1) grant[P_PE][in_sel] = 1'b1;
        end
        // N
        if (out_empty_N) begin
            cnt   = count_ones(req_mask[P_N]);
            in_sel = -1;
            if (cnt > 1) begin
                conflict_vec[P_N] = 1'b1;
                in_sel = pick_rr(req_mask[P_N], rr_ptr_rd(int_vc, P_N));
            end 
            else if (cnt == 1) begin
                in_sel = pick_rr(req_mask[P_N], rr_ptr_rd(int_vc, P_N));
            end
            if (in_sel != -1) grant[P_N][in_sel] = 1'b1;
        end
        // E
        if (out_empty_E) begin
            cnt   = count_ones(req_mask[P_E]);
            in_sel = -1;
            if (cnt > 1) begin
                conflict_vec[P_E] = 1'b1;
                in_sel = pick_rr(req_mask[P_E], rr_ptr_rd(int_vc, P_E));
            end 
            else if (cnt == 1) begin
                in_sel = pick_rr(req_mask[P_E], rr_ptr_rd(int_vc, P_E));
            end
            if (in_sel != -1) grant[P_E][in_sel] = 1'b1;
        end
        // S
        if (out_empty_S) begin
            cnt   = count_ones(req_mask[P_S]);
            in_sel = -1;
            if (cnt > 1) begin
                conflict_vec[P_S] = 1'b1;
                in_sel = pick_rr(req_mask[P_S], rr_ptr_rd(int_vc, P_S));
            end 
            else if (cnt == 1) begin
                in_sel = pick_rr(req_mask[P_S], rr_ptr_rd(int_vc, P_S));
            end
            if (in_sel != -1) grant[P_S][in_sel] = 1'b1;
        end
        // W
        if (out_empty_W) begin
            cnt   = count_ones(req_mask[P_W]);
            in_sel = -1;
            if (cnt > 1) begin
                conflict_vec[P_W] = 1'b1;
                in_sel = pick_rr(req_mask[P_W], rr_ptr_rd(int_vc, P_W));
            end 
            else if (cnt == 1) begin
                in_sel = pick_rr(req_mask[P_W], rr_ptr_rd(int_vc, P_W));
            end
            if (in_sel != -1) grant[P_W][in_sel] = 1'b1;
        end
    end
    // --------------- Router input channel receiving logic ---------------
    integer p, inx;
    always @(posedge clk) begin
        if (reset) begin
            for (p=0; p<PORTS; p=p+1) begin
                in_full0[p]  <= 1'b0;  in_full1[p]  <= 1'b0;
                out_full0[p] <= 1'b0;  out_full1[p] <= 1'b0;
                rr_ptr0[p]   <= 3'd0;  rr_ptr1[p]   <= 3'd0;
            end
        end 
        else begin
            if (pesi && peri) begin
                if (ext_vc==1'b0) begin 
                    in_buf0[P_PE] <= pedi; 
                    in_full0[P_PE] <= 1'b1;
                end
                else begin 
                    in_buf1[P_PE] <= pedi;
                    in_full1[P_PE] <= 1'b1;
                end
            end
            if (nsi && nri) begin
                if (ext_vc==1'b0) begin
                    in_buf0[P_N] <= ndi;
                    in_full0[P_N] <= 1'b1;
                end
                else begin 
                    in_buf1[P_N] <= ndi;
                    in_full1[P_N] <= 1'b1;
                end
            end
            if (esi && eri) begin
                if (ext_vc==1'b0) begin
                    in_buf0[P_E] <= edi;
                    in_full0[P_E] <= 1'b1;
                end
                else begin 
                    in_buf1[P_E] <= edi;
                    in_full1[P_E] <= 1'b1;
                end
            end
            if (ssi && sri) begin
                if (ext_vc==1'b0) begin
                    in_buf0[P_S] <= sdi;
                    in_full0[P_S] <= 1'b1;
                end
                else begin 
                    in_buf1[P_S] <= sdi;
                    in_full1[P_S] <= 1'b1;
                end
            end
            if (wsi && wri) begin
                if (ext_vc==1'b0) begin
                    in_buf0[P_W] <= wdi;
                    in_full0[P_W] <= 1'b1;
                end
                else begin 
                    in_buf1[P_W] <= wdi;
                    in_full1[P_W] <= 1'b1;
                end
            end
            // ---------------- clear sent ----------------
            if (peso && pero) begin 
                if (ext_vc==1'b0) 
                    out_full0[P_PE] <= 1'b0; 
                else out_full1[P_PE] <= 1'b0;
            end
            if (nso && nro) begin 
                if (ext_vc==1'b0) 
                    out_full0[P_N] <= 1'b0; 
                else out_full1[P_N] <= 1'b0;
            end
            if (eso && ero) begin 
                if (ext_vc==1'b0) 
                    out_full0[P_E] <= 1'b0; 
                else out_full1[P_E] <= 1'b0;
            end
            if (sso && sro) begin 
                if (ext_vc==1'b0) 
                    out_full0[P_S] <= 1'b0; 
                else out_full1[P_S] <= 1'b0;
            end
            if (wso && wro) begin 
                if (ext_vc==1'b0) 
                    out_full0[P_W] <= 1'b0; 
                else out_full1[P_W] <= 1'b0;
            end
            // ---------------- On grants: move data IN[int_vc] -> OUT[int_vc], update hop----------------
            // PE
            for (inx = 0; inx < PORTS; inx = inx+1) begin
                if (grant[P_PE][inx]) begin
                    if (int_vc==1'b0) begin
                        out_buf0[P_PE]  <= rd_in_buf(int_vc, inx);
                        out_full0[P_PE] <= 1'b1;
                        in_full0[inx]   <= 1'b0;
                        if (conflict_vec[P_PE]) rr_ptr0[P_PE] <= (inx + 1) % PORTS;
                    end 
                    else begin
                        out_buf1[P_PE]  <= rd_in_buf(int_vc, inx);
                        out_full1[P_PE] <= 1'b1;
                        in_full1[inx]   <= 1'b0;
                        if (conflict_vec[P_PE]) rr_ptr1[P_PE] <= (inx + 1) % PORTS;
                    end
                end
            end
            // N
            for (inx = 0; inx < PORTS; inx = inx + 1) begin
                if (grant[P_N][inx]) begin
                    if (int_vc==1'b0) begin
                        out_buf0[P_N]  <= dec_xy(rd_in_buf(int_vc, inx));
                        out_full0[P_N] <= 1'b1;
                        in_full0[inx]  <= 1'b0;
                        if (conflict_vec[P_N]) rr_ptr0[P_N] <= (inx + 1) % PORTS;
                    end else begin
                        out_buf1[P_N]  <= dec_xy(rd_in_buf(int_vc, inx));
                        out_full1[P_N] <= 1'b1;
                        in_full1[inx]  <= 1'b0;
                        if (conflict_vec[P_N]) rr_ptr1[P_N] <= (inx + 1) % PORTS;
                    end
                end
            end
            // E
            for (inx = 0; inx < PORTS; inx = inx + 1) begin
                if (grant[P_E][inx]) begin
                    if (int_vc==1'b0) begin
                        out_buf0[P_E]  <= dec_xy(rd_in_buf(int_vc, inx));
                        out_full0[P_E] <= 1'b1;
                        in_full0[inx]  <= 1'b0;
                        if (conflict_vec[P_E]) rr_ptr0[P_E] <= (inx + 1) % PORTS;
                    end else begin
                        out_buf1[P_E]  <= dec_xy(rd_in_buf(int_vc, inx));
                        out_full1[P_E] <= 1'b1;
                        in_full1[inx]  <= 1'b0;
                        if (conflict_vec[P_E]) rr_ptr1[P_E] <= (inx + 1) % PORTS;
                    end
                end
            end
            // S
            for (inx = 0; inx < PORTS; inx = inx + 1) begin
                if (grant[P_S][inx]) begin
                    if (int_vc==1'b0) begin
                        out_buf0[P_S]  <= dec_xy(rd_in_buf(int_vc, inx));
                        out_full0[P_S] <= 1'b1;
                        in_full0[inx]  <= 1'b0;
                        if (conflict_vec[P_S]) rr_ptr0[P_S] <= (inx + 1) % PORTS;
                    end else begin
                        out_buf1[P_S]  <= dec_xy(rd_in_buf(int_vc, inx));
                        out_full1[P_S] <= 1'b1;
                        in_full1[inx]  <= 1'b0;
                        if (conflict_vec[P_S]) rr_ptr1[P_S] <= (inx + 1) % PORTS;
                    end
                end
            end
            // W
            for (inx = 0; inx < PORTS; inx = inx + 1) begin
                if (grant[P_W][inx]) begin
                    if (int_vc==1'b0) begin
                        out_buf0[P_W]  <= dec_xy(rd_in_buf(int_vc, inx));
                        out_full0[P_W] <= 1'b1;
                        in_full0[inx]  <= 1'b0;
                        if (conflict_vec[P_W]) rr_ptr0[P_W] <= (inx + 1) % PORTS;
                    end else begin
                        out_buf1[P_W]  <= dec_xy(rd_in_buf(int_vc, inx));
                        out_full1[P_W] <= 1'b1;
                        in_full1[inx]  <= 1'b0;
                        if (conflict_vec[P_W]) rr_ptr1[P_W] <= (inx + 1) % PORTS;
                    end
                end
            end
        end
    end
    // ---------------- Toggle polarity every cycle ----------------
    always @(posedge clk) begin
        if (reset) polarity <= 1'b0;  // reset 时 even
        else       polarity <= ~polarity;
    end
endmodule
