`timescale 1ns / 1ps

module dm_tb();

reg         clk_i;
reg [3:0]       I;
reg [31:0] addr_i;   // read adress
reg [31:0]   wd_i;   // write port
reg          we_i;   // control port

wire [31:0]  rd_o;   // read port

dm data_memory (clk_i, I, addr_i, wd_i, we_i, rd_o);

localparam CLK_FREQ_MHZ  = 5;                  // 100 MHz
localparam CLK_SEMI      = CLK_FREQ_MHZ / 2;   // 50  MHz

task testDM;

  input integer input_addr;
  input integer input_data;

  begin

    addr_i = input_addr;
    wd_i   = input_data;

    #50
	  $display("--------------------------------------------");
    $display("Addres: %d", addr_i, " Write port value: %d / %b", wd_i, wd_i);
    $display("Addres: %d", addr_i, " Read  port value: %d / %b", rd_o, rd_o);
    if (wd_i != rd_o)
  		$error("*** TEST FAILED ***");
  end

endtask

initial begin

  $display("\nREAD TEST");
  we_i = 0;
  testDM(32'h00000004, 32'b_0000_0000_0000_0000_0000_0000_0000_0000);
  testDM(32'h00000008, 32'b_0000_0000_0000_0000_0000_0000_0000_0000);

  // $display("\nWRITE ENABELED TEST");
  // we_i = 1;
  // testDM(32'h00000000, 32'b_0000_0000_0000_0000_0000_0000_0000_0000);
  // testDM(32'h00000001, 32'b_0000_0000_0000_0000_0000_0000_0000_0001);
  // testDM(32'h00000002, 32'b_0000_0000_0000_0000_0000_0000_0000_0011);
  // testDM(32'h00000003, 32'b_0000_0000_0000_0000_0000_0000_0000_0111);
  // testDM(32'h00000004, 32'b_0000_0000_0000_0000_0000_0000_0000_1111);
  //
  // $display("\nWRITE DISABLED TEST");
  // we_i = 0;
  // testDM(32'h00000004, 32'b_0000_0000_0000_0000_0000_0000_0000_0000);

end

initial begin
  clk_i = 1'b1;
  forever begin
    #CLK_SEMI clk_i = ~clk_i;
  end
end

endmodule
