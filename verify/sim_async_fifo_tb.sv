//////////////////////////////////////////////////////////////////////////
//  Module:         sim_async_fifo_tb.sv
//  Description:    Test bench for the asynchronous fifo DUT and model
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           01/25/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`define MEM_DEPTH 333
`define DATA_WIDTH 8
`define MAX_BURST 1024

import ccd_pkg::*;

module top;

// Test signals / variables
localparam time producer_clk = 2ns; // Producer clock of 500MHz or 2nS cycle
localparam time consumer_clk = 4.44ns; // Consumer clock of 225 MHz or 4.44nS cycle
logic prod_clk = 1'b0;
logic con_clk = 1'b0;

// Testing
logic [`DATA_WIDTH-1:0] data [`MAX_BURST-1:0];

// Model Creation for the Producer and Consumner
ccd     #(.P_DATA_WIDTH(`DATA_WIDTH), .P_MAX_BURST(`MAX_BURST)) ccd_inst;
ccd_if  #(.P_DATA_WIDTH(`DATA_WIDTH)) ccd_inst_if();

// Interface Assignment statements
assign ccd_inst_if.PROD_CLK = prod_clk;
assign ccd_inst_if.CON_CLK = con_clk;

// Clocks generation for producer with 50% duty cycle
initial begin
  forever begin
    prod_clk = ~prod_clk;
    #(producer_clk/2);  // Create a period 
  end
end

// Clocks generation for producer with 50% duty cycle
initial begin
  forever begin
    con_clk = ~con_clk;
    #(consumer_clk/2);  // Create a period 
  end
end

initial begin
  // Create producer and consumer objects
  ccd_inst = new();
  ccd_inst.device_if = ccd_inst_if;
  ccd_inst.wr_idle = 2;
  ccd_inst.rd_idle = 1;
  ccd_inst_if.I_FULL = 0;
  ccd_inst_if.I_EMPTY = 0;

  // Initialize needed values for producer and consumer
  data[0] = 8'h01;
  for(int i = 0; i < `MAX_BURST; i++) begin
    data[i] = data[0] * i+1;
  end

  ccd_inst.start(`MAX_BURST, data);
 
  // TODO: Add tests here
  




  $stop(2);
end

  

// TODO: Add DUT here 

endmodule
