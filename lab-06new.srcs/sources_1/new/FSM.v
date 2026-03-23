module FSM(
    input clk,
    input rst,
    output reg [3:0] ALUctl
);

    
    reg [3:0] state;

    
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= 4'd0;
        else if (state == 4'd8)
            state <= 4'd0;      // Loop
        else
            state <= state + 1;
    end
//moore fsm
    always @(*) begin
        case (state)
            4'd0: ALUctl = 4'b0000;  // AND
            4'd1: ALUctl = 4'b0001;  // OR
            4'd2: ALUctl = 4'b0010;  // ADD
            4'd3: ALUctl = 4'b0110;  // SUB
            4'd4: ALUctl = 4'b0111;  // SLT
            4'd5: ALUctl = 4'b1100;  // NOR
            4'd6: ALUctl = 4'b1000;  // SLL
            4'd7: ALUctl = 4'b1001;  // SRL
            4'd8: ALUctl = 4'b1010;  // XOR
            default: ALUctl = 4'b0000;
        endcase
    end

endmodule
