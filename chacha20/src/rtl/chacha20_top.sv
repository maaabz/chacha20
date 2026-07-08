`timescale 1ns / 1ps

module chacha20_top
   import chacha_pack::*;
(
   input  logic         clock_i,
   input  logic         resetb_i,
   input  logic         start_i,
   input  logic [127:0] data_i,
   input  logic         data_valid_i,
   input  logic [255:0] key_i,
   input  logic [95:0]  nonce_i,
   output logic [127:0] cipher_o,
   output logic         cipher_valid_o,
   output logic         end_o
);
  // Signaux de controle issus de la FSM
   logic init_s;
   logic active_s;
   logic sel_s;
   logic add_sinit_s;
   logic end_s;
   logic cipher_valid_s;
   logic ena_s;
   logic init_count_s;

   // Sorties des compteurs
   logic [4:0] round_count_s;
   logic [4:0] block_count_raw_s;
   logic [1:0] block_count_s;

   // Pipeline de sortie
   state_t keystream_s;
   logic [127:0] keystream_slice_s;
   logic [127:0] cipher_next_s;
   logic [127:0] cipher_reg_s;
   logic         cipher_valid_reg_s;

   // FSM Moore : pilote toute la sequence
   chacha_fsm fsm_inst (
      .clock_i        (clock_i),
      .resetb_i       (resetb_i),
      .start_i        (start_i),
      .data_valid_i   (data_valid_i),
      .count_i        (round_count_s),
      .block_count_i  (block_count_s),
      .init_o         (init_s),
      .active_o       (active_s),
      .sel_o          (sel_s),
      .add_sinit_o    (add_sinit_s),
      .end_o          (end_s),
      .cipher_valid_o (cipher_valid_s),
      .ena_o          (ena_s),
      .init_count_o   (init_count_s)
   );
// Compteur des rondes (0 a 19)
   counter rounds_counter_inst (
      .clock_i  (clock_i),
      .resetb_i (resetb_i),
      .ena_i    (ena_s),
      .init_i   (init_count_s),
      .count_o  (round_count_s)
   );

   // Compteur des blocs chiffres (0 a 2)
   // ena_i = init_count_s | cipher_valid_s : on remet a zero pendant INIT
   //   et on incremente a chaque pulse cipher_valid_o
   counter blocks_counter_inst (
      .clock_i  (clock_i),
      .resetb_i (resetb_i),
      .ena_i    (init_count_s | cipher_valid_s),
      .init_i   (init_count_s),
      .count_o  (block_count_raw_s)
   );

   // On ne garde que les 2 bits utiles (3 blocs max)
   assign block_count_s = block_count_raw_s[1:0];

 // Bloc de calcul du keystream
   chacha_block block_inst (
      .clock_i     (clock_i),
      .resetb_i    (resetb_i),
      .key_i       (key_i),
      .nonce_i     (nonce_i),
      .init_i      (init_s),
      .sel_i       (sel_s),
      .active_i    (active_s),
      .add_sinit_i (add_sinit_s),
      .keystream_o (keystream_s)
   );

   // Selection de la tranche 128 bits du keystream (512 bits total)
   // selon le bloc en cours : bloc 0 -> mots 0..3, bloc 1 -> mots 4..7,
   // bloc 2 -> mots 8..11
   always_comb begin
      case (block_count_s)
         2'd0:    keystream_slice_s = {keystream_s[3],  keystream_s[2],  keystream_s[1], keystream_s[0]};
         2'd1:    keystream_slice_s = {keystream_s[7],  keystream_s[6],  keystream_s[5], keystream_s[4]};
         2'd2:    keystream_slice_s = {keystream_s[11], keystream_s[10], keystream_s[9], keystream_s[8]};
         default: keystream_slice_s = 128'h0;
      endcase
   end

   // XOR plaintext / keystream
   assign cipher_next_s = data_i ^ keystream_slice_s;

   // Registre de sortie pour cipher_o.
   // Sans lui, cipher_o changerait des le cycle suivant l'etat CIPHER
   // (le compteur de blocs aurait deja ete incremente). cipher_valid_o
   // est aussi decale d'un cycle pour rester aligne avec cipher_o.
   always_ff @(posedge clock_i or negedge resetb_i) begin
      if (resetb_i == 1'b0) begin
         cipher_reg_s       <= 128'h0;
         cipher_valid_reg_s <= 1'b0;
      end else begin
         cipher_valid_reg_s <= cipher_valid_s;
         if (cipher_valid_s == 1'b1) begin
            cipher_reg_s <= cipher_next_s;
         end
      end
   end

   assign cipher_o       = cipher_reg_s;
   assign cipher_valid_o = cipher_valid_reg_s;
   assign end_o          = end_s;

endmodule : chacha20_top
