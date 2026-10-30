module memory #(
    parameter INIT_FILE = "software/images/demo.mem"
) (
    input  logic        clk,
    input  logic [7:0]  addr,
    input  logic [15:0] write_data,
    input  logic        write_en,
    output logic [15:0] read_data
);
    logic [15:0] mem [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 16'b0;
        $readmemb(INIT_FILE, mem);
    end

    assign read_data = mem[addr];

    // A plain clocked process is used because the initialization block also
    // writes this array; strict tools disallow that combination with always_ff.
    always @(posedge clk)
        if (write_en)
            mem[addr] <= write_data;
endmodule
