`timescale 1ns / 1ps

module counter
	(
     input logic		clock_i,
	 input logic		resetb_i,
	 input logic		ena_i,
	 input logic		init_i,
	 output logic [4:0]	count_o
	 );
	
	always_ff @(posedge clock_i, negedge resetb_i) begin
		if (resetb_i == 1'b0) begin
			count_o <= 0;
		end
		else begin
			if (ena_i == 1'b1) begin
				if (init_i == 1'b1)
					count_o <= 0;
				else
					count_o <= count_o + 1;
			end
		end
	end // always_ff @ (posedge clock_i, negedge resetb_i)
	
endmodule : counter

