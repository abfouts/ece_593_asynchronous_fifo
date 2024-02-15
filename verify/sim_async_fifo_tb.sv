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
logic coverage_clk = 1'b0;

// Testing
//enum bit[1:0] {D_ZERO = 2'b00, D_ONE = 2'b11, D_RAND = 2'b01} STIMULUS;
logic [`DATA_WIDTH-1:0] data [];

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

// Clock for coverage
initial begin
  forever begin
    coverage_clk = ~coverage_clk;
    #(250ps);  // Create a period 
  end
end

 // logic PROD_CLK;
 // logic CON_CLK;
 // logic RST_n;
 // // Data Logic
 // logic [P_DATA_WIDTH-1:0] O_DATA ;
 // logic [P_DATA_WIDTH-1:0] I_DATA ;
 // // Write / Read
 // logic O_WR_EN;
 // logic O_RD_EN;
 // // Full / Empty
 // logic I_FULL;
 // logic I_EMPTY;

// ----------------------
// Cover Groups
// ----------------------
covergroup input_data_cg;
  data_in: coverpoint ccd_inst_if.I_DATA {
    bins ones = {'hFF};
    bins others = {['h01:'hFE]};
    bins zeroes = {'h00};
  }
endgroup
covergroup output_data_cg;
  data_out: coverpoint ccd_inst_if.O_DATA {
    bins ones = {'hFF};
    bins others = {['h01:'hFE]};
    bins zeroes = {'h00};
  }
endgroup

covergroup ctrl_signals_cg; 
  full : coverpoint ccd_inst_if.I_FULL {
    bins one = {'b1};
    bins zero = {'b0};
  }

  empty : coverpoint ccd_inst_if.I_EMPTY {
    bins one = {'b1};
    bins zero = {'b0};
  }

  rd_en : coverpoint ccd_inst_if.O_RD_EN {
    bins one = {'b1};
    bins zero = {'b0};
  }

  wr_en : coverpoint ccd_inst_if.O_WR_EN {
    bins one = {'b1};
    bins zero = {'b0};
  }

endgroup

// ----------------------
// Coverage section
// ----------------------
input_data_cg input_data; 
output_data_cg output_data; 
ctrl_signals_cg ctrl_signals;

initial begin : coverage
  input_data = new();
  output_data = new();
  ctrl_signals = new();

  fork
    forever begin 
      @(negedge prod_clk);
      input_data.sample();
    end
    forever begin
      @(negedge con_clk);
      output_data.sample();
    end
    forever begin
      @(posedge coverage_clk);
      ctrl_signals.sample();  
    end
  join_none
  
end : coverage
// ----------------------
// Test
// ----------------------
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
  repeat(300) begin
    data = ccd_inst.get_rand_data();
    ccd_inst.start(ccd_inst.num_entries, data);
  end
 

  $stop(2);
  $finish;
end
endmodule
