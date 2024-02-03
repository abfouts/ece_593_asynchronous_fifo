module R_PTR_handler #(parameter PTR_WIDTH=3)
(
input logic R_CLK, RRST_n, R_EN,
input logic [PTR_WIDTH:0] G_WPTR_SYNC,
output logic [PTR_WIDTH:0] B_RPTR, G_RPTR,
output logic EMPTY
);

logic [PTR_WIDTH:0] B_RPTR_NXT;
logic [PTR_WIDTH:0] G_RPTR_NXT;
logic R_EMPTY;

assign B_RPTR_NXT = B_RPTR+(R_EN & !EMPTY);
assign G_RPTR_NXT = (B_RPTR_NXT >> 1) ^ B_RPTR_NXT;
assign R_EMPTY = (G_WPTR_SYNC == G_RPTR_NXT);

always_ff @(posedge R_CLK or negedge RRST_n) begin

	if (!RRST_n) begin
		B_RPTR <= 0;
		G_RPTR <= 0;
	end
	else begin
	B_RPTR <= B_RPTR_NXT;
	G_RPTR <= G_RPTR_NXT;
	end
	end

always_ff @(posedge R_CLK or negedge RRST_n) begin
	if(!RRST_n) EMPTY <= 1;
	else EMPTY <= R_EMPTY;
	
end



endmodule
