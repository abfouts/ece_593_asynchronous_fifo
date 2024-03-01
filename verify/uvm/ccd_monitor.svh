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

  endfunction

  virtual task run_phase(uvm_phase phase);
    ccd_seq_item seq;
    int rd_cntr;
    bit read;
    int wr_cntr;
    bit write;
    string msg;
    
    forever begin
      seq = ccd_seq_item::type_id::create("seq", this);
      rd_cntr = 0;
      read = 1'b0;
      wr_cntr = 0;
      write = 1'b0;

      wait(vif.RST_n);

      `uvm_info(get_name(), "Transaction Monitoring started", UVM_LOW); 
      
      fork
        begin
          //wait(vif.O_WR_EN);
          //@(posedge vif.PROD_CLK);
          @(posedge vif.O_WR_EN);
          do begin
            write = 0;

            do begin
              @(posedge vif.PROD_CLK);
              @(posedge vif.PROD_CLK);
              if (!vif.I_FULL && vif.O_WR_EN) begin
                write = 1;
                seq.data_in = new[seq.data_in.size() + 1] (seq.data_in);  // Increase dynamic vector
                seq.data_in[wr_cntr] = vif.I_DATA;  
                wr_cntr++;
                @(posedge vif.PROD_CLK);
                //$display("WRITE %0d |||| %0x", wr_cntr, seq.data_in[wr_cntr]);
              end
              if (!vif.O_WR_EN) begin
                break;
              end
            end while(!write);
          end while(vif.O_WR_EN);

          //while (vif.O_WR_EN && vif.RST_n) begin
          //  repeat(2) begin
          //    @(posedge vif.PROD_CLK);
          //  end
          //  //while(vif.I_FULL && vif.O_RD_EN) begin
          //  //  @(posedge vif.PROD_CLK);
          //  //end
          //  @(posedge vif.PROD_CLK);
          //  //#1ns; // Stabalizations
          //  if (vif.O_WR_EN && !vif.I_FULL) begin
          //    seq.data_in = new[seq.data_in.size() + 1] (seq.data_in);  // Increase dynamic vector
          //    seq.data_in[wr_cntr] = vif.I_DATA;  
          //    wr_cntr++;
          //  end
          //end
        end
        begin
          wait(vif.O_RD_EN);
          do begin
            read = 0;
            do begin
              @(posedge vif.CON_CLK);
              if (!vif.I_EMPTY && vif.O_RD_EN) begin
                read = 1;
                @(posedge vif.CON_CLK);
                seq.data_out = new[seq.data_out.size() + 1] (seq.data_out);  // Increase dynamic vector
                seq.data_out[rd_cntr] = vif.O_DATA;  
                rd_cntr++;
                //$display("READ %0d |||| %0x", rd_cntr, seq.data_out[rd_cntr-1]);
              end
              if (!vif.O_RD_EN) begin
                break;
              end
            end while(!read);
          end while (vif.O_RD_EN);
          //while (vif.O_RD_EN && vif.RST_n) begin
          //  repeat(1) begin
          //    @(posedge vif.CON_CLK);
          //  end
          //  //while(vif.I_EMPTY && vif.O_WR_EN) begin
          //  //  @(posedge vif.CON_CLK);
          //  //end
          //  @(posedge vif.CON_CLK);
          //  //#1ns; //Let data stabalize
          //  // Just in case it is deasserted mid txn
          //  if(vif.O_RD_EN && !vif.I_EMPTY) begin
          //    seq.data_out = new[seq.data_out.size() + 1] (seq.data_out);  // Increase dynamic vector
          //    seq.data_out[rd_cntr] = vif.O_DATA;  
          //    rd_cntr++;
          //  end
          //end
        end
      join

      if (vif.RST_n) begin
        msg = $sformatf("BURST Transaction Monitored: DATA IN: %0d -- DATA OUT:%0d", $size(seq.data_in), $size(seq.data_out));
        `uvm_info(get_name(), msg, UVM_LOW); 
        ap.write(seq);
      end
    end
  endtask

endclass
