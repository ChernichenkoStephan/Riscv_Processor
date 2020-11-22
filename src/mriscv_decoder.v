`include "../defines/miriscv_defines.v"

module mriscv_decoder(
input 	    [31:0]                 fetched_instr_i,    // Decoding instruction read from instruction memory
output reg 	[1:0]                  ex_op_a_sel_o,      // Multiplexer control signal to select the first ALU operand
output reg 	[2:0]                  ex_op_b_sel_o,      // Multiplexer control signal to select the second ALU operand
output reg 	[`ALU_OP_WIDTH-1:0]    alu_op_o,           // ALU operation
output reg 			                   mem_req_o,          // Memory access request (part of the memory interface)
output reg 			                   mem_we_o,           // Memory write enable signal, "write enable" (== 0 - read)
output reg 	[2:0]                  mem_size_o,         // Control signal to select the word size when reading-writing to memory (part of the memory interface)
output reg 			                   gpr_we_a_o,         // Register file write enable signal
output reg 			                   wb_src_sel_o,       // Multiplexer control signal for selecting data to be written to the register file
output reg 			                   illegal_instr_o,    // Incorrect instruction signal (not marked on the diagram)
output reg 			                   branch_o,           // Conditional branch instruction signal
output reg 			                   jal_o,              // Jal unconditional jump instruction signal
output reg 			                   jalr_o              // Jarl unconditional jump instruction signal
);

wire  [1:0]  instr_size;
wire  [4:0]  instruction;
wire  [6:0]  funct7;
wire  [2:0]  funct3;
reg   [4:0]  rs1;
reg   [4:0]  rs2;
reg   [4:0]  rd;

assign instr_size = fetched_instr_i[1:0];
assign instruction = fetched_instr_i[6:2];
assign funct7 = fetched_instr_i[31:25];
assign funct3 = fetched_instr_i[14:12];

