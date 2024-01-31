//////////////////////////////////////////////////////////////////////////
//  Module:         sim_ccd.sv
//
//  Description:    Crossing Clock Domain model based off of the specifcation
//                  from the ECE-593 final project. This is for testing
//                  purposes. This models the external devices used with
//                  different clock frequencies writing and reading 
//                  to and from the FIFO
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           01/25/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

package ccd_pkg;
// Import anything useful here

// Parameterized to use the same parameter within everything
class ccd #(parameter int DATA_WIDTH = 8, parameter int MAX_BURST = 1024);
  // Number of idle cycles
  int wr_idle;
  int rd_idle;
  
  // Interface 
  virtual ccd_if device_if;

  // Protected Members
  // Mailbox for comparison
  protected mailbox data_in_mb;
  protected mailbox data_out_mb;

  // New override to initialize the mailboxes to an infinite size (dynamic)
  function new();
    // Initialization
    data_in_mb = new();
    data_out_mb = new();
    wr_idle = 0;
    rd_idle = 0;
  endfunction

  //----------------------------------------------------------------------
  //  Name: run 
  //
  //  Description:  Used to kick off verification comparing tasks
  //                and to run any indefinite checks 
  //----------------------------------------------------------------------
  virtual task run();
    // Fork join_none for all comparisons to occur that are timing based
    fork
      // Verification tasks
      compare_mb();
    join_none
   endtask

  //----------------------------------------------------------------------
  //  Name: start 
  //
  //  Description:  Starts a transaction and calls the write / reads
  //                A thread is kicked off that kicks off two more threads
  //                The two extra threads, loop through the expected number
  //                of writes and waits the idle cycles + 1 and the +1
  //                cycles will write or read when data comes in or goes
  //                out. Utilizing wait() if the empty or full occurs 
  //----------------------------------------------------------------------
  task start(int num_writes, logic data[MAX_BURST-1:0][DATA_WIDTH-1:0]);
    $display("Transaction Started");

    fork
      // Writes
      fork
        for(int i = 0; i < num_writes; i++) begin
          // Error checking for requirements
          if (i >= MAX_BURST) begin
            $error("Exceding burst limitations, Actual: %0d -- Expected Max: %0d -- Time:%0t", num_writes, MAX_BURST, $time);
          end

          // Is the does data exist?
          // TODO: Verify size
          if ($size(data) < i) begin
            $error("Attempting to write no data, index: %0d -- Time:%0t", i, $time);
          end

          for(int j = 0; j < wr_idle+1; j++) begin // Idle cylce + 1 is the current cycle to write 
            @(posedge device_if.PROD_CLK);
          end
          write(data[i]);
        end
      join

      // Reads
      fork
        for(int i = 0; i < num_writes; i++) begin
          for(int j = 0; j < rd_idle+1; j++) begin // Idle cylce + 1 is the current cycle to read
            @(posedge device_if.CON_CLK);
          end
          read();
        end
      join
    join

    $display("Transaction Completed");
  endtask

  //----------------------------------------------------------------------
  //  Name: write 
  //
  //  Description: writes to the FIFO 
  //----------------------------------------------------------------------
  protected task write(logic data[DATA_WIDTH-1:0]);
    // Interfacing Actions
    device_if.I_DATA[DATA_WIDTH-1:0] = data;  

    // Wait if the device is full
    wait(device_if.I_FULL == 1'b0);
    device_if.O_WR_EN = 1'b1;
    
    data_in_mb.put(data); // Place in MB

    // Strobing WR EN
    @(negedge device_if.PROD_CLK);
    device_if.O_WR_EN = 1'b0;
  endtask

  //----------------------------------------------------------------------
  //  Name: Read 
  //
  //  Description: reads from the FIFO 
  //----------------------------------------------------------------------
  protected task read();
    logic data [DATA_WIDTH-1:0];
    // Interfacing Actions
    data = device_if.O_DATA[DATA_WIDTH-1:0];

    // Wait if the device is full
    wait(device_if.I_EMPTY == 1'b0);
    device_if.O_RD_EN = 1'b1;
    
    data_out_mb.put(data); // Place in MB

    // Strobing RD EN
    @(negedge device_if.CON_CLK);
    device_if.O_RD_EN = 1'b0;
  endtask

  //----------------------------------------------------------------------
  //  Name: compare_mb
  //
  //  Description:  Uses blocking mb.get to wait for the input then the out
  //                items, then compares them in the order at which the 
  //                the mailboxes fill up. Then reports if the data
  //                is a match, or if the data is a mismatch 
  //----------------------------------------------------------------------
  task compare_mb();
    logic [DATA_WIDTH-1:0] d_in;
    logic [DATA_WIDTH-1:0] d_out;

    forever begin
      data_in_mb.get(d_in); // Blocking, so will not continue until it receives an item 
      data_out_mb.get(d_out); // Blocking, so will not continue until it receives an item 

      if (d_in == d_out) begin
        $display("Data In: %0x -- Data Out: %0x -- MATCH -- time %0t", d_in, d_out, $time);
      end else begin
        $display("Data In: %0x -- Data Out: %0x -- NO MATCH -- time %0t", d_in, d_out, $time);
        $stop;
      end
    end
  endtask

endclass
endpackage
