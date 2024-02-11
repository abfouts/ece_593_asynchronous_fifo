module W2_PTR_Handler(FULL, W_PTR, G_WPTR, W_CLK, WRST_n, W_EN, G_RPTR_SYNC);
parameter PTR_WIDTH = 10;

input logic W_CLK, WRST_n, W_EN;
input logic [PTR_WIDTH-1:0] G_RPTR_SYNC;
output logic [PTR_WIDTH-1:0] W_PTR;	 	
output logic [PTR_WIDTH-1:0] G_WPTR;  	
output logic FULL;
logic [PTR_WIDTH:0] B_WPTR_NXT;
logic [PTR_WIDTH:0] G_WPTR_NXT; 
logic wrap_around;
logic W_FULL;
logic R_FULL;

assign B_WPTR_NXT = W_PTR+(W_EN & !FULL);
assign G_WPTR_NXT = (B_WPTR_NXT >>1)^B_WPTR_NXT;

always@(posedge W_CLK or negedge WRST_n) begin
  if(!WRST_n) begin
    W_PTR <= 0; 
    G_WPTR <= 0;
  end
  else begin
    W_PTR <= B_WPTR_NXT; 
    G_WPTR <= G_WPTR_NXT; 
  end
end

always@(posedge W_CLK or negedge WRST_n)
 begin
  if(!WRST_n) FULL <= 0;
  else        FULL <= W_FULL;
end

assign W_FULL = (G_WPTR_NXT == {~G_RPTR_SYNC[PTR_WIDTH-1:PTR_WIDTH-2], G_RPTR_SYNC[PTR_WIDTH-3:0]});

endmodule