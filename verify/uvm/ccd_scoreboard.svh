//////////////////////////////////////////////////////////////////////////
//  Module:         scoreboard.sv
//  Description:    Test bench for the asynchronous fifo DUT and model
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

  function new(string name="ccd_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    //phase.raise_objection(this);

    //phase.drop_objection(this);
  endtask

  virtual function void write_ap (ccd_seq_item txn);
    string msg;
    msg = $sformatf("Scoreboard Received Transaction from Monitor: DATA IN: %0d -- DATA OUT:%0d", $size(txn.data_in), $size(txn.data_out));
    `uvm_info(get_name(), msg, UVM_LOW); 
    //TODO: Perform comparison here
    if (txn.data_in.size() == txn.data_out()) begin
      for(int i = 0; i < txn.data_in.size(); i++) begin

      end
    end
    else begin
      
    end
  endfunction 
endclass
