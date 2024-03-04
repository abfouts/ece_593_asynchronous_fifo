module gray_2_bin(O_BIN,I_GRAY);
parameter data_width = 9;

input logic [data_width-1:0] I_GRAY;
output logic [data_width-1:0] O_BIN;

always_comb begin
for(int i=data_width-1; i>=0; i--) begin
	if(i==data_width-1)
		O_BIN[data_width-1] = I_GRAY[data_width-1];
	else begin
		O_BIN[i] = I_GRAY[i] ^ O_BIN[i+1];
	end
end
end

endmodule