`timescale 1 ns/1 ns
module slave_device #(parameter DATA_WIDTH = 16, ADDR_WIDTH = 32)
  (
  input clk, clk_pll, rst_in, 
  input slave_req, slave_cmd, 
  
  output reg slave_ack, slave_resp,
  
  input [DATA_WIDTH-1:0] slave_wdata, 
  input [ADDR_WIDTH-1:0] slave_addr,
  output reg [DATA_WIDTH-1:0] slave_rdata
  
  );

  wire [DATA_WIDTH-1:0] ram_out;
  reg [DATA_WIDTH-1:0] wdata;
  reg [ADDR_WIDTH-1:0] addr;
  reg cmd;
  
  reg shift_req, shift_cmd;
  reg [DATA_WIDTH-1:0] delayed_rdata1, delayed_rdata2, delayed_rdata3, delayed_rdata4;
//
  always @ (posedge clk_pll)
    begin
      addr <= slave_addr;
      wdata <= slave_wdata;
      cmd <= slave_cmd;
    end
 
  always @ (posedge clk or negedge rst_in)
    begin
      if (!rst_in)
        begin
          shift_req <= 1'b0;
          shift_cmd <= 1'b0;
        end
      else
        begin
          shift_req <= slave_req;
          shift_cmd <= slave_cmd;
        end
    end
           
 
  always @ (*)
    begin
      if ((slave_req == 1) && (addr == slave_addr) && (wdata == slave_wdata) && (cmd == slave_cmd)) 
        begin slave_ack = 1'b1; end
      else 
        begin slave_ack = 1'b0; end
    end

  ram2port ram1 
  (
   .data(wdata),
	 .rdaddress(addr [5:0]),
	 .rdclock(clk),
	 .rden(!cmd),
	 .wraddress(addr [5:0]),
	 .wrclock(clk),
	 .wren(cmd),
	 .q(ram_out)
  );
  
//=======
// FSM for reading operation 
//=======

  reg [2:0] st_cnt, pres_state, next_state;
            
  localparam  // FSM states
  st0 = 3'd0, // waiting for read requests
  st1 = 3'd1, // buffering (counting) read requests
  st2 = 3'd2; // output rdata
  
// state register	
	always @ (posedge clk or negedge rst_in)
	 begin // slave_statereg
	   if (!rst_in)
	     begin
	       pres_state <= st0;
	     end
	   else
	     begin
	       pres_state <= next_state;
	     end
	 end

// state counter
  
  always @ (posedge clk or negedge rst_in)
	 begin // slave_1_state_counter
	   if (!rst_in)
	     begin 
	       st_cnt <= 3'd0; 
	     end
	   else
	     begin
	       case ({pres_state, next_state})
	         // waiting for read requests
	         {st0, st0}: begin st_cnt <= 3'd0; end
	         {st0, st1}: begin st_cnt <= 3'd1; end
	         // buffering read requests and delaying rdata from ram_out     
	         {st1, st1}: if (shift_req && !shift_cmd) 
	                       begin 
	                         st_cnt <= st_cnt + 1'b1; 
	                       end 
	                     else 
	                       begin 
	                         st_cnt <= st_cnt;   
	                       end
	         // output delayed rdata from ram_out and resp to slave_rdata              
	         {st1, st2}: begin st_cnt <= 3'd1;          end
	         {st2, st2}: begin st_cnt <= st_cnt + 1'b1; end
	         default:    begin st_cnt <= 3'd0;          end  
	       endcase
	     end 
	 end
  

// FSM's combinational block
  
  always @ (*)
    begin
      case (pres_state)
        st0: if (shift_req && !shift_cmd) begin next_state = st1; end
             else                         begin next_state = st0; end
        st1: if (st_cnt == 3'd4) begin next_state = st2; end
        st2: if (st_cnt == 3'd4) begin next_state = st0; end
      endcase
    end
  
 
// rdata, resp

  always @ (st_cnt)
    begin
      case (pres_state)
        st0: begin // waiting for read requests
         	    delayed_rdata1 = 16'b0;
              delayed_rdata2 = 16'b0;
              delayed_rdata3 = 16'b0;
              delayed_rdata4 = 16'b0;
              slave_rdata = 16'b0; 
              slave_resp = 1'b0;
           	 end
        st1: // delaying rdata from ram_out
          case (st_cnt)
            3'd1: begin delayed_rdata1 = ram_out; end 
            3'd2: begin delayed_rdata2 = ram_out; end 
            3'd3: begin delayed_rdata3 = ram_out; end
            3'd4: begin delayed_rdata4 = ram_out; end
            default: begin 
                        delayed_rdata1 = 16'b0;
                        delayed_rdata2 = 16'b0;
                        delayed_rdata3 = 16'b0;
                        delayed_rdata4 = 16'b0;
                     end
          endcase
        st2: // output buffering rdata to slave_rdata
          case (st_cnt)
            3'd1: begin slave_rdata = delayed_rdata1; slave_resp = 1'b1; end 
            3'd2: begin slave_rdata = delayed_rdata2; slave_resp = 1'b1; end
            3'd3: begin slave_rdata = delayed_rdata3; slave_resp = 1'b1; end
            3'd4: begin slave_rdata = delayed_rdata4; slave_resp = 1'b1; end
            default: begin slave_rdata = 16'b0; slave_resp = 1'b0; end
          endcase
      endcase
    end
              
endmodule