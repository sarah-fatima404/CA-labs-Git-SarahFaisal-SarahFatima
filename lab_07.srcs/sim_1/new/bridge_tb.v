`timescale 1ns/1ps

module bridge_tb;
    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] LED;
    wire [6:0] seg;
    wire [3:0] an;

    RF_ALU_TOP dut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .LED(LED),
        .seg(seg),
        .an(an)
    );

    integer code;
    reg [8*128:1] cmd;
    
    initial begin
        clk = 0;
        rst = 0;
        sw = 0;
        
        // Endless loop parsing commands from standard input
        forever begin
            code = $fscanf(32'h8000_0000, "%s", cmd);
            if (code <= 0) begin
                $finish;
            end
            
            if (cmd == "SET_SW") begin
                code = $fscanf(32'h8000_0000, "%b", sw);
                #1; // propagate combinational logic
                $display("STATE led=%b seg=%b an=%b", LED, seg, an);
                $fflush(32'h8000_0001); // flush stdout
            end else if (cmd == "SET_RST") begin
                code = $fscanf(32'h8000_0000, "%b", rst);
                #1;
                $display("STATE led=%b seg=%b an=%b", LED, seg, an);
                $fflush(32'h8000_0001);
            end else if (cmd == "TICK") begin
                clk = 1;
                #5;
                clk = 0;
                #5;
                $display("STATE led=%b seg=%b an=%b", LED, seg, an);
                $fflush(32'h8000_0001);
            end else if (cmd == "QUIT") begin
                $finish;
            end
        end
    end
endmodule

