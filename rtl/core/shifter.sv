module shifter (
    input  logic [15:0] in,
    input  logic [1:0]  shift,
    output logic [15:0] out
);
    always_comb begin
        case (shift)
            2'b00: out = in;
            2'b01: out = in << 1;
            2'b10: out = in >> 1;
            2'b11: out = {in[15], in[15:1]};
            default: out = in;
        endcase
    end
endmodule
