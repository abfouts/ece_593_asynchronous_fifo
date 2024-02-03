module synchronizer #(parameter DATA_WIDTH=8)
(
input logic CLK, RST_n, 
input logic  [DATA_WIDTH-1:0] DATA_I,
output logic [DATA_WIDTH-1:0] DATA_O
);
logic [DATA_WIDTH-1:0] d1,d2;

always_ff@(posedge CLK) begin
	if (!RST_n) begin
		d1 <= '0;
		d2 <= '0;
	end
	else
		begin
			d1 <= DATA_I;
			d2 <= d1;
		end
	end
	
assign DATA_O = d2;
			
endmodule
