module W_PTR_Handler #(parameter PTR_WIDTH = 3)
(
input logic W_CLK, WRST_n, W_EN,
input logic [PTR_WIDTH:0] G_RPTR_SYNC,
output logic [PTR_WIDTH:0] B_WPTR,G_WPTR,
output logic FULL
);

logic [PTR_WIDTH:0] B_WPTR_NXT;
logic [PTR_WIDTH:0] G_WPTR_NXT;

bit wrapped_mem;
logic W_FULL;

assign B_WPTR_NXT = B_WPTR_NXT+(W_EN & !FULL);
assign G_WPTR_NXT = (B_WPTR_NXT >> 1) ^ B_WPTR_NXT;

always_ff @(posedge W_CLK) begin

	if(WRST_n) begin
		B_WPTR <= 0;
		G_WPTR <= 0;
		end
		else begin
		B_WPTR <= B_WPTR_NXT;
		G_WPTR <= G_WPTR_NXT;
		end
	end
	
always_ff @(posedge W_CLK) begin

	if (!WRST_n) FULL <= 0;
	else FULL <= W_FULL;
	
	end
	
	assign W_FULL = (G_WPTR_NXT == {~G_RPTR_SYNC[PTR_WIDTH:PTR_WIDTH-1],G_RPTR_SYNC[PTR_WIDTH-2:0]});
endmodule
