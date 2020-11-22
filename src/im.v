module im (
	input 		  [31:0] addr_i, // read adress
	output wire	[31:0] rd_o    // read port
);

reg [31:0] MEM [0:63]; // define of memory from instructions memory

initial $readmemh ("C:\\altera\\13.0sp1\\Projects\\Riscv_Processor\\data\\instructions.txt", MEM);

assign rd_o = (24'h760000 == addr_i[31:8]) ?  MEM[addr_i[7:2]] : 32'd0; // make boarder for Memory [0x76000000,0x760000FC]

endmodule
