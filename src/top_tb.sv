`timescale 1ns / 1ps

module top_tb;

// Parameters
parameter addr_width = 10;
parameter data_width = 9;

// Signals
logic W_CLK, W_EN, WRST_n, R_CLK, R_EN, RRST_n;
logic FULL, EMPTY;
logic [data_width-1:0] I_DATA, O_DATA;

// Instantiate the Design module
Design2 #(addr_width, data_width) dut (
    .FULL(FULL),
    .EMPTY(EMPTY),
    .I_DATA(I_DATA),
    .W_CLK(W_CLK),
    .WRST_n(WRST_n),
    .O_DATA(O_DATA),
    .W_EN(W_EN),
    .RRST_n(RRST_n),
    .R_CLK(R_CLK),
    .R_EN(R_EN)
);

// Clock generation
initial begin
    W_CLK = 0;
    R_CLK = 0;
    forever #5 W_CLK = ~W_CLK;
    forever #10 R_CLK = ~R_CLK;
end

// Test scenario
initial begin
    // Initialize signals
    WRST_n = 1;
    RRST_n = 1;
    W_EN = 1;
    R_EN = 1;

    // Apply reset
    #20 WRST_n = 0;
    #20 RRST_n = 0;
    #20 WRST_n = 1;
    #20 RRST_n = 1;

    // Perform write and read operations
    #10;
    I_DATA = 9'b110110011; // Example data
    W_EN = 1;
    #50;
    W_EN = 0;
    #10;
    R_EN = 1;
    #30;
    R_EN = 0;

    // Add more test scenarios as needed

    // Finish simulation
    #10 $finish;
end

endmodule
