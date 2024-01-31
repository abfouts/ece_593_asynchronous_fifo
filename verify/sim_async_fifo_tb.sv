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

import ccd_pkg::*;

module top;

// Test signals / variables
localparam time producer_clk = 2ns; // Producer clock of 500MHz or 2nS cycle
localparam time consumer_clk = 4.44ns; // Consumer clock of 225 MHz or 4.44nS cycle
logic prod_clk = 1'b0;
logic con_clk = 1'b0;

// Model Creation for the Producer and Consumner
ccd ex_ccd;
ccd_if ex_ccd_if();

// Interface Assignment statements
assign ex_ccd_if.PROD_CLK = prod_clk;
assign ex_ccd_if.CON_CLK = con_clk;

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
  ex_ccd = new();
  ex_ccd.device_if = ex_ccd_if;

  // Initialize needed values for producer and consumer

 
  // TODO: Add tests here




  $stop(2);
end

  

// TODO: Add DUT here 

endmodule
