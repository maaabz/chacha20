`timescale 1ns / 1ps

module arx #(
   parameter SHIFT_g = 16
) (
   input  logic [31:0] augend_i,
   input  logic [31:0] addend_i,
   input  logic [31:0] xor_i,
   output logic [31:0] sum_o,
   output logic [31:0] shift_o
);

logic [31:0] add_s;
logic [31:0] xor_s;

assign add_s = augend_i + addend_i;
assign sum_o = add_s;
assign xor_s = xor_i ^ add_s;
assign shift_o = {xor_s[31-SHIFT_g:0], xor_s[31:32-SHIFT_g]}; // Rotation circulaire à gauche de SHIFT_g bits réalisée par concaténation

endmodule : arx
