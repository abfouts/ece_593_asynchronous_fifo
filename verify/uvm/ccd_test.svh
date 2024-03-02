//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_test.svh
//  Description:    UVM test for the asynchronous fifo 
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

class ccd_test extends uvm_test;
  `uvm_component_registry(ccd_test, "ccd_test");  // Register test with factory

  ccd_env ccd_env_h;
  ccd_config ccd_config_h;
  ccd_base_sequence reset_seq;
  ccd_rand_sequence rand_seq;

  protected int compare_fd;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    compare_fd = $fopen("ccd_tag_log.log", "w"); 

    assert(compare_fd);
    ccd_env_h.scoreboard_h.set_report_severity_action_hier(UVM_INFO, UVM_DISPLAY | UVM_LOG);
    ccd_env_h.scoreboard_h.set_report_severity_file_hier(UVM_INFO, compare_fd);
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

    repeat (10) begin
      rand_seq = ccd_rand_sequence::type_id::create("rand_seq", this);
      rand_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);
    end

    reset_seq = ccd_base_sequence::type_id::create("reset_seq", this);
    reset_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);

    repeat (10) begin
      rand_seq = ccd_rand_sequence::type_id::create("rand_seq", this);
      rand_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);
    end


    #100ns;
    phase.drop_objection(this);
  endtask

  function void final_phase(uvm_phase phase);
    $fclose(compare_fd); 
  endfunction
endclass
