`include "../defines/miriscv_defines.v"

module miriscv_core
(
  input              clk_i,            //
  input              arstn_i,          //

  input  [31:0]      instr_rdata_i,    //
  output  [31:0]      instr_addr_o,    //

  input              data_gnt_i,       //
  input              data_rvalid_i,    //
  input  [31:0]      data_rdata_i,     //

  output             data_req_o,       //
  output             data_we_o,        //
  output [3:0]       data_be_o,        //
  output [31:0]      data_addr_o,      //
  output [31:0]      data_wdata_o      //
);

  // Processor
  reg  [31:0] program_counter;

  wire enable = !arstn_i;

  // Instructions memory
  wire [31:0] instruction = instr_rdata_i;

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
  wire    [31:0]   imm_I;
  wire    [31:0]   imm_S;
  wire    [31:0]   imm_J;
  wire    [31:0]   imm_B;

  // LSU wires
  wire req;
  wire kill;

  initial program_counter = 32'h76000000;

  miriscv_lsu load_store_unit
  (
    // hards
    .clk_i              (clk_i),          // clock
    .arstn_i            (enable),        // reset

    // memory protocol
    .data_gnt_i         (data_gnt_i),     // ??? Signals that memory has started processing a request
    .data_rvalid_i      (data_rvalid_i),  // Reports the appearance of a response from memory for data_rdata_i and data_err_i
    .data_rdata_i       (data_rdata_i),   // The signal contains data from the memory cell at the time of the request acceptance
    .data_req_o         (data_req_o),     // The signal informs the memory about the presence of a request.
    .data_we_o          (data_we_o),      // The signal informs the memory about the type of request
    .data_be_o          (data_be_o),      // The signal is used to indicate the required bytes
    .data_addr_o        (data_addr_o),    // RAM Data address to write  (data_addr_ram)
    .data_wdata_o       (data_wdata_o),   // RAM Data to write (data_wdata_ram)

    // core protocol
    .lsu_addr_i         (result),         // Address to read/write to Data memory
    .lsu_we_i           (mwe),            // Write enable control port for Data memory
    .lsu_size_i         (memi),           // Word size control port for Data memory
    .lsu_data_i         (rd2),            // Write to Data memory port
    .lsu_req_i          (mrq),            // ??? Indicates that transaction happening
    .lsu_kill_i         (kill),           // Not need
    .lsu_stall_req_o    (enpc),           // Stop program_counter
    .lsu_data_o         (rd)              // Read to Data memory port
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

  miriscv_rf register_file(
          .clk_i     (clk_i),
          .addr1_i   (instruction[19:15]),  // rd1 adress
          .addr2_i   (instruction[24:20]),  // rd2 adress
          .addr3_i   (instruction[11:7]),   // wd3 adress
          .wd_i      (wd3),                 // write port
          .we_i      (rfwe),                // control port
          .reset     (enable),             // reset port
          .rd1_o     (rd1),                 // first read port
          .rd2_o     (rd2)                  // second read port
  );

  miriscv_alu alu(
          .operator_i           (aop),                  // Operation type input
          .operand_a_i          (operand_a),            // Operand a input
          .operand_b_i          (operand_b),            // Operand b input
          .result_o             (result),               // Result of math operation
          .comparison_result_o  (comparsion_result)     // Result of comparsion operation
  );

  assign instr_addr_o = program_counter; // Output program_counter to RAM (instead of instructions_memory) ???

  always @ ( posedge clk_i ) begin

    // Main loop
    if (enable)
      program_counter <= 32'h76000000;
    else begin
      if (!enpc) begin
        if (jalr)
          program_counter <= rd1 + imm_I;
        else begin
          if ( jal || (comparsion_result && b) )
            if (b)
              program_counter <= program_counter + imm_B;
            else
              program_counter <= program_counter + imm_J;
          else
            program_counter <= program_counter + 32'd4;
        end
      end
    end


  end

  assign  imm_I  =  {{20{instruction[31]}}, instruction[31:20]};
  assign  imm_S  =  {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
  assign  imm_J  =  {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
  assign  imm_B  =  {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

  always @ ( * ) begin

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
