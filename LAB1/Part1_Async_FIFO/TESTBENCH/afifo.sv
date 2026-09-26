`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:39:04 06/02/2016 
// Design Name: 
// Module Name:    afifo 
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
module afifo_tb;
reg  write_en;
reg  w_clk;
reg  read_en;
reg  r_clk;
//reg  preset_empty;
//reg  preset_full;
reg  clr;
reg  [7:0] w_data;
wire [7:0] r_data;
wire empty;
wire full; 

afifo m(r_data,full,empty,w_data,w_clk,r_clk,write_en,read_en,clr);

initial
begin
w_data=8'h00;
#20   w_data=8'h01;
#20   w_data=8'h02;
#20   w_data=8'h03;
#20   w_data=8'h04;
#20   w_data=8'h05;
#20   w_data=8'h06;
#20   w_data=8'h07;
#20   w_data=8'h08;
#20   w_data=8'h09;
end

initial
begin
	 //w_data = 8'b0000_0000;
    w_clk    = 1'b1;
    write_en = 1'b0;
    r_clk    = 1'b1;
    read_en  = 1'b0;
    clr      = 1'b1;
#10 	 clr         = 1'b0;
#10    write_en    = 1'b1;
#20    read_en	    = 1'b1;
#500   $finish;
end

//initial
always #10   w_clk        <= ~w_clk;

always #20   r_clk        <= ~r_clk;

initial begin
	$fsdbDumpvars();
end

endmodule

