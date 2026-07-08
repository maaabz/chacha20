`timescale 1ns / 1ps

module chacha_round
import chacha_pack::*;
(
   input  state_t s_i,
   input  logic   sel_i, // 0 = ronde colonne, 1 = ronde diagonale
   output state_t s_o
);

logic [31:0] qr1_a_s, qr1_b_s, qr1_c_s, qr1_d_s;
logic [31:0] qr2_a_s, qr2_b_s, qr2_c_s, qr2_d_s;
logic [31:0] qr3_a_s, qr3_b_s, qr3_c_s, qr3_d_s;
logic [31:0] qr4_a_s, qr4_b_s, qr4_c_s, qr4_d_s;

// qr_1 : colonne 0 (0,4,8,12) ou diagonale 0 (0,5,10,15)

quarter_round qr_1 (
   .a_i(s_i[0]),
   .b_i(sel_i ? s_i[5]  : s_i[4]),
   .c_i(sel_i ? s_i[10] : s_i[8]),
   .d_i(sel_i ? s_i[15] : s_i[12]),
   .a_o(qr1_a_s),
   .b_o(qr1_b_s),
   .c_o(qr1_c_s),
   .d_o(qr1_d_s)
);

// qr_2 : colonne 1 (1,5,9,13) ou diagonale 1 (1,6,11,12)

quarter_round qr_2 (
   .a_i(s_i[1]),
   .b_i(sel_i ? s_i[6]  : s_i[5]),
   .c_i(sel_i ? s_i[11] : s_i[9]),
   .d_i(sel_i ? s_i[12] : s_i[13]),
   .a_o(qr2_a_s),
   .b_o(qr2_b_s),
   .c_o(qr2_c_s),
   .d_o(qr2_d_s)
);

// qr_3 : colonne 2 (2,6,10,14) ou diagonale 2 (2,7,8,13)

quarter_round qr_3 (
   .a_i(s_i[2]),
   .b_i(sel_i ? s_i[7]  : s_i[6]),
   .c_i(sel_i ? s_i[8]  : s_i[10]),
   .d_i(sel_i ? s_i[13] : s_i[14]),
   .a_o(qr3_a_s),
   .b_o(qr3_b_s),
   .c_o(qr3_c_s),
   .d_o(qr3_d_s)
);

// qr_4 : colonne 3 (3,7,11,15) ou diagonale 3 (3,4,9,14)

quarter_round qr_4 (
   .a_i(s_i[3]),
   .b_i(sel_i ? s_i[4]  : s_i[7]),
   .c_i(sel_i ? s_i[9]  : s_i[11]),
   .d_i(sel_i ? s_i[14] : s_i[15]),
   .a_o(qr4_a_s),
   .b_o(qr4_b_s),
   .c_o(qr4_c_s),
   .d_o(qr4_d_s)
);
// Demultiplexage : on remet les sorties des QR aux bons indices de l'etat
// selon le mode (colonne ou diagonale)
assign s_o[0]  = qr1_a_s;
assign s_o[1]  = qr2_a_s;
assign s_o[2]  = qr3_a_s;
assign s_o[3]  = qr4_a_s;
assign s_o[4]  = sel_i ? qr4_b_s : qr1_b_s;
assign s_o[5]  = sel_i ? qr1_b_s : qr2_b_s;
assign s_o[6]  = sel_i ? qr2_b_s : qr3_b_s;
assign s_o[7]  = sel_i ? qr3_b_s : qr4_b_s;
assign s_o[8]  = sel_i ? qr3_c_s : qr1_c_s;
assign s_o[9]  = sel_i ? qr4_c_s : qr2_c_s;
assign s_o[10] = sel_i ? qr1_c_s : qr3_c_s;
assign s_o[11] = sel_i ? qr2_c_s : qr4_c_s;
assign s_o[12] = sel_i ? qr2_d_s : qr1_d_s;
assign s_o[13] = sel_i ? qr3_d_s : qr2_d_s;
assign s_o[14] = sel_i ? qr4_d_s : qr3_d_s;
assign s_o[15] = sel_i ? qr1_d_s : qr4_d_s;

endmodule : chacha_round
