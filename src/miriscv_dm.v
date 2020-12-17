module miriscv_dm (
  input                 clk_i,
  input       [3:0]     I,      // word size
  input       [31:0]    addr_i, // read adress
  input       [31:0]    wd_i,   // write port
  input                 we_i,   // control port
  output wire [31:0]    rd_o    // read port
  );

  reg [31:0] MEM [0:63]; // define of memory from instructions memory

  initial $readmemb ("C:\\altera\\13.0sp1\\Projects\\Riscv_Processor\\data\\data.txt", MEM);

  assign rd_o = MEM[addr_i[7:2]]; // make boarder for Memory

  always @ (posedge clk_i)
  begin
    if (we_i)
      begin
        MEM[addr_i[7:2]] <= wd_i;
      end
  end

endmodule
