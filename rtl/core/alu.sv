module alu (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic [1:0]  op,
    output logic [15:0] result,
    output logic        z,
    output logic        n,
    output logic        v
);
    logic [16:0] sum;

    always_comb begin
        sum = 17'b0;
        case (op)
            2'b00: begin
                sum = {a[15], a} + {b[15], b};
                result = sum[15:0];
                v = (a[15] == b[15]) && (result[15] != a[15]);
            end
            2'b01: begin
                sum = {a[15], a} - {b[15], b};
                result = sum[15:0];
                v = (a[15] != b[15]) && (result[15] != a[15]);
            end
            2'b10: begin
                result = a & b;
                v = 1'b0;
            end
            2'b11: begin
                result = ~b;
                v = 1'b0;
            end
            default: begin
                result = 16'b0;
                v = 1'b0;
            end
        endcase
        z = (result == 16'b0);
        n = result[15];
    end
endmodule
