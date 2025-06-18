// top.v - Módulo principal del sistema ARM multicycle
// Integra el procesador 'arm' y la memoria 'mem'

module top (
    input wire clk,             // Señal de reloj
    input wire reset,           // Señal de reinicio
    output wire [31:0] WriteData, // Datos a escribir en memoria
    output wire [31:0] Adr,       // Dirección de acceso a memoria
    output wire MemWrite          // Señal de escritura a memoria
);

    // Cableado interno
    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] ReadData;

    // Instancia del procesador ARM multicycle
    // Este procesador ejecuta instrucciones incluyendo la nueva instrucción MUL
    arm arm(
        .clk(clk),
        .reset(reset),
        .MemWrite(MemWrite),
        .Adr(Adr),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );

    // Instancia de la memoria RAM compartida
    // La memoria se conecta al procesador a través de WriteData, Adr, y MemWrite
    mem mem(
        .clk(clk),
        .we(MemWrite),
        .a(Adr),
        .wd(WriteData),
        .rd(ReadData)
    );

endmodule
    