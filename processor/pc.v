`timescale 1ns/1ps

module pc(
    input  wire clk,
    input  wire reset,
    input  wire branch_taken,
    input  wire [15:0] imm16,          // absolute target immediate
    output reg  [31:0] pc,             // current PC
);

    // ----- Next-PC calculation -----
    wire [31:0] pc_inc  = pc + 32'd4;          // always byte address (+4)
    wire [31:0] br_tgt  = {16'b0, imm16};      // absolute target
    wire [31:0] pc_next = branch_taken ? br_tgt : pc_inc;

    // ----- Sequential update -----
    always @(posedge clk) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

endmodule