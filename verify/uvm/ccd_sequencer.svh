//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_sequencer.svh
//  Description:    Test bench for the asynchronous fifo DUT and model
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

class ccd_sequencer extends uvm_sequencer#(ccd_seq_item);
  `uvm_component_utils(ccd_sequencer);
 
  function new(string name="ccd_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass
