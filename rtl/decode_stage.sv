`include "ooo_defines.sv"

module decode_stage (
    input wire [`PC_W-1:0] fetch_pc [0:`FETCH_WIDTH-1],
    input wire [`INSTR_W-1:0] fetch_instr [0:`FETCH_WIDTH-1],
    input wire fetch_valid [0:`FETCH_WIDTH-1],
    output wire [`UOP_W-1:0] uop_bundle [0:`FETCH_WIDTH-1]
  );

  	genvar i;
  	generate
    for (i = 0; i < `FETCH_WIDTH; i = i + 1) begin : dec
      	decoder u_dec (
            .instr (fetch_instr[i]),
            .pc (fetch_pc[i]),
            .valid_in (fetch_valid[i]),
            .uop_out (uop_bundle[i])
        );
    end
    endgenerate

endmodule