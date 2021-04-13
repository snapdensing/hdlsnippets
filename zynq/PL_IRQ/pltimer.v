`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2021 15:58:21
// Design Name: 
// Module Name: pltimer
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


module pltimer #(
    parameter COUNT_MAX = 27'd100000000,
    parameter COUNT_WID = 27)(
    input clk,
    input nrst,
    output trig_out,
    output count
    );
    
    wire [COUNT_WID-1:0] count;
    
    reg [COUNT_WID-1:0] counter;
    assign count = counter;
    
    always@(posedge clk)
        if (!nrst)
            counter <= 0;
        else
            if (counter != COUNT_MAX)
                counter <= counter + 1;
            else
                counter <= 0;
    //assign trig_out = (counter == COUNT_MAX)? 1'b1 : 0;                
    reg trig_out;
    always@(posedge clk)
        if (!nrst)
            trig_out <= 0;
        else
            case(counter)
                0,1,2,3,4,5,6,7,8,COUNT_MAX: trig_out <= 1;
                default:      trig_out <= 0;
            endcase
                           
endmodule
