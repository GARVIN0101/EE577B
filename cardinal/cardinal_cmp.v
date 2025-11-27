`timescale 1ns/1ps
module cardinal_cmp (
    input  wire clk,
    input  wire reset,

    // ===================== Node 00 memories =====================
    output wire [0:7]  node00_imem_addr,
    input  wire [0:31] node00_imem_data,
    output wire        node00_dmem_en,
    output wire        node00_dmem_we,
    output wire [0:7]  node00_dmem_addr,
    output wire [0:63] node00_dmem_dout,
    input  wire [0:63] node00_dmem_din,

    // ===================== Node 01 memories =====================
    output wire [0:7]  node01_imem_addr,
    input  wire [0:31] node01_imem_data,
    output wire        node01_dmem_en,
    output wire        node01_dmem_we,
    output wire [0:7]  node01_dmem_addr,
    output wire [0:63] node01_dmem_dout,
    input  wire [0:63] node01_dmem_din,

    // ===================== Node 02 memories =====================
    output wire [0:7]  node02_imem_addr,
    input  wire [0:31] node02_imem_data,
    output wire        node02_dmem_en,
    output wire        node02_dmem_we,
    output wire [0:7]  node02_dmem_addr,
    output wire [0:63] node02_dmem_dout,
    input  wire [0:63] node02_dmem_din,

    // ===================== Node 03 memories =====================
    output wire [0:7]  node03_imem_addr,
    input  wire [0:31] node03_imem_data,
    output wire        node03_dmem_en,
    output wire        node03_dmem_we,
    output wire [0:7]  node03_dmem_addr,
    output wire [0:63] node03_dmem_dout,
    input  wire [0:63] node03_dmem_din,

    // ===================== Node 10 memories =====================
    output wire [0:7]  node10_imem_addr,
    input  wire [0:31] node10_imem_data,
    output wire        node10_dmem_en,
    output wire        node10_dmem_we,
    output wire [0:7]  node10_dmem_addr,
    output wire [0:63] node10_dmem_dout,
    input  wire [0:63] node10_dmem_din,

    // ===================== Node 11 memories =====================
    output wire [0:7]  node11_imem_addr,
    input  wire [0:31] node11_imem_data,
    output wire        node11_dmem_en,
    output wire        node11_dmem_we,
    output wire [0:7]  node11_dmem_addr,
    output wire [0:63] node11_dmem_dout,
    input  wire [0:63] node11_dmem_din,

    // ===================== Node 12 memories =====================
    output wire [0:7]  node12_imem_addr,
    input  wire [0:31] node12_imem_data,
    output wire        node12_dmem_en,
    output wire        node12_dmem_we,
    output wire [0:7]  node12_dmem_addr,
    output wire [0:63] node12_dmem_dout,
    input  wire [0:63] node12_dmem_din,

    // ===================== Node 13 memories =====================
    output wire [0:7]  node13_imem_addr,
    input  wire [0:31] node13_imem_data,
    output wire        node13_dmem_en,
    output wire        node13_dmem_we,
    output wire [0:7]  node13_dmem_addr,
    output wire [0:63] node13_dmem_dout,
    input  wire [0:63] node13_dmem_din,

    // ===================== Node 20 memories =====================
    output wire [0:7]  node20_imem_addr,
    input  wire [0:31] node20_imem_data,
    output wire        node20_dmem_en,
    output wire        node20_dmem_we,
    output wire [0:7]  node20_dmem_addr,
    output wire [0:63] node20_dmem_dout,
    input  wire [0:63] node20_dmem_din,

    // ===================== Node 21 memories =====================
    output wire [0:7]  node21_imem_addr,
    input  wire [0:31] node21_imem_data,
    output wire        node21_dmem_en,
    output wire        node21_dmem_we,
    output wire [0:7]  node21_dmem_addr,
    output wire [0:63] node21_dmem_dout,
    input  wire [0:63] node21_dmem_din,

    // ===================== Node 22 memories =====================
    output wire [0:7]  node22_imem_addr,
    input  wire [0:31] node22_imem_data,
    output wire        node22_dmem_en,
    output wire        node22_dmem_we,
    output wire [0:7]  node22_dmem_addr,
    output wire [0:63] node22_dmem_dout,
    input  wire [0:63] node22_dmem_din,

    // ===================== Node 23 memories =====================
    output wire [0:7]  node23_imem_addr,
    input  wire [0:31] node23_imem_data,
    output wire        node23_dmem_en,
    output wire        node23_dmem_we,
    output wire [0:7]  node23_dmem_addr,
    output wire [0:63] node23_dmem_dout,
    input  wire [0:63] node23_dmem_din,

    // ===================== Node 30 memories =====================
    output wire [0:7]  node30_imem_addr,
    input  wire [0:31] node30_imem_data,
    output wire        node30_dmem_en,
    output wire        node30_dmem_we,
    output wire [0:7]  node30_dmem_addr,
    output wire [0:63] node30_dmem_dout,
    input  wire [0:63] node30_dmem_din,

    // ===================== Node 31 memories =====================
    output wire [0:7]  node31_imem_addr,
    input  wire [0:31] node31_imem_data,
    output wire        node31_dmem_en,
    output wire        node31_dmem_we,
    output wire [0:7]  node31_dmem_addr,
    output wire [0:63] node31_dmem_dout,
    input  wire [0:63] node31_dmem_din,

    // ===================== Node 32 memories =====================
    output wire [0:7]  node32_imem_addr,
    input  wire [0:31] node32_imem_data,
    output wire        node32_dmem_en,
    output wire        node32_dmem_we,
    output wire [0:7]  node32_dmem_addr,
    output wire [0:63] node32_dmem_dout,
    input  wire [0:63] node32_dmem_din,

    // ===================== Node 33 memories =====================
    output wire [0:7]  node33_imem_addr,
    input  wire [0:31] node33_imem_data,
    output wire        node33_dmem_en,
    output wire        node33_dmem_we,
    output wire [0:7]  node33_dmem_addr,
    output wire [0:63] node33_dmem_dout,
    input  wire [0:63] node33_dmem_din
);

    // ============================================================
    //  Mesh <-> NIC flattened PE ports
    // ============================================================
    wire [15:0]   pesi, peri, peso, pero;
    wire [1023:0] pedi, pedo;
    wire [15:0]   pol;   // router polarity per node

    // ============================================================
    //  Instantiate 4x4 mesh
    // ============================================================
    cardinal_mesh u_mesh (
        .clk     (clk),
        .reset   (reset),
        .pesi    (pesi),
        .peri    (peri),
        .pedi    (pedi),
        .peso    (peso),
        .pero    (pero),
        .pedo    (pedo),
        .polarity(pol)
    );

    // ============================================================
    //  Per-node CPU <-> NIC wires
    // ============================================================
    // Node00
    wire        n00_nic_en,   n00_nic_enwr;
    wire [0:1]  n00_nic_addr;
    wire [0:63] n00_nic_dout, n00_nic_din;
    // Node01
    wire        n01_nic_en,   n01_nic_enwr;
    wire [0:1]  n01_nic_addr;
    wire [0:63] n01_nic_dout, n01_nic_din;
    // Node02
    wire        n02_nic_en,   n02_nic_enwr;
    wire [0:1]  n02_nic_addr;
    wire [0:63] n02_nic_dout, n02_nic_din;
    // Node03
    wire        n03_nic_en,   n03_nic_enwr;
    wire [0:1]  n03_nic_addr;
    wire [0:63] n03_nic_dout, n03_nic_din;

    // Node10
    wire        n10_nic_en,   n10_nic_enwr;
    wire [0:1]  n10_nic_addr;
    wire [0:63] n10_nic_dout, n10_nic_din;
    // Node11
    wire        n11_nic_en,   n11_nic_enwr;
    wire [0:1]  n11_nic_addr;
    wire [0:63] n11_nic_dout, n11_nic_din;
    // Node12
    wire        n12_nic_en,   n12_nic_enwr;
    wire [0:1]  n12_nic_addr;
    wire [0:63] n12_nic_dout, n12_nic_din;
    // Node13
    wire        n13_nic_en,   n13_nic_enwr;
    wire [0:1]  n13_nic_addr;
    wire [0:63] n13_nic_dout, n13_nic_din;

    // Node20
    wire        n20_nic_en,   n20_nic_enwr;
    wire [0:1]  n20_nic_addr;
    wire [0:63] n20_nic_dout, n20_nic_din;
    // Node21
    wire        n21_nic_en,   n21_nic_enwr;
    wire [0:1]  n21_nic_addr;
    wire [0:63] n21_nic_dout, n21_nic_din;
    // Node22
    wire        n22_nic_en,   n22_nic_enwr;
    wire [0:1]  n22_nic_addr;
    wire [0:63] n22_nic_dout, n22_nic_din;
    // Node23
    wire        n23_nic_en,   n23_nic_enwr;
    wire [0:1]  n23_nic_addr;
    wire [0:63] n23_nic_dout, n23_nic_din;

    // Node30
    wire        n30_nic_en,   n30_nic_enwr;
    wire [0:1]  n30_nic_addr;
    wire [0:63] n30_nic_dout, n30_nic_din;
    // Node31
    wire        n31_nic_en,   n31_nic_enwr;
    wire [0:1]  n31_nic_addr;
    wire [0:63] n31_nic_dout, n31_nic_din;
    // Node32
    wire        n32_nic_en,   n32_nic_enwr;
    wire [0:1]  n32_nic_addr;
    wire [0:63] n32_nic_dout, n32_nic_din;
    // Node33
    wire        n33_nic_en,   n33_nic_enwr;
    wire [0:1]  n33_nic_addr;
    wire [0:63] n33_nic_dout, n33_nic_din;

    // ============================================================
    //  Node 00  (ID = 0, bits 63:0)
    // ============================================================
    cardinal_cpu u_cpu_00 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node00_imem_addr),
        .imem_data (node00_imem_data),
        .dmem_en   (node00_dmem_en),
        .dmem_we   (node00_dmem_we),
        .dmem_addr (node00_dmem_addr),
        .dmem_dout (node00_dmem_dout),
        .dmem_din  (node00_dmem_din),
        .nic_en    (n00_nic_en),
        .nic_enwr  (n00_nic_enwr),
        .nic_addr  (n00_nic_addr),
        .nic_dout  (n00_nic_dout),
        .nic_din   (n00_nic_din)
    );

    cardinal_nic u_nic_00 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n00_nic_en),
        .nicEnWr     (n00_nic_enwr),
        .addr        (n00_nic_addr),
        .d_in        (n00_nic_dout),
        .d_out       (n00_nic_din),
        .net_si      (peso[0]),
        .net_ri      (pero[0]),
        .net_di      (pedo[63:0]),
        .net_so      (pesi[0]),
        .net_ro      (peri[0]),
        .net_do      (pedi[63:0]),
        .net_polarity(pol[0])
    );

    // ============================================================
    //  Node 01  (ID = 1, bits 127:64)
    // ============================================================
    cardinal_cpu u_cpu_01 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node01_imem_addr),
        .imem_data (node01_imem_data),
        .dmem_en   (node01_dmem_en),
        .dmem_we   (node01_dmem_we),
        .dmem_addr (node01_dmem_addr),
        .dmem_dout (node01_dmem_dout),
        .dmem_din  (node01_dmem_din),
        .nic_en    (n01_nic_en),
        .nic_enwr  (n01_nic_enwr),
        .nic_addr  (n01_nic_addr),
        .nic_dout  (n01_nic_dout),
        .nic_din   (n01_nic_din)
    );

    cardinal_nic u_nic_01 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n01_nic_en),
        .nicEnWr     (n01_nic_enwr),
        .addr        (n01_nic_addr),
        .d_in        (n01_nic_dout),
        .d_out       (n01_nic_din),
        .net_si      (peso[1]),
        .net_ri      (pero[1]),
        .net_di      (pedo[127:64]),
        .net_so      (pesi[1]),
        .net_ro      (peri[1]),
        .net_do      (pedi[127:64]),
        .net_polarity(pol[1])
    );

    // ============================================================
    //  Node 02  (ID = 2, bits 191:128)
    // ============================================================
    cardinal_cpu u_cpu_02 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node02_imem_addr),
        .imem_data (node02_imem_data),
        .dmem_en   (node02_dmem_en),
        .dmem_we   (node02_dmem_we),
        .dmem_addr (node02_dmem_addr),
        .dmem_dout (node02_dmem_dout),
        .dmem_din  (node02_dmem_din),
        .nic_en    (n02_nic_en),
        .nic_enwr  (n02_nic_enwr),
        .nic_addr  (n02_nic_addr),
        .nic_dout  (n02_nic_dout),
        .nic_din   (n02_nic_din)
    );

    cardinal_nic u_nic_02 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n02_nic_en),
        .nicEnWr     (n02_nic_enwr),
        .addr        (n02_nic_addr),
        .d_in        (n02_nic_dout),
        .d_out       (n02_nic_din),
        .net_si      (peso[2]),
        .net_ri      (pero[2]),
        .net_di      (pedo[191:128]),
        .net_so      (pesi[2]),
        .net_ro      (peri[2]),
        .net_do      (pedi[191:128]),
        .net_polarity(pol[2])
    );

    // ============================================================
    //  Node 03  (ID = 3, bits 255:192)
    // ============================================================
    cardinal_cpu u_cpu_03 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node03_imem_addr),
        .imem_data (node03_imem_data),
        .dmem_en   (node03_dmem_en),
        .dmem_we   (node03_dmem_we),
        .dmem_addr (node03_dmem_addr),
        .dmem_dout (node03_dmem_dout),
        .dmem_din  (node03_dmem_din),
        .nic_en    (n03_nic_en),
        .nic_enwr  (n03_nic_enwr),
        .nic_addr  (n03_nic_addr),
        .nic_dout  (n03_nic_dout),
        .nic_din   (n03_nic_din)
    );

    cardinal_nic u_nic_03 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n03_nic_en),
        .nicEnWr     (n03_nic_enwr),
        .addr        (n03_nic_addr),
        .d_in        (n03_nic_dout),
        .d_out       (n03_nic_din),
        .net_si      (peso[3]),
        .net_ri      (pero[3]),
        .net_di      (pedo[255:192]),
        .net_so      (pesi[3]),
        .net_ro      (peri[3]),
        .net_do      (pedi[255:192]),
        .net_polarity(pol[3])
    );

    // ============================================================
    //  Node 10  (ID = 4, bits 319:256)
    // ============================================================
    cardinal_cpu u_cpu_10 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node10_imem_addr),
        .imem_data (node10_imem_data),
        .dmem_en   (node10_dmem_en),
        .dmem_we   (node10_dmem_we),
        .dmem_addr (node10_dmem_addr),
        .dmem_dout (node10_dmem_dout),
        .dmem_din  (node10_dmem_din),
        .nic_en    (n10_nic_en),
        .nic_enwr  (n10_nic_enwr),
        .nic_addr  (n10_nic_addr),
        .nic_dout  (n10_nic_dout),
        .nic_din   (n10_nic_din)
    );

    cardinal_nic u_nic_10 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n10_nic_en),
        .nicEnWr     (n10_nic_enwr),
        .addr        (n10_nic_addr),
        .d_in        (n10_nic_dout),
        .d_out       (n10_nic_din),
        .net_si      (peso[4]),
        .net_ri      (pero[4]),
        .net_di      (pedo[319:256]),
        .net_so      (pesi[4]),
        .net_ro      (peri[4]),
        .net_do      (pedi[319:256]),
        .net_polarity(pol[4])
    );

    // ============================================================
    //  Node 11  (ID = 5, bits 383:320)
    // ============================================================
    cardinal_cpu u_cpu_11 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node11_imem_addr),
        .imem_data (node11_imem_data),
        .dmem_en   (node11_dmem_en),
        .dmem_we   (node11_dmem_we),
        .dmem_addr (node11_dmem_addr),
        .dmem_dout (node11_dmem_dout),
        .dmem_din  (node11_dmem_din),
        .nic_en    (n11_nic_en),
        .nic_enwr  (n11_nic_enwr),
        .nic_addr  (n11_nic_addr),
        .nic_dout  (n11_nic_dout),
        .nic_din   (n11_nic_din)
    );

    cardinal_nic u_nic_11 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n11_nic_en),
        .nicEnWr     (n11_nic_enwr),
        .addr        (n11_nic_addr),
        .d_in        (n11_nic_dout),
        .d_out       (n11_nic_din),
        .net_si      (peso[5]),
        .net_ri      (pero[5]),
        .net_di      (pedo[383:320]),
        .net_so      (pesi[5]),
        .net_ro      (peri[5]),
        .net_do      (pedi[383:320]),
        .net_polarity(pol[5])
    );

    // ============================================================
    //  Node 12  (ID = 6, bits 447:384)
    // ============================================================
    cardinal_cpu u_cpu_12 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node12_imem_addr),
        .imem_data (node12_imem_data),
        .dmem_en   (node12_dmem_en),
        .dmem_we   (node12_dmem_we),
        .dmem_addr (node12_dmem_addr),
        .dmem_dout (node12_dmem_dout),
        .dmem_din  (node12_dmem_din),
        .nic_en    (n12_nic_en),
        .nic_enwr  (n12_nic_enwr),
        .nic_addr  (n12_nic_addr),
        .nic_dout  (n12_nic_dout),
        .nic_din   (n12_nic_din)
    );

    cardinal_nic u_nic_12 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n12_nic_en),
        .nicEnWr     (n12_nic_enwr),
        .addr        (n12_nic_addr),
        .d_in        (n12_nic_dout),
        .d_out       (n12_nic_din),
        .net_si      (peso[6]),
        .net_ri      (pero[6]),
        .net_di      (pedo[447:384]),
        .net_so      (pesi[6]),
        .net_ro      (peri[6]),
        .net_do      (pedi[447:384]),
        .net_polarity(pol[6])
    );

    // ============================================================
    //  Node 13  (ID = 7, bits 511:448)
    // ============================================================
    cardinal_cpu u_cpu_13 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node13_imem_addr),
        .imem_data (node13_imem_data),
        .dmem_en   (node13_dmem_en),
        .dmem_we   (node13_dmem_we),
        .dmem_addr (node13_dmem_addr),
        .dmem_dout (node13_dmem_dout),
        .dmem_din  (node13_dmem_din),
        .nic_en    (n13_nic_en),
        .nic_enwr  (n13_nic_enwr),
        .nic_addr  (n13_nic_addr),
        .nic_dout  (n13_nic_dout),
        .nic_din   (n13_nic_din)
    );

    cardinal_nic u_nic_13 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n13_nic_en),
        .nicEnWr     (n13_nic_enwr),
        .addr        (n13_nic_addr),
        .d_in        (n13_nic_dout),
        .d_out       (n13_nic_din),
        .net_si      (peso[7]),
        .net_ri      (pero[7]),
        .net_di      (pedo[511:448]),
        .net_so      (pesi[7]),
        .net_ro      (peri[7]),
        .net_do      (pedi[511:448]),
        .net_polarity(pol[7])
    );

    // ============================================================
    //  Node 20  (ID = 8, bits 575:512)
    // ============================================================
    cardinal_cpu u_cpu_20 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node20_imem_addr),
        .imem_data (node20_imem_data),
        .dmem_en   (node20_dmem_en),
        .dmem_we   (node20_dmem_we),
        .dmem_addr (node20_dmem_addr),
        .dmem_dout (node20_dmem_dout),
        .dmem_din  (node20_dmem_din),
        .nic_en    (n20_nic_en),
        .nic_enwr  (n20_nic_enwr),
        .nic_addr  (n20_nic_addr),
        .nic_dout  (n20_nic_dout),
        .nic_din   (n20_nic_din)
    );

    cardinal_nic u_nic_20 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n20_nic_en),
        .nicEnWr     (n20_nic_enwr),
        .addr        (n20_nic_addr),
        .d_in        (n20_nic_dout),
        .d_out       (n20_nic_din),
        .net_si      (peso[8]),
        .net_ri      (pero[8]),
        .net_di      (pedo[575:512]),
        .net_so      (pesi[8]),
        .net_ro      (peri[8]),
        .net_do      (pedi[575:512]),
        .net_polarity(pol[8])
    );

    // ============================================================
    //  Node 21  (ID = 9, bits 639:576)
    // ============================================================
    cardinal_cpu u_cpu_21 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node21_imem_addr),
        .imem_data (node21_imem_data),
        .dmem_en   (node21_dmem_en),
        .dmem_we   (node21_dmem_we),
        .dmem_addr (node21_dmem_addr),
        .dmem_dout (node21_dmem_dout),
        .dmem_din  (node21_dmem_din),
        .nic_en    (n21_nic_en),
        .nic_enwr  (n21_nic_enwr),
        .nic_addr  (n21_nic_addr),
        .nic_dout  (n21_nic_dout),
        .nic_din   (n21_nic_din)
    );

    cardinal_nic u_nic_21 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n21_nic_en),
        .nicEnWr     (n21_nic_enwr),
        .addr        (n21_nic_addr),
        .d_in        (n21_nic_dout),
        .d_out       (n21_nic_din),
        .net_si      (peso[9]),
        .net_ri      (pero[9]),
        .net_di      (pedo[639:576]),
        .net_so      (pesi[9]),
        .net_ro      (peri[9]),
        .net_do      (pedi[639:576]),
        .net_polarity(pol[9])
    );

    // ============================================================
    //  Node 22  (ID = 10, bits 703:640)
    // ============================================================
    cardinal_cpu u_cpu_22 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node22_imem_addr),
        .imem_data (node22_imem_data),
        .dmem_en   (node22_dmem_en),
        .dmem_we   (node22_dmem_we),
        .dmem_addr (node22_dmem_addr),
        .dmem_dout (node22_dmem_dout),
        .dmem_din  (node22_dmem_din),
        .nic_en    (n22_nic_en),
        .nic_enwr  (n22_nic_enwr),
        .nic_addr  (n22_nic_addr),
        .nic_dout  (n22_nic_dout),
        .nic_din   (n22_nic_din)
    );

    cardinal_nic u_nic_22 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n22_nic_en),
        .nicEnWr     (n22_nic_enwr),
        .addr        (n22_nic_addr),
        .d_in        (n22_nic_dout),
        .d_out       (n22_nic_din),
        .net_si      (peso[10]),
        .net_ri      (pero[10]),
        .net_di      (pedo[703:640]),
        .net_so      (pesi[10]),
        .net_ro      (peri[10]),
        .net_do      (pedi[703:640]),
        .net_polarity(pol[10])
    );

    // ============================================================
    //  Node 23  (ID = 11, bits 767:704)
    // ============================================================
    cardinal_cpu u_cpu_23 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node23_imem_addr),
        .imem_data (node23_imem_data),
        .dmem_en   (node23_dmem_en),
        .dmem_we   (node23_dmem_we),
        .dmem_addr (node23_dmem_addr),
        .dmem_dout (node23_dmem_dout),
        .dmem_din  (node23_dmem_din),
        .nic_en    (n23_nic_en),
        .nic_enwr  (n23_nic_enwr),
        .nic_addr  (n23_nic_addr),
        .nic_dout  (n23_nic_dout),
        .nic_din   (n23_nic_din)
    );

    cardinal_nic u_nic_23 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n23_nic_en),
        .nicEnWr     (n23_nic_enwr),
        .addr        (n23_nic_addr),
        .d_in        (n23_nic_dout),
        .d_out       (n23_nic_din),
        .net_si      (peso[11]),
        .net_ri      (pero[11]),
        .net_di      (pedo[767:704]),
        .net_so      (pesi[11]),
        .net_ro      (peri[11]),
        .net_do      (pedi[767:704]),
        .net_polarity(pol[11])
    );

    // ============================================================
    //  Node 30  (ID = 12, bits 831:768)
    // ============================================================
    cardinal_cpu u_cpu_30 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node30_imem_addr),
        .imem_data (node30_imem_data),
        .dmem_en   (node30_dmem_en),
        .dmem_we   (node30_dmem_we),
        .dmem_addr (node30_dmem_addr),
        .dmem_dout (node30_dmem_dout),
        .dmem_din  (node30_dmem_din),
        .nic_en    (n30_nic_en),
        .nic_enwr  (n30_nic_enwr),
        .nic_addr  (n30_nic_addr),
        .nic_dout  (n30_nic_dout),
        .nic_din   (n30_nic_din)
    );

    cardinal_nic u_nic_30 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n30_nic_en),
        .nicEnWr     (n30_nic_enwr),
        .addr        (n30_nic_addr),
        .d_in        (n30_nic_dout),
        .d_out       (n30_nic_din),
        .net_si      (peso[12]),
        .net_ri      (pero[12]),
        .net_di      (pedo[831:768]),
        .net_so      (pesi[12]),
        .net_ro      (peri[12]),
        .net_do      (pedi[831:768]),
        .net_polarity(pol[12])
    );

    // ============================================================
    //  Node 31  (ID = 13, bits 895:832)
    // ============================================================
    cardinal_cpu u_cpu_31 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node31_imem_addr),
        .imem_data (node31_imem_data),
        .dmem_en   (node31_dmem_en),
        .dmem_we   (node31_dmem_we),
        .dmem_addr (node31_dmem_addr),
        .dmem_dout (node31_dmem_dout),
        .dmem_din  (node31_dmem_din),
        .nic_en    (n31_nic_en),
        .nic_enwr  (n31_nic_enwr),
        .nic_addr  (n31_nic_addr),
        .nic_dout  (n31_nic_dout),
        .nic_din   (n31_nic_din)
    );

    cardinal_nic u_nic_31 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n31_nic_en),
        .nicEnWr     (n31_nic_enwr),
        .addr        (n31_nic_addr),
        .d_in        (n31_nic_dout),
        .d_out       (n31_nic_din),
        .net_si      (peso[13]),
        .net_ri      (pero[13]),
        .net_di      (pedo[895:832]),
        .net_so      (pesi[13]),
        .net_ro      (peri[13]),
        .net_do      (pedi[895:832]),
        .net_polarity(pol[13])
    );

    // ============================================================
    //  Node 32  (ID = 14, bits 959:896)
    // ============================================================
    cardinal_cpu u_cpu_32 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node32_imem_addr),
        .imem_data (node32_imem_data),
        .dmem_en   (node32_dmem_en),
        .dmem_we   (node32_dmem_we),
        .dmem_addr (node32_dmem_addr),
        .dmem_dout (node32_dmem_dout),
        .dmem_din  (node32_dmem_din),
        .nic_en    (n32_nic_en),
        .nic_enwr  (n32_nic_enwr),
        .nic_addr  (n32_nic_addr),
        .nic_dout  (n32_nic_dout),
        .nic_din   (n32_nic_din)
    );

    cardinal_nic u_nic_32 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n32_nic_en),
        .nicEnWr     (n32_nic_enwr),
        .addr        (n32_nic_addr),
        .d_in        (n32_nic_dout),
        .d_out       (n32_nic_din),
        .net_si      (peso[14]),
        .net_ri      (pero[14]),
        .net_di      (pedo[959:896]),
        .net_so      (pesi[14]),
        .net_ro      (peri[14]),
        .net_do      (pedi[959:896]),
        .net_polarity(pol[14])
    );

    // ============================================================
    //  Node 33  (ID = 15, bits 1023:960)
    // ============================================================
    cardinal_cpu u_cpu_33 (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (node33_imem_addr),
        .imem_data (node33_imem_data),
        .dmem_en   (node33_dmem_en),
        .dmem_we   (node33_dmem_we),
        .dmem_addr (node33_dmem_addr),
        .dmem_dout (node33_dmem_dout),
        .dmem_din  (node33_dmem_din),
        .nic_en    (n33_nic_en),
        .nic_enwr  (n33_nic_enwr),
        .nic_addr  (n33_nic_addr),
        .nic_dout  (n33_nic_dout),
        .nic_din   (n33_nic_din)
    );

    cardinal_nic u_nic_33 (
        .clk         (clk),
        .reset       (reset),
        .nicEn       (n33_nic_en),
        .nicEnWr     (n33_nic_enwr),
        .addr        (n33_nic_addr),
        .d_in        (n33_nic_dout),
        .d_out       (n33_nic_din),
        .net_si      (peso[15]),
        .net_ri      (pero[15]),
        .net_di      (pedo[1023:960]),
        .net_so      (pesi[15]),
        .net_ro      (peri[15]),
        .net_do      (pedi[1023:960]),
        .net_polarity(pol[15])
    );

endmodule
