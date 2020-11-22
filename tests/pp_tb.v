`timescale 1ns / 1ps

module pp_tb();

reg           clk_i;
reg    [9:0]  switches_i;
reg           reset;

wire   [6:0]  hex1_o;
wire   [6:0]  hex2_o;

localparam CLK_FREQ_MHZ  = 5;                  // 100 MHz
localparam CLK_SEMI      = CLK_FREQ_MHZ / 2;   // 50  MHz

wire  [31:0]  instruction_addr; 	// instruction_addr
wire  [31:0]  instruction; 				// instruction
wire  [31:0]  wd; 								// wd
wire  [31:0]  read1; 							// rd1
wire  [31:0]  read2; 							// rd2
wire  [31:0]  result; 						// result
wire          comparsion_result; 	// comparsion_result



wire  [31:0]  debug_result;

proto_processor proc(
.clk_i(clk_i),
.switches_i(switches_i),
.reset(reset),
.hex1_o(hex1_o),
.hex2_o(hex2_o),
.debug_result(debug_result),
.debug0(instruction_addr),
.debug1(instruction),
.debug2(wd),
.debug3(read1),
.debug4(read2),
.debug5(result),
.debug6(comparsion_result)
);


task testPP;

	input integer sw;

	begin
	switches_i = sw;

	#100

	$display("=====================================");
  $display("Switches: %b", switches_i );
  $display("Result  = %d / %b ", debug_result, debug_result);
  $display("First display o  = %d / %b ", hex1_o, hex1_o);
  $display("Second display o = %d / %b ", hex2_o, hex2_o);
  $display("=====================================");


	end
endtask

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

Обработка данных на АЛУ.
0_0_1_10_dddd_ddddd_ddddd_ddddd_xxxxxxxx

Загрузка константы из инструкции в регистровый файл по адресу WA.
0_0_1_00_xxxx_xxxxx_xxxxx_ddddd_dddddddd

Загрузка константы, выставленной на переключателях (switches) в регистровый файл по адресу WA.
0_0_1_01_xxxx_xxxxx_xxxxx_ddddd_xxxxxxxx

Безусловный переход.
1_0_0_xx_xxxx_xxxxx_xxxxx_xxxxx_dddddddd

Инструкция условного перехода.
0_1_0_xx_dddd_ddddd_ddddd_xxxxx_dddddddd


0_0_1_00_0000_00000_00000_00001_00001101// reg[1] ← 13 || размещаем в регистре эталонное число 13
0_0_1_01_0000_00000_00000_00010_00000000// reg[2] ← switches || запоминаем сколько сделать повторений
0_0_1_00_0000_00000_00000_00011_00000001// reg[3] ← 1 || чтобы уменьшать количество оставшихся кругов
0_1_0_00_1100_00010_00000_00000_00000100// if reg[2] == reg[0]) PC ← PC + (4*4) || если осталось 0 кругов, то в конец
0_0_1_10_0000_00100_00001_00100_00000000// reg[4] ← reg[4] + reg[1] || прибавить 13 к итоговому произведению
0_0_1_10_0001_00010_00011_00010_00000000// reg[2] ← reg[2] - reg[3] || уменьшить количество оставшихся кругов на 1
1_0_0_00_0000_00000_00000_00000_11111101// PC ← PC + (–3 * 4) || вернуться на 3 инструкции назад
1_0_0_00_0000_00100_00000_00000_00000000// PC ← PC + (0 * 4) || остановить программу и вывести ответ

00100000000000000000000100001101
00101000000000000000001000000000
00100000000000000000001100000001
01000110000010000000000000000100
00110000000100000010010000000000
00110000100010000110001000000000
10000000000000000000000011111101
10000000000100000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000

*/

initial begin

reset = 0;
#6
reset = 1;
#6
reset = 0;
testPP(10'b0000000001);
#6
reset = 0;
#6
reset = 1;
#6
reset = 0;
testPP(10'b0000000010);
#6
reset = 0;
#6
reset = 1;
#6
reset = 0;
testPP(10'b0000000011);

end

initial begin
  clk_i = 1'b1;
  forever begin
    #CLK_SEMI clk_i = ~clk_i;
  end
end

endmodule
