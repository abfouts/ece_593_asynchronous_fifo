//////////////////////////////////////////////////////////////////////////
//  Module:         top.sv
//  Description:    Test bench for the asynchronous fifo DUT and model
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps

`define MEM_DEPTH 333
`define DATA_WIDTH 8
`define MAX_BURST 1024

import ccd_agent_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh" 
`include "ccd_scoreboard.svh"
`include "ccd_env.svh"
`include "ccd_test.svh"

module top;
  localparam time producer_clk = 2ns; // Producer clock of 500MHz or 2nS cycle
  localparam time consumer_clk = 4.44ns; // Consumer clock of 225 MHz or 4.44nS cycle
  logic prod_clk = 1'b0;
  logic con_clk = 1'b0;

  ccd_if  #(.P_DATA_WIDTH(`DATA_WIDTH)) ccd_if_h();
  
  //DUT Instantiation
  //async_fifo #(.DATA_WIDTH(`DATA_WIDTH), .MEM_DEPTH(`MEM_DEPTH)) 
  //dut (
  //  .W_CLK(ccd_if_h.PROD_CLK),
  //  .R_CLK(ccd_if_h.CON_CLK),
  //  .WRST_n(1'b1),
  //  .RRST_n(1'b1),
  //  .W_EN(ccd_if_h.O_WR_EN),
  //  .R_EN(ccd_if_h.O_RD_EN),
  //  .I_DATA(ccd_if_h.I_DATA),
  //  .O_DATA(ccd_if_h.O_DATA),
  //  .FULL(ccd_if_h.I_FULL),
  //  .EMPTY(ccd_if_h.I_EMPTY)
  //);
  
  async_fifo #(
    .P_DATA_WIDTH(`DATA_WIDTH),
    .P_MEM_DEPTH(`MEM_DEPTH)
  ) dut (
    // Inputs
    .PROD_CLK(ccd_if_h.PROD_CLK),
    .CON_CLK(ccd_if_h.CON_CLK),
    .RST_n(ccd_if_h.RST_n),
    .DATA_IN(ccd_if_h.I_DATA),
    .W_EN(ccd_if_h.O_WR_EN), 
    .R_EN(ccd_if_h.O_RD_EN),
  
    // Outputs
    .DATA_OUT(ccd_if_h.O_DATA),
    .FULL(ccd_if_h.I_FULL),
    .EMPTY(ccd_if_h.I_EMPTY)
  );
  
  typedef ccd_test ccd_test_t;

  // ----------------------
  // Test
  // ----------------------
  initial begin
    uvm_config_db #(virtual ccd_if)::set(null, "*", "vif", ccd_if_h);
    run_test("ccd_test");
  end

  assign ccd_if_h.PROD_CLK = prod_clk;
  assign ccd_if_h.CON_CLK = con_clk;
  
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

endmodule
