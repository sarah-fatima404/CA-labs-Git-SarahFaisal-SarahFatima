`timescale 1ns / 1ps

module debouncer(
    input clk,       // FPGA clock
    input rst,       // reset
    input pbin,      // raw push button or switch input
    output reg pbout // debounced output
);

    reg [19:0] counter;  // 20-bit counter for debounce timing
    reg sync_0, sync_1;  // synchronize input

    // Step 1: Synchronize input to clock
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_0 <= 0;
            sync_1 <= 0;
        end else begin
            sync_0 <= pbin;
            sync_1 <= sync_0;
        end
    end

    // Step 2: Debounce logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pbout <= 0;
            counter <= 0;
        end else begin
            if (sync_1 == pbout) begin
                counter <= 0; // input stable, reset counter
            end else begin
                counter <= counter + 1;
                if (counter == 20'hFFFFF) begin
                    pbout <= sync_1;  // input stable long enough ? update output
                    counter <= 0;
                end
            end
        end
    end

endmodule