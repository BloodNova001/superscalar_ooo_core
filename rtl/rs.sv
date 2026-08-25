`include "ooo_defines.sv"

module rs (
    input clk, reset,
    input [`UOP_W-1:0] uops_in [0:`DISPATCH_WIDTH-1],
    input [63:0] value_in [0:`DISPATCH_WIDTH-1]
);

    reg [`RS_W-1:0] RS_int [0:`RS_INT_SIZE-1];
    reg [`RS_W-1:0] RS_mul [0:`RS_MUL_SIZE-1];
    reg [`RS_W-1:0] RS_lsu [0:`RS_LSU_SIZE-1];

    reg [$clog2(`RS_INT_SIZE)-1:0] free_int [0:`RS_INT_SIZE-1];
    reg [$clog2(`RS_MUL_SIZE)-1:0] free_mul [0:`RS_MUL_SIZE-1];
    reg [$clog2(`RS_LSU_SIZE)-1:0] free_lsu [0:`RS_LSU_SIZE-1];

    reg [$clog2(`RS_INT_SIZE)-1:0] head_int;
    reg [$clog2(`RS_INT_SIZE)-1:0] tail_int;
    reg [$clog2(`RS_MUL_SIZE)-1:0] head_mul;
    reg [$clog2(`RS_MUL_SIZE)-1:0] tail_mul;
    reg [$clog2(`RS_LSU_SIZE)-1:0] head_lsu;
    reg [$clog2(`RS_LSU_SIZE)-1:0] tail_lsu;

    reg [$clog2(`RS_INT_SIZE):0] free_int_counter;
    reg [$clog2(`RS_MUL_SIZE):0] free_mul_counter;
    reg [$clog2(`RS_LSU_SIZE):0] free_lsu_counter;

    always @(posedge clk ) begin
        integer i;
        if (reset) begin
            for (i = 0;i < `RS_INT_SIZE ;i = i + 1 ) begin
                RS_int[i] <= `RS_W'b0;
            end
            for (i = 0;i < `RS_MUL_SIZE ;i = i + 1 ) begin
                RS_mul[i] <= `RS_W'b0;
            end
            for (i = 0;i < `RS_LSU_SIZE ;i = i + 1 ) begin
                RS_lsu[i] <= `RS_W'b0;
            end

            for (i = 0;i < $clog2(`RS_INT_SIZE) ;i = i + 1 ) begin
                free_int[i] <= ($clog2(`RS_INT_SIZE))'(i);
            end
            for (i = 0;i < $clog2(`RS_MUL_SIZE) ;i = i + 1 ) begin
                free_mul[i] <= ($clog2(`RS_MUL_SIZE))'(i);
            end
            for (i = 0;i < $clog2(`RS_LSU_SIZE) ;i = i + 1 ) begin
                free_lsu[i] <= ($clog2(`RS_LSU_SIZE))'(i);
            end

            head_int <= $clog2(`RS_INT_SIZE)'d0;
            tail_int <= $clog2(`RS_INT_SIZE)'d0;
            head_mul <= $clog2(`RS_MUL_SIZE)'d0;
            tail_mul <= $clog2(`RS_MUL_SIZE)'d0;
            head_lsu <= $clog2(`RS_LSU_SIZE)'d0;
            tail_lsu <= $clog2(`RS_LSU_SIZE)'d0;

            free_int_counter <= $clog2(`RS_INT_SIZE)'d16;
            free_mul_counter <= $clog2(`RS_MUL_SIZE)'d16;
            free_lsu_counter <= $clog2(`RS_LSU_SIZE)'d16;
        end
        else begin
            for (i = 0;i < `DISPATCH_WIDTH ;i = i + 1 ) begin
                if (uops_in[i][`UOP_FU_TYPE] == `FU_ALU) begin
                    if (uops_in[i][`UOP_USES_RS2]) begin
                        RS_int[tail_int] <= {uops_in[i][`UOP_ROB_TAG],uops_in[i][`UOP_ALU_OP],!uops_in[i][`UOP_Q1_VALID],uops_in[i][`UOP_Q1_TAG],value_in[i][31:0],1'b1,uops_in[i][`UOP_Q2_TAG],uops_in[i][`UOP_IMM]};
                    end
                    else begin
                        RS_int[tail_int] <= {uops_in[i][`UOP_ROB_TAG],uops_in[i][`UOP_ALU_OP],!uops_in[i][`UOP_Q1_VALID],uops_in[i][`UOP_Q1_TAG],value_in[i][31:0],!uops_in[i][`UOP_Q2_VALID],uops_in[i][`UOP_Q2_TAG],value_in[i][63:32]};
                    end
                    tail_int <= tail_int + 1;
                    free_int_counter <= free_int_counter - 1;
                end
                else if (uops_in[i][`UOP_FU_TYPE] == `FU_MUL) begin
                    RS_mul[tail_mul] <= {uops_in[i][`UOP_ROB_TAG],uops_in[i][`UOP_ALU_OP],!uops_in[i][`UOP_Q1_VALID],uops_in[i][`UOP_Q1_TAG],value_in[i][31:0],!uops_in[i][`UOP_Q2_VALID],uops_in[i][`UOP_Q2_TAG],value_in[i][63:32]};
                    tail_mul <= tail_mul + 1;
                    free_mul_counter <= free_mul_counter - 1;
                end
                else if (uops_in[i][`UOP_FU_TYPE] == `FU_LSU) begin
                    if (uops_in[i]['UOP_IS_STORE]) begin
                        RS_lsu[tail_lsu] <= {uops_in[i][`UOP_ROB_TAG],uops_in[i][`UOP_ALU_OP],!uops_in[i][`UOP_Q1_VALID],uops_in[i][`UOP_Q1_TAG],value_in[i][31:0],!uops_in[i][`UOP_Q2_VALID],uops_in[i][`UOP_Q2_TAG],value_in[i][63:32]};
                    end
                    else begin
                        RS_lsu[tail_lsu] <= {uops_in[i][`UOP_ROB_TAG],uops_in[i][`UOP_ALU_OP],!uops_in[i][`UOP_Q1_VALID],uops_in[i][`UOP_Q1_TAG],value_in[i][31:0],1'b1,uops_in[i][`UOP_Q2_TAG],uops_in[i][`UOP_IMM]};
                    end
                    tail_lsu <= tail_lsu + 1;
                    free_lsu_counter <= free_lsu_counter - 1;
                end
            end
        end
    end

endmodule