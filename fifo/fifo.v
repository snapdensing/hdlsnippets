`timescale 1ns/1ps
`include "regfile.v"
module fifo(
  clk,
  nrst,
  push,
  pop,
  data_in,
  data_out,
  full,
  empty
);
  
  input clk,nrst;
  input push,pop;
  input [7:0] data_in;
  output [7:0] data_out;
  output full, empty;
  
  reg full,empty;
  reg [7:0] data_out;
  
  reg wr_en;
  reg [2:0] rd_addr,wr_addr;
  wire [7:0] rf_out;
  
  regfile U0(
    .clk(clk),
    .wr_addr(wr_addr),
    .wr_en(wr_en),
    .wr_data(data_in),
    .rd_addr(rd_addr),
    .rd_data(rf_out)
  );
  
  wire [2:0] next_wr_addr, next_rd_addr;
  assign next_wr_addr = wr_addr + 1;
  assign next_rd_addr = rd_addr + 1;
  
  always@(*)
    if (!full && push)
      wr_en <= 1'b1;
  	else
      wr_en <= 0;
  
  always@(posedge clk)
    if (!nrst)
      wr_addr <= 0;
  	else
      if (!full && push)
        wr_addr <= next_wr_addr;
  
  always@(*)
    if (next_wr_addr == rd_addr)
      full <= 1'b1;
  	else
      full <= 0;
   
  always@(posedge clk)
    if (!nrst)
      rd_addr <= 0;
  	else
      if (!empty && pop)
        rd_addr <= next_rd_addr;
  
  always@(*)
    if (wr_addr == rd_addr)
      empty <= 1'b1;
  	else
      empty <= 0;
  
  always@(posedge clk)
    if (!nrst)
      data_out <= 0;
  	else
      if (!empty && pop)
        data_out <= rf_out;
  
endmodule
