module FIFO2_mem (I_DATA, O_DATA, W_ADDR, W_EN, W_CLK, R_ADDR, R_EN, R_CLK, FULL, EMPTY);
parameter data_width = 9;
parameter addr_width = 10;

input logic [data_width-1:0] I_DATA;
input logic [addr_width-1:0] W_ADDR, R_ADDR;
input logic W_EN, R_EN;
input logic W_CLK, R_CLK;
input logic FULL, EMPTY;
output logic [data_width-1:0] O_DATA;

logic [data_width-1:0] mem [2**(addr_width-1)-1:0];

always_ff@(posedge W_CLK) begin
  if(W_EN && !FULL)
	mem[W_ADDR] <= O_DATA;
  else
	mem[W_ADDR] <= mem[W_ADDR];
end

always_ff@(posedge R_CLK) begin
  if(R_EN && !EMPTY)
	I_DATA <= mem[R_ADDR];
  else
	I_DATA <= 'X;
end

endmodule