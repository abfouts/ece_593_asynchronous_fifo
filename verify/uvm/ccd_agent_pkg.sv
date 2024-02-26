//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_agent_package.sv
//  Description:    agent package
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

package ccd_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "ccd_config.svh"
  `include "ccd_sequence_lib.svh"
  `include "ccd_monitor.svh"
  `include "ccd_driver.svh"
  `include "ccd_sequencer.svh"
  `include "ccd_agent.svh"
endpackage
