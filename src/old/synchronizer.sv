module synchronizer (PTR_SYNC, CLK, RST_N, PTR);
parameter data_width = 10;

input bit CLK, RST_N;
input logic[data_width-1:0] PTR;
output logic [data_width-1:0] PTR_SYNC;

logic [data_width-1:0] REG_PTR1, REG_PTR2;

always_ff@(posedge CLK) begin
	if(!RST_N)
	  begin
		REG_PTR1 <= '0;
		REG_PTR2 <= '0;
	  end
	else
	  begin
		REG_PTR1 <= PTR;
		REG_PTR2 <= REG_PTR1;
	  end
end

assign PTR_SYNC = REG_PTR2;

endmodule