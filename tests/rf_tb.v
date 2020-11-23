`timescale 1ns / 1ps

module rf_tb();

reg           clk_i;
reg   [4:0]   addr1_i;  // rd1 adress
reg   [4:0]   addr2_i;  // rd2 adress
reg   [4:0]   addr3_i;  // wd adress
reg   [31:0]  wd_i;     // write port
reg           we_i;     // control port
reg           reset;    // reset port

wire  [31:0]    rd1_o;  // first read port
wire  [31:0]    rd2_o;  // second read port

rf RAM (clk_i, addr1_i, addr2_i, addr3_i, wd_i, we_i, reset, rd1_o, rd2_o);

localparam CLK_FREQ_MHZ  = 5;                  // 100 MHz
localparam CLK_SEMI      = CLK_FREQ_MHZ / 2;   // 50  MHz

task testRF;
  input integer addr_1;
  input integer addr_2;
  input integer addr_3;
  input integer WD;

  begin
  addr1_i = addr_1;
  addr2_i = addr_2;
  addr3_i = addr_3;
  wd_i    =     WD;

  #10

  /*
  Второе задание
  Хотя созданные модули относительно просты, тем не менее необходимо убедиться в
  правильности их функционирования. Для этого нужно написать testbench реализующий,
  на модели, последовательную автоматическую запись во все регистры RF некоторых
  случайных значений, а затем их считывание; убеждаясь в правильности записанного.
  В результате работы в терминал должны быть выведены сообщения: (1) об адресах
  регистров, в которые производится запись, (2) данные, которые были записаны,
  (3) считаны и (4) результат автоматического сравнения в конце в виде сообщения
  «good» или «bad», в случае успехов и ошибок, соответственно.
  */

  $display("--------------------------------------------");
  $display("WRITE)   Addres: %d", addr_3, "\t Port value: %d", WD);
  $display("READ_1)  Addres: %d", addr_1, "\t Port value: %d", rd1_o);
  $display("READ_2)  Addres: %d", addr_2, "\t Port value: %d", rd2_o);

  if (rd1_o != wd_i)
    $error("*** TEST FAILED ***");

  end
endtask

task test_ONE_PORT_READ_RF;
  input integer addr_1;
  input integer addr_3;
  input integer WD;

  begin
  addr1_i = addr_1;
  addr3_i = addr_3;
  wd_i    =     WD;

  #10

  $display("--------------------------------------------");
  $display("WRITE)   Addres: %d", addr_3, "\t Port value: %d", WD);
  $display("READ)    Addres: %d", addr_1, "\t Port value: %d", rd1_o);


  if (rd1_o != wd_i)
    $error("*** ONE PORT READ TEST FAILED ***");

  end
endtask

task test_RESET_RF;
  begin
  reset  = 1;
  addr1_i = 4'b0001;
  addr2_i = 4'b0010;
  #20
  $display("rd1_o: %d", rd1_o, "\t rd2_o: %d", rd2_o);

  if (rd1_o != 32'b_0000_0000_0000_0000_0000_0000_0000_0000 ||
      rd2_o != 32'b_0000_0000_0000_0000_0000_0000_0000_0000)
    $error("*** RESET TEST FAILED ***");

  addr1_i = 4'b0100;
  addr2_i = 4'b1111;
  #20
  $display("rd1_o: %d", rd1_o, "\t rd2_o: %d", rd2_o);
  if (rd1_o != 32'b_0000_0000_0000_0000_0000_0000_0000_0000 ||
      rd2_o != 32'b_0000_0000_0000_0000_0000_0000_0000_0000)
    $error("*** RESET TEST FAILED ***");

  end
endtask


initial begin

  $display("\nWRITE ENABELED TEST");
  we_i   = 1;
  reset  = 0;

  //                     addres1  addres3  data
  test_ONE_PORT_READ_RF(4'b0001, 4'b0001, 32'b_0000_0000_0000_0000_0000_0000_0000_0110);
  test_ONE_PORT_READ_RF(4'b0010, 4'b0010, 32'b_0000_0000_0000_0000_0000_0000_0000_0110);
  test_ONE_PORT_READ_RF(4'b0100, 4'b0100, 32'b_0000_0000_0000_0000_0000_0000_0000_0110);
  test_ONE_PORT_READ_RF(4'b1111, 4'b1111, 32'b_0000_0000_0000_0000_0000_0000_0000_0110);

  //     addres1  addres2  addres3  data
  testRF(4'b0001, 4'b0010, 4'b0001, 32'b_0000_0000_0000_0000_0000_0000_0000_0110);


  $display("\nWRITE DISABLED TEST");
  we_i   = 0;
  reset  = 0;
  test_ONE_PORT_READ_RF(4'b0001, 4'b0001, 32'b_0000_0000_0000_0000_0000_0000_0000_1111);

  $display("\nFIRST REG TEST");
  we_i   = 1;
  reset  = 0;
  test_ONE_PORT_READ_RF(4'b0000, 4'b0000, 32'b_0000_0000_0000_0000_0000_0000_0000_0110);

  $display("\nRESET TEST");
  test_RESET_RF();

end

initial begin
  clk_i = 1'b1;
  forever begin
    #CLK_SEMI clk_i = ~clk_i;
  end
end


endmodule
