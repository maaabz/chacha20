`timescale 1ns / 1ps

// fsm de type moore 

module chacha_fsm (
   input  logic       clock_i,
   input  logic       resetb_i,

   // Commandes externes
   input  logic       start_i,         //  demarrage du chiffrement
   input  logic       data_valid_i,    // un nouveau bloc plaintext est present

   // Retours des compteurs
   input  logic [4:0] count_i,         //   compteur de rondes (0 a 19)
   input  logic [1:0] block_count_i,   // compteur de blocs chiffres (0 a 2)

   // Signaux de controle pour chacha_block
   output logic       init_o,          //   chargement de l'etat initial
   output logic       active_o,        //  execution d'une ronde
   output logic       sel_o,           // 0 = colonne, 1 = diagonale
   output logic       add_sinit_o,     // declenche l'addition finale

   // Sorties externes
   output logic       end_o,           // keystream pret
   output logic       cipher_valid_o,  //un bloc chiffre est disponible

   // Pilotage du compteur de rondes
   output logic       ena_o,           // activation du compteur
   output logic       init_count_o     //  remise a zero du compteur
);

typedef enum logic [2:0] {
   IDLE,
   INIT,
   COL_ROUND,
   DIAG_ROUND,
   ADD_SINIT,
   WAIT_DATA,
   CIPHER
} state_t;

state_t state_s, next_state_s;
// Processus 1 (seq_0) : memorisation de l'etat courant
always_ff @(posedge clock_i or negedge resetb_i) begin
   if (resetb_i == 1'b0)
      state_s <= IDLE;
   else
      state_s <= next_state_s;
end
// Processus 2 (comb_0) : calcul de l'etat suivant
always_comb begin
   next_state_s = state_s;
   case (state_s)
      IDLE: begin
         if (start_i == 1'b1)
            next_state_s = INIT;
      end
      INIT: begin
         next_state_s = COL_ROUND;
      end
      COL_ROUND: begin
         next_state_s = DIAG_ROUND;
      end
      DIAG_ROUND: begin
         if (count_i == 5'd19) // 20 rondes effectuees (10 col + 10 diag)
            next_state_s = ADD_SINIT;
         else
            next_state_s = COL_ROUND;
      end
      ADD_SINIT: begin
         next_state_s = WAIT_DATA;
      end
      WAIT_DATA: begin
         if (data_valid_i == 1'b1)
            next_state_s = CIPHER;
      end
      CIPHER: begin
         if (block_count_i == 2'd2)  // troisieme bloc chiffre
            next_state_s = IDLE;
         else
            next_state_s = WAIT_DATA;
      end
      default: begin
         next_state_s = IDLE;
      end
   endcase
end
// Processus 3 (comb_1) : calcul des sorties (depend uniquement de l'etat - Moore)
always_comb begin
   init_o         = 1'b0;
   active_o       = 1'b0;
   sel_o          = 1'b0;
   add_sinit_o    = 1'b0;
   end_o          = 1'b0;
   cipher_valid_o = 1'b0;
   ena_o          = 1'b0;
   init_count_o   = 1'b0;
   case (state_s)
      INIT: begin
         init_o       = 1'b1;
         init_count_o = 1'b1;
         ena_o        = 1'b1;
      end
      COL_ROUND: begin
         active_o = 1'b1;
         sel_o    = 1'b0;
         ena_o    = 1'b1;
      end
      DIAG_ROUND: begin
         active_o = 1'b1;
         sel_o    = 1'b1;
         ena_o    = 1'b1;
      end
      ADD_SINIT: begin
         add_sinit_o = 1'b1;
         end_o       = 1'b1;
      end
      CIPHER: begin
         cipher_valid_o = 1'b1;
      end
      default: begin
      end
   endcase
end

endmodule : chacha_fsm
