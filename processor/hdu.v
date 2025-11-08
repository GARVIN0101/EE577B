`timescale 1ns/1ps
module hdu (
    // ===== ID stage inputs =====
    input  wire [0:4] id_rS1,        // Source register 1
    input  wire [0:4] id_rS2,        // Source register 2
    input  wire       id_uses_S1,    // The instruction in ID uses rS1
    input  wire       id_uses_S2,    // The instruction in ID uses rS2
    input  wire       id_is_branch,  // (Optional) branch info — not used here

    // ===== EX/MEM stage view =====
    input  wire [0:4] exm_rD,        // Destination register of EX/MEM instruction
    input  wire       exm_writes_rD, // EX/MEM instruction writes to a register
    input  wire       exm_is_load,   // EX/MEM instruction is a LOAD (data not ready yet)

    // ===== WB stage view (not used here, but kept for top-level compatibility) =====
    input  wire [0:4] wb_rD,
    input  wire       wb_writes_rD,

    // ===== Control outputs =====
    output wire       stall,        // Stall pipeline
    output wire       if_id_hold,   // Hold IF/ID register (also holds PC update)
    output wire       id_ex_flush   // Insert NOP into ID/EX
);

    // Detect RAW hazard: EX/MEM destination register equals current ID source
    wire hazard_s1 = id_uses_S1 &&
                     exm_writes_rD &&
                     (exm_rD != 5'd0) &&
                     (exm_rD == id_rS1);

    wire hazard_s2 = id_uses_S2 &&
                     exm_writes_rD &&
                     (exm_rD != 5'd0) &&
                     (exm_rD == id_rS2);

    // A load-use hazard occurs when EX/MEM is a load and ID consumes the value
    wire load_use_hazard = exm_is_load && (hazard_s1 || hazard_s2);

    // Stall & bubble insertion on load-use hazard
    assign stall       = load_use_hazard;
    assign if_id_hold  = load_use_hazard; // Freeze IF/ID pipeline register + PC
    assign id_ex_flush = load_use_hazard; // Insert bubble into ID/EX (NOP)

endmodule
