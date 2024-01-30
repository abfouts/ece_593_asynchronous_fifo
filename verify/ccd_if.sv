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

interface ccd_if #(parameter DATA_WIDTH = 8) ();
  // Timing
  logic CLK;
  // Data Logic
  logic [DATA_WIDTH-1:0] O_DATA;
  logic [DATA_WIDTH-1:0] I_DATA;
  // Write / Read
  logic W_EN;
  logic R_EN;
  // Full / Empty
  logic FULL;
  logic EMPTY;
endinterface

