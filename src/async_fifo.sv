//////////////////////////////////////////////////////////////////////
//  Module:         async_fifo.sv
//  Description:    Asynchronous Fifo based off of the specifcation
//                  from the ECE-593 final project.
//
//  Authors:        Abram Fouts, Yunus Syed
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////


module async_fifo #(
    DATA_WIDTH = 8;
)(
    // Inputs
    input logic [DATA_WIDTH-1:0] data_in,
    input write, 
    input read,

    // Outputs
    output logic [DATA_WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);

//TODO: Add a memory block from the specification to write the data to
//      and read the data from

    //---------------------------
    // Always block for writes
    //---------------------------
    always_comb begin
     
    end

    //---------------------------
    // Always block for reads 
    //---------------------------
    always_comb begin
     
    end

endmodule
