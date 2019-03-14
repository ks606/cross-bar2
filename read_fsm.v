`timescale 1 ns/1 ns
module read_fsm
  (
  input clk, rst_in, slave_req, slave_cmd,
  output reg [2:0] st_cnt, pres_state, next_state
  );
  
  localparam 
  st0 = 3'd0, // waiting for read requests
  st1 = 3'd1, // buffering (counting) read requests
  st2 = 3'd2, // buffering rdata
  st3 = 3'd3, // output rdata to masters
  st4 = 3'd4; // reset read and write buffers

// state register  
  always @ (posedge clk or negedge rst_in)
	 begin // reading from slave statereg
	   if (!rst_in)
	     begin
	       pres_state <= st0;
	     end
	   else
	     begin
	       pres_state <= next_state;
	     end
	 end

// counter 
  always @ (posedge clk or negedge rst_in)
	 begin // slave_state_counter
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
	         // counting read requests      
	         {st1, st1}: if (slave_req && !slave_cmd) 
	                       begin 
	                         st_cnt <= st_cnt + 1'b1; 
	                       end 
	                     else 
	                       begin 
	                         st_cnt <= st_cnt;   
	                       end 
	         // receiving and buffering slave_rdata
	         // and definition of order in queue         
	         {st1, st2}: begin st_cnt <= 3'd0;          end
	         {st2, st2}: begin st_cnt <= st_cnt + 1'b1; end
	         // output slave_rdata to master_rdata 
	         // according to order of write operations
	         {st2, st3}: begin st_cnt <= 3'd1;          end
	         {st3, st3}: begin st_cnt <= st_cnt + 1'b1; end
	         // reset read & write buffers
	         {st3, st4}: begin st_cnt <= 3'd1;          end  
	         {st4, st4}: begin st_cnt <= st_cnt + 1'b1; end  
	         default:    begin st_cnt <= 3'd0;          end  
	       endcase
	     end 
	 end
  
// combinational block

  always @ (*)
    begin
      case (pres_state)
        st0: 
        if (slave_req && !slave_cmd) begin next_state = st1; end
    
        else                         begin next_state = st0; end
        st1: if (st_cnt == 3'd4) begin next_state = st2; end
        st2: if (st_cnt == 3'd4) begin next_state = st3; end
        st3: if (st_cnt == 3'd4) begin next_state = st4; end
        st4: if (st_cnt == 3'd1) begin next_state = st0; end  
      endcase
    end
    
endmodule
  	