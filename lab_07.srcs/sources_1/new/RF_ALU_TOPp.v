`timescale 1ns / 1ps


module RF_ALU_TOP(
    input clk,
    input rst,
    input [15:0] sw,
    output [15:0] LED,
    output [3:0] an,
    output [6:0] seg
);

    wire [3:0] ALUctl;
    wire [31:0] ALUout;
    wire Zero;
    wire [31:0] ReadData1, ReadData2, RdData;
    wire RegWrite;
    wire [4:0] rs1, rs2, rd;
    wire [1:0] ALUSrc;
    wire [31:0] ConstData;
    wire [3:0] fsm_state;
    wire read_mode;

    wire [31:0] WriteData;
    assign WriteData = (ALUSrc == 1) ? ConstData : ALUout;

    // Display Mux
    wire [31:0] display_value;
    assign display_value = read_mode ? RdData : ALUout;

    assign LED[15:12] = fsm_state;
    assign LED[11]    = Zero;                    // Map Zero flag to LED 11
    assign LED[10:0]  = display_value[10:0];     // Bottom 11 LEDs show ALU result

    FSM fsm_inst(
        .clk(clk), .rst(rst), .sw(sw), .Zero(Zero),
        .ALUctl(ALUctl), .RegWrite(RegWrite),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .ALUSrc(ALUSrc), .ConstData(ConstData),
        .state_out(fsm_state), .read_mode(read_mode)
    );

    RegisterFile rf_inst(
        .clk(clk), .rst(rst), .RegWrite(RegWrite),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1), .ReadData2(ReadData2),
        .RdData(RdData)
    );

    ALU alu_inst(
        .ALUctl(ALUctl), .A(ReadData1), .B(ReadData2),
        .ALUout(ALUout), .Zero(Zero)
    );

    sevenseg_basys3 sseg_inst(
        .clk(clk), .rst(rst),
        .value(display_value[15:0]),
        .seg(seg), .an(an)
    );

endmodule