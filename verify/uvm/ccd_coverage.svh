//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_coverage.svh
//  Description:    Coverage for asynchronous fifo
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           03/02/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

class ccd_coverage extends uvm_subscriber #(ccd_seq_item);
  `uvm_component_utils(ccd_coverage);

  virtual ccd_if vif;
  ccd_seq_item req;

  protected real coverage_ctrl_rst;
  protected real coverage_ctrl_full;
  protected real coverage_ctrl_empty;
  protected real coverage_ctrl_wr_en;
  protected real coverage_ctrl_rd_en;
  protected real coverage_data_in;
  protected real coverage_data_out;

  protected bit [7:0] data_in;
  protected bit [7:0] data_out;

  covergroup input_data_cg;
    data_in: coverpoint data_in {
      bins ones = {'hFF};
      bins others = {['h01:'hFE]};
      bins zeroes = {'h00};
    }
  endgroup
  covergroup output_data_cg;
    data_out: coverpoint data_out {
      bins ones = {'hFF};
      bins others = {['h01:'hFE]};
      bins zeroes = {'h00};
    }
  endgroup
  
  covergroup ctrl_signals_cg; 
    full : coverpoint vif.I_FULL {
      bins one = {'b1};
      bins zero = {'b0};
    }
  
    empty : coverpoint vif.I_EMPTY {
      bins one = {'b1};
      bins zero = {'b0};
    }
  
    rd_en : coverpoint vif.O_RD_EN {
      bins one = {'b1};
      bins zero = {'b0};
    }
  
    wr_en : coverpoint vif.O_WR_EN {
      bins one = {'b1};
      bins zero = {'b0};
    }

    rst_n : coverpoint vif.RST_n {
      bins one = {'b1};
      bins zero = {'b0};
    }
  endgroup

  function new(input string name = "ccd_coverage", uvm_component parent = null);
    super.new(name, parent);
    req = ccd_seq_item::type_id::create("req");
    input_data_cg = new();
    output_data_cg = new();
    ctrl_signals_cg = new();
  endfunction

  virtual task run_phase(uvm_phase phase);
    // Each control signal is not sent to the scoreboard for evalutaion
    // So the VIf will be used from the uvm_config_db to monitor these
    // control signals whenever they change.
    // There are simple, are they 1 or are they 0
    fork
      forever begin
        @(posedge vif.RST_n or negedge vif.RST_n) begin
          ctrl_signals_cg.sample(); 
          coverage_ctrl_rst = ctrl_signals_cg.get_coverage();
          `uvm_info(get_type_name(), $sformatf("Reset coverage is %0d", coverage_ctrl_rst), UVM_DEBUG);
        end 
      end

      forever begin
        @(posedge vif.I_FULL or negedge vif.I_FULL) begin
          ctrl_signals_cg.sample(); 
          coverage_ctrl_full = ctrl_signals_cg.get_coverage();
          `uvm_info(get_type_name(), $sformatf("Full coverage is %0d", coverage_ctrl_full), UVM_DEBUG);
        end 
      end

      forever begin
        @(posedge vif.I_FULL or negedge vif.I_EMPTY) begin
          ctrl_signals_cg.sample(); 
          coverage_ctrl_empty = ctrl_signals_cg.get_coverage();
          `uvm_info(get_type_name(), $sformatf("Empty coverage is %0d", coverage_ctrl_empty), UVM_DEBUG);
        end 
      end

      forever begin
        @(posedge vif.O_RD_EN or negedge vif.O_RD_EN) begin
          ctrl_signals_cg.sample(); 
          coverage_ctrl_rd_en = ctrl_signals_cg.get_coverage();
          `uvm_info(get_type_name(), $sformatf("Read Enable coverage is %0d", coverage_ctrl_rd_en), UVM_DEBUG);
        end 
      end

      forever begin
        @(posedge vif.O_WR_EN or negedge vif.O_WR_EN) begin
          ctrl_signals_cg.sample(); 
          coverage_ctrl_wr_en = ctrl_signals_cg.get_coverage();
          `uvm_info(get_type_name(), $sformatf("Write Enable coverage is %0d", coverage_ctrl_wr_en), UVM_DEBUG);
        end 
      end
    join_none
  endtask

  virtual function void write(input ccd_seq_item t);
    `uvm_info(get_type_name(), "Reading monitor data for coverage", UVM_DEBUG);
    req = t;
    
    fork 
      begin
        for (int i = 0; i < req.data_in.size(); i++) begin
          data_in = req.data_in[i];
          input_data_cg.sample();
        end
        coverage_data_in = input_data_cg.get_coverage();
        `uvm_info(get_full_name(), $sformatf("Input Data Coverage is %0d", coverage_data_in), UVM_DEBUG);
      end
      begin
        for (int i = 0; i < req.data_out.size(); i++) begin
          data_out = req.data_out[i];
          output_data_cg.sample();
        end
        coverage_data_out = output_data_cg.get_coverage();
        `uvm_info(get_full_name(), $sformatf("Output Data Coverage is %0d", coverage_data_out), UVM_DEBUG);
      end
    join

  endfunction
endclass

