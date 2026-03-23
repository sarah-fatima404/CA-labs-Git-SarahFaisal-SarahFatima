`timescale 1ns / 1ps

module RF_ALU_FSM_tb;

    reg         clk;
    reg         rst;
    reg  [15:0] sw;
    wire [15:0] LED;
    wire [3:0]  an;
    wire [6:0]  seg;

    RF_ALU_TOP uut (
        .clk(clk), .rst(rst), .sw(sw),
        .LED(LED), .an(an), .seg(seg)
    );

    // Clock: 10ns period (5 high, 5 low)
    // Rises at: 0, 10, 20, 30, ...
    always #5 clk = ~clk;

    // Helper task: wait N clock cycles then move 2ns into high phase
    // So switch changes are clearly visible mid-cycle in waveform
    task wait_cycles(input integer n);
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge clk);
            #2; // land 2ns after rising edge = mid high phase
        end
    endtask

    initial begin
        clk = 0; rst = 1; sw = 16'h0000;
        wait_cycles(3);     // hold reset for 3 cycles
        rst = 0;

        // ==============================================
        // INIT SAFETY: FSM must stay in INIT if sw != 0
        // ==============================================
        $display("===========================================================");
        $display("  INIT safety: switches not zero -> stay in INIT");
        sw = 16'h0001;              // random switch ON
        wait_cycles(3);
        $display("  FSM_STATE = %0d (expected 0 = INIT, blocked!)", LED[15:12]);
        sw = 16'h8000;              // another random switch
        wait_cycles(2);
        $display("  FSM_STATE = %0d (expected 0 = INIT, still blocked!)", LED[15:12]);
        sw = 16'h0000;              // all OFF -> should advance
        wait_cycles(2);
        $display("  FSM_STATE = %0d (expected 1 = LOAD_A, advanced!)", LED[15:12]);

        // ==============================================
        // LOAD A: Reject when BOTH confirms ON
        // ==============================================
        $display("");
        $display("===========================================================");
        $display("  LOAD_A safety: both confirms ON -> reject");
        sw[8:4] = 5'd3;
        sw[13] = 1'b1;
        sw[12] = 1'b1;             // BOTH on! should be rejected
        wait_cycles(3);
        $display("  FSM_STATE = %0d (expected 1 = LOAD_A, rejected!)", LED[15:12]);
        $display("  x3 = 0x%08h (expected 0x00000000, NOT written)", uut.rf_inst.regs[3]);
        sw[12] = 1'b0;             // now only sw[13] = correct!
        wait_cycles(3);

        $display("  x3 = 0x%08h (expected 0x10101010)", uut.rf_inst.regs[3]);
        $display("  FSM_STATE = %0d (expected 2 = LOAD_B)", LED[15:12]);
        sw[13] = 1'b0;
        sw[8:4] = 5'd0;
        wait_cycles(2);

        // ==============================================
        // LOAD B: Reject when BOTH confirms ON
        // ==============================================
        $display("");
        $display("===========================================================");
        $display("  LOAD_B safety: both confirms ON -> reject");
        sw[8:4] = 5'd7;
        sw[13] = 1'b1;
        sw[12] = 1'b1;             // BOTH on! should be rejected
        wait_cycles(3);
        $display("  FSM_STATE = %0d (expected 2 = LOAD_B, rejected!)", LED[15:12]);
        $display("  x7 = 0x%08h (expected 0x00000000, NOT written)", uut.rf_inst.regs[7]);
        sw[13] = 1'b0;             // now only sw[12] = correct!
        wait_cycles(3);

        $display("  x7 = 0x%08h (expected 0x01010101)", uut.rf_inst.regs[7]);
        $display("  stored_rs1 = %0d (expected 3)", uut.fsm_inst.stored_rs1);
        $display("  stored_rs2 = %0d (expected 7)", uut.fsm_inst.stored_rs2);
        $display("  FSM_STATE = %0d (expected 3 = OP_SELECT)", LED[15:12]);
        sw[12] = 1'b0;
        sw[8:4] = 5'd0;
        wait_cycles(2);
        // ==============================================
        // MODE 00: Just view ALU results
        // ==============================================
        $display("");
        $display("===========================================================");
        $display("  Mode 00: ALU operations...");
        $display("===========================================================");
        sw = 16'b0;

        wait_cycles(3);
        sw[3:0] = 4'b0010;             // ADD
        wait_cycles(4);
        $display("  ADD:  0x%08h (expected 0x11111111)", uut.ALUout);

        wait_cycles(3);
        sw[3:0] = 4'b0110;             // SUB
        wait_cycles(4);
        $display("  SUB:  0x%08h (expected 0x0F0F0F0F)", uut.ALUout);

        wait_cycles(2);
        sw[3:0] = 4'b0000;             // AND
        wait_cycles(5);
        $display("  AND:  0x%08h (expected 0x00000000) Zero=%b", uut.ALUout, uut.Zero);

        wait_cycles(3);
        sw[3:0] = 4'b0001;             // OR
        wait_cycles(4);
        $display("  OR:   0x%08h (expected 0x11111111)", uut.ALUout);

        wait_cycles(2);
        sw[3:0] = 4'b1010;             // XOR
        wait_cycles(3);
        $display("  XOR:  0x%08h (expected 0x11111111)", uut.ALUout);

        wait_cycles(4);
        sw[3:0] = 4'b1000;             // SLL
        wait_cycles(3);
        $display("  SLL:  0x%08h (expected 0x20202020)", uut.ALUout);

        wait_cycles(2);
        sw[3:0] = 4'b1001;             // SRL
        wait_cycles(5);
        $display("  SRL:  0x%08h (expected 0x08080808)", uut.ALUout);

        wait_cycles(2);
        sw[3:0] = 4'b0111;             // SLT
        wait_cycles(3);
        $display("  SLT:  0x%08h (expected 0x00000000)", uut.ALUout);

        wait_cycles(2);
        sw[3:0] = 4'b1100;             // NOR
        wait_cycles(3);
        $display("  NOR:  0x%08h (expected 0x%08h)", uut.ALUout, ~(32'h10101010 | 32'h01010101));

        // ==============================================
        // MODE 10: Write ADD to x10
        // ==============================================
        $display("");
        $display("===========================================================");
        $display("  Mode 10: Write ADD to x10...");
        $display("===========================================================");
        sw = 16'b0;
        wait_cycles(3);
        sw[3:0] = 4'b0010;             // ADD
        sw[8:4] = 5'd10;               // rd = x10
        wait_cycles(3);
        sw[15] = 1'b1;                 // write!
        wait_cycles(2);
        $display("  display = 0x%08h (ALU result, read_mode=%b)", uut.display_value, uut.read_mode);
        sw[15] = 1'b0;
        wait_cycles(3);
        $display("  x10 = 0x%08h (expected 0x11111111)", uut.rf_inst.regs[10]);

        // ==============================================
        // MODE 10: Write SUB to x11
        // ==============================================
        $display("");
        $display("  Writing SUB to x11...");
        sw = 16'b0;
        wait_cycles(3);
        sw[3:0] = 4'b0110;             // SUB
        sw[8:4] = 5'd11;
        wait_cycles(2);
        sw[15] = 1'b1;
        wait_cycles(2);
        sw[15] = 1'b0;
        wait_cycles(3);
        $display("  x11 = 0x%08h (expected 0x0F0F0F0F)", uut.rf_inst.regs[11]);

        // ==============================================
        // MODE 01: Browse registers
        // ==============================================
        $display("");
        $display("===========================================================");
        $display("  Mode 01: Browsing registers...");
        $display("===========================================================");
        sw = 16'b0;
        sw[14] = 1'b1;                 // read ON

        wait_cycles(3);
        sw[8:4] = 5'd3;               // x3
        wait_cycles(4);
        $display("  x3  = 0x%08h (expected 0x10101010)", uut.display_value);

        wait_cycles(2);
        sw[8:4] = 5'd7;               // x7
        wait_cycles(3);
        $display("  x7  = 0x%08h (expected 0x01010101)", uut.display_value);

        wait_cycles(2);
        sw[8:4] = 5'd10;              // x10
        wait_cycles(4);
        $display("  x10 = 0x%08h (expected 0x11111111)", uut.display_value);

        wait_cycles(2);
        sw[8:4] = 5'd11;              // x11
        wait_cycles(3);
        $display("  x11 = 0x%08h (expected 0x0F0F0F0F)", uut.display_value);

        wait_cycles(3);
        sw[8:4] = 5'd0;               // x0
        wait_cycles(2);
        $display("  x0  = 0x%08h (expected 0x00000000)", uut.display_value);

        wait_cycles(2);
        sw[8:4] = 5'd5;               // x5 never written
        wait_cycles(3);
        $display("  x5  = 0x%08h (expected 0x00000000)", uut.display_value);

        $display("  rs1 = %0d (expected 3)", uut.fsm_inst.rs1);
        $display("  rs2 = %0d (expected 7)", uut.fsm_inst.rs2);
        sw[14] = 1'b0;

        // ==============================================
        // MODE 11: Write AND to x12 + display register
        // ==============================================
        $display("");
        $display("===========================================================");
        $display("  Mode 11: Write AND to x12 + show reg value...");
        $display("===========================================================");
        sw = 16'b0;
        wait_cycles(3);
        sw[3:0] = 4'b0000;             // AND
        sw[8:4] = 5'd12;               // rd = x12
        sw[15]  = 1'b1;
        sw[14]  = 1'b1;
        wait_cycles(3);
        $display("  read_mode = %b (expected 1)", uut.read_mode);
        $display("  display   = 0x%08h (reg value)", uut.display_value);
        sw[15] = 1'b0; sw[14] = 1'b0;
        wait_cycles(4);
        $display("  x12 = 0x%08h (expected 0x00000000)", uut.rf_inst.regs[12]);

        // ==============================================
        // x0 PROTECTION
        // ==============================================
        $display("");
        $display("===========================================================");
        $display("  x0 protection...");
        $display("===========================================================");
        sw = 16'b0;
        wait_cycles(2);
        sw[3:0] = 4'b0010;             // ADD
        sw[8:4] = 5'd0;                // x0
        sw[15]  = 1'b1;
        wait_cycles(3);
        sw[15] = 1'b0;
        wait_cycles(2);
        $display("  x0 = 0x%08h (expected 0x00000000)", uut.rf_inst.regs[0]);

        // ==============================================
        // OVERWRITE x3 (rs1 source)
        // ==============================================
        $display("");
        $display("===========================================================");
        $display("  Overwriting x3 with OR result...");
        $display("===========================================================");
        sw = 16'b0;
        sw[3:0] = 4'b0001;             // OR
        sw[8:4] = 5'd3;
        wait_cycles(3);
        sw[15] = 1'b1;
        wait_cycles(2);
        sw[15] = 1'b0;
        wait_cycles(3);
        $display("  x3 = 0x%08h (expected 0x11111111)", uut.rf_inst.regs[3]);

        sw = 16'b0;
        sw[3:0] = 4'b0010;             // ADD with new x3
        wait_cycles(3);
        $display("  ADD = 0x%08h (expected 0x12121212)", uut.ALUout);
        $display("  rs1 reads updated x3!");

        // ==============================================================
        // SYSTEMATIC TEST OF ALL 4 READ/WRITE COMBINATIONS
        // ==============================================================
        // First, write some known values to work with
        // Write XOR result to x13
        $display("");
        $display("===========================================================");
        $display("  Setup: Writing more values...");
        $display("===========================================================");
        sw = 16'b0;
        sw[3:0] = 4'b1010;             // XOR
        sw[8:4] = 5'd13;
        wait_cycles(2);
        sw[15] = 1'b1;
        wait_cycles(2);
        sw[15] = 1'b0;
        wait_cycles(2);
        $display("  x13 = 0x%08h (expected 0x12121212 XOR)", uut.rf_inst.regs[13]);

        // Write SLL result to x14
        sw = 16'b0;
        sw[3:0] = 4'b1000;             // SLL
        sw[8:4] = 5'd14;
        wait_cycles(2);
        sw[15] = 1'b1;
        wait_cycles(2);
        sw[15] = 1'b0;
        wait_cycles(2);
        $display("  x14 = 0x%08h (expected SLL)", uut.rf_inst.regs[14]);

        // Write SRL result to x15
        sw = 16'b0;
        sw[3:0] = 4'b1001;             // SRL
        sw[8:4] = 5'd15;
        wait_cycles(2);
        sw[15] = 1'b1;
        wait_cycles(2);
        sw[15] = 1'b0;
        wait_cycles(2);
        $display("  x15 = 0x%08h (expected SRL)", uut.rf_inst.regs[15]);

        // -------------------------------------------------------
        // COMBO 1: W=0, R=0 → Show ALU, no write
        // -------------------------------------------------------
        $display("");
        $display("===========================================================");
        $display("  COMBO TEST 1: W=0 R=0 → ALU result, no write");
        $display("===========================================================");
        sw = 16'b0;
        sw[3:0] = 4'b0010;             // ADD
        sw[8:4] = 5'd20;               // rd=x20 (should NOT be written)
        // sw[15]=0, sw[14]=0
        wait_cycles(4);
        $display("  display    = 0x%08h (expected ALU=0x12121212)", uut.display_value);
        $display("  read_mode  = %b (expected 0)", uut.read_mode);
        $display("  RegWrite   = %b (expected 0)", uut.RegWrite);
        $display("  x20 before = 0x%08h (expected 0x00000000)", uut.rf_inst.regs[20]);
        wait_cycles(3);
        $display("  x20 after  = 0x%08h (expected 0x00000000, not written!)", uut.rf_inst.regs[20]);

        // -------------------------------------------------------
        // COMBO 2: W=1, R=0 → Show ALU, write to register
        // -------------------------------------------------------
        $display("");
        $display("===========================================================");
        $display("  COMBO TEST 2: W=1 R=0 → ALU result + write to x20");
        $display("===========================================================");
        sw = 16'b0;
        sw[3:0] = 4'b0010;             // ADD
        sw[8:4] = 5'd20;               // rd=x20
        sw[15]  = 1'b1;                // write ON
        // sw[14]=0
        wait_cycles(2);
        $display("  display    = 0x%08h (expected ALU=0x12121212)", uut.display_value);
        $display("  read_mode  = %b (expected 0)", uut.read_mode);
        $display("  RegWrite   = %b (expected 1)", uut.RegWrite);
        wait_cycles(2);
        sw[15] = 1'b0;
        wait_cycles(2);
        $display("  x20        = 0x%08h (expected 0x12121212, written!)", uut.rf_inst.regs[20]);

        // -------------------------------------------------------
        // COMBO 3: W=0, R=1 → Show register value, no write
        // -------------------------------------------------------
        $display("");
        $display("===========================================================");
        $display("  COMBO TEST 3: W=0 R=1 → Show register, no write");
        $display("===========================================================");
        sw = 16'b0;
        sw[14]  = 1'b1;                // read ON
        // sw[15]=0

        // Browse x20 (should show what we just wrote)
        sw[8:4] = 5'd20;
        wait_cycles(3);
        $display("  display    = 0x%08h (expected reg x20=0x12121212)", uut.display_value);
        $display("  read_mode  = %b (expected 1)", uut.read_mode);
        $display("  RegWrite   = %b (expected 0)", uut.RegWrite);

        // Browse x13
        sw[8:4] = 5'd13;
        wait_cycles(3);
        $display("  display    = 0x%08h (expected reg x13=XOR)", uut.display_value);

        // Browse x10
        sw[8:4] = 5'd10;
        wait_cycles(3);
        $display("  display    = 0x%08h (expected reg x10=0x11111111)", uut.display_value);

        // Browse x0
        sw[8:4] = 5'd0;
        wait_cycles(3);
        $display("  display    = 0x%08h (expected reg x0=0x00000000)", uut.display_value);

        // Verify ALU untouched
        $display("  rs1 = %0d, rs2 = %0d (must not change)", uut.fsm_inst.rs1, uut.fsm_inst.rs2);
        $display("  ALU still = 0x%08h (correct computation)", uut.ALUout);
        sw[14] = 1'b0;

        // -------------------------------------------------------
        // COMBO 4: W=1, R=1 → Show register value + write
        // -------------------------------------------------------
        $display("");
        $display("===========================================================");
        $display("  COMBO TEST 4: W=1 R=1 → Show register + write to x21");
        $display("===========================================================");
        sw = 16'b0;
        sw[3:0] = 4'b0110;             // SUB
        sw[8:4] = 5'd21;               // rd=x21
        sw[15]  = 1'b1;                // write ON
        sw[14]  = 1'b1;                // read ON
        wait_cycles(2);
        $display("  display    = 0x%08h (expected register value)", uut.display_value);
        $display("  read_mode  = %b (expected 1)", uut.read_mode);
        $display("  RegWrite   = %b (expected 1)", uut.RegWrite);
        $display("  ALUout     = 0x%08h (ALU still correct)", uut.ALUout);
        wait_cycles(2);
        sw[15] = 1'b0; sw[14] = 1'b0;
        wait_cycles(2);
        $display("  x21        = 0x%08h (expected SUB result written!)", uut.rf_inst.regs[21]);

        // Now verify x21 by reading it back in Mode 01
        sw = 16'b0;
        sw[14] = 1'b1;
        sw[8:4] = 5'd21;
        wait_cycles(3);
        $display("  Read x21   = 0x%08h (matches write)", uut.display_value);
        sw[14] = 1'b0;

        // -------------------------------------------------------
        // FINAL REGISTER DUMP
        // -------------------------------------------------------
        $display("");
        $display("===========================================================");
        $display("  FINAL REGISTER STATE");
        $display("===========================================================");
        $display("  x0  = 0x%08h (always 0)", uut.rf_inst.regs[0]);
        $display("  x3  = 0x%08h (rs1, was A, now OR)", uut.rf_inst.regs[3]);
        $display("  x7  = 0x%08h (rs2, B)", uut.rf_inst.regs[7]);
        $display("  x10 = 0x%08h (ADD)", uut.rf_inst.regs[10]);
        $display("  x11 = 0x%08h (SUB)", uut.rf_inst.regs[11]);
        $display("  x12 = 0x%08h (AND)", uut.rf_inst.regs[12]);
        $display("  x13 = 0x%08h (XOR)", uut.rf_inst.regs[13]);
        $display("  x14 = 0x%08h (SLL)", uut.rf_inst.regs[14]);
        $display("  x15 = 0x%08h (SRL)", uut.rf_inst.regs[15]);
        $display("  x20 = 0x%08h (ADD combo2)", uut.rf_inst.regs[20]);
        $display("  x21 = 0x%08h (SUB combo4)", uut.rf_inst.regs[21]);

        // ==============================================
        $display("");
        $display("===========================================================");
        $display("  ALL TESTS COMPLETE");
        $display("===========================================================");

        wait_cycles(5);
        $finish;
    end

    initial begin
        $monitor("Time=%0t | ST=%0d | sw=%016b | ALU=0x%08h | RdData=0x%08h | RW=%b | RM=%b | Zero=%b",
                 $time, LED[15:12], sw, uut.ALUout, uut.rf_inst.RdData, uut.RegWrite, uut.read_mode, uut.Zero);
    end

endmodule
