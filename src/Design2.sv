
//---------------------------------------------------------------
// FIFO TOP MODULE 
//---------------------------------------------------------------

module async_fifo #(parameter P_MEM_WIDTH = 10,
		parameter P_DATA_WIDTH = 9)


(
input logic W_CLK, W_EN, WRST_n,
input logic R_CLK, R_EN, RRST_n,
input logic [P_DATA_WIDTH-1:0] DATA_IN,

output logic FULL, EMPTY,
output logic [P_DATA_WIDTH-1:0] DATA_OUT
);

wire [P_MEM_WIDTH-1:0] W_ADDR, R_ADDR;
wire [P_MEM_WIDTH:0] wrd_ptr,rd_ptr;
wire [P_MEM_WIDTH:0] W2_RPTR,R2_WPTR;


W2_PTR_Handler #(P_MEM_WIDTH) W_P(.*);
R2_PTR_Handler #(P_MEM_WIDTH) R_P(.*);

sync_w2r #(P_MEM_WIDTH) W_2_R(.*);
sync_r2w #(P_MEM_WIDTH) R_2_W(.*);

FIFO_mem #(P_DATA_WIDTH,P_MEM_WIDTH) fifomem (.*);
endmodule

//---------------------------------------------------------------
// FIFO MEMORY MODULE 
//---------------------------------------------------------------

module FIFO_mem #(parameter P_DATA_WIDTH = 9,
parameter P_MEM_WIDTH = 10
)
(
input logic W_EN, R_EN,
input logic W_CLK, R_CLK,
input logic [P_MEM_WIDTH-1:0] W_ADDR, R_ADDR,
input logic [P_DATA_WIDTH-1:0] DATA_IN,
output logic [P_DATA_WIDTH-1:0] DATA_OUT,
input logic FULL, EMPTY
);
localparam depth = 1<<P_MEM_WIDTH; //2*addr size
logic [P_DATA_WIDTH-1:0] mem [0:depth-1];

assign DATA_OUT = mem [R_ADDR];

always_ff @(posedge W_CLK) begin 
  if(W_EN && !FULL)
	mem[W_ADDR] <= DATA_IN;
end
endmodule

//---------------------------------------------------------------
// SYNCHRONIZER READ TO WRITE MODULE 
//---------------------------------------------------------------
module sync_r2w
#(
  parameter P_MEM_WIDTH = 10
)
(
  input   W_CLK, WRST_n,
  input   [P_MEM_WIDTH:0] rd_ptr,
  output reg  [P_MEM_WIDTH:0] W2_RPTR//readpointer with write side
);

  reg [P_MEM_WIDTH:0] W1_RPTR;

  always_ff @(posedge W_CLK or negedge WRST_n) begin

    if 
	(!WRST_n) {W2_RPTR,W1_RPTR} <= 0;
    else 
	{W2_RPTR,W1_RPTR} <= {W1_RPTR,rd_ptr};
end

endmodule

//---------------------------------------------------------------
// SYNCHRONIZER WRITE TO READ MODULE  
//---------------------------------------------------------------
module sync_w2r
#(
  parameter P_MEM_WIDTH = 10
)
(
  input   R_CLK, RRST_n,
  input   [P_MEM_WIDTH:0] wrd_ptr,
  output reg [P_MEM_WIDTH:0] R2_WPTR
);

  reg [P_MEM_WIDTH:0] R1_WPTR;

  always_ff @(posedge R_CLK or negedge RRST_n) begin
    if (!RRST_n)
      {R2_WPTR,R1_WPTR} <= 0;
    else
      {R2_WPTR,R1_WPTR} <= {R1_WPTR,wrd_ptr};
end
endmodule

//---------------------------------------------------------------
// WRITE FULL MODULE  
//---------------------------------------------------------------
module W2_PTR_Handler #(parameter P_MEM_WIDTH = 10)
(
input  W_CLK, WRST_n, W_EN,
input [P_MEM_WIDTH:0] W2_RPTR,
output reg FULL,
output reg [P_MEM_WIDTH:0] wrd_ptr,	 	
output [P_MEM_WIDTH-1:0] W_ADDR  	
);
reg [P_MEM_WIDTH:0] B_WPTR;					
wire [P_MEM_WIDTH:0] G_WPTR_NXT,B_WPTR_NXT; 		


always@(posedge W_CLK or negedge WRST_n) begin
  if(!WRST_n) begin
    B_WPTR <= '0; 
    wrd_ptr <= '0;
  end
  else begin
    B_WPTR <= B_WPTR_NXT; 
    wrd_ptr <= G_WPTR_NXT; 
  end
end

assign W_ADDR = B_WPTR[P_MEM_WIDTH-1:0];
assign B_WPTR_NXT = B_WPTR+(W_EN & !FULL);
assign G_WPTR_NXT = (B_WPTR_NXT >>1)^B_WPTR_NXT;

assign W_FULL_t6 = (G_WPTR_NXT == {~W2_RPTR[P_MEM_WIDTH:P_MEM_WIDTH-1], W2_RPTR[P_MEM_WIDTH-2:0]});


always_ff @(posedge W_CLK or negedge WRST_n)
 begin
  if(!WRST_n) FULL <= 1'b0;
  else        FULL <= W_FULL_t6;
end


endmodule

//---------------------------------------------------------------
// READ EMPTY MODULE  
//---------------------------------------------------------------

module R2_PTR_Handler #(parameter P_MEM_WIDTH = 10)
(
input logic R_CLK, RRST_n, R_EN,
input logic [P_MEM_WIDTH:0] R2_WPTR,

output reg EMPTY,
output reg [P_MEM_WIDTH:0] rd_ptr,
output [P_MEM_WIDTH-1:0] W_ADDR 
);
 	
reg [P_MEM_WIDTH:0] B_RPTR;  		
wire [P_MEM_WIDTH:0]  G_RPTR_NXT, B_RPTR_NXT;  		


always_ff @(posedge R_CLK or negedge RRST_n)begin
	if(!RRST_n) begin
		rd_ptr <= 0;
		B_RPTR <= 0;
	end
	else begin
		rd_ptr <= B_RPTR_NXT;
		B_RPTR <= B_RPTR_NXT;
	end
	end


	assign R_ADDR= B_RPTR[P_MEM_WIDTH-1:0];
	assign B_RPTR_NXT  = B_RPTR+(R_EN & !EMPTY);
	assign G_RPTR_NXT = (B_RPTR_NXT >>1)^B_RPTR_NXT;
	assign EMPTY_t6 = (G_RPTR_NXT== R2_WPTR );


always_ff @(posedge R_CLK or negedge RRST_n) begin
if(!RRST_n) 
	EMPTY <= 1'b1;
else
	EMPTY <= EMPTY_t6;
end

endmodule























