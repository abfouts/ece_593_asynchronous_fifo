//////////////////////////////////////////////////////////////////////////
//  Module:         sim_async_fifo_tb.sv
//  Description:    Test bench for the asynchronous fifo DUT and model
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           01/25/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////////

module top;

async_fifo fifo_model;

fifo_model.w_en = 1;

if input == output begin
  pass = 1'b1;
end

// TODO: Delete pseudo code
//$display({"async_1: Input: %0h, Input: %0h", input[332:0], output[332:0]);
  


endmodule

function bit compare(input in[], input out[]);
  bit pass; // 1: pass / 0: fail

  if (in == out) begin
    pass = 1'b1;
  end
  else begin
    pass = 1'b0;
  end
  
   

  return 1'b1;
endfunction
