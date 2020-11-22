`timescale 1ns / 1ps

module processor_tb();

reg           clk_i;
reg           reset;

localparam CLK_FREQ_MHZ  = 5;                  // 100 MHz
localparam CLK_SEMI      = CLK_FREQ_MHZ / 2;   // 50  MHz

wire [31:0] result;

riscv_processor processor( clk_i, reset, result );

/*

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
