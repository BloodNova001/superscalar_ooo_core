`include "ooo_defines.sv"

module rat (
    input clk, reset,
    input [`UOP_W-1:0] uops_in [0:`DISPATCH_WIDTH-1],
    input [`ROB_TAG_W-1:0] tag [0:`DISPATCH_WIDTH-1],
    input [`DATA_W+`ROB_TAG_W+1:0] CDB_in [0:`N_CDB-1],
    output reg [`UOP_W-1:0] uops_out [0:`DISPATCH_WIDTH-1],
    output reg [63:0] value_out [0:`DISPATCH_WIDTH-1]
);

    reg [`RAT_W-1:0] RAT_reg [0:`RAT_REGS-1];

    always @(*) begin
        integer j;
        for (j = 0;j < `DISPATCH_WIDTH ;j = j + 1 ) begin
            uops_out[j][123:0] = uops_in[j][123:0];
            uops_out[j][`UOP_ROB_TAG] = tag[j];
        end


        if (RAT_reg[uops_in[0][`UOP_RS1]][38]) begin
            uops_out[0][`UOP_Q1_VALID] = 0;
            uops_out[0][`UOP_Q1_TAG] = 6'b0;
            value_out[0][31:0] = RAT_reg[uops_in[0][`UOP_RS1]][31:0];
        end
        else begin
            uops_out[0][`UOP_Q1_VALID] = 1;
            uops_out[0][`UOP_Q1_TAG] = RAT_reg[uops_in[0][`UOP_RS1]][37:32];
            value_out[0][31:0] = 32'b0;
        end

        if (RAT_reg[uops_in[0][`UOP_RS2]][38]) begin
            uops_out[0][`UOP_Q2_VALID] = 0;
            uops_out[0][`UOP_Q2_TAG] = 6'b0;
            value_out[0][63:32] = RAT_reg[uops_in[0][`UOP_RS2]][31:0];
        end
        else begin
            uops_out[0][`UOP_Q2_VALID] = 1;
            uops_out[0][`UOP_Q2_TAG] = RAT_reg[uops_in[0][`UOP_RS2]][37:32];
            value_out[0][63:32] = 32'b0;
        end


        if (uops_in[0][`UOP_RD] == uops_in[1][`UOP_RS1]) begin
            uops_out[1][`UOP_Q1_VALID] = 1;
            uops_out[1][`UOP_Q1_TAG] = tag[0];
            value_out[1][31:0] = 32'b0;
        end
        else if (RAT_reg[uops_in[1][`UOP_RS1]][38]) begin
            uops_out[1][`UOP_Q1_VALID] = 0;
            uops_out[1][`UOP_Q1_TAG] = 6'b0;
            value_out[1][31:0] = RAT_reg[uops_in[1][`UOP_RS1]][31:0];
        end
        else begin
            uops_out[1][`UOP_Q1_VALID] = 1;
            uops_out[1][`UOP_Q1_TAG] = RAT_reg[uops_in[1][`UOP_RS1]][37:32];
            value_out[1][31:0] = 32'b0;
        end

        if (uops_in[0][`UOP_RD] == uops_in[1][`UOP_RS2]) begin
            uops_out[1][`UOP_Q2_VALID] = 1;
            uops_out[1][`UOP_Q2_TAG] = tag[0];
            value_out[1][63:32] = 32'b0;
        end
        else if (RAT_reg[uops_in[1][`UOP_RS2]][38]) begin
            uops_out[1][`UOP_Q2_VALID] = 0;
            uops_out[1][`UOP_Q2_TAG] = 6'b0;
            value_out[1][63:32] = RAT_reg[uops_in[1][`UOP_RS2]][31:0];
        end
        else begin
            uops_out[1][`UOP_Q2_VALID] = 1;
            uops_out[1][`UOP_Q2_TAG] = RAT_reg[uops_in[1][`UOP_RS2]][37:32];
            value_out[1][63:32] = 32'b0;
        end


        if (uops_in[1][`UOP_RD] == uops_in[2][`UOP_RS1]) begin
            uops_out[2][`UOP_Q1_VALID] = 1;
            uops_out[2][`UOP_Q1_TAG] = tag[1];
            value_out[2][31:0] = 32'b0;
        end
        else if (uops_in[0][`UOP_RD] == uops_in[2][`UOP_RS1]) begin
            uops_out[2][`UOP_Q1_VALID] = 1;
            uops_out[2][`UOP_Q1_TAG] = tag[0];
            value_out[2][31:0] = 32'b0;
        end
        else if (RAT_reg[uops_in[2][`UOP_RS1]][38]) begin
            uops_out[2][`UOP_Q1_VALID] = 0;
            uops_out[2][`UOP_Q1_TAG] = 6'b0;
            value_out[2][31:0] = RAT_reg[uops_in[2][`UOP_RS1]][31:0];
        end
        else begin
            uops_out[2][`UOP_Q1_VALID] = 1;
            uops_out[2][`UOP_Q1_TAG] = RAT_reg[uops_in[2][`UOP_RS1]][37:32];
            value_out[2][31:0] = 32'b0;
        end

        if (uops_in[1][`UOP_RD] == uops_in[2][`UOP_RS2]) begin
            uops_out[2][`UOP_Q2_VALID] = 1;
            uops_out[2][`UOP_Q2_TAG] = tag[1];
            value_out[2][63:32] = 32'b0;
        end
        else if (uops_in[0][`UOP_RD] == uops_in[2][`UOP_RS2]) begin
            uops_out[2][`UOP_Q2_VALID] = 1;
            uops_out[2][`UOP_Q2_TAG] = tag[0];
            value_out[2][63:32] = 32'b0;
        end
        else if (RAT_reg[uops_in[2][`UOP_RS2]][38]) begin
            uops_out[2][`UOP_Q2_VALID] = 0;
            uops_out[2][`UOP_Q2_TAG] = 6'b0;
            value_out[2][63:32] = RAT_reg[uops_in[2][`UOP_RS2]][31:0];
        end
        else begin
            uops_out[2][`UOP_Q2_VALID] = 1;
            uops_out[2][`UOP_Q2_TAG] = RAT_reg[uops_in[2][`UOP_RS2]][37:32];
            value_out[2][63:32] = 32'b0;
        end


        if (uops_in[2][`UOP_RD] == uops_in[3][`UOP_RS1]) begin
            uops_out[3][`UOP_Q1_VALID] = 1;
            uops_out[3][`UOP_Q1_TAG] = tag[2];
            value_out[3][31:0] = 32'b0;
        end
        else if (uops_in[1][`UOP_RD] == uops_in[3][`UOP_RS1]) begin
            uops_out[3][`UOP_Q1_VALID] = 1;
            uops_out[3][`UOP_Q1_TAG] = tag[1];
            value_out[3][31:0] = 32'b0;
        end
        else if (uops_in[0][`UOP_RD] == uops_in[3][`UOP_RS1]) begin
            uops_out[3][`UOP_Q1_VALID] = 1;
            uops_out[3][`UOP_Q1_TAG] = tag[0];
            value_out[3][31:0] = 32'b0;
        end
        else if (RAT_reg[uops_in[3][`UOP_RS1]][38]) begin
            uops_out[3][`UOP_Q1_VALID] = 0;
            uops_out[3][`UOP_Q1_TAG] = 6'b0;
            value_out[3][31:0] = RAT_reg[uops_in[3][`UOP_RS1]][31:0];
        end
        else begin
            uops_out[3][`UOP_Q1_VALID] = 1;
            uops_out[3][`UOP_Q1_TAG] = RAT_reg[uops_in[3][`UOP_RS1]][37:32];
            value_out[3][31:0] = 32'b0;
        end

        if (uops_in[2][`UOP_RD] == uops_in[3][`UOP_RS2]) begin
            uops_out[3][`UOP_Q2_VALID] = 1;
            uops_out[3][`UOP_Q2_TAG] = tag[2];
            value_out[3][63:32] = 32'b0;
        end
        else if (uops_in[1][`UOP_RD] == uops_in[3][`UOP_RS2]) begin
            uops_out[3][`UOP_Q2_VALID] = 1;
            uops_out[3][`UOP_Q2_TAG] = tag[1];
            value_out[3][63:32] = 32'b0;
        end
        else if (uops_in[0][`UOP_RD] == uops_in[3][`UOP_RS2]) begin
            uops_out[3][`UOP_Q2_VALID] = 1;
            uops_out[3][`UOP_Q2_TAG] = tag[0];
            value_out[3][63:32] = 32'b0;
        end
        else if (RAT_reg[uops_in[3][`UOP_RS2]][38]) begin
            uops_out[3][`UOP_Q2_VALID] = 0;
            uops_out[3][`UOP_Q2_TAG] = 6'b0;
            value_out[3][63:32] = RAT_reg[uops_in[3][`UOP_RS2]][31:0];
        end
        else begin
            uops_out[3][`UOP_Q2_VALID] = 1;
            uops_out[3][`UOP_Q2_TAG] = RAT_reg[uops_in[3][`UOP_RS2]][37:32];
            value_out[3][63:32] = 32'b0;
        end
    end

    always @(posedge clk ) begin
        integer i, k, r;
        if (reset) begin
            for (i = 0;i < `RAT_REGS ;i = i + 1 ) begin
                RAT_reg[i] <= 39'b0;
            end
        end
        else begin

            RAT_reg[uops_in[3][`UOP_RD]][37:32] <= tag[3];
            RAT_reg[uops_in[3][`UOP_RD]][38] <= 0;

            if (!(uops_in[2][`UOP_RD] == uops_in[3][`UOP_RD])) begin
                RAT_reg[uops_in[2][`UOP_RD]][37:32] <= tag[2];
                RAT_reg[uops_in[2][`UOP_RD]][38] <= 0;
            end
            
            if ((!(uops_in[1][`UOP_RD] == uops_in[3][`UOP_RD])) && (!(uops_in[1][`UOP_RD] == uops_in[2][`UOP_RD]))) begin
                RAT_reg[uops_in[1][`UOP_RD]][37:32] <= tag[1];
                RAT_reg[uops_in[1][`UOP_RD]][38] <= 0;
            end

            if ((!(uops_in[0][`UOP_RD] == uops_in[3][`UOP_RD])) && (!(uops_in[0][`UOP_RD] == uops_in[2][`UOP_RD])) && (!(uops_in[0][`UOP_RD] == uops_in[1][`UOP_RD]))) begin
                RAT_reg[uops_in[0][`UOP_RD]][37:32] <= tag[0];
                RAT_reg[uops_in[0][`UOP_RD]][38] <= 0;
            end
                        
        end

        for (k = 0;k < `N_CDB ;k = k + 1 ) begin
            for (r = 0;r < `RAT_REGS ;r = r + 1 ) begin
                if (!RAT_reg[r][38] && (RAT_reg[r][37:32] == CDB_in[k][37:32]) && (CDB_in[k][39:38] == 2'b01)) begin
                    RAT_reg[r][31:0] <= CDB_in[k][31:0];
                    RAT_reg[r][38] <= 1'b1;
                end
            end
        end
    end

endmodule