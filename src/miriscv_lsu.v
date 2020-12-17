// dmem type load store
`define LDST_B           3'b000
`define LDST_H           3'b001
`define LDST_W           3'b010
`define LDST_BU          3'b100
`define LDST_HU          3'b101

module miriscv_lsu
(
  // hards
  input           clk_i,              // clock
  input           arstn_i,            // reset

  // memory protocol
  input              data_gnt_i,           // Not need but (Signals that memory has started processing a request)
  input              data_rvalid_i,        // Reports the appearance of a response from memory for data_rdata_i and data_err_i
  input [31:0]       data_rdata_i,         // The signal contains data from the memory cell at the time of the request acceptance
  output             data_req_o,           // The signal informs the memory about the presence of a request.
  output             data_we_o,            // The signal informs the memory about the type of request
  output reg [3:0]   data_be_o,            // The signal is used to indicate the required bytes
  output     [31:0]  data_addr_o,          // Data address to write  (data_addr_ram)
  output reg [31:0]  data_wdata_o,         // Data to write (data_wdata_ram)

  // core protocol
  input [31:0]       lsu_addr_i,         // Address to read/write to Data memory
  input              lsu_we_i,           // Write enable control port for Data memory
  input [2:0]        lsu_size_i,         // Word size control port for Data memory
  input [31:0]       lsu_data_i,         // Data memory port
  input              lsu_req_i,          // Indicates that transaction happening
  input              lsu_kill_i,         // Not need
  output             lsu_stall_req_o,    // Stop program_counter
  output reg [31:0]  lsu_data_o          // Data memory port
);

assign data_addr_o = lsu_addr_i;
assign lsu_stall_req_o = (!data_rvalid_i && lsu_req_i);

assign data_req_o = lsu_req_i && !data_rvalid_i;
assign data_we_o = lsu_req_i && lsu_we_i && !data_rvalid_i;


always @ ( * ) begin

if (!arstn_i) begin

  if (lsu_req_i)
  begin

    if (lsu_we_i) begin
    /* --- Write (STORE) mode --- */


      case (lsu_size_i)

        // sign 8-bit value
        3'b000://LDST_B:
        begin
          data_wdata_o = { 4 { lsu_data_i[7:0] } };

          case (lsu_addr_i[1:0])
            // first bite
            2'b00: data_be_o = 4'b0001;
            // second bite
            2'b01: data_be_o = 4'b0010;
            // third bite
            2'b10: data_be_o = 4'b0100;
            // fourth bite
            2'b11: data_be_o = 4'b1000;
            // // Other
            // default: data_be_o = 4'b1111;
          endcase
        end



        // sign 16-bit value
        3'b001://LDST_H:
        begin
        data_wdata_o = { 2 { lsu_data_i[15:0] } };

        case (lsu_addr_i[1:0])
          // first bite
          2'b00: data_be_o = 4'b0011;
          // second bite
          2'b01: data_be_o = 4'b1100;
        endcase
        end

        // sign 32-bit value
        3'b010://LDST_W:
        begin
          data_wdata_o = lsu_data_i[31:0];
          data_be_o = 4'b1111;
        end

      endcase

    end
    else begin
    /* --- Read (LOAD) mode --- */

      case (lsu_size_i)
        // sign 8-bit value
        3'b000://LDST_B:
        begin
        case (lsu_addr_i[1:0])
          2'b00: lsu_data_o = { { 24 { data_rdata_i[7] } }, data_rdata_i[7:0] };
          2'b01: lsu_data_o = { { 24 { data_rdata_i[15] } }, data_rdata_i[15:8] };
          2'b10: lsu_data_o = { { 24 { data_rdata_i[23] } }, data_rdata_i[23:16] };
          2'b11: lsu_data_o = { { 24 { data_rdata_i[31] } }, data_rdata_i[31:24] };
        endcase
        end

        // sign 16-bit value
        3'b001://LDST_H:
        begin
        case (lsu_addr_i[1:0])
          2'b00: lsu_data_o = { { 16 { data_rdata_i[15] } }, data_rdata_i[15:0] };
          2'b01: lsu_data_o = { { 16 { data_rdata_i[31] } }, data_rdata_i[31:16] };
        endcase
        end

        // sign 32-bit value
        3'b010://LDST_W:
        lsu_data_o = data_rdata_i[31:0];

        // unsign 8-bit value
        3'b100://LDST_BU:
        begin
        case (lsu_addr_i[1:0])
          2'b00: lsu_data_o = { 24'b0, data_rdata_i[7:0] };
          2'b01: lsu_data_o = { 24'b0, data_rdata_i[15:8] };
          2'b10: lsu_data_o = { 24'b0, data_rdata_i[23:16] };
          2'b11: lsu_data_o = { 24'b0, data_rdata_i[31:24] };
        endcase
        end

        // unsign 16-bit value
        3'b101://LDST_HU:
        begin
        case (lsu_addr_i[1:0])
          2'b00: lsu_data_o = { 16'b0, data_rdata_i[15:0] };
          2'b01: lsu_data_o = { 16'b0, data_rdata_i[31:16] };
        endcase
        end

      endcase

    end
  end


end

end


endmodule
