module cardinal_nic(clk, reset, addr, d_in, d_out, nicEn, nicEnWr, 
           net_si, net_ri, net_di, net_so, net_ro, net_do, net_polarity);

    input clk, reset, nicEn, nicEnWr, net_si, net_ro, net_polarity;
    input [0:1] addr;
    input [0:63] d_in, net_di;
    output net_ri, net_so;
    output [0:63] d_out, net_do;
    reg net_ri, net_so;
    reg [0:63] d_out, net_do;

    //full when status = 1, empty when status = 0
    reg status_reg_i, status_reg_o;
    reg [0:63] buffer_in, buffer_out;

    always @(posedge clk) begin
        if (reset) begin
            status_reg_i <= 1'b0;
            status_reg_o <= 1'b0;
            net_ri <= 1'b1;
            net_so <= 1'b0;
            d_out <= 64'b0;
            net_do <= 64'b0;
            buffer_in <= 64'b0;
            buffer_out <= 64'b0;
        end else begin
            //interface between processor and the NIC
            //output channel buffer
            //receive and store only when output channel buffer is empty
            if (nicEn && nicEnWr && (addr == 2'b10) && !status_reg_o) begin
                status_reg_o <= 1'b1;
                buffer_out <= d_in;
            end
            //input channel buffer
            if (nicEn && !nicEnWr) begin
                case (addr)
                    2'b00: 
                    begin
                        //can respond even when empty, processor will handle it 
                        d_out <= buffer_in;
                        if (status_reg_i) begin
                            status_reg_i <= 1'b0;
                            net_ri <= 1'b1;
                        end
                    end
                    2'b01: d_out <= {63'b0, status_reg_i};
                    2'b11: d_out <= {63'b0, status_reg_o};
                    //default: d_out <= d_out;
                endcase
            end

            //interface between router and NIC
            //input channel buffer
            //receive and store data when net_si = 1 
            if (net_si) begin
                status_reg_i <= 1'b1;
                net_ri <= 1'b0;
                buffer_in <= net_di;
            end
            //output channel buffer
            if (net_ro && (net_polarity == buffer_out[63]) && status_reg_o) begin
                //set net_so to 1 and send out data
                status_reg_o <= 1'b0; 
                net_so <= 1'b1;
                net_do <= buffer_out;
            end else begin
                //set net_so to 0 if not going to send
                net_so <= 1'b0;
            end

        end
    end

endmodule