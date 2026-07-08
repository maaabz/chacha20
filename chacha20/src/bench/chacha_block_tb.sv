`timescale 1ns / 1ps

module chacha_block_tb ();
import chacha_pack::*;

logic         clock_s;
logic         resetb_s;
logic [255:0] key_s;
logic [95:0]  nonce_s;
logic         init_s;
logic         sel_s;
logic         active_s;
logic         add_sinit_s;
state_t       keystream_s;

chacha_block DUT (
   .clock_i(clock_s),
   .resetb_i(resetb_s),
   .key_i(key_s),
   .nonce_i(nonce_s),
   .init_i(init_s),
   .sel_i(sel_s),
   .active_i(active_s),
   .add_sinit_i(add_sinit_s),
   .keystream_o(keystream_s)
);

// generation horloge 100 MHz
initial clock_s = 1'b0;
always #5 clock_s = ~clock_s;

initial begin
   // valeurs par defaut
   resetb_s    = 1'b1;
   init_s      = 1'b0;
   sel_s       = 1'b0;
   active_s    = 1'b0;
   add_sinit_s = 1'b0;
   key_s       = 256'h0;
   nonce_s     = 96'h0;

   // reset
   #10;
   resetb_s = 1'b0;
   #10;
   resetb_s = 1'b1;
   #10;

   // cle et nonce du sujet (section 5)
   key_s   = 256'h4e7ced7e860e69aed3a53fefd52a3eec27a09386322fdc9a76a2b5eae921c73a;
   nonce_s = 96'hd4ac91b9caccf25906e46ce3;

   // initialisation
   init_s = 1'b1;
   #10;
   init_s = 1'b0;

   // 20 rondes : 10 paires colonne + diagonale
   repeat (10) begin
      // ronde colonne
      sel_s    = 1'b0;
      active_s = 1'b1;
      #10;
      // ronde diagonale
      sel_s    = 1'b1;
      #10;
   end
   active_s = 1'b0;

   // addition S + S_init
   add_sinit_s = 1'b1;
   #10;
   add_sinit_s = 1'b0;
   #20;
end

endmodule : chacha_block_tb
