module decode (
	input wire clk,
	input wire reset,
	input wire [1:0] Op,
	input wire [5:0] Funct,
	input wire [3:0] Rd,
	output wire [1:0] FlagW,
	output wire PCS,
	output wire NextPC,
	output wire RegW,
	output wire MemW,
	output wire IRWrite,
	output wire AdrSrc,
	output wire [1:0] ResultSrc,
	output wire [1:0] ALUSrcA,
	output wire [1:0] ALUSrcB,
	output wire [1:0] ImmSrc,
	output wire [1:0] RegSrc,
	output wire [1:0] ALUControl
);

	wire Branch;
	wire ALUOp;
	wire [3:0] Cond;      // Condición de la instrucción
	wire [3:0] Flags;     // Flags actuales (asumimos disponibles)

	// --- FSM Principal ---
	mainfsm fsm(
		.clk(clk),
		.reset(reset),
		.Op(Op),
		.Funct(Funct),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ResultSrc(ResultSrc),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.Branch(Branch),
		.ALUOp(ALUOp)
	);

	// --- ALU Decoder ---
	aludec aludecoder(
		.Funct(Funct),
		.ALUOp(ALUOp),
		.ALUControl(ALUControl)
	);

	// --- PC Logic ---
	condlogic pclogic(
		.clk(clk),
		.reset(reset),
		.Cond(Cond),         // normalmente viene de Instr[31:28]
		.Flags(Flags),       // normalmente viene de ALUFlags
		.PCS(PCS),
		.FlagW(FlagW),
		.Branch(Branch),
		.RegW(RegW)
	);

	// --- Instruction Decoder ---
	assign ImmSrc = Op;

	// RegSrc = {RnIsPC, RdIsPC}
	assign RegSrc = {Rd == 4'b1111, Rd == 4'b1111};
endmodule

module aludec(
    input wire [5:0] Funct,
    input wire ALUOp,
    output reg [1:0] ALUControl
);
    always @(*) begin
        if (!ALUOp)
            ALUControl = 2'b10; // Suma (por defecto para LDR/STR)
        else begin
            case (Funct[4:1])  // considerando bits relevantes de Funct
                4'b0100: ALUControl = 2'b10; // ADD
                4'b0010: ALUControl = 2'b11; // SUB
                4'b0000: ALUControl = 2'b00; // AND
                4'b1100: ALUControl = 2'b01; // ORR
                default: ALUControl = 2'b10; // default: ADD
            endcase
        end
    end
endmodule
