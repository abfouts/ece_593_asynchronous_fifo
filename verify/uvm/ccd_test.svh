//////////////////////////////////////////////////////////////////////////
//  Module:         sim_async_fifo_tb.sv
//  Description:    Test bench for the asynchronous fifo DUT and model
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

class ccd_test extends uvm_test;
  //`uvm_component_utils(ccd_test);

  `uvm_component_registry(ccd_test, "ccd_test");

  ccd_env ccd_env_h;
  ccd_config ccd_config_h;
  ccd_base_sequence reset_seq;
  ccd_rand_sequence rand_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ccd_env_h = ccd_env::type_id::create("ccd_env_h", this);
    ccd_config_h = ccd_config::type_id::create("ccd_config_h", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    reset_seq = ccd_base_sequence::type_id::create("reset_seq", this);
    reset_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);

    #100ns;

    repeat (10) begin
      rand_seq = ccd_rand_sequence::type_id::create("rand_seq", this);
      rand_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);
      //#100ns;
    end

    reset_seq = ccd_base_sequence::type_id::create("reset_seq", this);
    reset_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);
    //#100ns;

    repeat (10) begin
      rand_seq = ccd_rand_sequence::type_id::create("rand_seq", this);
      rand_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);
      //#100ns;
    end


    #100ns;
    $stop; 
    phase.drop_objection(this);
  endtask
endclass
