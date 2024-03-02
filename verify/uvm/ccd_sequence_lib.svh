//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_sequence_lib.svh
//  Description:    Contains sequencer and sequence items
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////
// SEQUENCE ITEM 
//////////////////////////////////////////////////
class ccd_seq_item extends uvm_sequence_item;
  `uvm_object_utils(ccd_seq_item);

  logic rst_n;
  rand int num_txn;
  logic [7:0] data_in[];
  logic [7:0] data_out[];
  const int wr_idle = 2;
  const int rd_idle = 1;

  rand logic [1:0] rand_data;
  rand logic [1:0] rand_num;
  rand logic [7:0] data_r;

  constraint num_txn_c {num_txn > 0;
                        num_txn <= 1024;} 

  function new(string name="ccd_sequence_item");
    super.new(name);
  endfunction
  
  //virtual function void do_copy(uvm_object obj);
  //  ccd_seq_item obj_item;
  //  if(!$cast(obj_item, obj) begin
  //    `uvm_fatal("ccd_seq_item", "failed to cast copy");
  //  end
  //  super.do_copy(obj);
  //
  //
  //  //TODO: Code Here
  //endfunction 
endclass

//////////////////////////////////////////////////
// BASE SEQUENCE TEST
//////////////////////////////////////////////////
class ccd_base_sequence extends uvm_sequence #(ccd_seq_item);
  `uvm_object_utils(ccd_base_sequence);
    
  ccd_seq_item reset_seq;  

  function new(string name = "ccd_sequencer");
    super.new(name);
    reset_seq = ccd_seq_item::type_id::create("reset_seq");
  endfunction

  virtual task body();
    string msg;
    msg = $sformatf("Base sequence generated");
    `uvm_info(get_name(), msg, UVM_LOW); 

    start_item(reset_seq);
    void'(reset_seq.randomize());
    reset_seq.rst_n = 1'b0;
    finish_item(reset_seq);
  endtask
endclass

//////////////////////////////////////////////////
// RANDOM MAX DATA TEST
//////////////////////////////////////////////////
class ccd_max_data_seq extends ccd_base_sequence;
  `uvm_object_utils(ccd_max_data_seq);

  ccd_seq_item max_data_seq;

  function new(string name = "max_data_sequence");
    super.new(name);
    max_data_seq = ccd_seq_item::type_id::create("max_data_seq");
  endfunction

  virtual task body();
    string msg;
    msg = $sformatf("Max Data sequence generated");
    `uvm_info(get_name(), msg, UVM_LOW);

    start_item(max_data_seq);

    void'(max_data_seq.randomize());
    max_data_seq.rst_n = 1'b1;
    max_data_seq.num_txn.rand_mode(0);

    if (max_data_seq.rand_num == '1) begin
      max_data_seq.num_txn = 1024;
    end

    max_data_seq.data_in = new[max_data_seq.num_txn];

    for (int i = 0; i < max_data_seq.num_txn; i++) begin
      max_data_seq.data_in[i] = 8'hFF;
    end

    finish_item(max_data_seq);
  endtask
endclass
//////////////////////////////////////////////////
// RANDOM MIN DATA TEST
//////////////////////////////////////////////////
class ccd_zero_data_seq extends ccd_base_sequence;
  `uvm_object_utils(ccd_zero_data_seq);

  ccd_seq_item min_data_seq;

  function new(string name = "min_data_seq");
    super.new(name);
    min_data_seq = ccd_seq_item::type_id::create("min_data_seq");
  endfunction

  virtual task body();
    string msg;
    msg = $sformatf("Min Data sequence generated");
    `uvm_info(get_name(), msg, UVM_LOW);

    start_item(min_data_seq);

    void'(min_data_seq.randomize());
    min_data_seq.rst_n = 1'b1;
    min_data_seq.num_txn.rand_mode(0);

    if (min_data_seq.rand_num == '1) begin
      min_data_seq.num_txn = 1024;
    end

    min_data_seq.data_in = new[min_data_seq.num_txn];

    for (int i = 0; i < min_data_seq.num_txn; i++) begin
      min_data_seq.data_in[i] = 8'h00;
    end

    finish_item(min_data_seq);
  endtask
endclass

//////////////////////////////////////////////////
// RANDOM SEQUENCE TEST
//////////////////////////////////////////////////
class ccd_rand_sequence extends ccd_base_sequence;
  `uvm_object_utils(ccd_rand_sequence);

  ccd_seq_item rand_seq;  

  function new(string name = "ccd_sequencer");
    super.new(name);
    rand_seq = ccd_seq_item::type_id::create("rand_seq");
  endfunction

  virtual task body();
    string msg;
    msg = $sformatf("Random sequence generated");
    `uvm_info(get_name(), msg, UVM_LOW); 

    start_item(rand_seq);

    void'(rand_seq.randomize());
    rand_seq.rst_n = 1'b1;

    // Turn of randomization for reset and number of txn
    //rand_seq.rst_n.rand_mode(0);
    rand_seq.num_txn.rand_mode(0);

    if (rand_seq.rand_num == '1) begin
      rand_seq.num_txn = 1024;
    end

    rand_seq.data_in = new[rand_seq.num_txn];
    rand_seq.data_out = new[rand_seq.num_txn];

    for(int i = 0; i < rand_seq.num_txn; i++) begin
      void'(rand_seq.randomize());
      if(rand_seq.rand_data == '1) begin
        rand_seq.data_in[i] = '1;
      end
      else if (rand_seq.rand_data == '0) begin
        rand_seq.data_in[i] = '0;
      end else begin
        rand_seq.data_in[i] = rand_seq.data_r;
      end
    end

    finish_item(rand_seq);
  endtask

endclass
