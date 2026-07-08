`timescale 1ns / 1ps

import chacha_pack::*;
module register_state 

(
    input state_t d_i,
    input logic clock_i,
    input logic resetb_i,
    input logic enable_i,
    output state_t  q_o
);
  //sequential process

  always_ff @(posedge clock_i or negedge resetb_i) begin : seq_0
    // Sequential process requires non-blocking assignment <=
    if (resetb_i == 1'b0) begin
      // At reset, set all bits to 0
      q_o <= '0;
    end
    else begin
      if (enable_i == 1'b1) 
        q_o <= d_i;
    end
  end : seq_0
endmodule : register_state

