module bin_2_gray(O_GRAY, I_BIN);
parameter data_width = 9;
   
input logic[data_width-1:0] I_BIN;
output logic [data_width-1:0] O_GRAY;

always_comb begin
for(int i=data_width-1; i>=0; i--) begin
	if(i==data_width-1)
		O_GRAY[data_width-1] = I_BIN[data_width-1];
	else begin
		O_GRAY[i] = I_BIN[i+1] ^ I_BIN[i];
	end
end
end

endmodule