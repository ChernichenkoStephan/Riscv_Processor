`define RESET_ADDR 32'h00000000

`define ALU_OP_WIDTH  6

`define ALU_ADD   6'b011000
`define ALU_SUB   6'b011001

`define ALU_XOR   6'b101111
`define ALU_OR    6'b101110
`define ALU_AND   6'b010101

// shifts
`define ALU_SRA   6'b100100
`define ALU_SRL   6'b100101
`define ALU_SLL   6'b100111

// comparisons
`define ALU_LTS   6'b000000
`define ALU_LTU   6'b000001
`define ALU_GES   6'b001010
`define ALU_GEU   6'b001011
`define ALU_EQ    6'b001100
`define ALU_NE    6'b001101

// set lower than operations
`define ALU_SLTS  6'b000010
`define ALU_SLTU  6'b000011

// opcodes
`define LOAD_OPCODE      5'b00_000
`define MISC_MEM_OPCODE  5'b00_011
`define OP_IMM_OPCODE    5'b00_100
`define AUIPC_OPCODE     5'b00_101
`define STORE_OPCODE     5'b01_000
`define OP_OPCODE        5'b01_100
`define LUI_OPCODE       5'b01_101
`define BRANCH_OPCODE    5'b11_000
`define JALR_OPCODE      5'b11_001
`define JAL_OPCODE       5'b11_011
`define SYSTEM_OPCODE    5'b11_100

// dmem type load store
`define LDST_B           3'b000
`define LDST_H           3'b001
`define LDST_W           3'b010
`define LDST_BU          3'b100
`define LDST_HU          3'b101

// operand a selection
`define OP_A_RS1         2'b00
`define OP_A_CURR_PC     2'b01
`define OP_A_ZERO        2'b10

// operand b selection
`define OP_B_RS2         3'b000
`define OP_B_IMM_I       3'b001
`define OP_B_IMM_U       3'b010
`define OP_B_IMM_S       3'b011
`define OP_B_INCR        3'b100

// writeback source selection
`define WB_EX_RESULT     1'b0
`define WB_LSU_DATA      1'b1
