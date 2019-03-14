`timescale 1 ns/ 1 ns
module cross_bar_tb #(parameter DATA_WIDTH = 16, ADDR_WIDTH = 32)
  ();
  
	reg clk, clk_pll, rst_in;										                   // clock's/reset
	
	reg req1, req2, req3, req4;
  reg cmd1, cmd2, cmd3, cmd4;
  wire ack1, ack2, ack3, ack4;
  wire resp1, resp2, resp3, resp4;
  
  reg [DATA_WIDTH-1:0] wdata1, wdata2, wdata3, wdata4;
  reg [ADDR_WIDTH-1:0] addr1, addr2, addr3, addr4; 
  wire [DATA_WIDTH-1:0] rdata1, rdata2, rdata3, rdata4;
  
	wire master_1_req, master_2_req,              			     // request signals from master devices
	    master_3_req, master_4_req;						         
	wire slave_1_req, slave_2_req,               			      // request signals to slave devices
	     slave_3_req, slave_4_req;							         
	
	wire [ADDR_WIDTH-1:0] master_1_addr, master_2_addr,	  // master's address bus
	           master_3_addr, master_4_addr;		   		
	wire [ADDR_WIDTH-1:0] slave_1_addr,	slave_2_addr,     // slave's address bus	
	            slave_3_addr, slave_4_addr;			   	
	
	wire master_1_cmd, master_2_cmd,              			     // sign of "master to slave" operation -- master's signal
	    master_3_cmd, master_4_cmd;					      	   
	wire slave_1_cmd,	slave_2_cmd,               			      // slave's signal
	     slave_3_cmd, slave_4_cmd;						         
	
	wire [DATA_WIDTH-1:0] master_1_wdata, master_2_wdata,  // writing data -- master's bus
	           master_3_wdata, master_4_wdata;   
	wire [DATA_WIDTH-1:0] slave_1_wdata, slave_2_wdata,   // writing data -- slave's bus
	            slave_3_wdata, slave_4_wdata;		  

	wire [DATA_WIDTH-1:0] master_1_rdata, master_2_rdata, // reading data -- master bus
              master_3_rdata, master_4_rdata;  
	wire [DATA_WIDTH-1:0] slave_1_rdata, slave_2_rdata,   // reading data -- slave bus
	            slave_3_rdata, slave_4_rdata;	   

	wire master_1_ack, master_2_ack,             			      // acknowledge signal 
	     master_3_ack, master_4_ack;				 	       
	wire slave_1_ack,	slave_2_ack,               			      // acknowledge signal 
	     slave_3_ack, slave_4_ack;						         
	
	wire master_1_resp, master_2_resp,           			      // responding signal 
	     master_3_resp, master_4_resp;				       
	wire slave_1_resp, slave_2_resp,             			      // responding signal 
	     slave_3_resp, slave_4_resp;					        

// module examples 
  master_device mdev1 
  (.clk(clk),.rst_in(rst_in),.req(req1),.cmd(cmd1),.ack(ack1),.resp(resp1),.wdata(wdata1),.rdata(rdata1),.addr(addr1),
  .master_req(master_1_req),.master_cmd(master_1_cmd),.master_wdata(master_1_wdata),.master_rdata(master_1_rdata),
  .master_addr(master_1_addr),.master_ack(master_1_ack),.master_resp(master_1_resp));
  
  master_device mdev2 
  (.clk(clk),.rst_in(rst_in),.req(req2),.cmd(cmd2),.ack(ack2),.resp(resp2),.wdata(wdata2),.rdata(rdata2),.addr(addr2),
  .master_req(master_2_req),.master_cmd(master_2_cmd),.master_wdata(master_2_wdata),.master_rdata(master_2_rdata),
  .master_addr(master_2_addr),.master_ack(master_2_ack),.master_resp(master_2_resp));
  
  master_device mdev3 
  (.clk(clk),.rst_in(rst_in),.req(req3),.cmd(cmd3),.ack(ack3),.resp(resp3),.wdata(wdata3),.rdata(rdata3),.addr(addr3),
  .master_req(master_3_req),.master_cmd(master_3_cmd),.master_wdata(master_3_wdata),.master_rdata(master_3_rdata),
  .master_addr(master_3_addr),.master_ack(master_3_ack),.master_resp(master_3_resp));
  
  master_device mdev4 
  (.clk(clk),.rst_in(rst_in),.req(req4),.cmd(cmd4),.ack(ack4),.resp(resp4),.wdata(wdata4),.rdata(rdata4),.addr(addr4),
  .master_req(master_4_req),.master_cmd(master_4_cmd),.master_wdata(master_4_wdata),.master_rdata(master_4_rdata),
  .master_addr(master_4_addr),.master_ack(master_4_ack),.master_resp(master_4_resp));

  
  cross_bar cross_bar
  (
  .clk(clk),.rst_in(rst_in),
  .master_1_req(master_1_req),.master_2_req(master_2_req),.master_3_req(master_3_req),.master_4_req(master_4_req),
  .slave_1_req(slave_1_req),.slave_2_req(slave_2_req),.slave_3_req(slave_3_req),.slave_4_req(slave_4_req),
  .master_1_addr(master_1_addr),.master_2_addr(master_2_addr),.master_3_addr(master_3_addr),.master_4_addr(master_4_addr),
  .slave_1_addr(slave_1_addr),.slave_2_addr(slave_2_addr),.slave_3_addr(slave_3_addr),.slave_4_addr(slave_4_addr),
  .master_1_cmd(master_1_cmd),.master_2_cmd(master_2_cmd),.master_3_cmd(master_3_cmd),.master_4_cmd(master_4_cmd),
  .slave_1_cmd(slave_1_cmd),.slave_2_cmd(slave_2_cmd),.slave_3_cmd(slave_3_cmd), .slave_4_cmd(slave_4_cmd),
  .master_1_wdata(master_1_wdata),.master_2_wdata(master_2_wdata),.master_3_wdata(master_3_wdata),.master_4_wdata(master_4_wdata),
  .slave_1_wdata(slave_1_wdata),.slave_2_wdata(slave_2_wdata),.slave_3_wdata(slave_3_wdata), .slave_4_wdata(slave_4_wdata),
  .master_1_rdata(master_1_rdata),.master_2_rdata(master_2_rdata),.master_3_rdata(master_3_rdata),.master_4_rdata(master_4_rdata),
  .slave_1_rdata(slave_1_rdata),.slave_2_rdata(slave_2_rdata),.slave_3_rdata(slave_3_rdata),.slave_4_rdata(slave_4_rdata),
  .master_1_ack(master_1_ack),.master_2_ack(master_2_ack),.master_3_ack(master_3_ack),.master_4_ack(master_4_ack),
  .slave_1_ack(slave_1_ack),.slave_2_ack(slave_2_ack),.slave_3_ack(slave_3_ack),.slave_4_ack(slave_4_ack),
  .master_1_resp(master_1_resp),.master_2_resp(master_2_resp), .master_3_resp(master_3_resp),.master_4_resp(master_4_resp),
  .slave_1_resp(slave_1_resp),.slave_2_resp(slave_2_resp),.slave_3_resp(slave_3_resp),.slave_4_resp(slave_4_resp)
  );  


  slave_device sdev1
  (.clk_pll (clk_pll),.clk(clk),.rst_in(rst_in),.slave_req(slave_1_req),.slave_cmd(slave_1_cmd),
  .slave_ack(slave_1_ack),.slave_resp(slave_1_resp),.slave_wdata(slave_1_wdata),.slave_addr(slave_1_addr),
  .slave_rdata(slave_1_rdata));
   
  slave_device sdev2
  (.clk_pll (clk_pll),.clk(clk),.rst_in(rst_in),.slave_req(slave_2_req),.slave_cmd(slave_2_cmd),
  .slave_ack(slave_2_ack),.slave_resp(slave_2_resp),.slave_wdata(slave_2_wdata),.slave_addr(slave_2_addr),
  .slave_rdata(slave_2_rdata));
   
  slave_device sdev3
  (.clk_pll (clk_pll),.clk(clk),.rst_in(rst_in),.slave_req(slave_3_req),.slave_cmd(slave_3_cmd),
  .slave_ack(slave_3_ack),.slave_resp(slave_3_resp),.slave_wdata(slave_3_wdata),.slave_addr(slave_3_addr),
  .slave_rdata(slave_3_rdata));
   
  slave_device sdev4
  (.clk_pll (clk_pll),.clk(clk),.rst_in(rst_in),.slave_req(slave_4_req),.slave_cmd(slave_4_cmd),
  .slave_ack(slave_4_ack),.slave_resp(slave_4_resp),.slave_wdata(slave_4_wdata),.slave_addr(slave_4_addr),
  .slave_rdata(slave_4_rdata));
  
  initial
    begin
      clk = 1'b0;
      clk_pll = 1'b0;    
      #2 rst_in = 1'b0;
      #3 rst_in = 1'b1;
    end
//clocks  
  always #10 clk = !clk;
  always #2 clk_pll = !clk_pll;
   
//=========
// master_1 
//=========  
  initial
    begin
      // write request from master_1 to slave_1
      @ (posedge clk)   
      req1 = 1;
      addr1 = 32'h1000_0001;
      cmd1 = 1;
      wdata1 = 16'd1111;
      // canceling request
      @ (negedge master_1_req)
          req1 = 0;
          addr1 = 32'h0;
          cmd1 = 0;
          wdata1 = 16'd0;          
      // read request from master_1 to slave_1 
      repeat (10) begin @ (posedge clk); end
      req1 = 1;
      addr1 = 32'h1000_0001;
      cmd1 = 0;     
      @ (negedge master_1_req)
      // canceling request
      req1 = 0;
      
      @ (posedge slave_1_resp)
      // write request from master_1 to slave_2
      repeat (1) begin @ (posedge clk); end
      req1 = 1;
      addr1 = 32'h2000_0001;
      cmd1 = 1;
      wdata1 = 16'd1111;
      // canceling request
      @ (negedge master_1_req)
          req1 = 0;
          addr1 = 32'h0;
          cmd1 = 0;
          wdata1 = 16'd0;        
      repeat (10)
      // read request from master_1 to slave_2 
      begin @ (posedge clk); end
      req1 = 1;
      addr1 = 32'h2000_0001;
      cmd1 = 0;
      // canceling request
      @ (negedge master_1_req)
      req1 = 0; 
      
      @ (posedge slave_2_resp)
      // write request from master_1 to slave_3
      repeat (1) begin @ (posedge clk); end
      req1 = 1;
      addr1 = 32'h4000_0001;
      cmd1 = 1;
      wdata1 = 16'd1111;
      // canceling request
      @ (negedge master_1_req)
          req1 = 0;
          addr1 = 32'h0;
          cmd1 = 0;
          wdata1 = 16'd0;        
      repeat (10)
      // read request from master_1 to slave_3 
      begin @ (posedge clk); end
      req1 = 1;
      addr1 = 32'h4000_0001;
      cmd1 = 0;
      // canceling request
      @ (negedge master_1_req)
      req1 = 0;
      
      @ (posedge slave_3_resp)
      // write request from master_1 to slave_4
      repeat (1) begin @ (posedge clk); end
      req1 = 1;
      addr1 = 32'h8000_0001;
      cmd1 = 1;
      wdata1 = 16'd1111;
      // canceling request
      @ (negedge master_1_req)
          req1 = 0;
          addr1 = 32'h0;
          cmd1 = 0;
          wdata1 = 16'd0;        
      repeat (10)
      // read request from master_1 to slave_4 
      begin @ (posedge clk); end
      req1 = 1;
      addr1 = 32'h8000_0001;
      cmd1 = 0;
      // canceling request
      @ (negedge master_1_req)
      req1 = 0;  
    end    
//=========
// master_2 
//========= 
  initial
    begin
      // write request from master_2 to slave_1
      @ (posedge clk)   
      req2 = 1;
      addr2 = 32'h1000_0002;
      cmd2 = 1;
      wdata2 = 16'd2222; 
      // canceling request
      @ (negedge master_2_req)
          req2 = 0;
          addr2 = 32'h0;
          cmd2 = 0;
          wdata2 = 16'd0;     
      repeat (7) 
      // read request from master_2 to slave_1
      begin @ (posedge clk); end
      req2 = 1;
      addr2 = 32'h1000_0002;
      cmd2 = 0;
      // canceling request
      @ (negedge master_2_req)
      req2 = 0;
      
      @ (posedge slave_1_resp)
      // write request from master_2 to slave_2
      repeat (1) begin @ (posedge clk); end
      req2 = 1;
      addr2 = 32'h2000_0002;
      cmd2 = 1;
      wdata2 = 16'd2222;
      // canceling request
      @ (negedge master_2_req)
          req2 = 0;
          addr2 = 32'h0;
          cmd2 = 0;
          wdata2 = 16'd0;        
      repeat (7)
      // read request from master_2 to slave_2 
      begin @ (posedge clk); end
      req2 = 1;
      addr2 = 32'h2000_0002;
      cmd2 = 0;
      // canceling request
      @ (negedge master_2_req)
      req2 = 0;
      
      @ (posedge slave_2_resp)
      // write request from master_2 to slave_3
      repeat (1) begin @ (posedge clk); end
      req2 = 1;
      addr2 = 32'h4000_0002;
      cmd2 = 1;
      wdata2 = 16'd2222;
      // canceling request
      @ (negedge master_2_req)
          req2 = 0;
          addr2 = 32'h0;
          cmd2 = 0;
          wdata2 = 16'd0;        
      repeat (7)
      // read request from master_2 to slave_3 
      begin @ (posedge clk); end
      req2 = 1;
      addr2 = 32'h4000_0002;
      cmd2 = 0;
      // canceling request
      @ (negedge master_2_req)
      req2 = 0;
      
      @ (posedge slave_3_resp)
      // write request from master_2 to slave_4
      repeat (1) begin @ (posedge clk); end
      req2 = 1;
      addr2 = 32'h8000_0002;
      cmd2 = 1;
      wdata2 = 16'd2222;
      // canceling request
      @ (negedge master_2_req)
          req2 = 0;
          addr2 = 32'h0;
          cmd2 = 0;
          wdata2 = 16'd0;        
      repeat (7)
      // read request from master_2 to slave_4 
      begin @ (posedge clk); end
      req2 = 1;
      addr2 = 32'h8000_0002;
      cmd2 = 0;
      // canceling request
      @ (negedge master_2_req)
      req2 = 0;
    end
//=========
// master_3
//=========    
  initial
    begin
      // write request from master_3 to slave_1
      @ (posedge clk)   
      req3 = 1;
      addr3 = 32'h1000_0004;
      cmd3 = 1;
      wdata3 = 16'd3333; 
      // canceling request
      @ (negedge master_3_req)
          req3 = 0;
          addr3 = 32'h0;
          cmd3 = 0;
          wdata3 = 16'd0;     
      repeat (3)
      // read request from master_3 to slave_1 
      begin @ (posedge clk); end
      req3 = 1;
      addr3 = 32'h1000_0004;
      cmd3 = 0;
      // canceling request
      @ (negedge master_3_req)
      req3 = 0;
      
      @ (posedge slave_1_resp)
      // write request from master_3 to slave_2
      repeat (1) begin @ (posedge clk); end
      req3 = 1;
      addr3 = 32'h2000_0004;
      cmd3 = 1;
      wdata3 = 16'd3333;
      // canceling request
      @ (negedge master_3_req)
          req3 = 0;
          addr3 = 32'h0;
          cmd3 = 0;
          wdata3 = 16'd0;        
      repeat (3)
      // read request from master_3 to slave_2 
      begin @ (posedge clk); end
      req3 = 1;
      addr3 = 32'h2000_0004;
      cmd3 = 0;
      // canceling request
      @ (negedge master_3_req)
      req3 = 0;
      
      @ (posedge slave_2_resp)
      // write request from master_3 to slave_3
      repeat (1) begin @ (posedge clk); end
      req3 = 1;
      addr3 = 32'h4000_0004;
      cmd3 = 1;
      wdata3 = 16'd3333;
      // canceling request
      @ (negedge master_3_req)
          req3 = 0;
          addr3 = 32'h0;
          cmd3 = 0;
          wdata3 = 16'd0;        
      repeat (3)
      // read request from master_3 to slave_3 
      begin @ (posedge clk); end
      req3 = 1;
      addr3 = 32'h4000_0004;
      cmd3 = 0;
      // canceling request
      @ (negedge master_3_req)
      req3 = 0;
      
      @ (posedge slave_3_resp)
      // write request from master_3 to slave_4
      repeat (1) begin @ (posedge clk); end
      req3 = 1;
      addr3 = 32'h8000_0004;
      cmd3 = 1;
      wdata3 = 16'd3333;
      // canceling request
      @ (negedge master_3_req)
          req3 = 0;
          addr3 = 32'h0;
          cmd3 = 0;
          wdata3 = 16'd0;        
      repeat (3)
      // read request from master_3 to slave_4 
      begin @ (posedge clk); end
      req3 = 1;
      addr3 = 32'h8000_0004;
      cmd3 = 0;
      // canceling request
      @ (negedge master_3_req)
      req3 = 0;
    end
//========= 
// master_4
//=========
  initial
    begin
      // write request from master_4 to slave_1
      @ (posedge clk)   
      req4 = 1;
      addr4 = 32'h1000_0008;
      cmd4 = 1;
      wdata4 = 16'd4444; 
      // canceling request
      @ (negedge master_4_req)
          req4 = 0;
          addr4 = 32'h0;
          cmd4 = 0;
          wdata4 = 16'd0;     
      repeat (2) 
      // read request from master_4 to slave_1
      begin @ (posedge clk); end
      req4 = 1;
      addr4 = 32'h1000_0008;
      cmd4 = 0;
      // canceling request
      @ (negedge master_4_req)
      req4 = 0;
      
      @ (posedge slave_1_resp)
      // write request from master_4 to slave_2
      repeat (1) begin @ (posedge clk); end
      req4 = 1;
      addr4 = 32'h2000_0008;
      cmd4 = 1;
      wdata4 = 16'd4444;
      // canceling request
      @ (negedge master_4_req)
          req4 = 0;
          addr4 = 32'h0;
          cmd4 = 0;
          wdata4 = 16'd0;        
      repeat (2)
      // read request from master_4 to slave_2 
      begin @ (posedge clk); end
      req4 = 1;
      addr4 = 32'h2000_0008;
      cmd4 = 0;
      // canceling request
      @ (negedge master_4_req)
      req4 = 0;
      
      @ (posedge slave_2_resp)
      // write request from master_4 to slave_3
      repeat (1) begin @ (posedge clk); end
      req4 = 1;
      addr4 = 32'h4000_0008;
      cmd4 = 1;
      wdata4 = 16'd4444;
      // canceling request
      @ (negedge master_4_req)
          req4 = 0;
          addr4 = 32'h0;
          cmd4 = 0;
          wdata4 = 16'd0;        
      repeat (2)
      // read request from master_4 to slave_3 
      begin @ (posedge clk); end
      req4 = 1;
      addr4 = 32'h4000_0008;
      cmd4 = 0;
      // canceling request
      @ (negedge master_4_req)
      req4 = 0;
      
      @ (posedge slave_3_resp)
      // write request from master_4 to slave_4
      repeat (1) begin @ (posedge clk); end
      req4 = 1;
      addr4 = 32'h8000_0008;
      cmd4 = 1;
      wdata4 = 16'd4444;
      // canceling request
      @ (negedge master_4_req)
          req4 = 0;
          addr4 = 32'h0;
          cmd4 = 0;
          wdata4 = 16'd0;        
      repeat (2)
      // read request from master_4 to slave_4 
      begin @ (posedge clk); end
      req4 = 1;
      addr4 = 32'h8000_0008;
      cmd4 = 0;
      // canceling request
      @ (negedge master_4_req)
      req4 = 0;
    end
  
endmodule