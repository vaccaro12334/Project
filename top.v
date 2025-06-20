
module top (
    input wire clk,             
    input wire reset,           
    output wire [31:0] WriteData, 
    output wire [31:0] Adr,       
    output wire MemWrite           
);


    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] ReadData;


    
    arm arm(
        .clk(clk),
        .reset(reset),
        .MemWrite(MemWrite),
        .Adr(Adr),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );


    // conecta al procesador a través de WriteData, Adr, y MemWrite
    mem mem(
        .clk(clk),
        .we(MemWrite),
        .a(Adr),
        .wd(WriteData),
        .rd(ReadData)
    );

endmodule
    
