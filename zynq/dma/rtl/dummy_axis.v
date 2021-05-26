`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.05.2021 17:42:51
// Design Name: 
// Module Name: dummy_axis
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dummy_axis(
    clk,
    nrst,
    s_axis_tdata,
    s_axis_tlast,
    s_axis_tvalid,
    s_axis_tready,
    datacap
    );

    input clk,nrst;
    input [7:0] s_axis_tdata;
    input s_axis_tlast;
    input s_axis_tvalid;
    output s_axis_tready;
    output [7:0] datacap;

    reg state;
    parameter S_IDLE = 1'd0;
    parameter S_TRAN = 1'd1;

    always@(posedge clk)
      if (!nrst)
        state <= S_IDLE;
      else
        case(state)
          S_IDLE:
            if (s_axis_tvalid)
              state <= S_TRAN;
            else
              state <= S_IDLE;

          S_TRAN:
            if (s_axis_tlast)
              state <= S_IDLE;
            else
              state <= S_TRAN;
        endcase

    assign s_axis_tready = (state == S_TRAN) ? 1'b1 : 0;

    reg [7:0] datacap;
    always@(posedge clk)
      if (!nrst)
        datacap <= 0;
      else
        if (s_axis_tvalid && s_axis_tready)
          datacap <= s_axis_tdata;
        else
          datacap <= datacap;

endmodule
