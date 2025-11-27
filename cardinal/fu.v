`timescale 1ns/1ps
module fu (
    // ===== ID/EX (current EX stage source registers) =====
    input  wire [0:4] ex_srcA,   // Source register A
    input  wire [0:4] ex_srcB,   // Source register B

    // ===== EX/MEM stage (one stage ahead) =====
    input  wire [0:4] exm_rD,        // Destination register in EX/MEM
    input  wire       exm_writes_rD, // EX/MEM instruction writes register
    input  wire       exm_is_load,   // EX/MEM is load → value not yet available

    // ===== MEM/WB stage (two stages ahead) =====
    input  wire [0:4] wb_rD,         // Destination register in MEM/WB
    input  wire       wb_writes_rD,  // MEM/WB instruction writes register

    // ===== Forwarding control outputs =====
    // 00: use regfile
    // 01: forward from EX/MEM
    // 10: forward from MEM/WB
    output reg  [1:0] fwdA_sel,
    output reg  [1:0] fwdB_sel
);

    // EX/MEM forwarding candidates (must not be load; must write; must not be x0; match source reg)
    wire exm_ok_A = exm_writes_rD && !exm_is_load && (exm_rD != 5'd0) && (ex_srcA == exm_rD);
    wire exm_ok_B = exm_writes_rD && !exm_is_load && (exm_rD != 5'd0) && (ex_srcB == exm_rD);

    // WB forwarding candidates (must write; must not be x0; match source reg)
    wire wb_ok_A  = wb_writes_rD  && (wb_rD  != 5'd0) && (ex_srcA == wb_rD);
    wire wb_ok_B  = wb_writes_rD  && (wb_rD  != 5'd0) && (ex_srcB == wb_rD);

    always @* begin
        // Default: read from register file
        fwdA_sel = 2'b00;
        fwdB_sel = 2'b00;

        // Priority: EX/MEM > WB
        // Load cannot forward from EX/MEM because value is not ready
        if (exm_ok_A)       fwdA_sel = 2'b01;
        else if (wb_ok_A)   fwdA_sel = 2'b10;

        if (exm_ok_B)       fwdB_sel = 2'b01;
        else if (wb_ok_B)   fwdB_sel = 2'b10;
    end
endmodule