always @ ( * ) begin

    illegal_instr_o = ~&instr_size;
    mem_req_o       = (instruction == `LOAD_OPCODE |
                       instruction == `STORE_OPCODE);     // Write enable control
    mem_we_o        = (instruction == `STORE_OPCODE);     // Input data

    gpr_we_a_o      = (instruction == `AUIPC_OPCODE |
                       instruction == `OP_IMM_OPCODE |
                       instruction == `LUI_OPCODE |
                       instruction == `OP_OPCODE |
                       instruction == `JAL_OPCODE |
                       instruction == `JALR_OPCODE |
                       instruction == `LOAD_OPCODE);      // Disable write to registers

    branch_o        = (instruction == `BRANCH_OPCODE);
    jal_o           = (instruction == `JAL_OPCODE);
    jalr_o          = (instruction == `JALR_OPCODE);
    wb_src_sel_o    = (instruction == `LOAD_OPCODE);

    case (instruction)

      // Write data from memory to rd at address rs1 + imm
      `LOAD_OPCODE  : begin
          alu_op_o      = `ALU_ADD;
          ex_op_a_sel_o = 2'd0;
          ex_op_b_sel_o = 3'd1;
          case (funct3)
          //LB
              3'b000 : mem_size_o  = `LDST_B;
          //LH
              3'b001 : mem_size_o  = `LDST_H;
          //LW
              3'b010 : mem_size_o  = `LDST_W;
          //LBU
              3'b100 : mem_size_o  = `LDST_BU;
          //LHU
              3'b101 : mem_size_o  = `LDST_HU;
              default: illegal_instr_o = 1'b1;
          endcase
      end

      // Do not perform operation illegal_instr_o = 0
      `MISC_MEM_OPCODE  :;

      // Write in rd the result of calculating the ALU over rs1 and imm
      `OP_IMM_OPCODE  : begin
          ex_op_a_sel_o = 2'd0;
          ex_op_b_sel_o = 3'd1;
          case (funct3)
              3'b000 : alu_op_o = `ALU_ADD;
              3'b011 : alu_op_o = `ALU_SLTU;
              3'b100 : alu_op_o = `ALU_XOR;
              3'b110 : alu_op_o = `ALU_OR;
              3'b111 : alu_op_o = `ALU_AND;
              3'b001 : begin
                  if (funct7 == 7'b0000000)
                      alu_op_o = `ALU_SLL;
                  else
                      illegal_instr_o = 1'b1;
              end
              3'b010 : alu_op_o = `ALU_SLTS;
              3'b101 : case (funct7)
                          7'b0000000 : alu_op_o = `ALU_SRL;
                          7'b0100000 : alu_op_o = `ALU_SRA;
                          default: illegal_instr_o = 1'b1;
                      endcase
              default: illegal_instr_o = 1'b1;
          endcase
          end

          // Write to rd the result of the addition of the immediate U-type operand (imm_u) and the program counter
          `AUIPC_OPCODE  : begin
              ex_op_a_sel_o = 2'd1;
              ex_op_b_sel_o = 3'd2;
              alu_op_o      = `ALU_ADD;
          end

          // Write data from rs2 to memory at rs1 + imm
          `STORE_OPCODE  : begin
              alu_op_o      = `ALU_ADD;
              ex_op_a_sel_o = 2'd0;
              ex_op_b_sel_o = 3'd3;
              case (funct3)
                  3'b000  : mem_size_o  = `LDST_B;
                  3'b001  : mem_size_o  = `LDST_H;
                  3'b010  : mem_size_o  = `LDST_W;
                  default: illegal_instr_o = 1'b1;
              endcase
          end

        // Write to rd the result of ALU calculation over rs1 and rs2
        `OP_OPCODE  : begin
            ex_op_a_sel_o = 2'd0;
            ex_op_b_sel_o = 3'd0;
            case ({funct7, funct3})
                10'b0000000_000 : alu_op_o = `ALU_ADD;
                10'b0100000_000 : alu_op_o = `ALU_SUB;
                10'b0000000_001 : alu_op_o = `ALU_SLL;
                10'b0000000_010 : alu_op_o = `ALU_SLTS;
                10'b0000000_011 : alu_op_o = `ALU_SLTU;
                10'b0000000_100 : alu_op_o = `ALU_XOR;
                10'b0000000_101 : alu_op_o = `ALU_SRL;
                10'b0100000_101 : alu_op_o = `ALU_SRA;
                10'b0000000_110 : alu_op_o = `ALU_OR;
                10'b0000000_111 : alu_op_o = `ALU_AND;
                default: illegal_instr_o = 1'b1;
            endcase
        end

        // Write to rd the value of the U-type immediate operand (imm_u)
        `LUI_OPCODE  : begin
            ex_op_a_sel_o = 2'd2;
            ex_op_b_sel_o = 3'd2;
            alu_op_o      = `ALU_ADD;
        end

        // Increase the command counter by the value imm if the result of comparing rs1 and rs2 is correct
        `BRANCH_OPCODE  : begin
            ex_op_a_sel_o = 2'd0;
            ex_op_b_sel_o = 3'd0;
            case (funct3)
                //BEQ
                3'b000 : alu_op_o = `ALU_EQ;
                //BNE
                3'b001 : alu_op_o = `ALU_NE;
                //BLT
                3'b100 : alu_op_o = `ALU_LTS;
                //BGE
                3'b101 : alu_op_o = `ALU_GES;
                //BLTU
                3'b110 : alu_op_o = `ALU_LTU;
                //BGEU
                3'b111 : alu_op_o = `ALU_GEU;
                default: illegal_instr_o = 1'b1;
            endcase
        end

        // Write the next address of the command counter to rd, write rs1 to the command counter
        `JALR_OPCODE  : begin
            ex_op_a_sel_o = 2'd1;
            ex_op_b_sel_o = 3'd4;
            alu_op_o      = `ALU_ADD;
        end

        // Write the next address of the command counter to rd, write rs1 to the command counter
        `JAL_OPCODE  : begin
            ex_op_a_sel_o = 2'd1;
            ex_op_b_sel_o = 3'd4;
            alu_op_o      = `ALU_ADD;
        end

        // Do not perform operation illegal_instr_o = 0
        `SYSTEM_OPCODE  :;

        // Completely impossible operation
        default: illegal_instr_o = 1'b1;
    endcase

end


endmodule
