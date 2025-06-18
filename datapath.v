module datapath (
    input wire clk,
    input wire reset,
    output wire [31:0] Adr,
    output wire [31:0] WriteData,
    input wire [31:0] ReadData,
    output wire [31:0] Instr,
    output wire [3:0] ALUFlags,
    input wire PCWrite,
    input wire RegWrite,
    input wire IRWrite,
    input wire AdrSrc,
    input wire [1:0] RegSrc,
    input wire [1:0] ALUSrcA,
    input wire [1:0] ALUSrcB,
    input wire [1:0] ResultSrc,
    input wire [1:0] ImmSrc,
    input wire [1:0] ALUControl
);

    wire [31:0] PCNext;
    wire [31:0] PC;
    wire [31:0] ExtImm;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] Result;
    wire [31:0] Data;
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [31:0] A;
    wire [31:0] ALUResult;
    wire [31:0] ALUOut;
    wire [3:0] RA1;
    wire [3:0] RA2;
    wire [31:0] InstrReg;

     flopenr #(32) pcreg(
        .clk(clk),
        .reset(reset),
        .en(PCWrite),
        .d(PCNext),
        .q(PC)
    );

     flopenr #(32) instrreg(
        .clk(clk),
        .reset(reset),
        .en(IRWrite),
        .d(ReadData),
        .q(InstrReg)
    );

    assign Instr = InstrReg;

     mux2 #(4) ra1mux(
        .d0(InstrReg[19:16]),
        .d1(4'b1111),
        .s(RegSrc[0]),
        .y(RA1)
    );

    mux2 #(4) ra2mux(
        .d0(InstrReg[3:0]),
        .d1(InstrReg[15:12]),
        .s(RegSrc[1]),
        .y(RA2)
    );

     regfile rf(
        .clk(clk),
        .we3(RegWrite),
        .ra1(RA1),
        .ra2(RA2),
        .wa3(InstrReg[15:12]),
        .wd3(Result),
	    .r15(PC + 8),   
        .rd1(RD1),
        .rd2(RD2)
    );

     flopr #(32) regA(clk, reset, RD1, A);
    flopr #(32) regWD(clk, reset, RD2, WriteData);

     extend ext(
        .Instr(InstrReg[23:0]),
        .ImmSrc(ImmSrc),
        .ExtImm(ExtImm)
    );

     mux3 #(32) srcamux(
        .d0(PC),
        .d1(A),
        .d2(32'b0),
        .s(ALUSrcA),
        .y(SrcA)
    );

     mux3 #(32) srcbmux(
        .d0(WriteData),
        .d1(ExtImm),
        .d2(32'd4),
        .s(ALUSrcB),
        .y(SrcB)
    );

     alu alu(
        .a(SrcA),
        .b(SrcB),
        .alucontrol(ALUControl),
        .result(ALUResult),
        .flags(ALUFlags)
    );

     flopr #(32) regALUOut(clk, reset, ALUResult, ALUOut);

     mux3 #(32) resultmux(
        .d0(ALUResult),
        .d1(ALUOut),
        .d2(ReadData),
        .s(ResultSrc),
        .y(Result)
    );

     assign Adr = (AdrSrc) ? ALUOut : PC;

     assign PCNext = Result;

endmodule
