`timescale 1ns/1ps
module pc(
    input  wire clk,
    input  wire reset,
    input  wire en,              // enable PC update
    input  wire branch_taken,
    input  wire [0:15] imm16,    // absolute target immediate
    output reg  [0:31] pc        // current PC
);
    wire [0:31] pc_inc  = pc + 32'd1;         // byte address +1
    wire [0:31] br_tgt  = {16'b0, imm16};     // absolute target
    wire [0:31] pc_next = branch_taken ? br_tgt : pc_inc;

    always @(posedge clk) begin
        if (reset)
            pc <= 32'b0;
        else if (en)
            pc <= pc_next;
    end
endmodule
