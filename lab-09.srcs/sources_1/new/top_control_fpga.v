`timescale 1ns / 1ps

module top_control_fpga(
    input clk,
    input rst,
    input btnC,
    input [15:0] sw,
    output [15:0] led
);

    reg [1:0] state;
    reg [6:0] opcode_reg;
    reg [2:0] funct3_reg;
    reg [6:0] funct7_reg;

    wire [31:0] switch_readData;

    wire RegWrite;
    wire [1:0] ALUOp;
    wire MemRead;
    wire MemWrite;
    wire ALUSrc;
    wire MemtoReg;
    wire Branch;
    wire [3:0] ALUControl_out;

    wire [15:0] led_bus;

    reg btn_prev;
    wire btn_pulse;

    assign btn_pulse = btnC & ~btn_prev;

    // Switch interface
    switches sw_if (
        .clk(clk),
        .rst(rst),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(1'b1),
        .memAddress(30'b0),
        .sw(sw),
        .readData(switch_readData),
        .leds()
    );

    // Button edge detection
    always @(posedge clk or posedge rst) begin
        if (rst)
            btn_prev <= 1'b0;
        else
            btn_prev <= btnC;
    end

    // FSM for loading opcode, funct3, funct7
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= 2'b00;
            opcode_reg <= 7'b0;
            funct3_reg <= 3'b0;
            funct7_reg <= 7'b0;
        end
        else if (btn_pulse) begin
            case (state)
                2'b00: begin
                    opcode_reg <= switch_readData[6:0];
                    state <= 2'b01;
                end
                2'b01: begin
                    funct3_reg <= switch_readData[2:0];
                    state <= 2'b10;
                end
                2'b10: begin
                    funct7_reg <= switch_readData[6:0];
                    state <= 2'b11;
                end
                2'b11: begin
                    state <= 2'b11;  // stay here to observe outputs
                end
            endcase
        end
    end

    // Main Control
    MainControl mc (
        .opcode(opcode_reg),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .Branch(Branch)
    );

    // ALU Control (with opcode input)
    ALUControl alu_ctrl (
        .opcode(opcode_reg),
        .ALUOp(ALUOp),
        .funct3(funct3_reg),
        .funct7(funct7_reg),
        .ALUControl(ALUControl_out)
    );

    /*
    LED Mapping
    LED0 = RegWrite
    LED1 = ALUSrc
    LED2 = MemRead
    LED3 = MemWrite
    LED4 = MemtoReg
    LED5 = Branch
    LED6 = ALUOp[1]
    LED7 = ALUOp[0]
    LED8-11 = ALUControl_out (4 bits)
    */

//    assign led_bus = {
//        4'b0000,                    // Upper 4 bits unused
//        ALUControl_out,             // LED8-11: ALUControl
//        ALUOp[0],                   // LED7: ALUOp[0]
//        ALUOp[1],                   // LED6: ALUOp[1]
//        Branch,                     // LED5: Branch
//        MemtoReg,                   // LED4: MemtoReg
//        MemWrite,                   // LED3: MemWrite
//        MemRead,                    // LED2: MemRead
//        ALUSrc,                     // LED1: ALUSrc
//        RegWrite                    // LED0: RegWrite
//    };

//    // LED interface
//    leds led_if (
//        .clk(clk),
//        .rst(rst),
//        .btns(16'b0),
//        .writeData({16'b0, led_bus}),
//        .writeEnable(1'b1),
//        .readEnable(1'b0),
//        .memAddress(30'b0),
//        .display_value(4'b0000),
//        .readData(),
//        .led_out(led)
//    );
    assign led[15:12] = ALUControl_out; // ALU control (4 bits)
    assign led[11]    = ALUOp[1];
    assign led[10]    = ALUOp[0];
    assign led[9]     = Branch;
    assign led[8]     = MemtoReg;
    assign led[7]     = MemWrite;
    assign led[6]     = MemRead;
    assign led[5]     = ALUSrc;
    assign led[4]     = RegWrite;
    assign led[3:2]   = 2'b00;          // unused
    assign led[1:0]   = state;          // FSM state

endmodule