`timescale 1ns / 1ps
module switches(
    input clk,
    input rst,
    input readEnable,         
    input [3:0] phySW,   
   
    output reg [3:0] ALUctl   
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALUctl <= 4'b0000;
        end else if (readEnable) begin
            ALUctl <= phySW; 
        end
    end
endmodule