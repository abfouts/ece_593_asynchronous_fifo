//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_driver.svh
//  Description:    Test bench for the asynchronous fifo DUT and model
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
    //if (!uvm_config_db #(virtual ccd_if)::get(this, "*", "vif", vif)) begin
    //  `uvm_fatal(get_type_name(), "CCD_DRIVER cannot get virtual interface for ccd_if");
    //end

    //if(ccd_config_h == null) begin
    //  `uvm_fatal("ccd_driver", "Configuration is null");
    //end

    //vif = ccd_config_h.vif;

  endfunction

  task run_phase(uvm_phase phase);
    ccd_seq_item seq;

    forever begin
      seq_item_port.get_next_item(seq);
      drive(seq);
      seq_item_port.item_done();
    end
  endtask

  // Forks two tasks to hand the rd_en assert and the wr_en with write data
  task drive_two(ccd_seq_item seq);
    string msg;

    vif.RST_n = seq.rst_n;;
    if (seq.rst_n == 1'b1) begin
      msg = $sformatf("BURST Transaction of: %0d", seq.num_txn);
      `uvm_info(get_name(), msg, UVM_LOW); 
      fork
        begin
          for(int i = 0; i < seq.num_txn; i++) begin
            for(int j = 0; j < seq.wr_idle+1; j++) begin
              @(posedge vif.PROD_CLK);
            end
            vif.I_DATA = seq.data_in[i];
            
            // Wait if the device is full
            wait(vif.I_FULL == 1'b0);
            vif.O_WR_EN = 1'b1;
            
            // Strobing WR EN
            @(negedge vif.PROD_CLK);
            vif.O_WR_EN = 1'b0;
          end
        end
        begin
          for(int i = 0; i < seq.num_txn; i++) begin
            for(int j = 0; j < seq.rd_idle+1; j++) begin
              @(posedge vif.CON_CLK);
            end
            // Wait if the device is full
            wait(vif.I_EMPTY == 1'b0);
            vif.O_RD_EN = 1'b1;
            
            // Strobing RD EN
            @(negedge vif.CON_CLK);
            vif.O_RD_EN = 1'b0;
          end
        end
      join
    end
    else begin
      `uvm_info(get_name(), "Reset caught, not transmitting any data", UVM_LOW); 
    end
  endtask

  task drive(ccd_seq_item seq);
    string msg;

    vif.RST_n = seq.rst_n;
    if (seq.rst_n == 1'b1) begin
      msg = $sformatf("BURST Transaction of: %0d", seq.num_txn);
      `uvm_info(get_name(), msg, UVM_LOW); 
      fork
        fork
          begin
            vif.O_WR_EN = 1'b1;
            for(int i = 0; i < seq.num_txn; i++) begin
              for(int j = 0; j < seq.wr_idle; j++) begin
                @(posedge vif.PROD_CLK);
              end

              // Wait if the device is full
              while(vif.I_FULL) begin
                @(posedge vif.PROD_CLK);
              end

              vif.I_DATA = seq.data_in[i];
              @(posedge vif.PROD_CLK);
            end
            @(posedge vif.PROD_CLK);
            vif.O_WR_EN = 1'b0;
            @(posedge vif.PROD_CLK);

          end
        join
        fork
          begin
            // Sync clk and rd en
            vif.O_RD_EN = 1'b1;
            for(int i = 0; i < seq.num_txn; i++) begin
              for(int j = 0; j < seq.rd_idle; j++) begin
                @(posedge vif.CON_CLK);
              end
              while(vif.I_EMPTY == 1'b1) begin
                @(posedge vif.CON_CLK);
              end
              
              @(posedge vif.CON_CLK);
            end

            @(posedge vif.CON_CLK);
            vif.O_RD_EN = 1'b0;
            @(posedge vif.CON_CLK);
          end
        join
      join
    end
    else begin
      `uvm_info(get_name(), "Reset caught, not transmitting any data", UVM_LOW); 
    end
  endtask


endclass
