`include "ooo_defines.sv"

module fetch_unit (
    input clk, reset, redirect_valid, stall,
    input [`PC_W-1:0] redirect_pc,
    output reg [`PC_W-1:0] fetch_pc [0:`FETCH_WIDTH-1],
    output reg [`INSTR_W-1:0] fetch_instr [0:`FETCH_WIDTH-1],
    output reg fetch_valid [0:`FETCH_WIDTH-1]
);

    reg [`PC_W-1:0] PC;
    reg [`INSTR_W-1:0] imem [0:1023];

    always @(posedge clk) begin
        if (reset)
            PC <= 32'h0;
        else if (redirect_valid)
            PC <= redirect_pc;
        else if (!stall)
            PC <= PC + 32'd16;
    end

    genvar i;
    generate
        for (i = 0; i < `FETCH_WIDTH; i = i + 1) begin : fetch_lane
            always@(*) begin
                fetch_pc[i] = PC + (i * 4);
                fetch_instr[i] = imem[(PC >> 2) + i];
                fetch_valid[i] = !reset;
            end
        end
    endgenerate

endmodule
