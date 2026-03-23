`timescale 1ns/1ps

module ALU_tb;

// Inputs
reg [31:0] A, B;
reg [3:0] ALUctl;

// Outputs
wire [31:0] ALUout;
wire Zero;

// Instantiate the ALU
ALU uut (
    .ALUctl(ALUctl),
    .A(A),
    .B(B),
    .ALUout(ALUout),
    .Zero(Zero)
);

initial begin

    // Initialize
    A = 0; 
    B = 0; 
    ALUctl = 0;
    #10;

    // -------------------------
    // AND
    A = 32'd2; B = 32'd3; ALUctl = 4'b0000; #10;

    // OR
    ALUctl = 4'b0001; #10;

    // ADD
    ALUctl = 4'b0010; #10;

    // SUB
    A = 32'd3; B = 32'd2; ALUctl = 4'b0110; #10;

    // SLT
    A = 32'd2; B = 32'd3; ALUctl = 4'b0111; #10;

    // SLT
    A = 32'd3; B = 32'd2; #10;

    // NOR
    A = 32'd2; B = 32'd3; ALUctl = 4'b1100; #10;

    // XOR
    ALUctl = 4'b1010; #10;

    // SLL Tests
    A = 32'd2; B = 32'd1; ALUctl = 4'b1000; #10;

    A = 32'd3; B = 32'd2; #10;

    // SRL Tests
    A = 32'd8; B = 32'd1; ALUctl = 4'b1001; #10;

    A = 32'd16; B = 32'd2; #10;

    // Zero Flag Test (4 - 4 = 0)
    A = 32'd2; B = 32'd2; ALUctl = 4'b0110; #10;

    // DEFAULT test
    A = 32'd10; B = 32'd5; ALUctl = 4'b1111; #10;

    $stop;   
end

endmodule
