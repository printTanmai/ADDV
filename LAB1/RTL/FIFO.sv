`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:21:38 06/02/2016 
// Design Name: 
// Module Name:    FIFOCODE 
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
module afifo(r_data,full,empty,w_data,w_clk,r_clk,write_en,read_en,clr);
parameter data_width    = 8;
parameter address_width = 4;
parameter fifo_depth    = 8;

input [data_width-1:0] w_data;
input                  w_clk;
input                  write_en;
input                  r_clk;
input                  read_en;
input                  clr;

output logic                  full;
output logic [data_width-1:0] r_data;
output logic                  empty;
output logic            almost_full;
output logic            almost_empty;

logic status;

logic [address_width-1:0]  wptr,rptr;
logic                      presetempty,presetfull;
logic [address_width-1:0]  w_addr,r_addr;
logic                      w_addr_en,r_addr_en;
logic                      set_status;
logic                      rst_status;

logic [data_width-1:0] fifo[0:fifo_depth-1];

always @(posedge w_clk)
if(write_en & !full)
	fifo[wptr] <=w_data;

always @(posedge r_clk)
if(read_en & !empty)
	r_data <=fifo[rptr];
	
assign w_addr_en= write_en & !full;
assign r_addr_en= read_en  & !empty;

graycounter graycounter_pwr(.gray_out(wptr),
                            .binary_count(wbin),
                            .en_in(w_addr_en),
                            .clr_in(clr),
                            .clk(w_clk)
                             );
 
graycounter graycounter_prd(.gray_out(rptr),
                            .binary_count(rbin),
                            .en_in(r_addr_en),
                            .clr_in(clr),
                            .clk(r_clk)
                            );
 
assign equaladdress =(wptr==rptr);
assign set_status = (wptr[address_width-2] ~^ rptr[address_width-1]) & (wptr[address_width-1] ^ rptr[address_width-2]);
assign rst_status = (wptr[address_width-2] ^  rptr[address_width-1])  & (wptr[address_width-1] ~^ rptr[address_width-2]);
                             
always @ (set_status,rst_status,clr)
if(rst_status|clr)
	status=0;

else if(set_status)
	status=1;

assign presetfull	= status & equaladdress;

always @(posedge w_clk,posedge presetfull)
if(presetfull)
	full<=1;
	else
	full<=0;

assign presetempty=~status & equaladdress;



always @(posedge r_clk, posedge presetempty)
if(presetempty)
	empty<=1;
  else
	empty<=0;
	
endmodule