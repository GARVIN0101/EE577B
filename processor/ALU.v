module ALU(
    input clk,
    input rst,   
    input [0:1] ww,
    input [0:5] op, func,
    input [0:63] in_a, in_b,
    output reg [0:63] out
);
    localparam
    //instructions
    Rtype = 6'b101010,
    LD    = 6'b100000,
    SD    = 6'b100001,
    BEZ   = 6'b100010,
    BNEZ  = 6'b100011,
    NOP   = 6'b111100,
    //function code
    AND   = 6'b000001,
    OR    = 6'b000010,
    XOR   = 6'b000011,
    NOT   = 6'b000100,
    MOV   = 6'b000101,
    ADD   = 6'b000110,
    SUB   = 6'b000111,
    MULEU = 6'b001000,
    MULOU = 6'b001001,
    SLL   = 6'b001010,
    SRL   = 6'b001011,
    SRA   = 6'b001100,
    RTTH  = 6'b001101,
    DIV   = 6'b001110,
    MOD   = 6'b001111,
    SQEU  = 6'b010000,
    SQOU  = 6'b010001,
    SQRT  = 6'b010010;

    integer s0, s1, s2, s3, s4, s5, s6, s7, i;

    function [0:7] sqrt8;
        input [0:7] num;
        reg [0:7] x;       // current estimate
        reg [0:7] x_next;  // next estimate

        begin
            if (num <= 8'b1) begin
                sqrt8 = 8'b1;
            end else begin
                x = num >> 1;  // initial guess ≈ num/2
                // Newton-Raphson iterations:
                // x_{n+1} = (x + num/x) / 2
                for (i = 0; i < 8; i = i + 1) begin
                    if (x != 0) begin
                        x_next = (x + (num / x)) >> 1;
                    end else begin
                        x_next = 8'b1;   // avoid divide-by-zero corner case
                    end
                    x = x_next;
                end
                // Put the sqrt result (lower 16 bits of x) into [15:0],
                // and zero-fill [31:16] so the output bus is 32 bits.
                sqrt8 = x;
            end
        end
    endfunction

    function [0:15] sqrt16;
        input [0:15] num;
        reg [0:15] x;       // current estimate
        reg [0:15] x_next;  // next estimate

        begin
            if (num <= 16'b1) begin
                sqrt16 = 16'b1;
            end else begin
                x = num >> 1;  // initial guess ≈ num/2
                // Newton-Raphson iterations:
                // x_{n+1} = (x + num/x) / 2
                for (i = 0; i < 9; i = i + 1) begin
                    if (x != 0) begin
                        x_next = (x + (num / x)) >> 1;
                    end else begin
                        x_next = 16'b1;   // avoid divide-by-zero corner case
                    end
                    x = x_next;
                end
                // Put the sqrt result (lower 16 bits of x) into [15:0],
                // and zero-fill [31:16] so the output bus is 32 bits.
                sqrt16 = x;
            end
        end
    endfunction

    function [0:31] sqrt32;
        input [0:31] num;
        reg [0:31] x;       // current estimate
        reg [0:31] x_next;  // next estimate

        begin
            if (num <= 32'b1) begin
                sqrt32 = 32'b1;
            end else begin
                x = num >> 1;  // initial guess ≈ num/2
                // Newton-Raphson iterations:
                // x_{n+1} = (x + num/x) / 2
                for (i = 0; i < 10; i = i + 1) begin
                    if (x != 0) begin
                        x_next = (x + (num / x)) >> 1;
                    end else begin
                        x_next = 32'b1;   // avoid divide-by-zero corner case
                    end
                    x = x_next;
                end
                // Put the sqrt result (lower 16 bits of x) into [15:0],
                // and zero-fill [31:16] so the output bus is 32 bits.
                sqrt32 = x;
            end
        end
    endfunction

    function [0:63] sqrt64;
        input [0:63] num;
        reg [0:63] x;       // current estimate
        reg [0:63] x_next;  // next estimate

        begin
            if (num <= 64'b1) begin
                sqrt64 = 64'b1;
            end else begin
                x = num >> 1;  // initial guess ≈ num/2
                // Newton-Raphson iterations:
                // x_{n+1} = (x + num/x) / 2
                for (i = 0; i < 11; i = i + 1) begin
                    if (x != 0) begin
                        x_next = (x + (num / x)) >> 1;
                    end else begin
                        x_next = 64'b1;   // avoid divide-by-zero corner case
                    end
                    x = x_next;
                end
                // Put the sqrt result (lower 16 bits of x) into [15:0],
                // and zero-fill [31:16] so the output bus is 32 bits.
                sqrt64 = x;
            end
        end
    endfunction

    always @* begin
        // default value to avoid latches
        out = 64'b0;

        case (op)
            Rtype: begin
                case (func)
                    AND: out = in_a & in_b;
                    OR : out = in_a | in_b;
                    XOR: out = in_a ^ in_b;
                    NOT: out = ~in_a;
                    MOV: out = in_a;

                    ADD: begin
                        case (ww)
                            2'b00: begin
                                out = { (in_a[0:7]   + in_b[0:7]),
                                        (in_a[8:15]  + in_b[8:15]),
                                        (in_a[16:23] + in_b[16:23]),
                                        (in_a[24:31] + in_b[24:31]),
                                        (in_a[32:39] + in_b[32:39]),
                                        (in_a[40:47] + in_b[40:47]),
                                        (in_a[48:55] + in_b[48:55]),
                                        (in_a[56:63] + in_b[56:63]) };
                            end
                            2'b01: begin
                                out = { (in_a[0:15]  + in_b[0:15]),
                                        (in_a[16:31] + in_b[16:31]),
                                        (in_a[32:47] + in_b[32:47]),
                                        (in_a[48:63] + in_b[48:63]) };
                            end
                            2'b10: out = { (in_a[0:31]  + in_b[0:31]),
                                           (in_a[32:63] + in_b[32:63]) };
                            2'b11: out = in_a + in_b;
                            default: out = 64'b0;
                        endcase
                    end

                    SUB: begin
                        case (ww)
                            2'b00: begin
                                out = { (in_a[0:7]   - in_b[0:7]),
                                        (in_a[8:15]  - in_b[8:15]),
                                        (in_a[16:23] - in_b[16:23]),
                                        (in_a[24:31] - in_b[24:31]),
                                        (in_a[32:39] - in_b[32:39]),
                                        (in_a[40:47] - in_b[40:47]),
                                        (in_a[48:55] - in_b[48:55]),
                                        (in_a[56:63] - in_b[56:63]) };
                            end
                            2'b01: begin
                                out = { (in_a[0:15]  - in_b[0:15]),
                                        (in_a[16:31] - in_b[16:31]),
                                        (in_a[32:47] - in_b[32:47]),
                                        (in_a[48:63] - in_b[48:63]) };
                            end
                            2'b10: out = { (in_a[0:31]  - in_b[0:31]),
                                           (in_a[32:63] - in_b[32:63]) };
                            2'b11: out = in_a - in_b;
                            default: out = 64'b0;
                        endcase
                    end

                    MULEU: begin
                        // zeroed by default; write the active lanes
                        case (ww)
                            2'b00: begin
                                out[0:15]   = in_a[0:7]   * in_b[0:7];
                                out[16:31]  = in_a[16:23] * in_b[16:23];
                                out[32:47]  = in_a[32:39] * in_b[32:39];
                                out[48:63]  = in_a[48:55] * in_b[48:55];
                            end
                            2'b01: begin
                                out[0:31]   = in_a[0:15]  * in_b[0:15];
                                out[32:63]  = in_a[32:47] * in_b[32:47];
                            end
                            2'b10: out = in_a[0:31] * in_b[0:31];
                            default: out = 64'b0;
                        endcase
                    end

                    MULOU: begin
                        case (ww)
                            2'b00: begin
                                out[0:15]   = in_a[8:15]   * in_b[8:15];
                                out[16:31]  = in_a[24:31]  * in_b[24:31];
                                out[32:47]  = in_a[40:47]  * in_b[40:47];
                                out[48:63]  = in_a[56:63]  * in_b[56:63];
                            end
                            2'b01: begin
                                out[0:31]   = in_a[16:31]  * in_b[16:31];
                                out[32:63]  = in_a[48:63]  * in_b[48:63];
                            end
                            2'b10: out = in_a[32:63] * in_b[32:63];
                            default: out = 64'b0;
                        endcase
                    end

                    SLL: begin
                        case (ww)
                            2'b00: begin
                                s0 = in_b[5:7];  s1 = in_b[13:15]; s2 = in_b[21:23]; s3 = in_b[29:31];
                                s4 = in_b[37:39]; s5 = in_b[45:47]; s6 = in_b[53:55]; s7 = in_b[61:63];
                                out = { (in_a[0:7]  << s0), (in_a[8:15]  << s1),
                                        (in_a[16:23] << s2), (in_a[24:31] << s3),
                                        (in_a[32:39] << s4), (in_a[40:47] << s5),
                                        (in_a[48:55] << s6), (in_a[56:63] << s7) };
                            end
                            2'b01: begin
                                s0 = in_b[12:15]; s1 = in_b[28:31]; s2 = in_b[44:47]; s3 = in_b[60:63];
                                out = { (in_a[0:15]  << s0), (in_a[16:31] << s1),
                                        (in_a[32:47] << s2), (in_a[48:63] << s3) };
                            end
                            2'b10: begin
                                s0 = in_b[27:31]; s1 = in_b[59:63];
                                out = { (in_a[0:31]  << s0), (in_a[32:63] << s1) };
                            end
                            2'b11: begin
                                s0 = in_b[58:63];
                                out = in_a << s0;
                            end
                            default: out = 64'b0;
                        endcase
                    end

                    SRL: begin
                        case (ww)
                            2'b00: begin
                                s0 = in_b[5:7];  s1 = in_b[13:15]; s2 = in_b[21:23]; s3 = in_b[29:31];
                                s4 = in_b[37:39]; s5 = in_b[45:47]; s6 = in_b[53:55]; s7 = in_b[61:63];
                                out = { (in_a[0:7]  >> s0), (in_a[8:15]  >> s1),
                                        (in_a[16:23] >> s2), (in_a[24:31] >> s3),
                                        (in_a[32:39] >> s4), (in_a[40:47] >> s5),
                                        (in_a[48:55] >> s6), (in_a[56:63] >> s7) };
                            end
                            2'b01: begin
                                s0 = in_b[12:15]; s1 = in_b[28:31]; s2 = in_b[44:47]; s3 = in_b[60:63];
                                out = { (in_a[0:15]  >> s0), (in_a[16:31] >> s1),
                                        (in_a[32:47] >> s2), (in_a[48:63] >> s3) };
                            end
                            2'b10: begin
                                s0 = in_b[27:31]; s1 = in_b[59:63];
                                out = { (in_a[0:31]  >> s0), (in_a[32:63] >> s1) };
                            end
                            2'b11: begin
                                s0 = in_b[58:63];
                                out = in_a >> s0;
                            end
                            default: out = 64'b0;
                        endcase
                    end

                    SRA: begin
                        case (ww)
                            2'b00: begin
                                s0 = in_b[5:7];  s1 = in_b[13:15]; s2 = in_b[21:23]; s3 = in_b[29:31];
                                s4 = in_b[37:39]; s5 = in_b[45:47]; s6 = in_b[53:55]; s7 = in_b[61:63];
                                out = { (in_a[0:7]  >>> s0), (in_a[8:15]  >>> s1),
                                        (in_a[16:23] >>> s2), (in_a[24:31] >>> s3),
                                        (in_a[32:39] >>> s4), (in_a[40:47] >>> s5),
                                        (in_a[48:55] >>> s6), (in_a[56:63] >>> s7) };
                            end
                            2'b01: begin
                                s0 = in_b[12:15]; s1 = in_b[28:31]; s2 = in_b[44:47]; s3 = in_b[60:63];
                                out = { (in_a[0:15]  >>> s0), (in_a[16:31] >>> s1),
                                        (in_a[32:47] >>> s2), (in_a[48:63] >>> s3) };
                            end
                            2'b10: begin
                                s0 = in_b[27:31]; s1 = in_b[59:63];
                                out = { (in_a[0:31]  >>> s0), (in_a[32:63] >>> s1) };
                            end
                            2'b11: begin
                                s0 = in_b[58:63];
                                out = $signed(in_a) >>> s0;
                            end
                            default: out = 64'b0;
                        endcase
                    end

                    RTTH: begin
                        case (ww)
                            2'b00: out = { in_a[4:7],   in_a[0:3],   in_a[12:15], in_a[8:11],
                                           in_a[20:23], in_a[16:19], in_a[28:31], in_a[24:27],
                                           in_a[36:39], in_a[32:35], in_a[44:47], in_a[40:43],
                                           in_a[52:55], in_a[48:51], in_a[60:63], in_a[56:59] };
                            2'b01: out = { in_a[8:15],  in_a[0:7],   in_a[24:31], in_a[16:23],
                                           in_a[40:47], in_a[32:39], in_a[56:63], in_a[48:55] };
                            2'b10: out = { in_a[16:31], in_a[0:15],  in_a[48:63], in_a[32:47] };
                            2'b11: out = { in_a[32:63], in_a[0:31] };
                            default: out = 64'b0;
                        endcase
                    end

                    DIV: begin
                        case (ww)
                            2'b00: out = { (in_a[0:7]   / in_b[0:7]),   (in_a[8:15]  / in_b[8:15]),
                                           (in_a[16:23] / in_b[16:23]), (in_a[24:31] / in_b[24:31]),
                                           (in_a[32:39] / in_b[32:39]), (in_a[40:47] / in_b[40:47]),
                                           (in_a[48:55] / in_b[48:55]), (in_a[56:63] / in_b[56:63]) };
                            2'b01: out = { (in_a[0:15]  / in_b[0:15]),  (in_a[16:31] / in_b[16:31]),
                                           (in_a[32:47] / in_b[32:47]), (in_a[48:63] / in_b[48:63]) };
                            2'b10: out = { (in_a[0:31]  / in_b[0:31]),  (in_a[32:63] / in_b[32:63]) };
                            2'b11: out = in_a / in_b;
                            default: out = 64'b0;
                        endcase
                    end

                    MOD: begin
                        case (ww)
                            2'b00: out = { (in_a[0:7]   % in_b[0:7]),   (in_a[8:15]  % in_b[8:15]),
                                           (in_a[16:23] % in_b[16:23]), (in_a[24:31] % in_b[24:31]),
                                           (in_a[32:39] % in_b[32:39]), (in_a[40:47] % in_b[40:47]),
                                           (in_a[48:55] % in_b[48:55]), (in_a[56:63] % in_b[56:63]) };
                            2'b01: out = { (in_a[0:15]  % in_b[0:15]),  (in_a[16:31] % in_b[16:31]),
                                           (in_a[32:47] % in_b[32:47]), (in_a[48:63] % in_b[48:63]) };
                            2'b10: out = { (in_a[0:31]  % in_b[0:31]),  (in_a[32:63] % in_b[32:63]) };
                            2'b11: out = in_a % in_b;
                            default: out = 64'b0;
                        endcase
                    end

                    SQEU: begin
                        case (ww)
                            2'b00: begin
                                out[0:15]   = in_a[0:7]   * in_a[0:7];
                                out[16:31]  = in_a[16:23] * in_a[16:23];
                                out[32:47]  = in_a[32:39] * in_a[32:39];
                                out[48:63]  = in_a[48:55] * in_a[48:55];
                            end
                            2'b01: begin
                                out[0:31]   = in_a[0:15]  * in_a[0:15];
                                out[32:63]  = in_a[32:47] * in_a[32:47];
                            end
                            2'b10: out = in_a[0:31] * in_a[0:31];
                            default: out = 64'b0;
                        endcase
                    end

                    SQOU: begin
                        case (ww)
                            2'b00: begin
                                out[0:15]   = in_a[8:15]   * in_a[8:15];
                                out[16:31]  = in_a[24:31]  * in_a[24:31];
                                out[32:47]  = in_a[40:47]  * in_a[40:47];
                                out[48:63]  = in_a[56:63]  * in_a[56:63];
                            end
                            2'b01: begin
                                out[0:31]   = in_a[16:31]  * in_a[16:31];
                                out[32:63]  = in_a[48:63]  * in_a[48:63];
                            end
                            2'b10: out = in_a[32:63] * in_a[32:63];
                            default: out = 64'b0;
                        endcase
                    end

                    SQRT: begin
                        case (ww)
                            2'b00: out = { sqrt8(in_a[0:7]),   sqrt8(in_a[8:15]),
                                           sqrt8(in_a[16:23]), sqrt8(in_a[24:31]),
                                           sqrt8(in_a[32:39]), sqrt8(in_a[40:47]),
                                           sqrt8(in_a[48:55]), sqrt8(in_a[56:63]) };
                            2'b01: out = { sqrt16(in_a[0:15]),  sqrt16(in_a[16:31]),
                                           sqrt16(in_a[32:47]), sqrt16(in_a[48:63]) };
                            2'b10: out = { sqrt32(in_a[0:31]),  sqrt32(in_a[32:63]) };
                            2'b11: out = sqrt64(in_a);
                            default: out = 64'b0;
                        endcase
                    end

                    default: out = 64'b0;  // unknown func -> 0
                endcase
            end

            SD: begin
                // Store uses ALU as a bypass for the store data (A path).
                out = in_a;
            end

            // All other opcodes (LD/BEZ/BNEZ/NOP/unknown) produce no ALU result.
            default: begin
                out = 64'b0;
            end
        endcase
    end
endmodule