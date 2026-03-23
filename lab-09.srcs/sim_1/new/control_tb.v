`timescale 1ns / 1ps
module control_tb;
reg  [6:0] opcode;
reg  [2:0] funct3;
reg  [6:0] funct7;
wire RegWrite;
wire [1:0] ALUOp;
wire MemRead;
wire MemWrite;
wire ALUSrc;
wire MemtoReg;
wire Branch;
wire [3:0] ALUControl;
// Main Control
MainControl mc (
    .opcode(opcode),
    .RegWrite(RegWrite),
    .ALUOp(ALUOp),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .MemtoReg(MemtoReg),
    .Branch(Branch));
// ALU Control
ALUControl alu_ctrl (
    .opcode(opcode),
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7(funct7),
    .ALUControl(ALUControl));
initial begin
// ADD
opcode = 7'b0110011;
funct3 = 3'b000;
funct7 = 7'b0000000;
#10;
// ADDI
opcode = 7'b0010011;
funct3 = 3'b000;
funct7 = 7'b0000000;
#10;

// SUB
opcode = 7'b0110011;
funct3 = 3'b000;
funct7 = 7'b0100000;
#10;

// SLL
opcode = 7'b0110011;
funct3 = 3'b001;
funct7 = 7'b0000000;
#10;

// SRL
opcode = 7'b0110011;
funct3 = 3'b101;
funct7 = 7'b0000000;
#10;

// AND
opcode = 7'b0110011;
funct3 = 3'b111;
funct7 = 7'b0000000;
#10;

// OR
opcode = 7'b0110011;
funct3 = 3'b110;
funct7 = 7'b0000000;
#10;

// XOR
opcode = 7'b0110011;
funct3 = 3'b100;
funct7 = 7'b0000000;
#10;


// LW
opcode = 7'b0000011;
funct3 = 3'b010;
funct7 = 7'b0000000;
#10;

// LH
opcode = 7'b0000011;
funct3 = 3'b001;
funct7 = 7'b0000000;
#10;

// LB
opcode = 7'b0000011;
funct3 = 3'b000;
funct7 = 7'b0000000;
#10;


// SW
opcode = 7'b0100011;
funct3 = 3'b010;
funct7 = 7'b0000000;
#10;

// SH
opcode = 7'b0100011;
funct3 = 3'b001;
funct7 = 7'b0000000;
#10;

// SB
opcode = 7'b0100011;
funct3 = 3'b000;
funct7 = 7'b0000000;
#10;


// BEQ
opcode = 7'b1100011;
funct3 = 3'b000;
funct7 = 7'b0000000;
#10;


#10;

end

endmodule