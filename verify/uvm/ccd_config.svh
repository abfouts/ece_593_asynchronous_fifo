//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_agent_package.sv
//  Description:    agent package
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

class ccd_config extends uvm_object;
  `uvm_object_utils(ccd_config);

  virtual ccd_if vif;
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(string name = "ccd_config", uvm_component parent = null);

  endfunction
endclass
