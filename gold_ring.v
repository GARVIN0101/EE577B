`timescale 1ns/1ps
module gold_ring(
    input  wire clk,
    input  wire reset,
    // PE ports flattened into 16 entries
    input  wire [15:0]    pesi,     // PE input valid
    output wire [15:0]    peri,     // PE input ready
    input  wire [1023:0]  pedi,     // PE input data (16×64-bit)
    output wire [15:0]    peso,     // PE output valid
    input  wire [15:0]    pero,     // PE output ready
    output wire [1023:0]  pedo,     // PE output data (16×64-bit)
    output wire [15:0]    polarity  // router polarity bits
);
    // Fixed parameters (declared as integer for DC compatibility)
    parameter integer NX  = 4;
    parameter integer NY  = 4;
    parameter integer TOT = NX*NY; // total 16 routers

    // ------------ East port signals ------------
    wire [TOT-1:0]     eso;    // east send-out valid
    wire [TOT*64-1:0]  edo;    // east data-out
    wire [TOT-1:0]     eri;    // east ready-in
    wire [TOT-1:0]     esi;    // east send-in valid
    wire [TOT*64-1:0]  edi;    // east data-in
    wire [TOT-1:0]     ero;    // east ready-out
    // ------------ West port signals ------------
    wire [TOT-1:0]     wso;
    wire [TOT*64-1:0]  wdo;
    wire [TOT-1:0]     wri;
    wire [TOT-1:0]     wsi;
    wire [TOT*64-1:0]  wdi;
    wire [TOT-1:0]     wro;
    // ------------ North port signals ------------
    wire [TOT-1:0]     nso;
    wire [TOT*64-1:0]  ndo;
    wire [TOT-1:0]     nri;
    wire [TOT-1:0]     nsi;
    wire [TOT*64-1:0]  ndi;
    wire [TOT-1:0]     nro;
    // ------------ South port signals ------------
    wire [TOT-1:0]     sso;
    wire [TOT*64-1:0]  sdo;
    wire [TOT-1:0]     sri;
    wire [TOT-1:0]     ssi;
    wire [TOT*64-1:0]  sdi;
    wire [TOT-1:0]     sro;

    // ------------ Router array generation ------------
    genvar gy, gx;
    generate
        for (gy = 0; gy < NY; gy = gy + 1) begin: row
            for (gx = 0; gx < NX; gx = gx + 1) begin: col
                // Inline constant expressions to avoid localparam evaluation issues
                wire pol;

                // Flattened index and offset macros (pure text substitution, DC-safe)
                `define ID   ((gy*NX)+gx)
                `define LO   (((gy*NX)+gx)*64)
                `define RID  ((gy*NX)+(gx+1))
                `define RLO  (((gy*NX)+(gx+1))*64)
                `define BID  (((gy+1)*NX)+gx)
                `define BLO  ((((gy+1)*NX)+gx)*64)

                // Instantiate one router
                gold_router u_router(
                    .clk (clk),
                    .reset (reset),
                    .polarity (pol),
                    // PE interface
                    .pesi (pesi[`ID]),
                    .peri (peri[`ID]),
                    .pedi (pedi[`LO+63:`LO]),
                    .peso (peso[`ID]),
                    .pero (pero[`ID]),
                    .pedo (pedo[`LO+63:`LO]),
                    // North
                    .nsi (nsi[`ID]),
                    .nri (nri[`ID]),
                    .ndi (ndi[`LO+63:`LO]),
                    .nso (nso[`ID]),
                    .nro (nro[`ID]),
                    .ndo (ndo[`LO+63:`LO]),
                    // East
                    .esi (esi[`ID]),
                    .eri (eri[`ID]),
                    .edi (edi[`LO+63:`LO]),
                    .eso (eso[`ID]),
                    .ero (ero[`ID]),
                    .edo (edo[`LO+63:`LO]),
                    // South
                    .ssi (ssi[`ID]),
                    .sri (sri[`ID]),
                    .sdi (sdi[`LO+63:`LO]),
                    .sso (sso[`ID]),
                    .sro (sro[`ID]),
                    .sdo (sdo[`LO+63:`LO]),
                    // West
                    .wsi (wsi[`ID]),
                    .wri (wri[`ID]),
                    .wdi (wdi[`LO+63:`LO]),
                    .wso (wso[`ID]),
                    .wro (wro[`ID]),
                    .wdo (wdo[`LO+63:`LO])
                );

                // Export router polarity
                assign polarity[`ID] = pol;

                // --------- West–East inter-router connections ----------
                if (gx < NX-1) begin: we_conn
                    // East → right neighbor’s West
                    assign wsi[`RID] = eso[`ID];
                    assign wdi[`RLO+63:`RLO] = edo[`LO+63:`LO];
                    assign ero[`ID] = wri[`RID];
                    // Right neighbor’s West → East
                    assign esi[`ID] = wso[`RID];
                    assign edi[`LO+63:`LO] = wdo[`RLO+63:`RLO];
                    assign wro[`RID] = eri[`ID];
                end

                // --------- North–South inter-router connections ----------
                if (gy < NY-1) begin: ns_conn
                    // South → bottom neighbor’s North
                    assign nsi[`BID] = sso[`ID];
                    assign ndi[`BLO+63:`BLO] = sdo[`LO+63:`LO];
                    assign sro[`ID] = nri[`BID];
                    // Bottom neighbor’s North → South
                    assign ssi[`ID] = nso[`BID];
                    assign sdi[`LO+63:`LO] = ndo[`BLO+63:`BLO];
                    assign nro[`BID] = sri[`ID];
                end

                // --------- Boundary conditions ----------
                if (gx == 0) begin: left_bd
                    assign wsi[`ID] = 1'b0;
                    assign wdi[`LO+63:`LO] = 64'b0;
                    assign wro[`ID] = 1'b0;
                end
                if (gx == NX-1) begin: right_bd
                    assign esi[`ID] = 1'b0;
                    assign edi[`LO+63:`LO] = 64'b0;
                    assign ero[`ID] = 1'b0;
                end
                if (gy == 0) begin: top_bd
                    assign nsi[`ID] = 1'b0;
                    assign ndi[`LO+63:`LO] = 64'b0;
                    assign nro[`ID] = 1'b0;
                end
                if (gy == NY-1) begin: bottom_bd
                    assign ssi[`ID] = 1'b0;
                    assign sdi[`LO+63:`LO] = 64'b0;
                    assign sro[`ID] = 1'b0;
                end

                // Remove macros to avoid global pollution
                `undef BLO
                `undef BID
                `undef RLO
                `undef RID
                `undef LO
                `undef ID
            end
        end
    endgenerate
endmodule
