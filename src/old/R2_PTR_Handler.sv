module R2_PTR_Handler (EMPTY, R_PTR, G_RPTR, R_CLK, RRST_n, R_EN, G_WPTR_SYNC);

parameter PTR_WIDTH = 10;

input logic [PTR_WIDTH-1:0] G_WPTR_SYNC;
input logic R_CLK, RRST_n, R_EN;
output logic [PTR_WIDTH-1:0] R_PTR;	 	
output logic [PTR_WIDTH-1:0] G_RPTR;  	
output logic EMPTY;
logic R_EMPTY;

logic [PTR_WIDTH-1:0] B_RPTR_NXT;
logic [PTR_WIDTH-1:0] G_RPTR_NXT; 

assign B_RPTR_NXT  = R_PTR+(R_EN &! EMPTY);
assign G_RPTR_NXT = (B_RPTR_NXT >>1)^B_RPTR_NXT;

always@(posedge R_CLK or negedge RRST_n)
begin
if(!RRST_n) begin
R_PTR <= 0;
G_RPTR <= 0;
end
else begin
R_PTR <= B_RPTR_NXT;
G_RPTR <= G_RPTR_NXT;

end
end

always@(posedge R_CLK or negedge RRST_n) begin
if(!RRST_n) EMPTY <= 1;
			else
			EMPTY <= R_EMPTY;
			end

endmodule


