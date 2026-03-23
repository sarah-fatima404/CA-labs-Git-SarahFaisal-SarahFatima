`timescale 1ns / 1ps

module sevenseg_basys3 (
    input clk,
    input rst,
    input [15:0] value,
    output reg [6:0] seg,
    output reg [3:0] an
);

    // Refresh counter - upper 2 bits cycle through 4 digits
    reg [19:0] refresh_counter;
    always @(posedge clk or posedge rst)
        if (rst)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;

    wire [1:0] active_digit = refresh_counter[19:18];

    // Select which 4-bit hex nibble to display
    reg [3:0] digit;
    always @(*) begin
        case (active_digit)
            2'b00: begin an = 4'b1110; digit = value[3:0];   end  // Rightmost digit
            2'b01: begin an = 4'b1101; digit = value[7:4];   end
            2'b10: begin an = 4'b1011; digit = value[11:8];  end
            2'b11: begin an = 4'b0111; digit = value[15:12]; end  // Leftmost digit
            default: begin an = 4'b1111; digit = 4'b0000; end
        endcase
    end

    // 7-segment hex decoder (active low, common anode)
    always @(*) begin
        case (digit)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end

endmodule
