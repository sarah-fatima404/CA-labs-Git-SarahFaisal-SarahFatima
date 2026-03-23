`timescale 1ns / 1ps

module leds(
    input clk,
    input rst,
    input [31:0] writeData,   
    input writeEnable,         
    input readEnable,          
    input [29:0] memAddress,   

    output reg [31:0] readData = 32'b0, 
    output reg [15:0] leds    
);

    integer i;
    reg [7:0] ledBytes [3:0]; 

    // Initialize LEDs
    initial begin
        leds = 16'b0;
        for (i = 0; i < 4; i = i + 1)
            ledBytes[i] = 8'b0;
        readData = 32'b0;
    end

    // Handle writes
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            leds <= 16'b0;
            readData <= 32'b0;
            for (i = 0; i < 4; i = i + 1)
                ledBytes[i] <= 8'b0;
        end else if (writeEnable) begin
            leds <= writeData[15:0];       // lower 16 bits to LEDs
            // Optional internal storage
            ledBytes[0] <= writeData[7:0];
            ledBytes[1] <= writeData[15:8];
            ledBytes[2] <= writeData[23:16];
            ledBytes[3] <= writeData[31:24];
        end
    end

    // Optional readback
    always @(*) begin
        if (readEnable)
            readData = {ledBytes[3], ledBytes[2], ledBytes[1], ledBytes[0]};
        else
            readData = 32'b0;
    end

endmodule
