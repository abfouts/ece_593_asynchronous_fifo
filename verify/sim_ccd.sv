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

class ccd;
 
  // Interface 
  virtual ccd_if device_if;

  virtual task run();

    // Fork join_none for all comparisons to occur that are timing based
    fork
      // Verification tasks
      compare_input();
    join_none

   endtask

  task compare_input();
    forever begin
      $display("Test");
    end
  endtask

endclass
endpackage
