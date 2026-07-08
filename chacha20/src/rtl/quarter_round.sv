`timescale 1ns / 1ps

module quarter_round (
   input  logic [31:0] a_i,
   input  logic [31:0] b_i,
   input  logic [31:0] c_i,
   input  logic [31:0] d_i,
   output logic [31:0] a_o,
   output logic [31:0] b_o,
   output logic [31:0] c_o,
   output logic [31:0] d_o
);

logic [31:0] a1_s, d1_s; // sorties etage 1
logic [31:0] c1_s, b1_s; // sorties etage 2
logic [31:0] a2_s, d2_s; // sorties etage 3
logic [31:0] c2_s, b2_s; // sorties etage 4

// Etage 1 : a = a + b ; d = d ^ a ; d = d <<< 16
arx #(.SHIFT_g(16)) arx_1 (
   .augend_i(a_i),
   .addend_i(b_i),
   .xor_i(d_i),
   .sum_o(a1_s),
   .shift_o(d1_s)
);

// Etage 2 : c = c + d ; b = b ^ c ; b = b <<< 12
arx #(.SHIFT_g(12)) arx_2 (
   .augend_i(c_i),
   .addend_i(d1_s),
   .xor_i(b_i),
   .sum_o(c1_s),
   .shift_o(b1_s)
);

// Etage 3 : a = a + b ; d = d ^ a ; d = d <<< 8
arx #(.SHIFT_g(8)) arx_3 (
   .augend_i(a1_s),
   .addend_i(b1_s),
   .xor_i(d1_s),
   .sum_o(a2_s),
   .shift_o(d2_s)
);

// Etage 4 : c = c + d ; b = b ^ c ; b = b <<< 7
arx #(.SHIFT_g(7)) arx_4 (
   .augend_i(c1_s),
   .addend_i(d2_s),
   .xor_i(b1_s),
   .sum_o(c2_s),
   .shift_o(b2_s)
);

assign a_o = a2_s;
assign b_o = b2_s;
assign c_o = c2_s;
assign d_o = d2_s;

endmodule : quarter_round
