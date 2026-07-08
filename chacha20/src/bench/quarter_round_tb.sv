`timescale 1ns / 1ps

module quarter_round_tb ();

logic [31:0] a_s, b_s, c_s, d_s;
logic [31:0] a_out_s, b_out_s, c_out_s, d_out_s;

quarter_round DUT (
   .a_i(a_s),
   .b_i(b_s),
   .c_i(c_s),
   .d_i(d_s),
   .a_o(a_out_s),
   .b_o(b_out_s),
   .c_o(c_out_s),
   .d_o(d_out_s)
);

initial begin
   // Entrees : section 3.3.2 du sujet
   a_s = 32'h11111111;
   b_s = 32'h01020304;
   c_s = 32'h9b8d6f43;
   d_s = 32'h01234567;
   
   // Sorties attendues :
   //   a_out_s = 0xea2a92f4   c_out_s = 0x4581472e
   //   b_out_s = 0xcb1cf8ce   d_out_s = 0x5881c4bb
   #20;
end

endmodule : quarter_round_tb

