`timescale 1 ns/ 1 ns

module slave_device_tb ();
  
  reg clk, clk_pll, rst_in;

  reg slave_req, slave_cmd;
  
  wire slave_ack, slave_resp;
  
  reg [31:0] slave_wdata, slave_addr;
  wire [31:0] slave_rdata;
  
  slave_device slave_dev
  (.clk_pll (clk_pll),
  .slave_clk(clk),.slave_rst_in(rst_in),.slave_req(slave_req),.slave_cmd(slave_cmd),.slave_ack(slave_ack),
   .slave_resp(slave_resp),.slave_wdata(slave_wdata),.slave_addr(slave_addr),.slave_rdata(slave_rdata));
  
  initial
    begin
      rst_in = 1'b0;
      clk = 1'b0;
      clk_pll = 1'b0;
    end
  
  always #10 clk = !clk;
  always #2 clk_pll = !clk_pll;
  always #1 rst_in = 1'b1;
  
 /* initial
    begin
      fork
      #5 slave_req = 1'b1;
      #5 slave_addr = 32'h1000_0001;
      #5 slave_wdata = 32'd1111;
      #5 slave_cmd = 1'b1;
      join
      fork
      #20 slave_req = 1'b0;
      #20 slave_addr = 32'h0000_0000;
      #20 slave_wdata = 32'd0;
      #20 slave_cmd = 1'b0;
      join
    end*/
    
    initial
      begin
        @ (posedge clk)
        slave_req = 1'b1;
        slave_addr = 32'h1000_0001;
        slave_cmd = 1'b1;
        slave_wdata = 32'd1111;
        @ (slave_ack)
        @ (posedge clk_pll)
        slave_cmd = 1'b0;
        slave_wdata = 32'd0; 
        
        @ (posedge clk)
        slave_req = 1'b1;
        slave_addr = 32'h1000_0002;
        slave_cmd = 1'b1;
        slave_wdata = 32'd2222;
        @ (slave_ack)
        @ (posedge clk_pll)
        slave_cmd = 1'b0;
        slave_wdata = 32'd0;
        
        @ (posedge clk)
        slave_req = 1'b1;
        slave_addr = 32'h1000_0004;
        slave_cmd = 1'b1;
        slave_wdata = 32'd3333;
        @ (slave_ack)
        @ (posedge clk_pll)
        slave_cmd = 1'b0;
        slave_wdata = 32'd0; 
        
        @ (posedge clk)
        slave_req = 1'b0;
        slave_addr = 32'h0;
      end

//  always @ (posedge clk_pll)
  //  begin
      
 
endmodule