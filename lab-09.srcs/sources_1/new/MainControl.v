`timescale 1ns / 1ps

module MainControl(
    input  [6:0] opcode,
    output reg RegWrite,
    output reg [1:0] ALUOp,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg MemtoReg,
    output reg Branch
);

always @(*) begin
    // Safe defaults
    RegWrite = 1'b0;
    ALUOp    = 2'b00;
    MemRead  = 1'b0;
    MemWrite = 1'b0;
    ALUSrc   = 1'b0;
    MemtoReg = 1'b0;
    Branch   = 1'b0;
    
    case (opcode)
        // R-type: ADD, SUB, SLL, SRL, AND, OR, XOR
        7'b0110011: begin
            RegWrite = 1'b1;
            ALUOp    = 2'b10;
            ALUSrc   = 1'b0;
            MemtoReg = 1'b0;
        end
        
        // I-type (ALU): ADDI
        7'b0010011: begin
            RegWrite = 1'b1;
            ALUOp    = 2'b10;
            ALUSrc   = 1'b1;
            MemtoReg = 1'b0;
        end
        
        // Load instructions: LW, LH, LB
        7'b0000011: begin
            RegWrite = 1'b1;
            ALUOp    = 2'b00;
            MemRead  = 1'b1;
            ALUSrc   = 1'b1;
            MemtoReg = 1'b1;
        end
        
        // Store instructions: SW, SH, SB
        7'b0100011: begin
            RegWrite = 1'b0;
            ALUOp    = 2'b00;
            MemWrite = 1'b1;
            ALUSrc   = 1'b1;
        end
        
        // Branch instruction: BEQ
        7'b1100011: begin
            RegWrite = 1'b0;
            ALUOp    = 2'b01;
            Branch   = 1'b1;
            ALUSrc   = 1'b0;
        end
        
        default: begin
            // Keep defaults for unsupported instructions
        end
    endcase
   end
endmodule 