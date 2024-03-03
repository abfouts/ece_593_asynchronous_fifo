//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_driver.svh
//  Description:    Driver for the asynchronous FIFO model 
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

class ccd_driver extends uvm_driver #(ccd_seq_item);
  `uvm_component_utils(ccd_driver);
 
  virtual ccd_if vif; 
  ccd_config ccd_config_h;

  function new(string name="driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    ccd_seq_item seq;

    forever begin
      seq_item_port.get_next_item(seq);
      drive(seq);
      seq_item_port.item_done();
    end
  endtask

  task drive(ccd_seq_item seq);
    string msg;
    bit write = 0;
    bit read = 0;

    vif.RST_n = seq.rst_n;

    if (seq.rst_n == 1'b1) begin
      msg = $sformatf("BURST Transaction of: %0d", seq.num_txn);
      `uvm_info(get_name(), msg, UVM_LOW); 
      fork
        fork
          begin
            @(posedge vif.PROD_CLK);
            vif.O_WR_EN = 1'b1;
            for(int i = 0; i < seq.num_txn; i++) begin
              vif.I_DATA = seq.data_in[i];
              write = 0;

              do begin
                @(posedge vif.PROD_CLK);
                @(posedge vif.PROD_CLK);
                if (!vif.I_FULL) begin
                  write = 1;
                  @(posedge vif.PROD_CLK);
                end
              end while(!write);
            end
            //@(posedge vif.PROD_CLK);
            vif.O_WR_EN = 1'b0;
            @(posedge vif.PROD_CLK);
            @(posedge vif.PROD_CLK);

          end
        join
        fork
          begin
            // Sync clk and rd en
            @(posedge vif.CON_CLK);
            vif.O_RD_EN = 1'b1;
            for(int i = 0; i < seq.num_txn; i++) begin
              read = 0;
              do begin
                @(posedge vif.CON_CLK);
                if (!vif.I_EMPTY) begin
                  read = 1;
                  @(posedge vif.CON_CLK);
                end
              
              end while(!read);
            end

            @(posedge vif.CON_CLK);
            vif.O_RD_EN = 1'b0;
            @(posedge vif.CON_CLK);
          end
        join
      join
    end
    else begin
      if (vif.O_WR_EN || vif.O_RD_EN) begin
        `uvm_info(get_name(), "Reset caught during transaction: Holding reset asserted until txn until WR/RD enable are deasserted", UVM_LOW); 
        fork
          wait(vif.O_WR_EN == 1'b0);
          wait(vif.O_RD_EN == 1'b0);
        join
        `uvm_info(get_name(), "Reset completed", UVM_LOW); 
      end
      else begin
        `uvm_info(get_name(), "Reset caught during no transaction: not transmitting any data", UVM_LOW); 
      end
    end
  endtask


endclass
