`timescale 1ns / 1ps

module ALU_TOP(

    input [3:0] switches,   // 4 switches for ALUctl
    output [15:0] LED       // 16 LEDs: lower 15 for ALUout, last for Zero
);

    wire [31:0] ALUout;
    wire Zero;

    // Fixed operands
wire [31:0] A = 32'h00000002; // decimal 2
wire [31:0] B = 32'h00000003; // decimal 3

    // ALU instance
    ALU alu_inst (
        .ALUctl(switches),   // ALU operation from switches
        .A(A),
        .B(B),
        .ALUout(ALUout),
        .Zero(Zero)
    );

    // Map ALU outputs to LEDs
    assign LED[14:0] = ALUout[14:0]; // lower 15 bits of ALUout
    assign LED[15]   = Zero;         // Zero flag on last LED

endmodule

