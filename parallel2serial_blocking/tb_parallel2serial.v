// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
`define CLK_PERIOD 10

module tb_parallel2serial;
  
  reg clk, nrst, en;
  reg [7:0] data_in;
  wire data_out;
  
  parallel2serial UUT(
    .clk(clk),
    .nrst(nrst),
    .en(en),
    .data_in(data_in),
    .data_out(data_out)
  );
  
  always begin
    #(`CLK_PERIOD/2) clk = ~clk;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
    
    clk = 0;
    nrst = 0;
    en = 0;
    data_in = 8'd0;
    
    #(5*`CLK_PERIOD)
    nrst = 1'b1;
    
    #`CLK_PERIOD
    en = 1'b1;
    data_in = 8'hA5;
    
    #`CLK_PERIOD
    en = 0;
    data_in = 0;
    
    #(10 * `CLK_PERIOD)
    en = 1'b1;
    data_in = 8'h36;
    
    #`CLK_PERIOD
    en = 0;
    data_in = 0;
    
    #(10 * `CLK_PERIOD)
    $finish;
  end
endmodule
