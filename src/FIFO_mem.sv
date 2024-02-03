module FIFO_mem #(parameter DATA_WIDTH=8, MEM_DEPTH=333, PTR_WIDTH=3)
(
input logic W_CLK,R_CLK,// Read and Write clock
input logic W_EN, R_EN,// Read and Write Enable signals
input logic FULL,EMPTY,// Read empty and Write Full
input logic B_RPTR,B_WPTR,//Read and write pointers
input logic [DATA_WIDTH-1:0] I_DATA,//Write Data
output logic [DATA_WIDTH-1:0] O_DATA// Read Data

);

logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];


always_ff@(posedge W_CLK or negedge W_EN) begin

	if (W_EN && !FULL) begin

		 mem[B_WPTR[PTR_WIDTH-1:0]]<=I_DATA;
	end
end

assign O_DATA <= mem[B_RPTR[PTR_WIDTH-1:0]];

endmodule
