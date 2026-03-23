`timescale 1ns / 1ps

module AddressDecoder(
    input clk,
    input rst,
    input [31:0] address,
    input readEnable,
    input writeEnable,
    input [31:0] writeData,
    input [15:0] switches_in,
    output [31:0] readData,
    output [15:0] leds_out
    );

    wire [31:0] memReadData;
    wire [31:0] switchReadData;

    wire DataMemSelect = (address[9:8] == 2'b00);
    wire LEDSelect = (address[9:8] == 2'b01);
    wire SwitchSelect = (address[9:8] == 2'b10);

    wire DataMemWrite = writeEnable & DataMemSelect;
    wire LEDWrite = writeEnable & LEDSelect;
    wire SwitchRead = readEnable & SwitchSelect;

    DataMemory dm_inst (
        .clk(clk),
        .MemWrite(DataMemWrite),
        .MemRead(readEnable & DataMemSelect),
        .address(address[8:0]),
        .write_data(writeData),
        .read_data(memReadData)
    );

    leds led_inst (
        .clk(clk),
        .rst(rst),
        .btns(16'b0),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(SwitchRead),
        .memAddress(address[31:2]),
        .switches(switches_in),
        .readData(switchReadData)
    );

    switches sw_inst (
        .clk(clk),
        .rst(rst),
        .writeData(writeData),
        .writeEnable(LEDWrite),
        .readEnable(1'b0),
        .memAddress(address[31:2]),
        .readData(),
        .leds(leds_out)
    );

    assign readData = (DataMemSelect) ? memReadData :
                      (SwitchSelect) ? switchReadData :
                      32'h00000000;

endmodule