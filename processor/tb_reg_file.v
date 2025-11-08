module tb_reg_file;

    reg clk, rst, wrEn;
    reg [0:4] WA;
    reg [0:9] RA;
    reg [0:63] WD;
    wire [0:63] out_a, out_b;
    reg_file dut(clk, rst, wrEn, RA, WA, WD, out_a, out_b);

    //CLK with 4ns period (250MHz)
    initial clk = 1'b0;
    always #2 clk = ~clk;

    //print result
    always @(out_a, out_b) begin
        $display("clk = %b, rst = %b, RA_a = %d, RA_b = %d", clk, rst, RA[0:4], RA[5:9]);
        $display("output:  a = %d, b = %d", out_a, out_b);
        $display(" ");
    end

    integer i = 0;

    initial begin

        //reset
        rst = 1;
        @(negedge clk);
        rst = 0;
        wrEn = 1;
        //write i into data[i] and check if correctly write in
        repeat (32) begin
            WA = i;
            WD = i;
            @(negedge clk);
            RA = {i, 5'b0};
            i = i + 1;
        end
        wrEn = 0;
        @(negedge clk);
        $stop;

    end

endmodule