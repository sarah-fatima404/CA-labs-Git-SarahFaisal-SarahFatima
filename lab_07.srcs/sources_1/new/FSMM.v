module FSM(
    input              clk,
    input              rst,
    input      [15:0]  sw,
    input              Zero,
    output reg [3:0]   ALUctl,
    output reg         RegWrite,
    output reg [4:0]   rs1,
    output reg [4:0]   rs2,
    output reg [4:0]   rd,
    output reg [1:0]   ALUSrc,
    output reg [31:0]  ConstData,
    output     [3:0]   state_out,
    output reg         read_mode
);

    reg [3:0] state;
    assign state_out = state;

    reg [4:0] stored_rs1;
    reg [4:0] stored_rs2;

    localparam S_INIT      = 4'd0;
    localparam S_LOAD_A    = 4'd1;
    localparam S_LOAD_B    = 4'd2;
    localparam S_OP_SELECT = 4'd3;
    localparam S_READ      = 4'd4;
    localparam S_WRITE     = 4'd5;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= S_INIT;
            stored_rs1 <= 5'd0;
            stored_rs2 <= 5'd0;
        end
        else begin
            case (state)
                S_INIT: begin
                    if (sw == 16'b0) state <= S_LOAD_A;
                end
                S_LOAD_A: begin
                    if (sw[13] && !sw[12]) begin
                        stored_rs1 <= sw[8:4];
                        state      <= S_LOAD_B;
                    end
                end
                S_LOAD_B: begin
                    if (sw[12] && !sw[13]) begin
                        stored_rs2 <= sw[8:4];
                        state      <= S_OP_SELECT;
                    end
                end
                S_OP_SELECT: begin
                    if (sw[15])      state <= S_WRITE;
                    else if (sw[14]) state <= S_READ;
                end
                S_READ: begin
                    if (sw[15])       state <= S_WRITE;
                    else if (!sw[14]) state <= S_OP_SELECT;
                end
                S_WRITE: begin
                    if (!sw[15]) begin
                        if (sw[14]) state <= S_READ;
                        else        state <= S_OP_SELECT;
                    end
                end
                default: state <= S_INIT;
            endcase
        end
    end

    always @(*) begin
        ALUctl    = 4'b0000;
        RegWrite  = 1'b0;
        rs1       = stored_rs1;
        rs2       = stored_rs2;
        rd        = 5'd0;
        ALUSrc    = 2'd0;
        ConstData = 32'd0;
        read_mode = 1'b0;

        case (state)
            S_LOAD_A: begin
                if (sw[13] && !sw[12]) begin
                    RegWrite  = 1'b1;
                    rd        = sw[8:4];
                    ALUSrc    = 2'd1;
                    ConstData = 32'h10101010;
                end
            end
            S_LOAD_B: begin
                if (sw[12] && !sw[13]) begin
                    RegWrite  = 1'b1;
                    rd        = sw[8:4];
                    ALUSrc    = 2'd1;
                    ConstData = 32'h01010101;
                end
            end
            S_OP_SELECT: begin
                ALUctl = sw[3:0];
                rd     = sw[8:4];
            end
            S_READ: begin
                ALUctl    = sw[3:0];
                rd        = sw[8:4];
                read_mode = 1'b1;
            end
            S_WRITE: begin
                ALUctl    = sw[3:0];
                rd        = sw[8:4];
                RegWrite  = 1'b1;
                ALUSrc    = 2'd0;
                read_mode = 1'b1;
            end
            default: ;
        endcase
    end

endmodule
