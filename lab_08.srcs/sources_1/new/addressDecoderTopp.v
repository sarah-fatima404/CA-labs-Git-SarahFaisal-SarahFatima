`timescale 1ns / 1ps

module addressDecoderTop(
    input clk,
    input rst,
    input [15:0] switches,       // Control and data input
    output [15:0] leds,          // Physical LEDs display
    output [6:0] seg,            // 7-segment display segments
    output [3:0] an              // 7-segment display anodes
    );

    // Switch mapping:
    // sw[1:0] = 01: Read from memory at address 0x00
    // sw[1:0] = 10: Write to memory at address 0x00
    // sw[15:2] = Data to write (14 bits)

    wire [1:0] control = switches[1:0];
    wire [13:0] dataIn = switches[15:2];

    reg [31:0] address;
    reg readEnable, writeEnable;
    wire [31:0] writeData;
    wire [31:0] readData;
    wire [15:0] leds_decoder;

    // Assign write data (pad 14-bit input to 32 bits)
    assign writeData = {18'b0, dataIn};

    // Control logic based on switch input
    always @(*) begin
        address = 32'h00000000;      // Default: Memory address 0
        readEnable = 1'b0;
        writeEnable = 1'b0;

        case(control)
            2'b01: begin  // Read from memory
                address = 32'h00000000;  // address[9:8] = 00 (Memory)
                readEnable = 1'b1;
                writeEnable = 1'b0;
            end
            
            2'b10: begin  // Write to memory
                address = 32'h00000000;  // address[9:8] = 00 (Memory)
                readEnable = 1'b0;
                writeEnable = 1'b1;
            end
            
            default: begin
                address = 32'h00000000;
                readEnable = 1'b0;
                writeEnable = 1'b0;
            end
        endcase
    end

    // Instantiate the Address Decoder
    AddressDecoder DUT (
        .clk(clk),
        .rst(rst),
        .address(address),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .writeData(writeData),
        .switches_in(switches),
        .readData(readData),
        .leds_out(leds_decoder)
    );

    // Route output to physical LEDs when reading from memory
    // Otherwise, show whatever was last written to LED address
    assign leds = (control == 2'b01) ? readData[15:0] : leds_decoder;

    // Instantiate the 7-Segment Display Controller
    // Display lower 16 bits of readData (memory read results)
    sevenseg_basys3 Display (
        .clk(clk),
        .rst(rst),
        .value(readData[15:0]),
        .seg(seg),
        .an(an)
    );

endmodule