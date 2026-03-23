module ALU(
    input  [3:0] ALUctl,
    input  [31:0] A, B,
    output reg [31:0] ALUout,
    output Zero
);

assign Zero = (ALUout == 0);

always @(*) begin
    case (ALUctl)
        4'b0000: ALUout = A & B;
        4'b0001: ALUout = A | B;
        4'b0010: ALUout = A + B;
        4'b0110: ALUout = A - B;
        4'b0111: ALUout = (A < B) ? 32'd1 : 32'd0;
        4'b1100: ALUout = ~(A | B);
        4'b1000: ALUout = A << B;
        4'b1001: ALUout = A >> B;
        4'b1010: ALUout = A ^ B; //XOR
        default: ALUout = 32'd0; //DEFAULT: 0
    endcase
end

endmodule
 