`timescale 1ns/1ps
module hdu (
    // ===== ID stage inputs =====
    input  wire [4:0] id_rs1,      // source register 1 of instruction in ID
    input  wire [4:0] id_rs2,      // source register 2 of instruction in ID
    input  wire       id_memRead,  // whether current ID instruction will read memory (VLD)

    // ===== EX stage inputs =====
    input  wire [4:0] ex_rd,       // destination register of EX stage instruction
    input  wire       ex_regWrite, // EX stage will write back to register file
    input  wire       ex_memRead,  // EX stage is a memory-read (load)

    // ===== Control outputs =====
    output wire       stall,       // stall the pipeline (freeze PC and IF/ID)
    output wire       if_id_hold,  // hold IF/ID pipeline register
    output wire       id_ex_flush  // flush ID/EX pipeline register (insert bubble)
);

    //------------------------------------------------------------
    // Load-Use Hazard Detection
    //------------------------------------------------------------
    // If the EX-stage instruction is a load (memRead)
    // and its destination register matches either of the source
    // registers of the instruction in ID stage, a hazard occurs.
    // Stall one cycle to allow the load data to be ready.
    //------------------------------------------------------------
    wire hazard_load_use = ex_memRead && ((ex_rd == id_rs1 && id_rs1 != 0) || (ex_rd == id_rs2 && id_rs2 != 0));
    assign stall       = hazard_load_use;
    assign if_id_hold  = hazard_load_use;
    assign id_ex_flush = hazard_load_use;

endmodule