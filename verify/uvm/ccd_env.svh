//////////////////////////////////////////////////////////////////////////
//  Module:         env.sv
//  Description:    Test bench for the asynchronous fifo DUT and model
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

class ccd_env extends uvm_env;
  `uvm_component_utils(ccd_env);

  // TODO: Base Tester Here
  //coverage coverage_h;
  ccd_agent ccd_agent_h;
  ccd_scoreboard scoreboard_h;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //coverage_h = coverage::type_id::create("coverage_h", this); 
    ccd_agent_h = ccd_agent::type_id::create("ccd_agent_h", this);
    scoreboard_h = ccd_scoreboard::type_id::create("scoreboard_h", this); 
  endfunction

  task run_phase(uvm_phase phase);
    //phase.raise_objection(this);
    super.run_phase(phase);
      
    //phase.drop_objection(this);
  endtask

  virtual function void connect_phase(uvm_phase phase);
    ccd_agent_h.ap.connect(scoreboard_h.ap); 
  endfunction
endclass
