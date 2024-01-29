//////////////////////////////////////////////////////////////////////////
//  Module:         sim_async_fifo.sv
//  Description:    Asynchronous Fifo model based off of the specifcation
//                  from the ECE-593 final project. This is for testing
//                  purposes.
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           01/25/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

package
// Import anything useful here

class async_fifo;
  logic wr_en;
  logic rd_en;



  funtion run();
    fork
      // Verification tasks
      compare_input();
      compare_input1();
      compare_input2();
    join_none

  endfunction
endclass

task compare_input();
  forever begin
    @(posedge w_en); 
    $display("");
  end
endtask


endpackage
