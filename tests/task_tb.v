`timescale 1ns / 1ps

module task_tb();

reg           clk_i;
reg    [9:0]  switches_i;
reg           reset;

wire   [6:0]  hex1_o;
wire   [6:0]  hex2_o;

localparam CLK_FREQ_MHZ  = 5;                  // 100 MHz
localparam CLK_SEMI      = CLK_FREQ_MHZ / 2;   // 50  MHz

wire  [31:0]  instruction_addr;     // instruction_addr
wire  [31:0]  instruction;          // instruction
wire  [31:0]  wd;                   // wd
wire  [31:0]  read1;                // rd1
wire  [31:0]  read2;                // rd2
wire  [31:0]  result;               // result
wire          comparsion_result;    // comparsion_result

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

  int b = 0;
  int a = 0;
  int result = 0;

  while (b != 0) {
    if (b & 0x1 == 0x1)
      result += a;

    b >> = 1;
    a << = 1;
  }

  |31|30|29|28 27|26 25 24 23|22 21 20 19 18|17 16 15 14 13|12 11 10 9 8|7 6 5 4 3 2 1 0|
   B  C  WE  WS     ALUop          RA1            RA2           WA             CONST

  0_0_1_00_0000_00000_00000_00001_11111101 // reg[1] <- a                             || Put a const to 1 reg
  0_0_1_01_0000_00000_00000_00010_00000000 // reg[2] <- switches                      || Put a const to 2 reg
  0_0_1_00_0000_00000_00000_00011_00000000 // reg[3] <- 0                             || Make reg 3 accumulator of result
  0_0_1_00_0000_00000_00000_00100_00000001 // reg[4] <- 1                             || Put 1 const to 4 reg for compearations
  0_1_0_00_1100_00010_00000_00000_00001000 // if (reg[2] == reg[0]) PC <- PC + (7*4)  || If b = 0 > finish the Program
  0_0_1_10_0100_00010_00100_00101_00000000 // reg[5] <- reg[2] & reg[4]               || Check if b is odd
  0_1_0_00_1100_00101_00000_00000_00000010 // if (reg[5] == reg[0]) PC <- PC + (2*4)  || If b is odd add a to result
  0_0_1_10_0000_00011_00001_00011_00000000 // reg[3] <- reg[3] + reg[1]               || Adding a to result (accumulation)
  1_0_0_00_0000_00000_00000_00000_00000001 // PC <- PC + (1 * 4)                      || Skip for step bug
  0_0_1_10_0111_00001_00100_00001_00000000 // reg[1] <- reg[1] << reg[4]              || Multiplying a by 2
  0_0_1_10_0101_00010_00100_00010_00000000 // reg[2] <- reg[2] >>> reg[4]             || Dividing b by 2
  1_0_0_00_0000_00000_00000_00000_11111001 // PC <- PC + (-6 * 4)                     || Go back to first comparison
  0_0_1_10_0000_00011_00000_00011_00000000 // reg[3] <- reg[3] + reg[0]               || Making result signal equal to result
  1_0_0_00_0000_00100_00000_00000_00000000 // PC <- PC + (0 * 4)                      || Stop Program and output result

00100000000000000000000111111101
00101000000000000000001000000000
00100000000000000000001100000000
00100000000000000000010000000001
01000110000010000000000000001000
00110010000010001000010100000000
01000110000101000000000000000010
00110000000011000010001100000000
10000000000000000000000000000001
00110011100001001000000100000000
00110010100010001000001000000000
10000000000000000000000011111001
00110000000011000000001100000000
10000000000011000000000000000000

11111101
11111101

11111101
*/

initial begin

reset = 0;
#6
reset = 1;
#6
reset = 0;
testPP(10'b1111111011);

end

initial begin
  clk_i = 1'b1;
  forever begin
    #CLK_SEMI clk_i = ~clk_i;
  end
end

endmodule
