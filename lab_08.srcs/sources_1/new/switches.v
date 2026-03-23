module switches(
input clk,
input rst,
input [31:0] writeData,
input writeEnable,
input readEnable,
input [29:0] memAddress,
output reg [31:0] readData = 0, // not to be read
output reg [15:0] leds
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            leds <= 0;
        else if (writeEnable)
            leds <= writeData[15:0];
    end
endmodule