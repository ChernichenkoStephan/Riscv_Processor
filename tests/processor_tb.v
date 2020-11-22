`timescale 1ns / 1ps

module processor_tb();

reg           clk_i;
reg           reset;

localparam CLK_FREQ_MHZ  = 5;                  // 100 MHz
localparam CLK_SEMI      = CLK_FREQ_MHZ / 2;   // 50  MHz

wire [31:0] result;

riscv_processor processor( clk_i, reset, result );

/*

#  int b = 0;
#  int a = 0;
#  int result = 0;

#  while (b != 0) {
# 	 if (b & 0x1 == 0x1)
# 		 result += a;

# 	 b >> = 1;
# 	 a << = 1;
#  }

.globl __start

.text
__start:
		addi x7, x0, 4					#										|| Define a address
		addi x8, x0, 8					#										|| Define b address
		lw x9, 0(x7)						#										|| Load a
		lw x10, 0(x8)						#										|| Load b
		addi x11, x0, 0					# x11 <- 0    			|| Make reg 11 accumulator of result
		addi x12, x0, 1					# x12 <- 0x1  			|| Put 1 const to 12 reg for compearations
		jal mult								# mult(a, b)			  || Calling function
return:
		addi x15, x0, 12				# output result			|| Define result address
		sw x11, 0(x15)          # output result			|| Writing result to memory
		lw x11, 0(x15)					#										|| Print result
		nop											# 									|| finish the programm
		jal Exit								# 									|| exit programm

mult:
	while_start:								# {					   			|| start of while loop
			beq x10, x0, while_end  # while (b != 0)  	|| Check if (b != 0)
			and x13, x10, x12 			# x13 = b & 0x1     || Prepear b to compearations
			bne x13, x12, if 				# if (x13 == 0x1){	|| Check if b is even
			add x11, x11, x9 				# result += a;			|| Accumulating of result
	if:													# }									|| If's skip
			srl x10, x10, x12				# b >> = 1;					|| Dividing b by 2
			sll x9, x9, x12					# a << = 1;					|| Multiplying a by 2
			jal while_start				  #			 				     	|| While's go to
	while_end:								  # }									|| While close bracket
			jal return							# 									|| Returning to main func

Exit:
	nop
  tail Exit

*/


task testProcessor;

	begin

	#95

	$display("=====================================");
  $display("Result: %b/%d", result, result );
  $display("=====================================");

	end
endtask

initial begin
reset = 1;
#6
reset = 0;
#6
testProcessor();


end

initial begin
  clk_i = 1'b1;
  forever begin
    #CLK_SEMI clk_i = ~clk_i;
  end
end

endmodule
