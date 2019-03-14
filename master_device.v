`timescale 1 ns/1 ns
module master_device #(parameter DATA_WIDTH = 16, ADDR_WIDTH = 32)
  (
  input clk, rst_in, 
  input req, cmd, 
  input [DATA_WIDTH-1:0] wdata,  
  input [ADDR_WIDTH-1:0] addr,
  input [DATA_WIDTH-1:0] master_rdata,
  input master_ack, master_resp,
  
  output reg master_req, master_cmd, 
  output reg [DATA_WIDTH-1:0] master_wdata,
  output reg [ADDR_WIDTH-1:0] master_addr,
  output wire ack, resp,
  output [DATA_WIDTH-1:0] rdata
  );
  
  always @ (posedge clk)
    begin
      if (master_ack) 
        begin 
          master_req <= 0;
  //        master_addr <= 0;
  //        master_cmd <= 0; 
  //        master_wdata <= 0;    
        end
      else 
        begin 
          master_req <= req;
   //       master_addr <= addr;
   //       master_cmd <= cmd; 
   //       master_wdata <= wdata; 
        end
    end    
  
  always @ (*)
    begin
      if (!master_req)
        begin
          master_addr = 0; 
          master_wdata = 0;
          master_cmd = 0;
        end
      else
        begin
          master_addr = addr; 
          master_wdata = wdata;
          master_cmd = cmd; 
        end
    end
        
  assign ack = master_ack;
  assign resp = master_resp;
  assign rdata = master_rdata;
    
endmodule