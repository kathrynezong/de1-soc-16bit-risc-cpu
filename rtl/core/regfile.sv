// Extended from lab7/REGFILE.sv: the original single-read register file is
// retained, with a synchronous reset added for deterministic CPU startup.
module regfile (
    input logic [15:0] data_in, input logic [2:0] writenum,
    input logic write, input logic [2:0] readnum,
    input logic clk, input logic reset, output logic [15:0] data_out
);
    logic [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    always_comb begin
        case (readnum)
            3'd0: data_out = R0; 3'd1: data_out = R1;
            3'd2: data_out = R2; 3'd3: data_out = R3;
            3'd4: data_out = R4; 3'd5: data_out = R5;
            3'd6: data_out = R6; default: data_out = R7;
        endcase
    end
    always_ff @(posedge clk) begin
        if (reset) begin
            R0 <= 0; R1 <= 0; R2 <= 0; R3 <= 0;
            R4 <= 0; R5 <= 0; R6 <= 0; R7 <= 0;
        end else if (write) begin
            case (writenum)
                3'd0: R0 <= data_in; 3'd1: R1 <= data_in;
                3'd2: R2 <= data_in; 3'd3: R3 <= data_in;
                3'd4: R4 <= data_in; 3'd5: R5 <= data_in;
                3'd6: R6 <= data_in; 3'd7: R7 <= data_in;
            endcase
        end
    end
endmodule
