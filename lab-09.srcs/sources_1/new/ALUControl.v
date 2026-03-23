`timescale 1ns / 1ps

module ALUControl(
    input [6:0] opcode,
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] ALUControl
);

always @(*) begin
    // Default value
    ALUControl = 4'b0010; // ADD
    
    case(ALUOp)
        // Load/Store instructions (LW, LH, LB, SW, SH, SB)
        2'b00: begin
            ALUControl = 4'b0010; // ADD for address calculation
        end
        
        // Branch instructions (BEQ)
        2'b01: begin
            ALUControl = 4'b0110; // SUB for comparison
        end
        
        // R-type and I-type ALU instructions
        2'b10: begin
            case(funct3)
                3'b000: begin
                    // Check for SUB (R-type with funct7=0100000)
                    if (opcode == 7'b0110011 && funct7 == 7'b0100000)
                        ALUControl = 4'b0110; // SUB
                    else
                        ALUControl = 4'b0010; // ADD / ADDI
                end
                3'b001: ALUControl = 4'b0100; // SLL
                3'b010: ALUControl = 4'b0010; // SLT (default to ADD if not implemented)
                3'b011: ALUControl = 4'b0010; // SLTU (default to ADD if not implemented)
                3'b100: ALUControl = 4'b0011; // XOR
                3'b101: ALUControl = 4'b0101; // SRL
                3'b110: ALUControl = 4'b0001; // OR
                3'b111: ALUControl = 4'b0000; // AND
                default: ALUControl = 4'b0010;
            endcase
        end
        
        default: ALUControl = 4'b0010;
    endcase
end

endmodule