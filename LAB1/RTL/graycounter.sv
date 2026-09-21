`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:34:24 06/02/2016
// Design Name: 
// Module Name:    graycounter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module graycounter(gray_out, binary_count,en_in,clr_in,clk);
parameter counter_width = 4;

input logic en_in;
input logic clr_in;
input logic clk;
output logic[counter_width-1:0] gray_out;
output logic[counter_width-1:0] binary_count;

always @(posedge clk)
 if(clr_in)
 begin
   binary_count <= {counter_width{1'b0}}+1;
   gray_out     <= {counter_width{1'b0}};
 end
 else if(en_in)
      begin
         binary_count <= binary_count + 1;
         gray_out     <= {binary_count[counter_width-1],binary_count[counter_width-2:0] ^ binary_count[counter_width-1:1]};
      end
endmodule
