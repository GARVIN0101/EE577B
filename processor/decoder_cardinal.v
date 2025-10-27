`timescale 1ns/1ps
module decoder_cardinal (
    input wire [31:0] instr,
    output wire [4:0] rd,
    output wire [4:0] ra,
    output wire [4:0] rb,
    output wire [1:0] ww,
    output wire [15:0] imm16,
    output wire [5:0] opcode6,
    output wire [5:0] funct6,
    // Convenience type flags for controller/ALU
    output wire is_rtype,
    output wire is_vld,
    output wire is_vsd,
    output wire is_vbez,
    output wire is_vbnez,
    output wire is_vnop
);
    assign opcode6 = instr[31:26];
    assign rd = instr[25:21];
    assign ra = instr[20:16];
    assign rb = instr[15:11];
    assign ww = instr[7:6];
    assign funct6 = instr[5:0];
    assign imm16 = instr[15:0];


    // Opcode constants from ISA preliminary encoding
    localparam [5:0] OPC_RTYPE = 6'b101010; // vector ALU group
    localparam [5:0] OPC_VLD = 6'b100000; // load
    localparam [5:0] OPC_VSD = 6'b100001; // store
    localparam [5:0] OPC_VBEZ = 6'b100010; // branch if == 0 (uses rD field)
    localparam [5:0] OPC_VBNEZ = 6'b100011; // branch if != 0 (uses rD field)
    localparam [5:0] OPC_VNOP = 6'b111100; // nop


    assign is_rtype = (opcode6 == OPC_RTYPE);
    assign is_vld = (opcode6 == OPC_VLD);
    assign is_vsd = (opcode6 == OPC_VSD);
    assign is_vbez = (opcode6 == OPC_VBEZ);
    assign is_vbnez = (opcode6 == OPC_VBNEZ);
    assign is_vnop = (opcode6 == OPC_VNOP);
endmodule
