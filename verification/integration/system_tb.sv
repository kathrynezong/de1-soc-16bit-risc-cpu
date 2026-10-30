`timescale 1ns/1ps

module system_tb;
    logic clk = 1'b0;
    logic reset = 1'b1;
    logic halted;
    logic [15:0] result;
    logic Z, N, V;
    logic branch_halted;
    logic [15:0] branch_result;
    logic branch_z, branch_n, branch_v;
    integer cycles;

    simple_risc_system #(.INIT_FILE("software/images/demo.mem")) DUT (
        .clk(clk), .reset(reset), .halted(halted), .result(result),
        .Z(Z), .N(N), .V(V)
    );
    simple_risc_system #(.INIT_FILE("software/images/branch.mem")) DUT_BRANCH (
        .clk(clk), .reset(reset), .halted(branch_halted), .result(branch_result),
        .Z(branch_z), .N(branch_n), .V(branch_v)
    );

    always #5 clk = ~clk;

    initial begin
        repeat (2) @(posedge clk);
        reset <= 1'b0;

        cycles = 0;
        while ((!halted || !branch_halted) && cycles < 80) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        if (!halted)
            $fatal(1, "Load/store program did not halt");
        if (!branch_halted)
            $fatal(1, "Branch program did not halt");
        if (DUT.CPU.DP.REGFILE.R0 !== 16'h0005)
            $fatal(1, "R0 = %h, expected 0005", DUT.CPU.DP.REGFILE.R0);
        if (DUT.CPU.DP.REGFILE.R1 !== 16'hABCD)
            $fatal(1, "R1 = %h, expected ABCD", DUT.CPU.DP.REGFILE.R1);
        if (DUT.CPU.DP.REGFILE.R2 !== 16'h0006)
            $fatal(1, "R2 = %h, expected 0006", DUT.CPU.DP.REGFILE.R2);
        if (DUT.MEM.mem[6] !== 16'hABCD)
            $fatal(1, "mem[6] = %h, expected ABCD", DUT.MEM.mem[6]);
        if (DUT_BRANCH.CPU.DP.REGFILE.R1 !== 16'h0003)
            $fatal(1, "Branch loop R1 = %h, expected 0003",
                   DUT_BRANCH.CPU.DP.REGFILE.R1);

        $display("PASS: load/store and conditional-branch programs completed in %0d cycles", cycles);
        $finish;
    end
endmodule
