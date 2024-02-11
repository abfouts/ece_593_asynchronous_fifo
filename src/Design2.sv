module Design2(FULL,EMPTY, I_DATA,W_CLK, WRST_n, O_DATA, W_EN, RRST_n, R_CLK, R_EN);
parameter addr_width = 10;
parameter data_width = 9;
output logic FULL, EMPTY;
input logic [data_width-1:0] I_DATA;
output logic [data_width-1:0] O_DATA;
input logic W_CLK, W_EN, WRST_n, R_CLK, R_EN, RRST_n;
W2_PTR_Handler #(addr_width) W_P(FULL,W_PTR, G_WPTR, W_CLK, WRST_n, W_EN, G_RPTR_SYNC);
R2_PTR_Handler #(addr_width) R_P(EMPTY,R_PTR, G_RPTR, R_CLK, RRST_n, R_EN, G_WPTR_SYNC);
synchronizer #(addr_width) W_2_R(G_WPTR_SYNC, R_CLK, RRST_n, G_WPTR);
synchronizer #(addr_width) R_2_W(G_RPTR_SYNC, W_CLK, WRST_n, G_RPTR);
FIFO2_mem #(data_width
) FIFO (
  I_DATA, O_DATA, W_ADDR, W_EN, W_CLK, R_ADDR, R_EN, R_CLK, FULL, EMPTY
);
endmodule


























