`include "ooo_defines.sv"

module rob (
    input clk, reset,
    input [`UOP_W-1:0] uops_in [0:`DISPATCH_WIDTH-1],
    input [`DATA_W+`ROB_TAG_W+1:0] CDB_in [0:`N_CDB-1],
    output [`ROB_TAG_W-1:0] tag [0:`DISPATCH_WIDTH-1],
    output reg stall
);

    reg [`ROB_TAG_W-1:0] tail;
    reg [`ROB_TAG_W-1:0] head;

    reg [`ROB_TAG_W:0] free_counter;
    
    reg [`ROB_W-1:0] ROB_reg [0:`ROB_SIZE-1];

    always @(*) begin
        if (free_counter < 6'd4) stall = 1;
        else stall = 0;
    end
    
    assign tag[0] = tail;
    assign tag[1] = (tail + 1) % `ROB_SIZE;
    assign tag[2] = (tail + 2) % `ROB_SIZE;
    assign tag[3] = (tail + 3) % `ROB_SIZE;

    always @(posedge clk) begin
        integer i,k,r;

        if(reset) begin
            tail <= `ROB_TAG_W'b0;
            head <= `ROB_TAG_W'b0;
            free_counter <= `ROB_TAG_W'd63;

            for(i=0;i<`ROB_SIZE;i=i+1) begin
                ROB_reg[i] <= `ROB_W'b0;
            end
        end
        else begin
            ROB_reg[tail] <= {uops_in[0][`UOP_VALID],uops_in[0][`UOP_RD],32'b0,32'b0,32'b0,uops_in[0][`UOP_PC],3'b0,uops_in[0][`UOP_USES_RD],uops_in[0][`UOP_IS_STORE],uops_in[0][`UOP_IS_LOAD],uops_in[0][`UOP_IS_BRANCH],1'b0,1'b0};
            ROB_reg[tail+1] <= {uops_in[1][`UOP_VALID],uops_in[1][`UOP_RD],32'b0,32'b0,32'b0,uops_in[1][`UOP_PC],3'b0,uops_in[1][`UOP_USES_RD],uops_in[1][`UOP_IS_STORE],uops_in[1][`UOP_IS_LOAD],uops_in[1][`UOP_IS_BRANCH],1'b0,1'b0};
            ROB_reg[tail+2] <= {uops_in[2][`UOP_VALID],uops_in[2][`UOP_RD],32'b0,32'b0,32'b0,uops_in[2][`UOP_PC],3'b0,uops_in[2][`UOP_USES_RD],uops_in[2][`UOP_IS_STORE],uops_in[2][`UOP_IS_LOAD],uops_in[2][`UOP_IS_BRANCH],1'b0,1'b0};
            ROB_reg[tail+3] <= {uops_in[3][`UOP_VALID],uops_in[3][`UOP_RD],32'b0,32'b0,32'b0,uops_in[3][`UOP_PC],3'b0,uops_in[3][`UOP_USES_RD],uops_in[3][`UOP_IS_STORE],uops_in[3][`UOP_IS_LOAD],uops_in[3][`UOP_IS_BRANCH],1'b0,1'b0};

            tail <= tail + 4;
            free_counter <= free_counter - 4;

            for (k = 0;k < `N_CDB ;k = k + 1 ) begin
                for (r = 0;r < `ROB_SIZE ;r = r + 1 ) begin
                    if (CDB_in[k][39:38] == 2'b10) begin
                        ROB_reg[CDB_in[k][37:32]][136:105] <= CDB_in[k][31:0];
                    end
                    else if (CDB_in[k][39:38] == 2'b10) begin
                        ROB_reg[CDB_in[k][37:32]][104:73] <= CDB_in[k][31:0];
                    end
                    else if (CDB_in[k][39:38] == 2'b11) begin
                        ROB_reg[CDB_in[k][37:32]][72:41] <= CDB_in[k][31:0];
                    end
                end
            end
        end
    end

endmodule