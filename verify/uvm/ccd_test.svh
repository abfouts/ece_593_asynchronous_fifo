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
  ccd_zero_data_sequence zero_seq;
  ccd_max_data_sequence max_seq;

  protected int compare_fd;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    compare_fd = $fopen("ccd_tag_log.log", "w"); 

    assert(compare_fd);
    ccd_env_h.scoreboard_h.set_report_severity_action_hier(UVM_INFO, UVM_LOG);
    ccd_env_h.scoreboard_h.set_report_severity_file_hier(UVM_INFO, compare_fd);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ccd_env_h = ccd_env::type_id::create("ccd_env_h", this);
    ccd_config_h = ccd_config::type_id::create("ccd_config_h", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Create a reset sequence
    reset_seq = ccd_base_sequence::type_id::create("reset_seq", this);
    reset_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);

    // Data is zero sequence
    zero_seq = ccd_zero_data_sequence::type_id::create("zero_seq", this);
    zero_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);

    // Reset again to show recovery
    reset_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);

    // Max value sequence
    max_seq = ccd_max_data_sequence::type_id::create("max_seq", this);
    max_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);

    // Run a bunch of random sequences
    repeat (100) begin
      rand_seq = ccd_rand_sequence::type_id::create("rand_seq", this);
      rand_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);
    end

    // Reset and wait
    reset_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);
    #100ns;

    // Recover and send more frames
    repeat (10) begin
      rand_seq = ccd_rand_sequence::type_id::create("rand_seq", this);
      rand_seq.start(ccd_env_h.ccd_agent_h.ccd_sequencer_h);
    end


    #100ns;
    phase.drop_objection(this);
  endtask

  virtual function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);

    svr = uvm_report_server::get_server(); 

    if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin
      `uvm_info(get_type_name(), "CCD_TEST FAILED", UVM_NONE); 
      $display("\n ######## ########  ######  ########    ########    ###    #### ##       ");
      $display("    ##    ##       ##    ##    ##       ##         ## ##    ##  ##       ");
      $display("    ##    ##       ##          ##       ##        ##   ##   ##  ##       ");
      $display("    ##    ######    ######     ##       ######   ##     ##  ##  ##       ");
      $display("    ##    ##             ##    ##       ##       #########  ##  ##       ");
      $display("    ##    ##       ##    ##    ##       ##       ##     ##  ##  ##       ");
      $display("    ##    ########  ######     ##       ##       ##     ## #### ########");
    end
    else begin
      `uvm_info(get_type_name(), "CCD_TEST PASSED", UVM_NONE); 
      $display("\n ######## ########  ######  ########    ########     ###     ######   ######  ");
      $display("    ##    ##       ##    ##    ##       ##     ##   ## ##   ##    ## ##    ## ");
      $display("    ##    ##       ##          ##       ##     ##  ##   ##  ##       ##       ");
      $display("    ##    ######    ######     ##       ########  ##     ##  ######   ######  ");
      $display("    ##    ##             ##    ##       ##        #########       ##       ## ");
      $display("    ##    ##       ##    ##    ##       ##        ##     ## ##    ## ##    ## ");
      $display("    ##    ########  ######     ##       ##        ##     ##  ######   ######");
    end

  endfunction

  function void final_phase(uvm_phase phase);
    $fclose(compare_fd); 
  endfunction
endclass
