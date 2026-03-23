`timescale 1ns / 1ps

module leds(
    input clk,
    input rst,
    input [15:0] btns,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    input [3:0] display_value,
    output reg [31:0] readData,
    output reg [15:0] led_out
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        led_out <= 16'b0;
        readData <= 32'b0;
    end
    else begin
        if (writeEnable)
            led_out <= writeData[15:0];
        
        readData <= 32'b0; // always return 0 for reads
    end
end

endmodule