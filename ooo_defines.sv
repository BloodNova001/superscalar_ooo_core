`ifndef OOO_DEFINES_V
`define OOO_DEFINES_V


`define FETCH_WIDTH           4
`define DISPATCH_WIDTH        4
`define ROB_SIZE              64
`define ROB_W                 143
`define ROB_TAG_W             6
`define ARCH_REGS             32
`define AREG_W                5
`define RAT_REGS              32 
`define RAT_W                 39
`define DATA_W                32
`define PC_W                  32
`define INSTR_W               32

`define N_ALU                 2
`define N_MUL                 1
`define N_LSU                 2
`define N_FU                  (`N_ALU + `N_MUL + `N_LSU)
`define N_CDB                 4

`define RS_INT_SIZE           16
`define RS_MUL_SIZE           8
`define RS_LSU_SIZE           16
`define RS_W                  88

`define FU_ALU                3'b000
`define FU_MUL                3'b001
`define FU_LSU                3'b010
`define FU_BRANCH             3'b011

`define ALU_ADD               4'b0000
`define ALU_SUB               4'b0001
`define ALU_AND               4'b0010
`define ALU_OR                4'b0011
`define ALU_XOR               4'b0100
`define ALU_SLL               4'b0101
`define ALU_SRL               4'b0110
`define ALU_SRA               4'b0111
`define ALU_SLT               4'b1000
`define ALU_SLTU              4'b1001
`define ALU_LUI               4'b1010
`define ALU_AUIPC             4'b1011

`define OPC_LOAD              7'b0000011
`define OPC_STORE             7'b0100011
`define OPC_BRANCH            7'b1100011
`define OPC_JAL               7'b1101111
`define OPC_JALR              7'b1100111
`define OPC_LUI               7'b0110111
`define OPC_AUIPC             7'b0010111
`define OPC_OP                7'b0110011
`define OPC_OP_IMM            7'b0010011
`define OPC_NOP               32'h00000013

`define UOP_W                 144

`define UOP_VALID             0
`define UOP_PC                32:1
`define UOP_INSTR             64:33
`define UOP_RS1               69:65
`define UOP_RS2               74:70
`define UOP_RD                79:75
`define UOP_IMM               111:80
`define UOP_FU_TYPE           114:112
`define UOP_ALU_OP            118:115
`define UOP_IS_BRANCH         119
`define UOP_IS_LOAD           120
`define UOP_IS_STORE          121
`define UOP_USES_RS2          122
`define UOP_USES_RD           123
`define UOP_Q1_VALID          124
`define UOP_Q1_TAG            130:125
`define UOP_Q2_VALID          131
`define UOP_Q2_TAG            137:132
`define UOP_ROB_TAG           143:138

`endif
