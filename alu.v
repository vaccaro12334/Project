module alu(
    input wire [31:0] a, b,
    input wire [2:0] alucontrol,
    output reg [31:0] result,
    output wire zero
);

    assign zero = (result == 0);

    always @(*) begin
        case (alucontrol)
            3'b000: result = a & b;       // AND
            3'b001: result = a | b;       // OR
            3'b010: result = a + b;       // ADD
            3'b110: result = a - b;       // SUB
            3'b111: result = (a < b) ? 1 : 0; // SLT
            3'b011: result = a * b;       // MUL
            default: result = 0;
        endcase
    end
endmodule
