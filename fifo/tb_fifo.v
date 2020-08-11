`timescale 1ns/1ps
`define CLK_PERIOD 10

module tb_fifo;
  reg clk,nrst;
  reg push,pop;
  reg [7:0] data_in;
  wire [7:0] data_out;
  wire full,empty;
  
  fifo UUT(
    .clk(clk),
    .nrst(nrst),
    .push(push),
    .pop(pop),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );
  
  always begin
    #(`CLK_PERIOD/2) clk = ~clk;
  end
  
  initial begin
    $dumpfile("tb_fifo.vcd");
    $dumpvars(0,UUT);
    clk = 0;
    nrst = 0;
    push = 0;
    pop = 0;
    data_in = 0;
    #(`CLK_PERIOD*5)
    nrst = 1'b1;
    
    #(`CLK_PERIOD*5)
    push = 1'b1;
    data_in = 8'hab;
    #(`CLK_PERIOD)
    push = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    push = 1'b1;
    data_in = 8'h12;
    #(`CLK_PERIOD)
    push = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    push = 1'b1;
    data_in = 8'h34;
    #(`CLK_PERIOD)
    push = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    push = 1'b1;
    data_in = 8'h56;
    #(`CLK_PERIOD)
    push = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    push = 1'b1;
    data_in = 8'h78;
    #(`CLK_PERIOD)
    push = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    push = 1'b1;
    data_in = 8'h9a;
    #(`CLK_PERIOD)
    push = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    push = 1'b1;
    data_in = 8'hbc;
    #(`CLK_PERIOD)
    push = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    pop = 1'b1;
    #(`CLK_PERIOD)
    pop = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    push = 1'b1;
    data_in = 8'hde;
    #(`CLK_PERIOD)
    push = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    pop = 1'b1;
    #(`CLK_PERIOD)
    pop = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    pop = 1'b1;
    #(`CLK_PERIOD)
    pop = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    pop = 1'b1;
    #(`CLK_PERIOD)
    pop = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    pop = 1'b1;
    #(`CLK_PERIOD)
    pop = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    pop = 1'b1;
    #(`CLK_PERIOD)
    pop = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    push = 1'b1;
    data_in = 8'hf0;
    #(`CLK_PERIOD)
    push = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    pop = 1'b1;
    #(`CLK_PERIOD)
    pop = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    pop = 1'b1;
    #(`CLK_PERIOD)
    pop = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*2)
    pop = 1'b1;
    #(`CLK_PERIOD)
    pop = 0;
    data_in = 0;
    
    #(`CLK_PERIOD*10)
    $finish;
    
  end
  
endmodule
