module simple_risc_system #(
    parameter INIT_FILE = "software/images/demo.mem"
) (
    input  logic        clk,
    input  logic        reset,
    output logic        halted,
    output logic [15:0] result,
    output logic        Z,
    output logic        N,
    output logic        V
);
    logic [7:0] addr;
    logic [15:0] read_data, write_data;
    logic write_en;

    cpu CPU (
        .clk(clk), .reset(reset), .mem_rdata(read_data),
        .mem_addr(addr), .mem_wdata(write_data), .mem_we(write_en),
        .halted(halted), .Z(Z), .N(N), .V(V), .out(result)
    );
    memory #(.INIT_FILE(INIT_FILE)) MEM (
        .clk(clk), .addr(addr), .write_data(write_data),
        .write_en(write_en), .read_data(read_data)
    );
endmodule
