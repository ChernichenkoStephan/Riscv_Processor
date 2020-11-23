`include "../defines/miriscv_defines.v"

module miriscv_alu (
  input         [`ALU_OP_WIDTH-1:0]   operator_i,
  input         [31:0]                operand_a_i,
  input         [31:0]                operand_b_i,
  output reg    [31:0]                result_o,
  output reg                          comparison_result_o
  );

  always @ ( * ) begin
    case ( operator_i )
    `ALU_ADD :
        begin
          result_o <= operand_a_i + operand_b_i;
          comparison_result_o <= 1'b0;
        end
    `ALU_SUB :
        begin
          result_o <= operand_a_i - operand_b_i;
          comparison_result_o <= 1'b0;
        end
    `ALU_XOR :
        begin
          result_o <= operand_a_i ^ operand_b_i;
          comparison_result_o <= 1'b0;
        end
    `ALU_OR  :
        begin
          result_o <= operand_a_i | operand_b_i;
          comparison_result_o <= 1'b0;
        end
    `ALU_AND :
        begin
          result_o <= operand_a_i & operand_b_i;
          comparison_result_o <= 1'b0;
        end
    `ALU_SRA :
        begin
          result_o <= $signed(operand_a_i) >>> operand_b_i;
          comparison_result_o <= 1'b0;
        end
    `ALU_SRL :
        begin
          result_o <= operand_a_i >> operand_b_i;
          comparison_result_o <= 1'b0;
        end
    `ALU_SLL :
        begin
          result_o <= operand_a_i << operand_b_i;
          comparison_result_o <= 1'b0;
        end
    `ALU_LTS :
        begin
          result_o <= ($signed(operand_a_i) < $signed(operand_b_i)) ? 32'd1 : 32'd0;
          comparison_result_o <= ($signed(operand_a_i) < $signed(operand_b_i)) ? 1'b1 : 1'b0;
        end
    `ALU_LTU :
        begin
          result_o <= (operand_a_i < operand_b_i) ? 32'd1 : 32'd0;
          comparison_result_o <= (operand_a_i < operand_b_i) ? 1'b1 : 1'b0;
        end
    `ALU_GES :
        begin
          result_o <= ($signed(operand_a_i) >= $signed(operand_b_i))? 32'd1 : 32'd0;
          comparison_result_o <= ($signed(operand_a_i) >= $signed(operand_b_i))? 1'b1 : 1'b0;
        end
    `ALU_GEU :
        begin
          result_o <= (operand_a_i >= operand_b_i)? 32'd1 : 32'd0;
          comparison_result_o <= (operand_a_i >= operand_b_i)? 1'b1 : 1'b0;
        end
    `ALU_EQ  :
        begin
          result_o <= (operand_a_i == operand_b_i)? 32'd1 : 32'd0;
          comparison_result_o <= (operand_a_i == operand_b_i)? 1'b1 : 1'b0;
        end
    `ALU_NE  :
        begin
          result_o <= (operand_a_i != operand_b_i)? 32'd1: 32'd0;
          comparison_result_o <= (operand_a_i != operand_b_i)? 1'b1: 1'b0;
        end
    default :
        begin
          result_o <= 31'd0;
          comparison_result_o <= 1'b0;
        end
    endcase
  end
endmodule
