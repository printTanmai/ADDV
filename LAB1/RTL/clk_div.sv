`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:37:38 07/02/2016
// Design Name: 
// Module Name:    clk_div 
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
module clk_div(
    input clk,
    
    output reg clk_div
    );
	 
reg clk1 = 1'b0;


always @ (posedge clk)
	begin
		
		clk1 <= ~clk1;
		clk_div <= clk1;
	end

endmodule
