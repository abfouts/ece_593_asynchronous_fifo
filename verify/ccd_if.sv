//////////////////////////////////////////////////////////////////////////
//  Module:         sim_ccd.sv
//
//  Description:    Crossing Clock Domain interface for the connections
//                  to the FIFO / Control Unity and the producer 
//                  and consumer devices
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           01/28/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

interface ccd_if #(parameter P_DATA_WIDTH = 8) ();
  // Timing
  logic PROD_CLK;
  logic CON_CLK;
  // Data Logic
  logic [P_DATA_WIDTH-1:0] O_DATA ;
  logic [P_DATA_WIDTH-1:0] I_DATA ;
  // Write / Read
  logic O_WR_EN;
  logic O_RD_EN;
  // Full / Empty
  logic I_FULL;
  logic I_EMPTY;
endinterface

