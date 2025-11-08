`include "./include/gscl45nm.v"

module tb_ALU_syn;

    reg clk, rst;
    reg [0:1] ww;
    reg [0:5] op, func;
    reg [0:63] in_a, in_b;
    wire [0:63] out;
    ALU dut(clk, rst, in_a, in_b, op, ww, func, out);

    //CLK with 4ns period (250MHz)
    initial clk = 1'b0;
    always #2 clk = ~clk;

    //print result
    always @(out) begin
        $display("operation: %b, function: %b, ww: %b", op, func, ww);
        $display("input: in_a = %h, in_b = %h", in_a, in_b);
        $display("output = %h", out);
        $display(" ");
    end

    initial begin

        //reset
        rst = 1;
        @(negedge clk);
        rst = 0;
        //R-type
        //AND
        op = 6'b101010;
        func = 6'b000001;
        ww = 2'b00;
        in_a = 64'h0123_4567_89AB_CDEF;
        in_b = 64'hFEDC_BA98_7654_3210;
        $display("AND");
        @(negedge clk);
        //OR
        func = 6'b000010;
        $display("OR");
        @(negedge clk);
        //XOR
        func = 6'b000011;
        $display("XOR");
        @(negedge clk);
        //NOT
        func = 6'b000100;
        $display("NOT");
        @(negedge clk);
        //MOV
        func = 6'b000101;
        $display("MOV");
        @(negedge clk);

        //ADD_00
        func = 6'b000110;
        $display("ADD 00");
        @(negedge clk);
        //ADD_01
        $display("ADD 01");
        ww = 2'b01;
        @(negedge clk);
        //ADD_10
        $display("ADD 10");
        ww = 2'b10;
        @(negedge clk);
        //ADD_11
        $display("ADD 11");
        ww = 2'b11;
        @(negedge clk);

        //SUB_00
        func = 6'b000111;
        $display("SUB 00");
        ww = 2'b00;
        @(negedge clk);
        //SUB_01
        $display("SUB 01");
        ww = 2'b01;
        @(negedge clk);
        //SUB_10
        $display("SUB 10");
        ww = 2'b10;
        @(negedge clk);
        //SUB_11
        $display("SUB 11");
        ww = 2'b11;
        @(negedge clk);

        //MULEU_00
        func = 6'b001000;
        $display("MULEU 00");
        ww = 2'b00;
        @(negedge clk);
        //MULEU_01
        $display("MULEU 01");
        ww = 2'b01;
        @(negedge clk);
        //MULEU_10
        $display("MULEU 10");
        ww = 2'b10;
        @(negedge clk);

        //MULOU_00
        func = 6'b001001;
        $display("MULOU 00");
        ww = 2'b00;
        @(negedge clk);
        //MULOU_01
        $display("MULOU 01");
        ww = 2'b01;
        @(negedge clk);
        //MULOU_10
        $display("MULOU 10");
        ww = 2'b10;
        @(negedge clk);

        //SLL_00
        func = 6'b001010;
        $display("SLL 00");
        ww = 2'b00;
        @(negedge clk);
        //SLL_01
        $display("SLL 01");
        ww = 2'b01;
        @(negedge clk);
        //SLL_10
        $display("SLL 10");
        ww = 2'b10;
        @(negedge clk);
        //SLL_11
        $display("SLL 11");
        ww = 2'b11;
        @(negedge clk);

        //SRL_00
        func = 6'b001011;
        $display("SRL 00");
        ww = 2'b00;
        @(negedge clk);
        //SRL_01
        $display("SRL 01");
        ww = 2'b01;
        @(negedge clk);
        //SRL_10
        $display("SRL 10");
        ww = 2'b10;
        @(negedge clk);
        //SRL_11
        $display("SRL 11");
        ww = 2'b11;
        @(negedge clk);

        //SRA_00
        func = 6'b001100;
        $display("SRA 00");
        ww = 2'b00;
        @(negedge clk);
        //SRA_01
        $display("SRA 01");
        ww = 2'b01;
        @(negedge clk);
        //SRA_10
        $display("SRA 10");
        ww = 2'b10;
        @(negedge clk);
        //SRA_11
        $display("SRA 11");
        ww = 2'b11;
        @(negedge clk);

        //RTTH_00
        func = 6'b001101;
        $display("RTTH 00");
        ww = 2'b00;
        @(negedge clk);
        //RTTH_01
        $display("RTTH 01");
        ww = 2'b01;
        @(negedge clk);
        //RTTH_10
        $display("RTTH 10");
        ww = 2'b10;
        @(negedge clk);
        //RTTH_11
        $display("RTTH 11");
        ww = 2'b11;
        @(negedge clk);

        //DIV_00
        func = 6'b001110;
        $display("DIV 00");
        ww = 2'b00;
        @(negedge clk);
        //DIV_01
        $display("DIV 01");
        ww = 2'b01;
        @(negedge clk);
        //DIV_10
        $display("DIV 10");
        ww = 2'b10;
        @(negedge clk);
        //DIV_11
        $display("DIV 11");
        ww = 2'b11;
        @(negedge clk);

        //MOD_00
        func = 6'b001111;
        $display("MOD 00");
        ww = 2'b00;
        @(negedge clk);
        //MOD_01
        $display("MOD 01");
        ww = 2'b01;
        @(negedge clk);
        //MOD_10
        $display("MOD 10");
        ww = 2'b10;
        @(negedge clk);
        //MOD_11
        $display("MOD 11");
        ww = 2'b11;
        @(negedge clk);

        //SQEU_00
        func = 6'b010000;
        $display("SQEU 00");
        ww = 2'b00;
        @(negedge clk);
        //SQEU_01
        $display("SQEU 01");
        ww = 2'b01;
        @(negedge clk);
        //SQEU_10
        $display("SQEU 10");
        ww = 2'b10;
        @(negedge clk);

        //SQOU_00
        func = 6'b010001;
        $display("SQOU 00");
        ww = 2'b00;
        @(negedge clk);
        //SQOU_01
        $display("SQOU 01");
        ww = 2'b01;
        @(negedge clk);
        //SQOU_10
        $display("SQOU 10");
        ww = 2'b10;
        @(negedge clk);

        //SQRT
        func = 6'b010010;
        $display("SQRT 00");
        ww = 2'b00;
        @(negedge clk);
        //SQRT_01
        $display("SQRT 01");
        ww = 2'b01;
        @(negedge clk);
        //SQRT_10
        $display("SQRT 10");
        ww = 2'b10;
        @(negedge clk);
        //SQRT_11
        $display("SQRT 11");
        ww = 2'b11;
        @(negedge clk);

        //Store Data
        op = 6'b100001;
        @(negedge clk);

        $stop;

    end

    initial begin
		$sdf_annotate("./netlist/frequency_divider_by3.sdf", freq1,,"sdf.log","MAXIMUM","1.0:1.0:1.0", "FROM_MAXIMUM");	//http://www.pldworld.com/_hdl/2/_ref/se_html/manual_html/c_sdf10.html
		$enable_warnings;
		$log("ncsim.log");
	end

endmodule