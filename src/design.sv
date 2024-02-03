`include "synchronizer.sv"
`include "W_PTR_Handler.sv"
`include "R_PTR_handler.sv"
`include "FIFO_mem.sv"

module async_fifo #(parameter DATA_WIDTH=8, parameter MEM_DEPTH=333)
(input logic W_CLK,WRST_n,
input logic R_CLK,RRST_n,
input logic W_EN,R_EN,
input logic [DATA_WIDTH-1:0] I_DATA,
output logic [DATA_WIDTH-1:0] O_DATA,
output logic FULL,EMPTY);

parameter PTR_WIDTH = $clog2(MEM_DEPTH);

logic [PTR_WIDTH:0] G_WPTR_SYNC,G_RPTR_SYNC;
logic [PTR_WIDTH:0] B_WPTR,B_RPTR;
logic [PTR_WIDTH:0] G_WPTR,G_RPTR;
logic [PTR_WIDTH-1:0] W_ADDR, R_ADDR;

synchronizer #(PTR_WIDTH) Sync_wptr (R_CLK,RRST_n, G_WPTR, G_WPTR_SYNC);
synchronizer #(PTR_WIDTH) Sync_rptr (W_CLK,WRST_n, G_RPTR, G_RPTR_SYNC);

W_PTR_Handler #(PTR_WIDTH) Wptr_L(W_CLK, WRST_n, W_EN, G_RPTR_SYNC, B_WPTR, G_WPTR, FULL);
R_PTR_handler #(PTR_WIDTH) Rptr_L(R_CLK, RRST_n, R_EN, G_WPTR_SYNC, B_RPTR, G_RPTR, EMPTY);
FIFO_mem FIFO (W_CLK, W_EN, R_CLK, R_EN, B_WPTR,B_RPTR, I_DATA, FULL,EMPTY,O_DATA);








endmodule