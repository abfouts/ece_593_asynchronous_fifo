//////////////////////////////////////////////////////////////////////////
//  Module:         ccd_monitor.svh
//  Description:    Test bench for the asynchronous fifo DUT and model
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           02/21/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

class ccd_monitor extends uvm_monitor;
  `uvm_component_utils(ccd_monitor);
  
  ccd_config ccd_config_h; 
  uvm_analysis_port #(ccd_seq_item) ap;

  virtual ccd_if vif;

  function new(string name="ccd_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    ap = new("ap", this);

    //if (ccd_config_h == null) begin
    //  `uvm_fatal("ccd_monitor", "Config obj is null");
    //end

    //vif = ccd_config_h.vif;
  endfunction

  virtual task run_phase(uvm_phase phase);
    ccd_seq_item seq;
    int rd_cntr;
    bit rd_txn;
    int wr_cntr;
    bit wr_txn;
    string msg;
    
    forever begin
      seq = ccd_seq_item::type_id::create("seq", this);
      rd_cntr = 0;
      rd_txn = 1'b1;
      wr_cntr = 0;
      wr_txn = 1'b1;
      //seq.data_in = new[1];
      //seq.data_out = new[1];

      wait(vif.RST_n);
      wait(vif.O_WR_EN);
      
      `uvm_info(get_name(), "Transaction Monitoring started", UVM_LOW); 

      fork
        // WR IF
        begin
          while(wr_txn) begin
            repeat(3) begin
              @(posedge vif.PROD_CLK);
            end

            // If we expect a write and there is not write we are done
            if (!vif.O_WR_EN && !vif.I_FULL) begin
              wr_txn = 1'b0;
              break;
            end

            //seq.data_in = new[seq.data_in.size() + 1] (seq.data_in);  // Increase dynamic vector
            //seq.data_in[wr_cntr] = vif.I_DATA;  
            //wr_cntr++;
          end
        end

        // READ IF
        begin
          while(rd_txn) begin
            repeat(2) begin
              @(posedge vif.CON_CLK);
            end

            // If we expect a write and there is not write we are done
            if (!vif.O_RD_EN && vif.I_EMPTY) begin
              rd_txn = 1'b0;
              break;
            end

            //seq.data_out = new[seq.data_out.size() + 1] (seq.data_out);  // Increase dynamic vector
            //seq.data_out[rd_cntr] = vif.O_DATA;  
            //rd_cntr++;
          end
        end 

        begin
          while(wr_txn) begin
            @(negedge vif.O_WR_EN or negedge wr_txn);
            if(wr_txn == 1'b0) begin
              break;
            end
            seq.data_in = new[seq.data_in.size() + 1] (seq.data_in);  // Increase dynamic vector
            seq.data_in[wr_cntr] = vif.I_DATA;  
            wr_cntr++;
          end
        end

        begin
          while(rd_txn) begin
            @(posedge vif.O_RD_EN or negedge rd_txn);
            if(rd_txn == 1'b0) begin
              break;
            end
            #1ns; //Let data stabalize
            seq.data_out = new[seq.data_out.size() + 1] (seq.data_out);  // Increase dynamic vector
            seq.data_out[rd_cntr] = vif.O_DATA;  
            rd_cntr++;
          end
        end
      join

      msg = $sformatf("BURST Transaction Monitored: DATA IN: %0d -- DATA OUT:%0d", $size(seq.data_in), $size(seq.data_out));
      `uvm_info(get_name(), msg, UVM_LOW); 
      ap.write(seq);
    end
  endtask

endclass
