//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_scoreboard.sv
//  Description:    scoreboard component for the 
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

`uvm_analysis_imp_decl(_ap);

class ccd_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(ccd_scoreboard);
  uvm_analysis_imp_ap #(ccd_seq_item, ccd_scoreboard) ap;

  // These members keep track of how many compares, it does not matter to record EVERY comparison, only if they fail
  protected int sequence_idx;
  protected int data_compare_idx;
  protected int failures;
  protected int passes;
  int compare_limit = 30;

  function new(string name="ccd_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  
  function void build_phase(uvm_phase phase);
    ap = new("ap", this);
    sequence_idx = 0;
    data_compare_idx = 0;
    failures = 0;
    passes = 0;

  endfunction

  task run_phase(uvm_phase phase);
    //phase.raise_objection(this);

    //phase.drop_objection(this);
  endtask

  virtual function void write_ap (ccd_seq_item txn);
    string msg;
    data_compare_idx = 0;

    // Made it to the scoreboard
    msg = $sformatf("Scoreboard Received Transaction from Monitor: DATA IN: %0d -- DATA OUT:%0d", $size(txn.data_in), $size(txn.data_out));
    `uvm_info(get_name(), msg, UVM_HIGH); 

    // Check the size of the received data
    if (txn.data_in.size() == txn.data_out.size()) begin
      sequence_idx++;
      msg = $sformatf(  {"\nDescription: Comparing burst size elements written and read from the Asynchronous FIFO (CCD)",
                          "\nTEST TAG: TT_00",
                          "\nDATA BURST IN: %0d -- Data BURST OUT: %0d",
                          "\nResult: PASS",
                          "\nCount: %0d\n"}, (txn.data_in.size()), (txn.data_out.size()), sequence_idx);
      `uvm_info(get_type_name(), msg, UVM_MEDIUM);
      passes++;

      // COMPARE ALL THE ELEMENTS READ/WRITTEN
      for(int i = 0; i < txn.data_in.size(); i++) begin
        if (txn.data_in[i] == txn.data_out[i]) begin
          data_compare_idx++;
          msg = $sformatf( {"\nDescription: Comparing individual elements written and read from the Asynchronous FIFO (CCD)",
                            "\nTEST TAG: TT_01",
                            "\nDATA IN: %0x -- DATA OUT: %0x",
                            "\nResult: PASS",
                            "\nCount: %0d\n"}, (txn.data_in[i]), (txn.data_out[i]), data_compare_idx);
          if(data_compare_idx <= compare_limit) begin
            `uvm_info(get_type_name(), msg, UVM_MEDIUM);
          end
          passes++;
        end 
        // ELEMENT MISMATCH
        else begin
          data_compare_idx++;
          msg = $sformatf( {"\nDescription: Comparing individual elements written and read from the Asynchronous FIFO (CCD)",
                            "\nTEST TAG: TT_01",
                            "\nDATA IN: %0x -- DATA OUT: %0x",
                            "\nResult: FAIL",
                            "\nCount: %0d\n"}, (txn.data_in[i]), (txn.data_out[i]), data_compare_idx);
          `uvm_info(get_type_name(), msg, UVM_MEDIUM);
          `uvm_error(get_type_name(), "Failed individual element comparison");
          failures++;
        end
      end
    end
    // NOT AN EXACT MATCH OF ELEMENTS AS BURST SIZE
    else begin
      sequence_idx++;
      msg = $sformatf(  {"\nDescription: Comparing burst size elements written and read from the Asynchronous FIFO (CCD)",
                          "\nTEST TAG: TT_00",
                          "\nDATA BURST IN: %0d -- Data BURST OUT: %0d",
                          "\nResult: FAIL",
                          "\nCount: %0d\n"}, (txn.data_in.size()), (txn.data_out.size()), sequence_idx);

      `uvm_info(get_type_name(), msg, UVM_MEDIUM);
      `uvm_error(get_type_name(), "Failed burst data size comparison");
      failures++;
    end
  endfunction 


  function void final_phase(uvm_phase phase);
    if (failures == 0) begin
      $display("\n ######## ########  ######  ########    ########     ###     ######   ######  ");
      $display("    ##    ##       ##    ##    ##       ##     ##   ## ##   ##    ## ##    ## ");
      $display("    ##    ##       ##          ##       ##     ##  ##   ##  ##       ##       ");
      $display("    ##    ######    ######     ##       ########  ##     ##  ######   ######  ");
      $display("    ##    ##             ##    ##       ##        #########       ##       ## ");
      $display("    ##    ##       ##    ##    ##       ##        ##     ## ##    ## ##    ## ");
      $display("    ##    ########  ######     ##       ##        ##     ##  ######   ######");
      $display("");
      $display("Test Pass with %0d Failures and %0d Passes", failures, passes);
    end     
    else begin
      $display("\n ######## ########  ######  ########    ########    ###    #### ##       ");
      $display("    ##    ##       ##    ##    ##       ##         ## ##    ##  ##       ");
      $display("    ##    ##       ##          ##       ##        ##   ##   ##  ##       ");
      $display("    ##    ######    ######     ##       ######   ##     ##  ##  ##       ");
      $display("    ##    ##             ##    ##       ##       #########  ##  ##       ");
      $display("    ##    ##       ##    ##    ##       ##       ##     ##  ##  ##       ");
      $display("    ##    ########  ######     ##       ##       ##     ## #### ########");
      $display("");
      $display("Test Pass with %0d Failures and %0d Passes", failures, passes);
    end                                             
                                                           
  endfunction
endclass
