// Evolved from lab7/datapath.sv. The original single-read register file and
// clocked A, B, C, and status registers are preserved.
module datapath (
    input logic clk, reset, input logic [15:0] mdata, sximm8,
    input logic [7:0] PC, input logic [15:0] sximm5,
    input logic [2:0] readnum, writenum, input logic write,
    input logic [1:0] ALUop, shift, input logic asel, bsel,
    input logic [1:0] vsel, input logic loada, loadb, loadc, loads,
    output logic Z, N, V, output logic [15:0] datapath_out,
    output logic [15:0] data_to_memory
);
    logic [15:0] data_in, data_out, regA, regB;
    logic [15:0] shifted_b, alu_a, alu_b, alu_result;
    logic alu_z, alu_n, alu_v;

    regfile REGFILE(.data_in(data_in), .writenum(writenum), .write(write),
        .readnum(readnum), .clk(clk), .reset(reset), .data_out(data_out));
    shifter SHIFT(.in(regB), .shift(shift), .out(shifted_b));
    alu ALU(.a(alu_a), .b(alu_b), .op(ALUop), .result(alu_result),
        .z(alu_z), .n(alu_n), .v(alu_v));

    always_comb begin
        case (vsel)
            2'b00: data_in = mdata;
            2'b01: data_in = sximm8;
            2'b10: data_in = {8'b0, PC};
            default: data_in = datapath_out;
        endcase
    end
    assign alu_a = asel ? 16'b0 : regA;
    assign alu_b = bsel ? sximm5 : shifted_b;
    assign data_to_memory = regB;

    always_ff @(posedge clk) begin
        if (reset) begin
            regA <= 0; regB <= 0; datapath_out <= 0;
            Z <= 0; N <= 0; V <= 0;
        end else begin
            if (loada) regA <= data_out;
            if (loadb) regB <= data_out;
            if (loadc) datapath_out <= alu_result;
            if (loads) begin Z <= alu_z; N <= alu_n; V <= alu_v; end
        end
    end
endmodule
