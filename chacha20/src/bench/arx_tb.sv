`timescale 1ns / 1ps

module arx_tb ();

logic [31:0] augend_s, addend_s, xor_s;
logic [31:0] sum_s, shift_s;

// DUT instancie avec SHIFT_g = 7 (valeur testee dans le sujet)
arx #(.SHIFT_g(7)) DUT (
   .augend_i(augend_s),
   .addend_i(addend_s),
   .xor_i(xor_s),
   .sum_o(sum_s),
   .shift_o(shift_s)
);

initial begin
// Test 1 : attendu sum_s = 0x789abcde, shift_s = 0xcc5fed3c
   augend_s = 32'h01234567;
   addend_s = 32'h77777777;
   xor_s    = 32'h01020304;
   #20;

// Test 2 : attendu sum_s = 0x1E1FE57C, shift_s = 0x54080A06
   //       (somme depasse 2^32, retenue ignoree)
   augend_s = 32'hF2E1A126;
   addend_s = 32'h2B3E4456;
   xor_s    = 32'h12B7F568;
   #20;
end

endmodule : arx_tb
