`timescale 1 ns/1 ns

module cross_bar #(parameter DATA_WIDTH = 16, ADDR_WIDTH = 32) 
	(
	input clk, rst_in,														                          // clock
	
	input wire master_1_req, master_2_req,             			    // request signals from master devices
	           master_3_req, master_4_req,					        
	output wire slave_1_req, slave_2_req,              			    // request signals to slave devices
	            slave_3_req, slave_4_req,						        
	
	input wire [ADDR_WIDTH-1:0] master_1_addr, master_2_addr,	// master's address bus
	                            master_3_addr, master_4_addr,		  		
	output reg [ADDR_WIDTH-1:0] slave_1_addr,	slave_2_addr,  	// slave's address bus
	                            slave_3_addr, slave_4_addr,			   		
	
	input wire master_1_cmd, master_2_cmd,             			    // sign of write/read operation -- master's signal
	           master_3_cmd, master_4_cmd,					        
	output reg slave_1_cmd,	slave_2_cmd,               			    // sign of write/read operation -- slave's signal
	           slave_3_cmd, slave_4_cmd,						         
	
	input wire [DATA_WIDTH-1:0] master_1_wdata, master_2_wdata, // writing data -- master's bus
	                            master_3_wdata, master_4_wdata,  
	output reg [DATA_WIDTH-1:0] slave_1_wdata, slave_2_wdata,   // writing data -- slave's bus
	                            slave_3_wdata, slave_4_wdata,		  

	output reg master_1_ack, master_2_ack,             			      // acknowledge signal
	           master_3_ack, master_4_ack,				 	        
	input wire slave_1_ack,	slave_2_ack,               			      // acknowledge signal
	           slave_3_ack, slave_4_ack,						          
	
	output reg master_1_resp, master_2_resp,           			      // responding signal
	           master_3_resp, master_4_resp,				        
	input wire slave_1_resp, slave_2_resp,             			      // responding signal 
	           slave_3_resp, slave_4_resp,					        
	
	output reg [DATA_WIDTH-1:0] master_1_rdata, master_2_rdata, // reading data -- master's bus
	                            master_3_rdata, master_4_rdata,	 	
	input wire [DATA_WIDTH-1:0] slave_1_rdata, slave_2_rdata,   // reading data -- slave's bus
	                            slave_3_rdata, slave_4_rdata		   
	
	);
	
// addresses of slave devices
	localparam slave_1 = 4'h1;
	localparam slave_2 = 4'h2;
	localparam slave_3 = 4'h4;
	localparam slave_4 = 4'h8;

//-- internal wires/registers	
	reg  [3:0] rr_inreq1, rr_inreq2,	rr_inreq3, rr_inreq4;				
	wire [3:0] rr_outreq1, rr_outreq2, rr_outreq3, rr_outreq4;				

	reg dc_outreq1, dc_outreq2, dc_outreq3, dc_outreq4;
  
  wire [3:0] s1_present_wrreq, s2_present_wrreq, s3_present_wrreq, s4_present_wrreq;
	reg [3:0]  s1_wrreq1,   s1_wrreq2,   s1_wrreq3,   s1_wrreq4;
	reg [3:0]  s2_wrreq1,   s2_wrreq2,   s2_wrreq3,   s2_wrreq4;
	reg [3:0]  s3_wrreq1,   s3_wrreq2,   s3_wrreq3,   s3_wrreq4;
	reg [3:0]  s4_wrreq1,   s4_wrreq2,   s4_wrreq3,   s4_wrreq4;
  
	reg [3:0]  s1_present_rdreq, s2_present_rdreq, s3_present_rdreq, s4_present_rdreq;
	reg [3:0]  s1_present_reader, s2_present_reader, s3_present_reader, s4_present_reader;
	reg [3:0]  s1_readbuf,  s2_readbuf,  s3_readbuf,  s4_readbuf;
	reg [3:0]  s1_rdreq1,   s1_rdreq2,   s1_rdreq3,   s1_rdreq4;
	reg [3:0]  s2_rdreq1,   s2_rdreq2,   s2_rdreq3,   s2_rdreq4;
	reg [3:0]  s3_rdreq1,   s3_rdreq2,   s3_rdreq3,   s3_rdreq4;
	reg [3:0]  s4_rdreq1,   s4_rdreq2,   s4_rdreq3,   s4_rdreq4;
  
  reg [DATA_WIDTH-1:0] s1_rd_buf1, s1_rd_buf2, s1_rd_buf3, s1_rd_buf4;
  reg [DATA_WIDTH-1:0] s2_rd_buf1, s2_rd_buf2, s2_rd_buf3, s2_rd_buf4;
  reg [DATA_WIDTH-1:0] s3_rd_buf1, s3_rd_buf2, s3_rd_buf3, s3_rd_buf4;
  reg [DATA_WIDTH-1:0] s4_rd_buf1, s4_rd_buf2, s4_rd_buf3, s4_rd_buf4;

// reading FSM wires
  wire [2:0] s1_st_cnt, s1_pres_state, s1_next_state,
             s2_st_cnt, s2_pres_state, s2_next_state,
             s3_st_cnt, s3_pres_state, s3_next_state,
             s4_st_cnt, s4_pres_state, s4_next_state; 
  localparam 
  st0 = 3'd0, // waiting for read requests
  st1 = 3'd1, // buffering (counting) read requests
  st2 = 3'd2, // buffering rdata
  st3 = 3'd3, // output rdata to masters
  st4 = 3'd4; // reset read and write buffers
//================ 
// address decoder
//================
// vector rr_inreq_N - arbiter's (round robin) input vector; N - is a slave number
	always @ (*)
		begin
		  {rr_inreq1, rr_inreq2, rr_inreq3, rr_inreq4} = 0;
			case (master_1_addr [31:28]) 	// address decoding from master_1 address bus
				slave_1: begin rr_inreq1 [0] = master_1_req; end 
				slave_2: begin rr_inreq2 [0] = master_1_req; end 
				slave_3: begin rr_inreq3 [0] = master_1_req; end 
				slave_4: begin rr_inreq4 [0] = master_1_req; end 
				default: begin {rr_inreq1 [0], rr_inreq2 [0], rr_inreq3 [0], rr_inreq4 [0]} = 0; end
			endcase
			case (master_2_addr [31:28]) 	// address decoding from master_2 address bus
				slave_1: begin rr_inreq1 [1] = master_2_req; end 
				slave_2: begin rr_inreq2 [1] = master_2_req; end 
				slave_3: begin rr_inreq3 [1] = master_2_req; end 
				slave_4: begin rr_inreq4 [1] = master_2_req; end 
				default: begin {rr_inreq1 [1], rr_inreq2 [1], rr_inreq3 [1], rr_inreq4 [1]} = 0; end
			endcase
			case (master_3_addr [31:28])	// address decoding from master_3 address bus
				slave_1: begin rr_inreq1 [2] = master_3_req; end 
				slave_2: begin rr_inreq2 [2] = master_3_req; end 
				slave_3: begin rr_inreq3 [2] = master_3_req; end 
				slave_4: begin rr_inreq4 [2] = master_3_req; end 
				default: begin {rr_inreq1 [2], rr_inreq2 [2], rr_inreq3 [2], rr_inreq4 [2]} = 0; end
			endcase
			case (master_4_addr [31:28])	// address decoding from master_4 address bus
				slave_1: begin rr_inreq1 [3] = master_4_req; end 
				slave_2: begin rr_inreq2 [3] = master_4_req; end 
				slave_3: begin rr_inreq3 [3] = master_4_req; end 
				slave_4: begin rr_inreq4 [3] = master_4_req; end 
				default: begin {rr_inreq1 [3], rr_inreq2 [3], rr_inreq3 [3], rr_inreq4 [3]} = 0; end
			endcase
		end
//	
// request round_robin arbiter for 4 slaves
	round_robin rr_slave1_arbiter (.clk (clk),.rst_in (rst_in),.rr_in (rr_inreq1),.rr_out (rr_outreq1));
	round_robin rr_slave2_arbiter	(.clk (clk),.rst_in (rst_in),.rr_in (rr_inreq2),.rr_out (rr_outreq2));
	round_robin rr_slave3_arbiter (.clk (clk),.rst_in (rst_in),.rr_in (rr_inreq3),.rr_out (rr_outreq3));	
	round_robin rr_slave4_arbiter (.clk (clk),.rst_in (rst_in),.rr_in (rr_inreq4),.rr_out (rr_outreq4));
//
// queue of write requests
  assign s1_present_wrreq = (slave_1_req && slave_1_cmd) ? rr_outreq1 : 4'b0;
  assign s2_present_wrreq = (slave_2_req && slave_2_cmd) ? rr_outreq2 : 4'b0;
  assign s3_present_wrreq = (slave_3_req && slave_3_cmd) ? rr_outreq3 : 4'b0;
  assign s4_present_wrreq = (slave_4_req && slave_4_cmd) ? rr_outreq4 : 4'b0;
  
  always @ (posedge clk or negedge rst_in)
    begin // slave_1 write requests
      if (!rst_in)
		    begin
		      s1_wrreq1 <= 4'b0;
		      s1_wrreq2 <= 4'b0;
		      s1_wrreq3 <= 4'b0;
		      s1_wrreq4 <= 4'b0;
		    end
		  else if (slave_1_req && slave_1_cmd)
		    begin
		      s1_wrreq4 <= s1_present_wrreq;
		      s1_wrreq3 <= s1_wrreq4;
		      s1_wrreq2 <= s1_wrreq3;
		      s1_wrreq1 <= s1_wrreq2;
		    end
		  else if (s1_pres_state == st4) // reset when read operation is over
		    begin
		      s1_wrreq1 <= 4'b0;
		      s1_wrreq2 <= 4'b0;
		      s1_wrreq3 <= 4'b0;
		      s1_wrreq4 <= 4'b0;
		    end
    end

  always @ (posedge clk or negedge rst_in)
    begin // slave_2 write requests
      if (!rst_in)
		    begin
		      s2_wrreq1 <= 4'b0;
		      s2_wrreq2 <= 4'b0;
		      s2_wrreq3 <= 4'b0;
		      s2_wrreq4 <= 4'b0;
		    end
		  else if (slave_2_req && slave_2_cmd)
		    begin
		      s2_wrreq4 <= s2_present_wrreq;
		      s2_wrreq3 <= s2_wrreq4;
		      s2_wrreq2 <= s2_wrreq3;
		      s2_wrreq1 <= s2_wrreq2;
		    end
		  else if (s2_pres_state == st4) // reset when read operation is over
		    begin
		      s2_wrreq1 <= 4'b0;
		      s2_wrreq2 <= 4'b0;
		      s2_wrreq3 <= 4'b0;
		      s2_wrreq4 <= 4'b0;
		    end
    end
    
  always @ (posedge clk or negedge rst_in)
    begin // slave_3 write requests
      if (!rst_in)
		    begin
		      s3_wrreq1 <= 4'b0;
		      s3_wrreq2 <= 4'b0;
		      s3_wrreq3 <= 4'b0;
		      s3_wrreq4 <= 4'b0;
		    end
		  else if (slave_3_req && slave_3_cmd)
		    begin
		      s3_wrreq4 <= s3_present_wrreq;
		      s3_wrreq3 <= s3_wrreq4;
		      s3_wrreq2 <= s3_wrreq3;
		      s3_wrreq1 <= s3_wrreq2;
		    end
		  else if (s3_pres_state == st4) // reset when read operation is over
		    begin
		      s3_wrreq1 <= 4'b0;
		      s3_wrreq2 <= 4'b0;
		      s3_wrreq3 <= 4'b0;
		      s3_wrreq4 <= 4'b0;
		    end
    end

  always @ (posedge clk or negedge rst_in)
    begin // slave_4 write requests
      if (!rst_in)
		    begin
		      s4_wrreq1 <= 4'b0;
		      s4_wrreq2 <= 4'b0;
		      s4_wrreq3 <= 4'b0;
		      s4_wrreq4 <= 4'b0;
		    end
		  else if (slave_4_req && slave_4_cmd)
		    begin
		      s4_wrreq4 <= s4_present_wrreq;
		      s4_wrreq3 <= s4_wrreq4;
		      s4_wrreq2 <= s4_wrreq3;
		      s4_wrreq1 <= s4_wrreq2;
		    end
		  else if (s4_pres_state == st4) // reset when read operation is over
		    begin
		      s4_wrreq1 <= 4'b0;
		      s4_wrreq2 <= 4'b0;
		      s4_wrreq3 <= 4'b0;
		      s4_wrreq4 <= 4'b0;
		    end
    end  
//
// rr output decoder - decoding output signals of round robin arbiters
	task rr_out_decoder;
		input [3:0] rr_outreq1;
		output dc_outreq1;
		case (rr_outreq1)
			4'b0001: begin dc_outreq1 = rr_outreq1 [0]; end
			4'b0010: begin dc_outreq1 = rr_outreq1 [1]; end
			4'b0100: begin dc_outreq1 = rr_outreq1 [2]; end
			4'b1000: begin dc_outreq1 = rr_outreq1 [3]; end
			default: begin dc_outreq1 = 0; end
		endcase
	endtask
	
	always @ (*)
		begin 
			rr_out_decoder (rr_outreq1, dc_outreq1);
			rr_out_decoder (rr_outreq2, dc_outreq2);
			rr_out_decoder (rr_outreq3, dc_outreq3);
			rr_out_decoder (rr_outreq4, dc_outreq4);
		end

	assign slave_1_req = dc_outreq1;
	assign slave_2_req = dc_outreq2;
	assign slave_3_req = dc_outreq3;
	assign slave_4_req = dc_outreq4;
//==============================================================
// master address bus, cmd port to slave and slave_ack -> master
//==============================================================   
	always @ (*)
		begin
		  {master_1_ack,master_2_ack,master_3_ack,master_4_ack} = 0;
		  case ({slave_1_req, rr_outreq1}) // commutation to slave device N1
		    5'b10001: begin // master1 -> slave1
		                slave_1_addr = master_1_addr; slave_1_cmd = master_1_cmd; 
		                master_1_ack = slave_1_ack; slave_1_wdata = master_1_wdata;
		              end     
		    5'b10010: begin // master2 -> slave1
		                slave_1_addr = master_2_addr; slave_1_cmd = master_2_cmd; 
		                master_2_ack = slave_1_ack; slave_1_wdata = master_2_wdata;
		              end        
		    5'b10100: begin // master3 -> slave1
		                slave_1_addr = master_3_addr; slave_1_cmd = master_3_cmd; 
		                master_3_ack = slave_1_ack; slave_1_wdata = master_3_wdata;  
		              end
		    5'b11000: begin // master4 -> slave1
		                slave_1_addr = master_4_addr; slave_1_cmd = master_4_cmd; 
		                master_4_ack = slave_1_ack; slave_1_wdata = master_4_wdata;  
		              end
		    default:  begin {slave_1_addr,slave_1_cmd,slave_1_wdata} = 0; end 
		  endcase
		  case ({slave_2_req, rr_outreq2}) // commutation to slave device N2
		    5'b10001: begin // master1 -> slave2
		                slave_2_addr = master_1_addr; slave_2_cmd = master_1_cmd; 
		                master_1_ack = slave_2_ack; slave_2_wdata = master_1_wdata;
		              end
		    5'b10010: begin // master2 -> slave2
		                slave_2_addr = master_2_addr; slave_2_cmd = master_2_cmd; 
		                master_2_ack = slave_2_ack; slave_2_wdata = master_2_wdata; 
		              end
		    5'b10100: begin // master3 -> slave2
		                slave_2_addr = master_3_addr; slave_2_cmd = master_3_cmd; 
		                master_3_ack = slave_2_ack; slave_2_wdata = master_3_wdata; 
		              end
		    5'b11000: begin // master4 -> slave2
		                slave_2_addr = master_4_addr; slave_2_cmd = master_4_cmd; 
		                master_4_ack = slave_2_ack; slave_2_wdata = master_4_wdata; 
		              end
		    default:  begin {slave_2_addr,slave_2_cmd,slave_2_wdata} = 0; end
		  endcase
		  case ({slave_3_req, rr_outreq3}) // commutation to slave device N3
		    5'b10001: begin // master1 -> slave3
		                slave_3_addr = master_1_addr; slave_3_cmd = master_1_cmd; 
		                master_1_ack = slave_3_ack; slave_3_wdata = master_1_wdata; 
		              end
		    5'b10010: begin // master2 -> slave3
		                slave_3_addr = master_2_addr; slave_3_cmd = master_2_cmd; 
		                master_2_ack = slave_3_ack; slave_3_wdata = master_2_wdata;  
		              end
		    5'b10100: begin // master3 -> slave3
		                slave_3_addr = master_3_addr; slave_3_cmd = master_3_cmd; 
		                master_3_ack = slave_3_ack; slave_3_wdata = master_3_wdata;  
		              end
		    5'b11000: begin // master4 -> slave3
		                slave_3_addr = master_4_addr; slave_3_cmd = master_4_cmd; 
		                master_4_ack = slave_3_ack; slave_3_wdata = master_4_wdata;  
		              end
		    default:  begin {slave_3_addr,slave_3_cmd,slave_3_wdata} = 0; end
		  endcase
		  case ({slave_4_req, rr_outreq4}) // commutation to slave device N4
		    5'b10001: begin // master1 -> slave4
		                slave_4_addr = master_1_addr; slave_4_cmd = master_1_cmd; 
		                master_1_ack = slave_4_ack; slave_4_wdata = master_1_wdata;  
		              end
		    5'b10010: begin // master2 -> slave4
		                slave_4_addr = master_2_addr; slave_4_cmd = master_2_cmd; 
		                master_2_ack = slave_4_ack; slave_4_wdata = master_2_wdata;  
		              end
		    5'b10100: begin // master3 -> slave4
		                slave_4_addr = master_3_addr; slave_4_cmd = master_3_cmd; 
		                master_3_ack = slave_4_ack; slave_4_wdata = master_3_wdata; 
		              end
		    5'b11000: begin // master4 -> slave4
		                slave_4_addr = master_4_addr; slave_4_cmd = master_4_cmd; 
		                master_4_ack = slave_4_ack; slave_4_wdata = master_4_wdata;  
		              end
		    default:  begin {slave_4_addr,slave_4_cmd,slave_4_wdata} = 0; end
		  endcase
		end
//===============
// read operation
//===============
// queue of read requests   
  
  function [3:0] present_rdrequest; // function of present read request
    input slave_ack, slave_cmd;
    input [3:0] rr_outreq;
      if (slave_ack && !slave_cmd)
        begin present_rdrequest = rr_outreq; end
      else
        begin present_rdrequest = 4'b0; end
  endfunction

  always @ (*)
    begin // present read request from master to slave_1
      s1_present_rdreq = present_rdrequest (slave_1_ack, slave_1_cmd, rr_outreq1);
    end 
  always @ (*)
    begin // present read request from master to slave_2
      s2_present_rdreq = present_rdrequest (slave_2_ack, slave_2_cmd, rr_outreq2);
    end  
  always @ (*)
    begin // present read request from master to slave_3
      s3_present_rdreq = present_rdrequest (slave_3_ack, slave_3_cmd, rr_outreq3);
    end
  always @ (*)
    begin // present read request from master to slave_4
      s4_present_rdreq = present_rdrequest (slave_4_ack, slave_4_cmd, rr_outreq4);
    end
// buffering read request to slaves and
// definition queue of read requests  
  always @ (posedge clk or negedge rst_in)
    begin // slave_1 read requests
      if (!rst_in)
		    begin
		      s1_rdreq1 <= 4'b0;
		      s1_rdreq2 <= 4'b0;
		      s1_rdreq3 <= 4'b0;
		      s1_rdreq4 <= 4'b0;
		    end
		  else if (slave_1_req && !slave_1_cmd)
		    begin
		      s1_rdreq4 <= s1_present_rdreq;
		      s1_rdreq3 <= s1_rdreq4;
		      s1_rdreq2 <= s1_rdreq3;
		      s1_rdreq1 <= s1_rdreq2;
		    end
		  else if (s1_pres_state == st4) // reset when read operation is over
		    begin
		      s1_rdreq1 <= 4'b0;
		      s1_rdreq2 <= 4'b0;
		      s1_rdreq3 <= 4'b0;
		      s1_rdreq4 <= 4'b0;
		    end
    end

  always @ (posedge clk or negedge rst_in)
    begin // slave_2 read requests
      if (!rst_in)
		    begin
		      s2_rdreq1 <= 4'b0;
		      s2_rdreq2 <= 4'b0;
		      s2_rdreq3 <= 4'b0;
		      s2_rdreq4 <= 4'b0;
		    end
		  else if (slave_2_req && !slave_2_cmd)
		    begin
		      s2_rdreq4 <= s2_present_rdreq;
		      s2_rdreq3 <= s2_rdreq4;
		      s2_rdreq2 <= s2_rdreq3;
		      s2_rdreq1 <= s2_rdreq2;
		    end
		  else if (s2_pres_state == st4) // reset when read operation is over
		    begin
		      s2_rdreq1 <= 4'b0;
		      s2_rdreq2 <= 4'b0;
		      s2_rdreq3 <= 4'b0;
		      s2_rdreq4 <= 4'b0;
		    end
    end
    
  always @ (posedge clk or negedge rst_in)
    begin // slave_3 read requests
      if (!rst_in)
		    begin
		      s3_rdreq1 <= 4'b0;
		      s3_rdreq2 <= 4'b0;
		      s3_rdreq3 <= 4'b0;
		      s3_rdreq4 <= 4'b0;
		    end
		  else if (slave_3_req && !slave_3_cmd)
		    begin
		      s3_rdreq4 <= s3_present_rdreq;
		      s3_rdreq3 <= s3_rdreq4;
		      s3_rdreq2 <= s3_rdreq3;
		      s3_rdreq1 <= s3_rdreq2;
		    end
		  else if (s3_pres_state == st4) // reset when read operation is over
		    begin
		      s3_rdreq1 <= 4'b0;
		      s3_rdreq2 <= 4'b0;
		      s3_rdreq3 <= 4'b0;
		      s3_rdreq4 <= 4'b0;
		    end
    end

  always @ (posedge clk or negedge rst_in)
    begin // slave_4 read requests
      if (!rst_in)
		    begin
		      s4_rdreq1 <= 4'b0;
		      s4_rdreq2 <= 4'b0;
		      s4_rdreq3 <= 4'b0;
		      s4_rdreq4 <= 4'b0;
		    end
		  else if (slave_4_req && !slave_4_cmd)
		    begin
		      s4_rdreq4 <= s4_present_rdreq;
		      s4_rdreq3 <= s4_rdreq4;
		      s4_rdreq2 <= s4_rdreq3;
		      s4_rdreq1 <= s4_rdreq2;
		    end
		  else if (s4_pres_state == st4) // reset when read operation is over
		    begin
		      s4_rdreq1 <= 4'b0;
		      s4_rdreq2 <= 4'b0;
		      s4_rdreq3 <= 4'b0;
		      s4_rdreq4 <= 4'b0;
		    end
    end
//
// FSM module examples
  read_fsm s1_fsm (.clk(clk),.rst_in(rst_in),.slave_req(slave_1_req),.slave_cmd(slave_1_cmd), 
                  	.st_cnt(s1_st_cnt),.pres_state(s1_pres_state),.next_state(s1_next_state));
 	read_fsm s2_fsm (.clk(clk),.rst_in(rst_in),.slave_req(slave_2_req),.slave_cmd(slave_2_cmd), 
                  	.st_cnt(s2_st_cnt),.pres_state(s2_pres_state),.next_state(s2_next_state));
 	read_fsm s3_fsm (.clk(clk),.rst_in(rst_in),.slave_req(slave_3_req),.slave_cmd(slave_3_cmd), 
                  	.st_cnt(s3_st_cnt),.pres_state(s3_pres_state),.next_state(s3_next_state));
 	read_fsm s4_fsm (.clk(clk),.rst_in(rst_in),.slave_req(slave_4_req),.slave_cmd(slave_4_cmd), 
                  	.st_cnt(s4_st_cnt),.pres_state(s4_pres_state),.next_state(s4_next_state));
// definition of present reading master
  function [3:0] present_reader;
    input [2:0] pres_state, st_cnt;
    input [3:0] rdreq1, rdreq2, rdreq3, rdreq4;
      case (pres_state)
        st2:begin
              case (st_cnt)
                3'd1: begin present_reader = rdreq1; end
                3'd2: begin present_reader = rdreq2; end
                3'd3: begin present_reader = rdreq3; end
                3'd4: begin present_reader = rdreq4; end
                default: begin present_reader = 4'b0;end
              endcase
            end
        default: begin present_reader = 4'b0; end
      endcase
  endfunction
  
  always @ (*)
    begin
      // definition of current master reading from slave_1
      s1_present_reader = present_reader (s1_pres_state, s1_st_cnt, 
                        s1_rdreq1, s1_rdreq2, s1_rdreq3, s1_rdreq4);
      // definition of current master reading from slave_2                  
      s2_present_reader = present_reader (s2_pres_state, s2_st_cnt, 
                        s2_rdreq1, s2_rdreq2, s2_rdreq3, s2_rdreq4);
      // definition of current master reading from slave_3                  
      s3_present_reader = present_reader (s3_pres_state, s3_st_cnt, 
                        s3_rdreq1, s3_rdreq2, s3_rdreq3, s3_rdreq4);
      // definition of current master reading from slave_4                  
      s4_present_reader = present_reader (s4_pres_state, s4_st_cnt, 
                        s4_rdreq1, s4_rdreq2, s4_rdreq3, s4_rdreq4);                 
    end    
// buffering slave_rdata in cross-bar
//
  task slave_rdata_buffer;
    input [2:0] pres_state;
    input [3:0] present_reader;
    input [DATA_WIDTH-1:0] slave_rdata;
    output reg [DATA_WIDTH-1:0] rd_buf1, rd_buf2, rd_buf3, rd_buf4;
      case (pres_state)
        st2:begin
              case (present_reader) // buffering rdata from slave 
                4'b0001: begin rd_buf1 = slave_rdata; end
                4'b0010: begin rd_buf2 = slave_rdata; end
                4'b0100: begin rd_buf3 = slave_rdata; end
                4'b1000: begin rd_buf4 = slave_rdata; end
              endcase
            end
        st3:begin
              case (present_reader)
                4'b0001: begin rd_buf1 = rd_buf1; end
                4'b0010: begin rd_buf2 = rd_buf2; end
                4'b0100: begin rd_buf3 = rd_buf3; end
                4'b1000: begin rd_buf4 = rd_buf4; end
              endcase
            end
        default:begin
                  rd_buf1 = 16'b0;
                  rd_buf2 = 16'b0;
                  rd_buf3 = 16'b0;
                  rd_buf4 = 16'b0;
                end
      endcase
  endtask
  
  always @ (*)
    begin // buffering rdata from slave_1
      slave_rdata_buffer (s1_pres_state, s1_present_reader, slave_1_rdata,
                          s1_rd_buf1, s1_rd_buf2, s1_rd_buf3, s1_rd_buf4);
    end
  always @ (*)
    begin // buffering rdata from slave_2                  
      slave_rdata_buffer (s2_pres_state, s2_present_reader, slave_2_rdata,
                          s2_rd_buf1, s2_rd_buf2, s2_rd_buf3, s2_rd_buf4);
    end
  always @ (*)
    begin // buffering rdata from slave_3                        
      slave_rdata_buffer (s3_pres_state, s3_present_reader, slave_3_rdata,
                          s3_rd_buf1, s3_rd_buf2, s3_rd_buf3, s3_rd_buf4);
    end
  always @ (*)
    begin  // buffering rdata from slave_4                       
      slave_rdata_buffer (s4_pres_state, s4_present_reader, slave_4_rdata,
                          s4_rd_buf1, s4_rd_buf2, s4_rd_buf3, s4_rd_buf4); 
    end                   
// definition of current master receiveing rdata from slave
//    
  task rd_master;
    input [2:0] pres_state, st_cnt; 
    input [3:0] wrreq1, wrreq2, wrreq3, wrreq4;
    output reg [3:0] readbuf;
      if (pres_state == st3)
        begin
          case (st_cnt)
            3'd1: begin readbuf = wrreq1; end
            3'd2: begin readbuf = wrreq2; end
            3'd3: begin readbuf = wrreq3; end
            3'd4: begin readbuf = wrreq4; end
            default: begin readbuf = 4'b0; end
          endcase
        end
      else begin readbuf = 4'b0; end
  endtask
  // slave_1
  // conversion reading sequence according to writing sequence
  always @ (*)
    begin
      rd_master (s1_pres_state, s1_st_cnt, s1_wrreq1, s1_wrreq2, s1_wrreq3, s1_wrreq4, s1_readbuf);
    end
  // slave_2
  // conversion reading sequence according to writing sequence
  always @ (*)
    begin
      rd_master (s2_pres_state, s2_st_cnt, s2_wrreq1, s2_wrreq2, s2_wrreq3, s2_wrreq4, s2_readbuf);
    end
  // slave_3
  // conversion reading sequence according to writing sequence
  always @ (*)
    begin
      rd_master (s3_pres_state, s3_st_cnt, s3_wrreq1, s3_wrreq2, s3_wrreq3, s3_wrreq4, s3_readbuf);
    end
  // slave_4
  // conversion reading sequence according to writing sequence
  always @ (*)
    begin
      rd_master (s4_pres_state, s4_st_cnt, s4_wrreq1, s4_wrreq2, s4_wrreq3, s4_wrreq4, s4_readbuf);
    end

// transmitting slave's rdata to master's rdata
  task rdata_sequencer;
    input [2:0] pres_state;
    input [3:0] readbuf;
    input [DATA_WIDTH-1:0] rd_buf1, rd_buf2, rd_buf3, rd_buf4;
    output [DATA_WIDTH-1:0] master_1_rdata, master_2_rdata, master_3_rdata, master_4_rdata;
    output master_1_resp, master_2_resp, master_3_resp, master_4_resp;
    
    if (pres_state == st3)
        begin
          case (readbuf)
            4'b0001:begin 
                      master_1_rdata = rd_buf1;    master_1_resp = 1'b1;             
                      master_2_rdata = 16'b0;      master_2_resp = 1'b0;
                      master_3_rdata = 16'b0;      master_3_resp = 1'b0;
                      master_4_rdata = 16'b0;      master_4_resp = 1'b0; 
                    end
            4'b0010:begin 
                      master_2_rdata = rd_buf2;    master_2_resp = 1'b1;    
                      master_1_rdata = 16'b0;      master_1_resp = 1'b0;
                      master_3_rdata = 16'b0;      master_3_resp = 1'b0;
                      master_4_rdata = 16'b0;      master_4_resp = 1'b0;
                    end
            4'b0100:begin 
                      master_3_rdata = rd_buf3;    master_3_resp = 1'b1;                    
                      master_1_rdata = 16'b0;      master_1_resp = 1'b0;
                      master_2_rdata = 16'b0;      master_2_resp = 1'b0;
                      master_4_rdata = 16'b0;      master_4_resp = 1'b0;
                    end
            4'b1000:begin 
                      master_4_rdata = rd_buf4;    master_4_resp = 1'b1;             
                      master_1_rdata = 16'b0;      master_1_resp = 1'b0;
                      master_2_rdata = 16'b0;      master_2_resp = 1'b0;
                      master_3_rdata = 16'b0;      master_3_resp = 1'b0;
                    end
            default:begin 
                      master_1_rdata = 16'b0;      master_1_resp = 1'b1;
                      master_2_rdata = 16'b0;      master_2_resp = 1'b0;
                      master_3_rdata = 16'b0;      master_3_resp = 1'b0;
                      master_4_rdata = 16'b0;      master_4_resp = 1'b0; 
                    end
          endcase
        end
      else          begin 
                      master_1_rdata = 16'b0;      master_1_resp = 1'b0;
                      master_2_rdata = 16'b0;      master_2_resp = 1'b0;
                      master_3_rdata = 16'b0;      master_3_resp = 1'b0;
                      master_4_rdata = 16'b0;      master_4_resp = 1'b0; 
                    end
  endtask
      
  always @ (*)
    begin // slave_1 rdata sequencer
      rdata_sequencer (s1_pres_state, s1_readbuf, s1_rd_buf1, s1_rd_buf2, s1_rd_buf3, s1_rd_buf4,
                      master_1_rdata, master_2_rdata, master_3_rdata, master_4_rdata,
                      master_1_resp, master_2_resp, master_3_resp, master_4_resp);
    end
    
  always @ (*)
    begin // slave_2 rdata sequencer
      rdata_sequencer (s2_pres_state, s2_readbuf, s2_rd_buf1, s2_rd_buf2, s2_rd_buf3, s2_rd_buf4,
                      master_1_rdata, master_2_rdata, master_3_rdata, master_4_rdata,
                      master_1_resp, master_2_resp, master_3_resp, master_4_resp);
    end
  
  always @ (*)
    begin // slave_3 rdata sequencer
      rdata_sequencer (s3_pres_state, s3_readbuf, s3_rd_buf1, s3_rd_buf2, s3_rd_buf3, s3_rd_buf4,
                      master_1_rdata, master_2_rdata, master_3_rdata, master_4_rdata,
                      master_1_resp, master_2_resp, master_3_resp, master_4_resp);
    end
  
  always @ (*)
    begin // slave_4 rdata sequencer
      rdata_sequencer (s4_pres_state, s4_readbuf, s4_rd_buf1, s4_rd_buf2, s4_rd_buf3, s4_rd_buf4,
                      master_1_rdata, master_2_rdata, master_3_rdata, master_4_rdata,
                      master_1_resp, master_2_resp, master_3_resp, master_4_resp);
    end
  
endmodule
