module datapath (
	clk,
	reset,
	Adr,
	WriteData,
	ReadData,
	Instr,
	ALUFlags,
	PCWrite,
	RegWrite,
	IRWrite,
	AdrSrc,
	RegSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	ImmSrc,
	ALUControl
);
	input wire clk;
	input wire reset;
	output wire [31:0] Adr;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	output wire [31:0] Instr;
	output wire [3:0] ALUFlags;
	input wire PCWrite;
	input wire RegWrite;
	input wire IRWrite;
	input wire AdrSrc;
	input wire [1:0] RegSrc;
	input wire [1:0] ALUSrcA;
	input wire [1:0] ALUSrcB;
	input wire [1:0] ResultSrc;
	input wire [1:0] ImmSrc;
	input wire [1:0] ALUControl;
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

	// Your datapath hardware goes below. Instantiate each of the 
	// submodules that you need. Remember that you can reuse hardware
	// from previous labs. Be sure to give your instantiated modules 
	// applicable names such as pcreg (PC register), adrmux 
	// (Address Mux), etc. so that your code is easier to understand.

flopenr #(32) pcreg(clk, reset, PCWrite, Result, PC);
    flopenr #(32) ir(clk, reset, IRWrite, ReadData, InstrReg);
    flopr   #(32) regA(clk, reset, RD1, A);
    flopr   #(32) regWriteData(clk, reset, RD2, WriteData);
    flopr   #(32) regALUOut(clk, reset, ALUResult, ALUOut);
endmodule

// ADD CODE BELOW
// Add needed building blocks below (i.e., parameterizable muxes, 
// registers, etc.). Remember, you can reuse code from previous labs.
// We've also provided a parameterizable 3:1 mux below for your 
// convenience.
assign Instr = InstrReg;

    // Banco de registros
    assign RA1 = (RegSrc[0]) ? 4'b1111 : Instr[19:16]; // Rn or R15
    assign RA2 = (RegSrc[1]) ? Instr[15:12] : Instr[3:0]; // Rd or Rm

    regfile rf (
        .clk(clk),
        .we3(RegWrite),
        .ra1(RA1),
        .ra2(RA2),
        .wa3(Instr[15:12]),
        .wd3(Result),
        .rd1(RD1),
        .rd2(RD2)
    );

    // Extensor de inmediato
    extend ext (
        .Instr(Instr),
        .ImmSrc(ImmSrc),
        .ExtImm(ExtImm)
    );

    // ALU input multiplexers
    mux3 #(32) srcamux(A, PC, 32'b0, ALUSrcA, SrcA);        // 0:A, 1:PC
    mux3 #(32) srcbmux(WriteData, ExtImm, 32'd4, ALUSrcB, SrcB); // 0:B, 1:ExtImm, 2:4

    // ALU
    alu alu (
        .a(SrcA),
        .b(SrcB),
        .alucontrol(ALUControl),
        .result(ALUResult),
        .flags(ALUFlags)
    );

    // Result mux
    mux3 #(32) resultmux(ALUResult, ALUOut, ReadData, ResultSrc, Result);

    // Address mux
    assign Adr = (AdrSrc) ? ALUOut : PC;

endmodule



module flopr #(parameter WIDTH = 8) (
    input wire clk, reset,
    input wire [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk or posedge reset)
        if (reset) q <= 0;
        else q <= d;
endmodule


module flopenr #(parameter WIDTH = 8) (
    input wire clk, reset, en,
    input wire [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk or posedge reset)
        if (reset) q <= 0;
        else if (en) q <= d;
endmodule

module flopr #(parameter WIDTH = 8) (
    input wire clk, reset,
    input wire [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk or posedge reset)
        if (reset) q <= 0;
        else q <= d;
endmodule
module flopenr #(parameter WIDTH = 8) (
    input wire clk, reset, en,
    input wire [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk or posedge reset)
        if (reset) q <= 0;
        else if (en) q <= d;
endmodule
