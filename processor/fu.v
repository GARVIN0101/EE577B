module fu (
    // ID/EX (current EX stage operands)
    input  wire [4:0] id_ex_rs1,       // source register for ALU operand A
    input  wire [4:0] id_ex_rs2,       // source register for ALU operand B

    //EX/MEM (one stage ahead)
    input  wire [4:0] ex_mem_rd,       // destination register in EX/MEM stage
    input  wire       ex_mem_regWrite, // whether EX/MEM will write back
    input  wire       ex_mem_memRead,  // whether EX/MEM is a LOAD

    //MEM/WB (two stages ahead)
    input  wire [4:0] mem_wb_rd,       // destination register in MEM/WB stage
    input  wire       mem_wb_regWrite, // whether MEM/WB will write back

    //Outputs: select signals for ALU operand muxes
    output reg  [1:0] fwd_a_sel,       // ALU src A select
    output reg  [1:0] fwd_b_sel        // ALU src B select
);
    // Dependency detection
    // True when EX/MEM or MEM/WB destination matches current
    // ID/EX source register. Ignore register 0 (hardwired zero).
    wire exmem_hit_rs1 = ex_mem_regWrite && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1);
    wire exmem_hit_rs2 = ex_mem_regWrite && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2);

    wire memwb_hit_rs1 = mem_wb_regWrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1);
    wire memwb_hit_rs2 = mem_wb_regWrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2);

    // Do not forward from EX/MEM if it is a load (data not yet ready)
    wire exmem_can_forward = ex_mem_regWrite && !ex_mem_memRead;

    // Forwarding select logic (priority: EX/MEM > MEM/WB)
    always @* begin
        // defaults: no forwarding (use regfile data)
        fwd_a_sel = 2'b00;
        fwd_b_sel = 2'b00;

        // Operand A
        if (exmem_can_forward && exmem_hit_rs1)
            fwd_a_sel = 2'b10;        // from EX/MEM
        else if (memwb_hit_rs1)
            fwd_a_sel = 2'b01;        // from MEM/WB

        // Operand B
        if (exmem_can_forward && exmem_hit_rs2)
            fwd_b_sel = 2'b10;        // from EX/MEM
        else if (memwb_hit_rs2)
            fwd_b_sel = 2'b01;        // from MEM/WB
    end
endmodule