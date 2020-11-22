module hex_decoder (
	input 			  [3:0] 	hex_i	,
	output reg 		[6:0]		hex_o
	);
	
always@( * )
  begin
    case ( hex_i[3:0] )
      4'd0  : hex_o = 7'b1000000;
      4'd1  : hex_o = 7'b1111001;
      4'd2  : hex_o = 7'b0100100;
      4'd3  : hex_o = 7'b0110000;
      4'd4  : hex_o = 7'b0011001;
      4'd5  : hex_o = 7'b0010010;
      4'd6  : hex_o = 7'b0000010;
      4'd7  : hex_o = 7'b1111000;
      4'd8  : hex_o = 7'b0000000;
      4'd9  : hex_o = 7'b0010000;
      4'd10 : hex_o = 7'b0001000;
      4'd11 : hex_o = 7'b0000011;
      4'd12 : hex_o = 7'b1000110;
      4'd13 : hex_o = 7'b0100001;
      4'd14 : hex_o = 7'b0000110;
      4'd15 : hex_o = 7'b0001110;
    endcase
	end

endmodule
