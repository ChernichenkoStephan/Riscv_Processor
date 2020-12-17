`timescale 1ns / 1ps

module im_tb();

reg  [31:0] addr_i;  // read adress
wire [31:0]  rd_o;   // read port

miriscv_im instructions_memory (addr_i, rd_o);

task testIM;
  input integer input_addr;
  begin
  addr_i = input_addr;
  #50
  $display("--------------------------------------------");
  $display("Addres: %d", addr_i - 32'h76000000, " Read  port value: %d / %b", rd_o, rd_o);
  end
endtask

initial begin
  $display("\nREAD FROM FILE TEST");
  testIM(32'h76000001);
  testIM(32'h76000002);
  testIM(32'h76000003);
  testIM(32'h76000004);
  testIM(32'h76000005);
  testIM(32'h76000006);
  testIM(32'h76000007);
  testIM(32'h76000008);
  testIM(32'h76000009);
  testIM(32'h7600000a);
  testIM(32'h7600000b);
  testIM(32'h7600000c);
end

endmodule
