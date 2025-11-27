`timescale 1ns / 1ps
module decoder_cardinal (
    input  wire [0:31] instr,
    output wire [0:5]  op,
    output wire [0:4]  rD,
    output wire [0:4]  rA,
    output wire [0:4]  rB,
    output wire [0:1]  ww,
    output wire [0:5]  func,
    output wire [0:15] imm16,

    output wire is_rtype,
    output wire is_ld,
    output wire is_sd,
    output wire is_bez,
    output wire is_bnez,
    output wire is_nop,

    // datapath convenience signals
    output wire writes_rD,
    output wire [0:4] rS1,
    output wire [0:4] rS2,
    output wire uses_S1,
    output wire uses_S2
);

    // ===== Opcodes / function codes =====
    localparam [0:5] OP_RTYPE = 6'b101010;
    localparam [0:5] OP_LD    = 6'b100000;
    localparam [0:5] OP_SD    = 6'b100001;
    localparam [0:5] OP_BEZ   = 6'b100010;
    localparam [0:5] OP_BNEZ  = 6'b100011;
    localparam [0:5] OP_NOP   = 6'b111100;

    localparam [0:5] F_VAND   = 6'b000001;
    localparam [0:5] F_VOR    = 6'b000010;
    localparam [0:5] F_VXOR   = 6'b000011;
    localparam [0:5] F_VNOT   = 6'b000100;   // unary
    localparam [0:5] F_VMOV   = 6'b000101;   // unary
    localparam [0:5] F_VADD   = 6'b000110;
    localparam [0:5] F_VSUB   = 6'b000111;
    localparam [0:5] F_VMULEU = 6'b001000;
    localparam [0:5] F_VMULOU = 6'b001001;
    localparam [0:5] F_VSLL   = 6'b001010;
    localparam [0:5] F_VSRL   = 6'b001011;
    localparam [0:5] F_VSRA   = 6'b001100;
    localparam [0:5] F_VRTTH  = 6'b001101;   // unary
    localparam [0:5] F_VDIV   = 6'b001110;
    localparam [0:5] F_VMOD   = 6'b001111;
    localparam [0:5] F_VSQEU  = 6'b010000;   // unary
    localparam [0:5] F_VSQOU  = 6'b010001;   // unary
    localparam [0:5] F_VSQRT  = 6'b010010;   // unary

    // ===== Field extraction (big-endian [0:x]) =====
    assign op    = instr[0:5];
    assign rD    = instr[6:10];
    assign rA    = (op == OP_RTYPE) ? instr[11:15] : 5'd0;
    assign rB    = (op == OP_RTYPE) ? instr[16:20] : 5'd0;
    assign ww    = (op == OP_RTYPE) ? instr[24:25] : 2'b00;
    assign func  = (op == OP_RTYPE) ? instr[26:31] : 6'b0;
    assign imm16 = (op != OP_RTYPE) ? instr[16:31] : 16'b0;

    // ===== Opcode classification =====
    assign is_rtype = (op == OP_RTYPE);
    assign is_ld    = (op == OP_LD);
    assign is_sd    = (op == OP_SD);
    assign is_bez   = (op == OP_BEZ);
    assign is_bnez  = (op == OP_BNEZ);
    assign is_nop   = (op == OP_NOP);

    // Register writeback: R-type and LD write register
    assign writes_rD = is_rtype | is_ld;

    // Unary R-type operations do not use rB
    wire func_is_unary =
        (func==F_VNOT)  |
        (func==F_VMOV)  |
        (func==F_VRTTH) |
        (func==F_VSQEU) |
        (func==F_VSQOU) |
        (func==F_VSQRT);

    // If LD uses base register (for base+offset), set = 1.
    // Currently LD uses absolute addressing → does not read rA.
    localparam LD_USES_BASE = 1'b0;

    // ===== Source register definitions for hazards / forwarding =====
    // R-type: S1 = rA; S2 = rB (if not unary)
    // SD    : S1 = rD (store data)
    // BEZ   : S1 = rD (compare register)
    // BNEZ  : S1 = rD (compare register)
    // LD    : S1 = rA only if using base+offset
    assign rS1 = is_rtype ? rA : (is_sd | is_bez | is_bnez) ? rD : (is_ld & LD_USES_BASE) ? rA : 5'd0;

    assign rS2 = (is_rtype & ~func_is_unary) ? rB : 5'd0;

    // ===== Whether this instruction consumes S1/S2 =====
    // Used by HDU to detect dependence
    assign uses_S1 = is_rtype | is_sd | is_bez | is_bnez | (is_ld & LD_USES_BASE);
    assign uses_S2 = is_rtype & ~func_is_unary;

endmodule
