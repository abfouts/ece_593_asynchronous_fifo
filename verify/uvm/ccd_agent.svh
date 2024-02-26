//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_agent.svh
//  Description:    Test bench for the asynchronous fifo DUT and model
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

class ccd_agent extends uvm_agent;
  `uvm_component_utils(ccd_agent);
 
  uvm_analysis_port #(ccd_seq_item) ap;

  ccd_driver    ccd_driver_h;
  ccd_monitor   ccd_monitor_h;
  ccd_sequencer ccd_sequencer_h;
  ccd_config    ccd_config_h;
  virtual ccd_if vif;

  function new(string name="ccd_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    ccd_config_h = ccd_config::type_id::create("ccd_config_h", this);
    //if (!uvm_config_db #(ccd_config)::get(this, "", "ccd_config_h", ccd_config_h)) begin
    //  `uvm_fatal("ccd_config", "Failed to get ccd_config from uvm_config_db")
    //end 

    if (!uvm_config_db #(virtual ccd_if)::get(this, "*", "vif", vif)) begin
      `uvm_fatal(get_type_name(), "CCD_DRIVER cannot get virtual interface for ccd_if");
    end

    is_active = ccd_config_h.is_active;

    if (get_is_active() == UVM_ACTIVE) begin
      //ccd_sequencer_h = uvm_sequencer#(ccd_seq_item)::type_id::create("ccd_sequencer_h", this); 
      ccd_sequencer_h = ccd_sequencer::type_id::create("ccd_sequencer_h", this); 
      ccd_driver_h = ccd_driver::type_id::create("ccd_driver_h", this);
      ccd_driver_h.vif = vif;
    end

    ccd_monitor_h = ccd_monitor::type_id::create("ccd_monitor_h",this);
    ccd_monitor_h.vif = vif;
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE) begin
      ccd_driver_h.seq_item_port.connect(ccd_sequencer_h.seq_item_export);
    end

    ccd_monitor_h.ap.connect(ap);
  endfunction  

endclass
