`timescale 1ns / 1ps

module chacha_round_tb ();
import chacha_pack::*;

state_t state_s;
state_t result_s;
logic   sel_s;

chacha_round DUT (
   .s_i(state_s),
   .sel_i(sel_s),
   .s_o(result_s)
);

initial begin
   // bloc initial #1 (section 5 du sujet)
   state_s[0]  = 32'h61707865;
   state_s[1]  = 32'h3320646e;
   state_s[2]  = 32'h79622d32;
   state_s[3]  = 32'h6b206574;
   state_s[4]  = 32'he921c73a;
   state_s[5]  = 32'h76a2b5ea;
   state_s[6]  = 32'h322fdc9a;
   state_s[7]  = 32'h27a09386;
   state_s[8]  = 32'hd52a3eec;
   state_s[9]  = 32'hd3a53fef;
   state_s[10] = 32'h860e69ae;
   state_s[11] = 32'h4e7ced7e;
   state_s[12] = 32'h00000001;
   state_s[13] = 32'h06e46ce3;
   state_s[14] = 32'hcaccf259;
   state_s[15] = 32'hd4ac91b9;

   // test 1 : ronde en colonne (sel_i = 0)
   // Attendu (section 5 du sujet, ronde #0) :
   //   result_s[0]  = 0xdf768f7d   result_s[4]  = 0xb51b4034
   //   result_s[12] = 0xe8c5efe0   ... (etc.)
   sel_s = 1'b0;
   #20;

   // test 2 : ronde en diagonale (sel_i = 1)
   // on injecte le resultat de la ronde en colonne
   // Attendu (section 5 du sujet, ronde #0 finale) :
   //   result_s[0]  = 0xf2727b43   result_s[4]  = 0xbde92772
   //   result_s[12] = 0x14994be7   ... (etc.)
   state_s = result_s;
   sel_s = 1'b1;
   #20;
end

endmodule : chacha_round_tb
