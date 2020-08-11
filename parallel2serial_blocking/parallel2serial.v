`timescale 1ns/1ps
module parallel2serial(
  clk,
  nrst,
  en,
  data_in,
  data_out
);
  
  input clk,nrst,en;
  input [7:0] data_in;
  output data_out;
  
  reg [4:0] state;
  parameter S_IDLE = 5'd0;
  parameter S_PROCESS = 5'd1;
  
  reg [2:0] shiftctr;
  parameter SHIFTCTR_MAX = 3'd7;
  
  always@(posedge clk)
    if (!nrst)
      state = S_IDLE;
  	else
      case(state)
        
        S_IDLE:
          if (en == 1'b1)
           	state = S_PROCESS;
          else
            state = S_IDLE;
        
        S_PROCESS:
          if (shiftctr == SHIFTCTR_MAX)
            state = S_IDLE;
          else
            state = S_PROCESS;
        
        default:
          state = S_IDLE;
      endcase
  
  always@(posedge clk)
    if (!nrst)
      shiftctr = 0;
  	else
      case(state)
        
        S_IDLE:
          shiftctr = 0;
        S_PROCESS:
          if (shiftctr == SHIFTCTR_MAX)
            shiftctr = 0;
          else
          	shiftctr = shiftctr + 1;
        default:
          shiftctr = 0;
        
      endcase
  
  reg [7:0] data_sample;
  always@(posedge clk)
    if (!nrst)
      data_sample = 0;
  	else
      case(state)
        
        S_IDLE:
          if (en)
            data_sample = data_in;
        
        S_PROCESS:
          data_sample = {1'b0, data_sample[7:1]};
        
      endcase
  
  assign data_out = data_sample[0];
    
endmodule
