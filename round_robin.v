`timescale 1 ns/ 1 ns
module round_robin //#(parameter N = 4)
  (
  input wire clk, rst_in,
  input wire [3:0] rr_in,
  output reg [3:0] rr_out
  );

  reg	[1:0]	pointer;
  reg	[3:0]	shift_in, shift_out, priority_comb;

  initial
    begin
      {shift_in, shift_out, priority_comb, rr_out, pointer} = 0;
    end

  always @ (*)
    begin
	   case (pointer)
		   2'd0: begin shift_in [3:0] = rr_in[3:0]; end
		   2'd1: begin shift_in [3:0] = {rr_in[0],rr_in[3:1]};   end
		   2'd2: begin shift_in [3:0] = {rr_in[1:0],rr_in[3:2]}; end
		   2'd3: begin shift_in [3:0] = {rr_in[2:0],rr_in[3]};   end
	   endcase
    end
  
  always @ (*)
    begin
	   shift_out [3:0] = 4'b0;
	   if      (shift_in [0]) begin	shift_out [0] = 1'b1; end
	   else if (shift_in [1]) begin	shift_out [1] = 1'b1; end
	   else if (shift_in [2]) begin	shift_out [2] = 1'b1; end
	   else if (shift_in [3])	begin shift_out [3] = 1'b1; end
    end

// priority 
  always @ (*)
    begin
	    case (pointer)
		    2'd0: begin priority_comb [3:0] = shift_out [3:0]; end
		    2'd1: begin priority_comb [3:0] = {shift_out [2:0],shift_out [3]};   end
		    2'd2: begin priority_comb [3:0] = {shift_out [1:0],shift_out [3:2]}; end
		    2'd3: begin priority_comb [3:0] = {shift_out [0],shift_out [3:1]};   end
	    endcase
    end

// rr_out signal

  always @ (*)//(posedge clk or negedge rst_in)
    begin
	   if (!rst_in) begin	rr_out [3:0] = 4'b0; end
	   else begin	rr_out [3:0] = priority_comb [3:0] & ~rr_out [3:0]; end  
    end

// pointer

  always @ (posedge clk or negedge rst_in)
    begin
	   if (!rst_in) begin pointer <= 2'd0; end
	   else
		    case (rr_out)
			   4'b0001: begin pointer <= 2'd1; end
			   4'b0010: begin pointer <= 2'd2; end
			   4'b0100: begin pointer <= 2'd3; end
			   4'b1000: begin pointer <= 2'd0; end
		    endcase
    end
    
endmodule
