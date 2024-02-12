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
enum bit[1:0] {D_ZERO = 2'b00, D_ONE = 2'b11, D_RAND = 2'b01} STIMULUS;

//logic [`DATA_WIDTH-1:0] data [`MAX_BURST-1:0];


// Model Creation for the Producer and Consumner
ccd     #(.P_DATA_WIDTH(`DATA_WIDTH), .P_MAX_BURST(`MAX_BURST)) ccd_inst;
ccd_if  #(.P_DATA_WIDTH(`DATA_WIDTH)) ccd_inst_if();

//DUT Instantiation
//async_fifo #(.DATA_WIDTH(`DATA_WIDTH), .MEM_DEPTH(`MEM_DEPTH)) 
//dut (
//  .W_CLK(ccd_inst_if.PROD_CLK),
//  .R_CLK(ccd_inst_if.CON_CLK),
//  .WRST_n(1'b1),
//  .RRST_n(1'b1),
//  .W_EN(ccd_inst_if.O_WR_EN),
//  .R_EN(ccd_inst_if.O_RD_EN),
//  .I_DATA(ccd_inst_if.I_DATA),
//  .O_DATA(ccd_inst_if.O_DATA),
//  .FULL(ccd_inst_if.I_FULL),
//  .EMPTY(ccd_inst_if.I_EMPTY)
//);

async_fifo #(
  .P_DATA_WIDTH(`DATA_WIDTH),
  .P_MEM_DEPTH(`MEM_DEPTH)
) dut (
  // Inputs
  .RST_n(ccd_inst_if.RST_n),
  .DATA_IN(ccd_inst_if.I_DATA),
  .W_EN(ccd_inst_if.O_WR_EN), 
  .R_EN(ccd_inst_if.O_RD_EN),

  // Outputs
  .DATA_OUT(ccd_inst_if.O_DATA),
  .FULL(ccd_inst_if.I_FULL),
  .EMPTY(ccd_inst_if.I_EMPTY)
);

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

  // Kicks off scoreboard
  ccd_inst.run();

  ccd_inst_if.RST_n = 0;
  #100ns;
  ccd_inst_if.RST_n = 1;
  #100ns;
  
  // Send max burst random data
  repeat(30) begin
    ccd_inst.start(`MAX_BURST, ccd_inst.get_data(`MAX_BURST, D_RAND));
  end
 
  // TODO: Add tests here
  


  $stop(2);
  $finish;
end
endmodule
