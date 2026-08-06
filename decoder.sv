`include "ooo_defines.sv"

module decoder (
    input wire [`INSTR_W-1:0] instr,
    input wire [`PC_W-1:0] pc,
    input wire valid_in,
    output wire [`UOP_W-1:0] uop_out
);

    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_u = {instr[31:12], 12'b0};
    wire [31:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    reg [31:0] imm;
    reg [3:0] alu_op;
    reg [2:0] fu_type;
    reg is_branch, is_load, is_store;
    reg uses_rs2, uses_rd;

    always @(*) begin
        imm = 32'b0;
        alu_op = `ALU_ADD;
        fu_type = `FU_ALU;
        is_branch = 1'b0;
        is_load = 1'b0;
        is_store = 1'b0;
        uses_rs2 = 1'b0;
        uses_rd = 1'b1;

        case (opcode)
            `OPC_OP_IMM: begin
                imm      = imm_i;
                uses_rs2 = 1'b0;
                case (funct3)
                    3'b000: alu_op = `ALU_ADD;
                    3'b010: alu_op = `ALU_SLT; 
                    3'b011: alu_op = `ALU_SLTU;
                    3'b100: alu_op = `ALU_XOR;
                    3'b110: alu_op = `ALU_OR;
                    3'b111: alu_op = `ALU_AND;
                    3'b001: alu_op = `ALU_SLL;
                    3'b101: alu_op = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
                    default: alu_op = `ALU_ADD;
                endcase
            end
            `OPC_OP: begin
                uses_rs2 = 1'b1;
                case ({funct7[5],funct7[0], funct3})
                    4'b01_000: fu_type = `FU_MUL;
                    4'b00_000: alu_op = `ALU_ADD;
                    4'b10_000: alu_op = `ALU_SUB;
                    4'b00_001: alu_op = `ALU_SLL;
                    4'b00_010: alu_op = `ALU_SLT;
                    4'b00_011: alu_op = `ALU_SLTU;
                    4'b00_100: alu_op = `ALU_XOR;
                    4'b00_101: alu_op = `ALU_SRL;
                    4'b10_101: alu_op = `ALU_SRA;
                    4'b00_110: alu_op = `ALU_OR;
                    4'b00_111: alu_op = `ALU_AND;
                    default: alu_op = `ALU_ADD;
                endcase
            end
            `OPC_LUI: begin
                imm = imm_u;
                alu_op = `ALU_LUI;
                uses_rs2 = 1'b0;
            end
            `OPC_AUIPC: begin
                imm = imm_u;
                alu_op = `ALU_AUIPC;
                uses_rs2 = 1'b0;
            end
            `OPC_LOAD: begin
                imm = imm_i;
                fu_type = `FU_LSU;
                is_load = 1'b1;
                uses_rs2 = 1'b0;
            end
            `OPC_STORE: begin
                imm = imm_s;
                fu_type = `FU_LSU;
                is_store = 1'b1;
                uses_rs2 = 1'b1;
                uses_rd = 1'b0;
            end
            `OPC_BRANCH: begin
                imm = imm_b;
                fu_type = `FU_BRANCH;
                is_branch = 1'b1;
                uses_rs2 = 1'b1;
                uses_rd = 1'b0;
                case (funct3)
                    3'b000: alu_op = `ALU_SUB;
                    3'b001: alu_op = `ALU_SUB;
                    3'b100: alu_op = `ALU_SLT;
                    3'b101: alu_op = `ALU_SLT;
                    3'b110: alu_op = `ALU_SLTU;
                    3'b111: alu_op = `ALU_SLTU;
                    default: alu_op = `ALU_SUB;
                endcase
            end
            `OPC_JAL: begin
                imm = imm_j;
                fu_type = `FU_BRANCH;
                is_branch = 1'b1;
                uses_rs2 = 1'b0;
                uses_rd = 1'b1;
                alu_op = `ALU_ADD;
            end
            `OPC_JALR: begin
                imm = imm_i;
                fu_type = `FU_BRANCH;
                is_branch = 1'b1;
                uses_rs2 = 1'b0;
                uses_rd = 1'b1;
                alu_op = `ALU_ADD;
            end
            default: begin
                uses_rd = 1'b0;
            end
        endcase
        if (rd == 5'b0)
            uses_rd = 1'b0;
    end

    assign uop_out[`UOP_VALID] = valid_in;
    assign uop_out[`UOP_PC] = pc;
    assign uop_out[`UOP_INSTR] = instr;
    assign uop_out[`UOP_RS1] = rs1;
    assign uop_out[`UOP_RS2] = rs2;
    assign uop_out[`UOP_RD] = rd;
    assign uop_out[`UOP_IMM] = imm;
    assign uop_out[`UOP_FU_TYPE] = fu_type;
    assign uop_out[`UOP_ALU_OP] = alu_op;
    assign uop_out[`UOP_IS_BRANCH] = is_branch;
    assign uop_out[`UOP_IS_LOAD] = is_load;
    assign uop_out[`UOP_IS_STORE] = is_store;
    assign uop_out[`UOP_USES_RS2] = uses_rs2;
    assign uop_out[`UOP_USES_RD] = uses_rd;

    assign uop_out[`UOP_Q1_VALID] = 1'b0;
    assign uop_out[`UOP_Q1_TAG] = 6'b0;
    assign uop_out[`UOP_Q2_VALID] = 1'b0;
    assign uop_out[`UOP_Q2_TAG] = 6'b0;
    assign uop_out[`UOP_ROB_TAG] = 6'b0;

endmodule
