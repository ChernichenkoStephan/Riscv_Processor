`include "../defines/miriscv_defines.v"

module riscv_processor(
  input             clk_i,
  input             reset,
  output reg [31:0] debug_result
);

  // Processor
  reg  [31:0] program_counter;
  reg  [31:0] program_counter_add;

  // Instructions memory
  wire [31:0] instruction;

  // Data memory
  wire [31:0] rd;

  // Decoder
  wire [`ALU_OP_WIDTH-1:0] aop;
  wire        enpc;
  wire        jalr;
  wire        jal;
  wire        b;
  wire        rfwe;
  wire        WS;
  wire        mwe;
  wire        mrq;
  wire [3:0]  memi;
  wire [1:0]  srcA;
  wire [2:0]  srcB;

  // Unused ports
  wire illegal_instr;

  // Register file
  reg  [31:0] wd3;
  wire [31:0] rd1;
  wire [31:0] rd2;

  // ALU
  reg  [31:0] operand_a;
  reg  [31:0] operand_b;
  wire [31:0] result;
  wire comparsion_result;

  // Immediate constants
  wire     [31:0]   imm_I;
  wire     [31:0]   imm_S;
  wire     [31:0]   imm_J;
  wire     [31:0]   imm_B;

  initial program_counter = 32'h76000000;

  im instructions_memory(
        .addr_i   (program_counter),  // read adress
        .rd_o     (instruction)       // read port
  );

  dm data_memory(
        .clk_i    (clk_i),
        .I        (memi),   // word size
        .addr_i   (result), // read adress
        .wd_i     (rd2),    // write port
        .we_i     (mwe),    // control port
        .rd_o     (rd)      // read port
  );

  mriscv_decoder decoder(
            .fetched_instr_i    (instruction),      // Decoding instruction read from instruction memory
            .ex_op_a_sel_o      (srcA),             // Multiplexer control signal to select the first ALU operand
            .ex_op_b_sel_o      (srcB),             // Multiplexer control signal to select the second ALU operand
            .alu_op_o           (aop),              // ALU operation
            .mem_req_o          (mrq),              // Memory access request (part of the memory interface)
            .mem_we_o           (mwe),              // Memory write enable signal, "write enable" (== 0 - read)
            .mem_size_o         (memi),             // Control signal to select the word size when reading-writing to memory (part of the memory interface)
            .gpr_we_a_o         (rfwe),             // Register file write enable signal
            .wb_src_sel_o       (WS),               // Multiplexer control signal for selecting data to be written to the register file
            .illegal_instr_o    (illegal_instr),    // Incorrect instruction signal (not marked on the diagram)
            .branch_o           (b),                // Conditional branch instruction signal
            .jal_o              (jal),              // Jal unconditional jump instruction signal
            .jalr_o             (jalr)              // Jarl unconditional jump instruction signal
  );

  rf register_file(
          .clk_i     (clk_i),
          .addr1_i   (instruction[19:15]),  // rd1 adress
          .addr2_i   (instruction[24:20]),  // rd2 adress
          .addr3_i   (instruction[11:7]),   // wd3 adress
          .wd_i      (wd3),	                // write port
          .we_i      (rfwe),                // control port
          .reset     (reset),               // reset port
          .rd1_o     (rd1),                 // first read port
          .rd2_o     (rd2)	                // second read port
  );

  miriscv_alu alu(
          .operator_i           (aop),
          .operand_a_i          (operand_a),
          .operand_b_i          (operand_b),
          .result_o             (result),
          .comparison_result_o  (comparsion_result)
  );


  always @ ( posedge clk_i ) begin

    // Main loop
    // program_counter <= (reset ? 32'h76000000 : ( jalr ? rd1 : (program_counter + program_counter_add) ))

    if (reset)
      program_counter <= 32'h76000000;
    else begin
      if (~( jal || (comparsion_result && b) ) )
        program_counter <= program_counter + 32'd4;
      else if (b)
        program_counter <= program_counter + imm_B;
      else
        program_counter <= program_counter + imm_J;
    end

  end

  assign  imm_I  =  {{20{instruction[31]}}, instruction[31:20]};
  assign  imm_S  =  {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
  assign  imm_J  =  {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
  assign  imm_B  =  {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

  always @ ( * ) begin

    debug_result <= rd;

    // Jal unconditional jump instruction signal
    program_counter_add = (~( jal || (comparsion_result && b) ) ? 32'd4 : ((b) ? imm_B : imm_J) );

    // Multiplexer control signal for selecting data to be written to the register file
    wd3 <= ( WS ? rd : result );

    // Multiplexer control signal to select the first ALU operand
    case (srcA)
      3'b000 :  operand_a <= rd1;
      3'b001 :  operand_a <= program_counter;
      3'b010 :  operand_a <= 32'd0;
  		default : operand_a <= 32'd0;
  	endcase

    // Multiplexer control signal to select the second ALU operand
    case (srcB)
      3'b000 :  operand_b <= rd2;
      3'b001 :  operand_b <= imm_I;
      3'b010 :  operand_b <= { instruction[31:12], {11{1'b0}} };
      3'b011 :  operand_b <= imm_S;
      3'b100 :  operand_b <= 32'd4;
  		default : operand_b <= 32'd0;
  	endcase

  end

endmodule
