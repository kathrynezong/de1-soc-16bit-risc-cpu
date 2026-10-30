// Stored-program extension of the manual-instruction CPU in lab7/cpu.sv.
// It sequences the original A/B/C datapath and adds fetch, PC, memory, and flow.
module cpu (
    input logic clk, reset, input logic [15:0] mem_rdata,
    output logic [7:0] mem_addr, output logic [15:0] mem_wdata,
    output logic mem_we, halted, output logic Z, N, V,
    output logic [15:0] out
);
    typedef enum logic [3:0] {FETCH, DECODE, GET_A, GET_B, EXECUTE,
        WRITEBACK, MEM_READ, MEM_WRITE, BRANCH_REG, HALT_STATE} state_t;
    state_t state;
    logic [7:0] PC;
    logic [15:0] IR, sximm5, sximm8, store_data;
    logic [2:0] readnum, writenum;
    logic [1:0] ALUop, shift, vsel;
    logic write, asel, bsel, loada, loadb, loadc, loads, branch_taken;

    assign sximm5 = {{11{IR[4]}}, IR[4:0]};
    assign sximm8 = {{8{IR[7]}}, IR[7:0]};
    assign shift = IR[4:3];
    assign halted = (state == HALT_STATE);

    datapath DP(.clk(clk), .reset(reset), .mdata(mem_rdata), .sximm8(sximm8),
        .PC(PC), .sximm5(sximm5), .readnum(readnum), .writenum(writenum),
        .write(write), .ALUop(ALUop), .shift(shift), .asel(asel), .bsel(bsel),
        .vsel(vsel), .loada(loada), .loadb(loadb), .loadc(loadc), .loads(loads),
        .Z(Z), .N(N), .V(V), .datapath_out(out), .data_to_memory(store_data));

    always_comb begin
        case (IR[15:8])
            8'h20: branch_taken = 1'b1;
            8'h21: branch_taken = Z;
            8'h22: branch_taken = ~Z;
            8'h23: branch_taken = (N != V);
            8'h24: branch_taken = Z | (N != V);
            default: branch_taken = 1'b0;
        endcase
    end

    always_comb begin
        readnum = 0; writenum = IR[7:5]; ALUop = IR[12:11];
        vsel = 0; write = 0; asel = 0; bsel = 0;
        loada = 0; loadb = 0; loadc = 0; loads = 0;
        case (state)
            DECODE: begin
                if (IR[15:11] == 5'b11010) begin
                    writenum = IR[10:8]; vsel = 2'b01; write = 1;
                end else if (IR[15:8] == 8'h5F || IR[15:8] == 8'h57) begin
                    writenum = 3'd7; vsel = 2'b10; write = 1;
                end
            end
            GET_A: begin readnum = IR[10:8]; loada = 1; end
            GET_B: begin
                if (IR[15:11] == 5'b10000 || IR[15:8] == 8'h40 || IR[15:8] == 8'h57)
                    readnum = IR[7:5];
                else readnum = IR[2:0];
                loadb = 1;
            end
            EXECUTE: begin
                if (IR[15:11] == 5'b01100 || IR[15:11] == 5'b10000) bsel = 1;
                if (IR[15:11] == 5'b10111 || IR[15:11] == 5'b11000 ||
                    IR[15:8] == 8'h40 || IR[15:8] == 8'h57) asel = 1;
                if (IR[15:8] == 8'h40 || IR[15:8] == 8'h57) ALUop = 0;
                loadc = 1;
                loads = (IR[15:11] == 5'b10101);
            end
            WRITEBACK: begin writenum = IR[7:5]; vsel = 2'b11; write = 1; end
            MEM_READ: begin writenum = IR[7:5]; vsel = 2'b00; write = 1; end
            default: begin end
        endcase
    end

    always_comb begin
        mem_addr = PC; mem_wdata = store_data; mem_we = 0;
        if (state == MEM_READ || state == MEM_WRITE) mem_addr = out[7:0];
        if (state == MEM_WRITE) mem_we = 1;
    end

    always_ff @(posedge clk) begin
        if (reset) begin state <= FETCH; PC <= 0; IR <= 0; end
        else case (state)
            FETCH: begin IR <= mem_rdata; PC <= PC + 1'b1; state <= DECODE; end
            DECODE: begin
                if (IR[15:11] == 5'b11100) state <= HALT_STATE;
                else if (IR[15:11] == 5'b11010) state <= FETCH;
                else if (IR[15:11] == 5'b01100 || IR[15:11] == 5'b10000 ||
                         IR[15:11] == 5'b10100 || IR[15:11] == 5'b10101 ||
                         IR[15:11] == 5'b10110) state <= GET_A;
                else if (IR[15:11] == 5'b10111 || IR[15:11] == 5'b11000 ||
                         IR[15:8] == 8'h40 || IR[15:8] == 8'h57) state <= GET_B;
                else if (IR[15:8] == 8'h5F) begin
                    PC <= PC + $signed(IR[7:0]); state <= FETCH;
                end else if (IR[15:8] >= 8'h20 && IR[15:8] <= 8'h24) begin
                    if (branch_taken) PC <= PC + $signed(IR[7:0]);
                    state <= FETCH;
                end else state <= FETCH;
            end
            GET_A: if (IR[15:11] == 5'b01100) state <= EXECUTE; else state <= GET_B;
            GET_B: state <= EXECUTE;
            EXECUTE: begin
                if (IR[15:11] == 5'b01100) state <= MEM_READ;
                else if (IR[15:11] == 5'b10000) state <= MEM_WRITE;
                else if (IR[15:8] == 8'h40 || IR[15:8] == 8'h57) state <= BRANCH_REG;
                else if (IR[15:11] == 5'b10101) state <= FETCH;
                else state <= WRITEBACK;
            end
            WRITEBACK, MEM_READ, MEM_WRITE: state <= FETCH;
            BRANCH_REG: begin PC <= out[7:0]; state <= FETCH; end
            default: state <= HALT_STATE;
        endcase
    end
endmodule
