`timescale 1ns/1ps
module regfile(
  clk,
  wr_addr,
  wr_data,
  wr_en,
  rd_addr,
  rd_data
);
  
  input clk;
  input [2:0] wr_addr,rd_addr;
  input [7:0] wr_data;
  output [7:0] rd_data;
  input wr_en;
  
  reg [7:0] d0,d1,d2,d3,d4,d5,d6,d7;
  reg [7:0] rd_data;
  
  always@(posedge clk)
    if (wr_en)
      case(wr_addr)
        3'd0: d0 <= wr_data;
        3'd1: d1 <= wr_data;
        3'd2: d2 <= wr_data;
        3'd3: d3 <= wr_data;
        3'd4: d4 <= wr_data;
        3'd5: d5 <= wr_data;
        3'd6: d6 <= wr_data;
        3'd7: d7 <= wr_data;
      endcase
  
  always@(*)
    case(rd_addr)
      3'd0: rd_data <= d0;
      3'd1: rd_data <= d1;
      3'd2: rd_data <= d2;
      3'd3: rd_data <= d3;
      3'd4: rd_data <= d4;
      3'd5: rd_data <= d5;
      3'd6: rd_data <= d6;
      3'd7: rd_data <= d7;
    endcase
  
endmodule
