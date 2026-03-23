`timescale 1ns / 1ps

module RegisterFile (
    input              clk,
    input              rst,
    input              RegWrite,
    input      [4:0]   rs1,
    input      [4:0]   rs2,
    input      [4:0]   rd,
    input      [31:0]  WriteData,
    output     [31:0]  ReadData1,
    output     [31:0]  ReadData2,
    output     [31:0]  RdData
);
    reg [31:0] regs [31:0];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end
        else if (RegWrite && (rd != 5'd0)) begin
            regs[rd] <= WriteData;
        end
    end

    assign ReadData1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
    assign ReadData2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];
    assign RdData    = (rd  == 5'd0) ? 32'b0 : regs[rd];
endmodule
