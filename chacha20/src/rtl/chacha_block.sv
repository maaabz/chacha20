`timescale 1ns / 1ps

module chacha_block
import chacha_pack::*;
(
   input  logic         clock_i,
   input  logic         resetb_i,

   // Donnees pour la construction de l'etat initial
   input  logic [255:0] key_i,
   input  logic [95:0]  nonce_i,

   // Signaux de controle issus de la FSM
   input  logic         init_i,
   input  logic         sel_i,  // 0 = ronde colonne, 1 = ronde diagonale
   input  logic         active_i,
   input  logic         add_sinit_i,


   output state_t       keystream_o
);

state_t s_s;             // etat courant (sortie du registre)
state_t s_init_s;        // etat initial sauvegarde (sortie du registre)
state_t round_out_s;     // sortie de chacha_round (combinatoire)
state_t init_state_s;    // etat initial calcule combinatoirement
state_t s_next_s;        // entree du registre d'etat courant

logic   s_reg_enable_s;
logic   s_init_reg_enable_s;

// Instance combinatoire de chacha_round
chacha_round round_inst (
   .s_i  (s_s),
   .sel_i(sel_i),
   .s_o  (round_out_s)
);

// Construction combinatoire de l'etat initial
// (constante + cle + compteur de bloc + nonce)
assign init_state_s[0]  = 32'h61707865;
assign init_state_s[1]  = 32'h3320646e;
assign init_state_s[2]  = 32'h79622d32;
assign init_state_s[3]  = 32'h6b206574;
assign init_state_s[4]  = key_i[31:0];
assign init_state_s[5]  = key_i[63:32];
assign init_state_s[6]  = key_i[95:64];
assign init_state_s[7]  = key_i[127:96];
assign init_state_s[8]  = key_i[159:128];
assign init_state_s[9]  = key_i[191:160];
assign init_state_s[10] = key_i[223:192];
assign init_state_s[11] = key_i[255:224];
assign init_state_s[12] = 32'h00000001;
assign init_state_s[13] = nonce_i[31:0];
assign init_state_s[14] = nonce_i[63:32];
assign init_state_s[15] = nonce_i[95:64];

// Multiplexeur combinatoire de l'etat suivant :
//   - init_i      : on charge l'etat initial
//   - active_i    : on charge le resultat de la ronde
//   - add_sinit_i : on ajoute mot par mot s_s + s_init_s
//   - sinon       : on conserve l'etat courant
always_comb begin
   if (init_i == 1'b1) begin
      s_next_s = init_state_s;
   end
   else if (active_i == 1'b1) begin
      s_next_s = round_out_s;
   end
   else if (add_sinit_i == 1'b1) begin
      s_next_s[0]  = s_s[0]  + s_init_s[0];
      s_next_s[1]  = s_s[1]  + s_init_s[1];
      s_next_s[2]  = s_s[2]  + s_init_s[2];
      s_next_s[3]  = s_s[3]  + s_init_s[3];
      s_next_s[4]  = s_s[4]  + s_init_s[4];
      s_next_s[5]  = s_s[5]  + s_init_s[5];
      s_next_s[6]  = s_s[6]  + s_init_s[6];
      s_next_s[7]  = s_s[7]  + s_init_s[7];
      s_next_s[8]  = s_s[8]  + s_init_s[8];
      s_next_s[9]  = s_s[9]  + s_init_s[9];
      s_next_s[10] = s_s[10] + s_init_s[10];
      s_next_s[11] = s_s[11] + s_init_s[11];
      s_next_s[12] = s_s[12] + s_init_s[12];
      s_next_s[13] = s_s[13] + s_init_s[13];
      s_next_s[14] = s_s[14] + s_init_s[14];
      s_next_s[15] = s_s[15] + s_init_s[15];
   end
   else begin
      s_next_s = s_s;
   end
end

// Signaux d'enable des deux registres :
//   - s_s      est mis a jour a chaque init / active / add_sinit
//   - s_init_s est mis a jour uniquement lors de l'init (sauvegarde figee)
assign s_reg_enable_s      = init_i | active_i | add_sinit_i;
assign s_init_reg_enable_s = init_i;

// Registre de l'etat courant (instance de register_state)
register_state state_reg_inst (
   .clock_i (clock_i),
   .resetb_i(resetb_i),
   .enable_i(s_reg_enable_s),
   .d_i     (s_next_s),
   .q_o     (s_s)
);

// Registre de sauvegarde de l'etat initial (instance de register_state)
register_state init_state_reg_inst (
   .clock_i (clock_i),
   .resetb_i(resetb_i),
   .enable_i(s_init_reg_enable_s),
   .d_i     (init_state_s),
   .q_o     (s_init_s)
);

assign keystream_o = s_s;

endmodule : chacha_block
