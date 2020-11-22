/*

* B – выполнить безусловный переход;
* C – выполнить условный переход;
* WE – разрешение на запись в регистровый файл;
* WS[1:0] – источник данных для записи в регистровый файл (0 – константа
из инструкции, 1 – данные с переключателей, 2 – результат операции АЛУ;
* ALUop[3:0] – код операции, которую надо выполнить АЛУ;
* RA1[4:0] – адрес первого операнда для АЛУ;
* RA2[4:0] – адрес второго операнда для АЛУ;
* WA[4:0] – адрес регистра в регистровом файле, куда будет производиться
запись;
* const[7:0] – 8-битное значение константы.
|31|30|29|28 27|26 25 24 23|22 21 20 19 18|17 16 15 14 13|12 11 10 9 8|7 6 5 4 3 2 1 0|
 B  C  WE  WS     ALUop          RA1            RA2           WA             CONST

*/

module proto_processor
(
  input           clk_i,
  input    [9:0]  switches_i,
  input           reset,

  output   [6:0]  hex1_o,
  output   [6:0]  hex2_o,

  output reg  [31:0]  debug_result,

  output reg  [31:0]  debug0, // instruction_addr
  output reg  [31:0]  debug1, // instruction
  output reg  [31:0]  debug2, // wd
  output reg  [31:0]  debug3, // rd1
  output reg  [31:0]  debug4, // rd2
  output reg  [31:0]  debug5, // result
  output reg          debug6  // comparsion_result

);

reg      [31:0]   instruction_addr;
reg      [31:0]   wd;

wire     [31:0]   instruction;
wire     [31:0]   rd1;
wire     [31:0]   rd2;
wire     [31:0]   result;
wire              comparsion_result;
wire     [31:0]   se;
wire     [31:0]   data_data;
wire              data_we;

initial instruction_addr <= 32'h76000000; // Program Counter

hex_decoder display1(
   .hex_i		 (result[3:0]),
   .hex_o	   (hex1_o)
);

hex_decoder display2(
   .hex_i		 (result[7:4]),
   .hex_o	   (hex2_o)
);

dm data(
  .clk_i    (clk_i),              // read adress
  .addr_i   (instruction_addr),   // write port
  .wd_i     (data_data),          // control port
  .we_i     (data_we),            // read port
  .rd_o     (instruction)
);

rf registers(
  .clk_i    (clk_i),
  .addr1_i (instruction[22:18]),    // rd1 adress
  .addr2_i (instruction[17:13]),    // rd2 adress
  .addr3_i (instruction[12:8]),     // wd adress
  .wd_i    (wd),                    // write port
  .we_i    (instruction[29]),       // control port
  .reset   (reset),                  // reset port
  .rd1_o   (rd1),                   // first read port
  .rd2_o   (rd2)                    // second read port
);

miriscv_alu alu(
  .operator_i           (instruction[26:23]),
  .operand_a_i          (rd1),
  .operand_b_i          (rd2),
  .result_o             (result),
  .comparison_result_o  (comparsion_result)
);

assign  se =  {{24{instruction[7]}},instruction[7:0]}; // 8b > 32b

always @ ( * ) begin
  debug0 <= instruction_addr;   // instruction_addr
  debug1 <= instruction;        // instruction
  debug2 <= wd;                 // wd
  debug3 <= rd1;                // rd1
  debug4 <= rd2;                // rd2
  debug5 <= result;             // result
  debug6 <= comparsion_result;  // comparsion_result

  debug_result <= result;
end

always @ ( posedge clk_i ) begin
  if (reset) instruction_addr <= 32'h76000000;
  else if (instruction[31])
    instruction_addr <= instruction_addr + (se << 2); // align of adress
  else if (instruction[30])
      begin
        if (comparsion_result == 1)
          instruction_addr <= instruction_addr + (se << 2);
        else
          instruction_addr <= instruction_addr + 32'd4;
      end
  else
    instruction_addr <= instruction_addr + 32'd4;
end

// Choosing source of data
always @ ( * ) begin
	case (instruction[28:27])
		2'b00 :   wd[31:0] <= se;
		2'b01	:   wd[31:0] <= {{22{switches_i[9]}},switches_i[9:0]};
		2'b10 :   wd[31:0] <= result;
		default : wd[31:0] <= 32'd0;
	endcase
end

endmodule
