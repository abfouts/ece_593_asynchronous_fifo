module BIN_CNT(CNT, RST_n, CLK, EN);

parameter data_width = 9;

input logic	CLK, RST_n, EN;
output logic [data_width-1:0] CNT;  

logic [data_width:0] REG_CNT;

always_ff@(posedge CLK) begin
  if(!RST_n)
    REG_CNT <= '0;
  else if(EN)
	REG_CNT <= REG_CNT+1'b1;
  else
	REG_CNT <= REG_CNT;
end

assign CNT = REG_CNT;
endmodule