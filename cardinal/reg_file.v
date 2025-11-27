`timescale 1ns/1ps
module reg_file(
    input         clk,
    input         rst,
    input         wrEn,
    input  [0:4]  WA,
    input  [0:4]  RA_a,
    input  [0:4]  RA_b,
    input  [0:63] WD,
    output reg [0:63] out_a,
    output reg [0:63] out_b
);
    reg [0:63] data [0:31];
    integer k;

    // synchronous write
    always @(posedge clk) begin
        if (rst) begin
            for (k = 0; k < 32; k = k + 1)
                data[k] <= 64'b0;
        end else begin
            data[0] <= 64'b0;
            if (wrEn && WA != 5'd0)
                data[WA] <= WD;
        end
    end

    // asynchronous read
    always @* begin
        out_a = rst ? 64'b0 : data[RA_a];
        out_b = rst ? 64'b0 : data[RA_b];
    end
endmodule