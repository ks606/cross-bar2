`timescale 1 ns/1 ns
module rr_tb //#(parameter N_tb = 4)
  ();
  
  reg clk, rst_in;
  reg [3:0] rr_in;
  wire [3:0] rr_out;
  
  round_robin rr1
  (
  .clk (clk),
  .rst_in (rst_in),
  .rr_in (rr_in),
  .rr_out (rr_out)
  );

  initial 
    begin 
      clk = 1'b0;
      forever 
      #2 clk = !clk;
    end
  
  initial
    begin
    rst_in = 0;
    #1 rst_in = 1;
    end
  
  initial
    begin
      rr_in = 0;
      @ (negedge clk)
      rr_in [0] = 1;
      rr_in [1] = 1;
      rr_in [2] = 0;
      rr_in [3] = 1;
      @ (negedge clk)
      rr_in [2] = 1;
    end
      
endmodule
