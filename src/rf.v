module rf (
	input          clk_i,
	input  [4:0] addr1_i,   // rd1 adress
	input  [4:0] addr2_i,   // rd2 adress
	input  [4:0] addr3_i,   // wd adress
	input  [31:0]   wd_i,   // write port
	input           we_i,   // control port
	input          reset,   // reset port
	output [31:0]  rd1_o,   // first read port
	output [31:0]  rd2_o    // second read port
	);

integer i; // variable for reset loop

reg [31:0] RAM [0:31];

// make first reg const 0
assign rd1_o = (addr1_i != 32'd0) ?  RAM[addr1_i] : 32'd0;
assign rd2_o = (addr2_i != 32'd0) ?  RAM[addr2_i] : 32'd0;

always @ (posedge clk_i)
	begin
		if (we_i)
			begin
				if (addr3_i != 5'd0) RAM[addr3_i] <= wd_i; // making shure that we wouldn't write to first reg
			end
		if (reset)
			begin
				for (i = 0; i < 32; i = i + 1)
					begin
						RAM[i] <= 32'd0;
					end
			end
	end


endmodule
