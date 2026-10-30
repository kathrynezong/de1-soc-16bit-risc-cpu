module lab7_top (
    input  logic [3:0] KEY,
    input  logic [9:0] SW,
    output logic [9:0] LEDR,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5
);
    logic [7:0] addr;
    logic [15:0] read_data, write_data, result;
    logic write_en, halted, Z, N, V;

    // KEY0 steps the multi-cycle CPU and KEY1 is active-low reset.
    cpu CPU (
        .clk(~KEY[0]), .reset(~KEY[1]), .mem_rdata(read_data),
        .mem_addr(addr), .mem_wdata(write_data), .mem_we(write_en),
        .halted(halted), .Z(Z), .N(N), .V(V), .out(result)
    );
    memory #(.INIT_FILE("software/images/demo.mem")) MEM (
        .clk(~KEY[0]), .addr(addr), .write_data(write_data),
        .write_en(write_en), .read_data(read_data)
    );

    hex7seg H0(result[3:0], HEX0);
    hex7seg H1(result[7:4], HEX1);
    hex7seg H2(result[11:8], HEX2);
    hex7seg H3(result[15:12], HEX3);
    assign HEX4 = 7'b1111111;
    assign HEX5 = {~N, 2'b11, ~V, 2'b11, ~Z};
    assign LEDR = {halted, write_en, addr};
endmodule

module hex7seg (
    input  logic [3:0] value,
    output logic [6:0] segments
);
    always_comb begin
        case (value)
            4'h0: segments = 7'b1000000; 4'h1: segments = 7'b1111001;
            4'h2: segments = 7'b0100100; 4'h3: segments = 7'b0110000;
            4'h4: segments = 7'b0011001; 4'h5: segments = 7'b0010010;
            4'h6: segments = 7'b0000010; 4'h7: segments = 7'b1111000;
            4'h8: segments = 7'b0000000; 4'h9: segments = 7'b0010000;
            4'hA: segments = 7'b0001000; 4'hB: segments = 7'b0000011;
            4'hC: segments = 7'b1000110; 4'hD: segments = 7'b0100001;
            4'hE: segments = 7'b0000110; default: segments = 7'b0001110;
        endcase
    end
endmodule
