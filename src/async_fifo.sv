//////////////////////////////////////////////////////////////////////
//  Module:         async_fifo.sv
//  Description:    Asynchronous Fifo based off of the specifcation
//                  from the ECE-593 final project.
//
//  Authors:        Abram Fouts, Yunus Syed
//  Date:           01/25/2024
//  
//  Revision:       1.0 
//////////////////////////////////////////////////////////////////////


module async_fifo #(
  P_DATA_WIDTH = 8,
  P_MEM_DEPTH = 333
)(
  // Inputs
  input PROD_CLK,
  input CON_CLK,
  input logic RST_n,
  input logic [P_DATA_WIDTH-1:0] DATA_IN,
  input W_EN, 
  input R_EN,

  // Outputs
  output logic [P_DATA_WIDTH-1:0] DATA_OUT,
  output logic FULL = 0,
  output logic EMPTY = 1
);

integer wr_ptr = 0;
integer rd_ptr = 0;
bit wrapped_mem = 1'b0;

// Memory
logic [P_DATA_WIDTH-1:0] memory [P_MEM_DEPTH-1:0];

// Write/Read Logic
integer wr_clk_cnt = 0;
integer rd_clk_cnt = 0;
logic write = 1'b0;
logic read = 1'b0;

always @(posedge PROD_CLK or negedge RST_n) begin
  if (RST_n == 1'b0) begin
    wr_clk_cnt <= 0;
  end 
  else if(W_EN) begin
    wr_clk_cnt = ((wr_clk_cnt+1) % 3);
  end
  else begin
    wr_clk_cnt <= 0;
  end
end

always @(posedge CON_CLK or negedge RST_n) begin
  if (RST_n == 1'b0) begin
    rd_clk_cnt <= 0;
  end 
  else if (R_EN) begin
    rd_clk_cnt = ((rd_clk_cnt + 1) % 2);
  end
  else begin
    rd_clk_cnt <= 0;
  end
end

always @(posedge PROD_CLK or negedge RST_n) begin
  if (RST_n == 1'b0) begin
    write <= 0;
  end 
  if (wr_clk_cnt == 2) begin
    if (!FULL) begin
      if (W_EN) begin
        write <= 1'b1;
      end
    end
  end 
  else begin
    write <= 1'b0;
  end
end

always @(posedge CON_CLK or negedge RST_n) begin
  if (RST_n == 1'b0) begin
    read <= 0;
  end 
  if (rd_clk_cnt == 1) begin
    if (!EMPTY) begin
      if (R_EN) begin
        read <= 1'b1;
      end
    end
  end 
  else begin
    read <= 1'b0;
  end 
end

  //---------------------------
  // Always block for writes
  //---------------------------
  always @(posedge write or negedge RST_n) begin 
    if (RST_n == 1'b0) begin
      foreach (memory[i]) begin
        memory[i] = 8'h00;
      end 
      wr_ptr = '0;

    end
    else begin
      if (write && W_EN && !FULL) begin
        memory[wr_ptr] = DATA_IN;
        wr_ptr = (wr_ptr + 1'b1) % P_MEM_DEPTH;
      end
    end
  end

  //---------------------------
  // Always block for reads
  //---------------------------
  always @(posedge read or negedge RST_n) begin 
    if (RST_n == 1'b0) begin
      DATA_OUT = 'z;
      rd_ptr = '0;
    end
    else begin
      if (read && R_EN && !EMPTY) begin
        DATA_OUT = memory[rd_ptr];
        rd_ptr = (rd_ptr + 1'b1) % P_MEM_DEPTH;
      end 
    end
  end

  //---------------------------
  // Always block for wrapped control 
  //---------------------------
  always_latch begin
    if (RST_n == 1'b0) begin
      wrapped_mem = 1'b0;
    end 
    else begin
      if (wr_ptr == 0) begin
        wrapped_mem = 1'b1;
      end

      if (rd_ptr == 0) begin
        wrapped_mem = 1'b0;
      end
    end
  end


  //---------------------------
  // FULL / EMPTY Handles
  //---------------------------
  always_comb begin
    if (RST_n == 1'b0) begin
      FULL = 1'b0;
      EMPTY = 1'b1;
    end
    else begin
      if (rd_ptr == wr_ptr) begin
        if (wrapped_mem) begin
          FULL = 1'b1;
          EMPTY = 1'b0;
        end   
        else begin
          FULL = 1'b0;
          EMPTY = 1'b1;
        end
      end
      else begin
        FULL = 1'b0;
        EMPTY = 1'b0;
      end 
    end
  end

endmodule
