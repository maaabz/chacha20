`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// chacha20_top_tb : testbench du module final chacha20_top
//
// Scenario :
//   1. Reset asynchrone actif bas pendant plusieurs cycles
//   2. Chargement de la cle (256 bits) et du nonce (96 bits)
//   3. Impulsion start_i = 1 pendant 1 cycle
//   4. Attente du pulse end_o (fin du calcul du keystream)
//   5. Envoi sequentiel des 3 blocs de plaintext (P1, P2, P3) avec
//      data_valid_i, capture du cipher_o sur cipher_valid_o et comparaison
//      bloc par bloc avec les valeurs attendues
//   6. Comparaison globale C = {C3[111:0], C2, C1} vs vecteur attendu
//
// Vecteurs de test : issus de la section 5 du sujet (46 octets)
// -----------------------------------------------------------------------------

module chacha20_top_tb
   import chacha_pack::*;
();

   logic         clock_tb;
   logic         resetb_tb;
   logic         start_tb;
   logic [127:0] data_tb;
   logic         data_valid_tb;
   logic [255:0] key_tb;
   logic [95:0]  nonce_tb;
   logic [127:0] cipher_tb;
   logic         cipher_valid_tb;
   logic         end_tb;

   logic [127:0] c1_tb;
   logic [127:0] c2_tb;
   logic [127:0] c3_tb;
   logic [367:0] full_cipher_tb;

   int errors_tb;

   localparam logic [255:0] KEY_EXP    = 256'h4e7ced7e860e69aed3a53fefd52a3eec27a09386322fdc9a76a2b5eae921c73a;
   localparam logic [95:0]  NONCE_EXP  = 96'hd4ac91b9caccf25906e46ce3;

   localparam logic [127:0] P1_EXP     = 128'h65704f20656966696e67697320657551;
   localparam logic [127:0] P2_EXP     = 128'h65766e49206561727574614e20617472;
   localparam logic [127:0] P3_EXP     = 128'h00003f206172656e754d20746e75696e;

   localparam logic [127:0] C1_EXP     = 128'h322523b73ceabe5e8e05fc68143022e0;
   localparam logic [127:0] C2_EXP     = 128'he46c5ee17a42f515954acdecd4eeef62;
   localparam logic [127:0] C3_EXP     = 128'h2cc9fab0b90f73406abbf0408580ba3e;

   localparam logic [367:0] FULL_C_EXP = 368'hfab0b90f73406abbf0408580ba3ee46c5ee17a42f515954acdecd4eeef62322523b73ceabe5e8e05fc68143022e0;

   chacha20_top dut (
      .clock_i        (clock_tb),
      .resetb_i       (resetb_tb),
      .start_i        (start_tb),
      .data_i         (data_tb),
      .data_valid_i   (data_valid_tb),
      .key_i          (key_tb),
      .nonce_i        (nonce_tb),
      .cipher_o       (cipher_tb),
      .cipher_valid_o (cipher_valid_tb),
      .end_o          (end_tb)
   );

   initial begin
      clock_tb = 1'b0;
      forever #5 clock_tb = ~clock_tb;
   end

   initial begin
      $timeformat(-9, 3, " ns", 10);

      resetb_tb     = 1'b0;
      start_tb      = 1'b0;
      data_tb       = 128'h0;
      data_valid_tb = 1'b0;
      key_tb        = KEY_EXP;
      nonce_tb      = NONCE_EXP;
      errors_tb     = 0;

      repeat (5) @(negedge clock_tb);
      resetb_tb = 1'b1;
      @(negedge clock_tb);

      $display("==================================================");
      $display("  Demarrage du chiffrement ChaCha20 @%t", $time);
      $display("  Cle     = %h", key_tb);
      $display("  Nonce   = %h", nonce_tb);
      $display("==================================================");

      start_tb = 1'b1;
      @(negedge clock_tb);
      start_tb = 1'b0;

      wait (end_tb == 1'b1);
      $display("[KEYSTREAM] end_o = 1 @%t : keystream pret", $time);
      @(negedge clock_tb);

      @(negedge clock_tb);
      data_tb       = P1_EXP;
      data_valid_tb = 1'b1;
      wait (cipher_valid_tb == 1'b1);
      @(negedge clock_tb);
      c1_tb = cipher_tb;
      $display("[BLOC 1] @%t : plaintext = %h", $time, P1_EXP);
      $display("[BLOC 1]      cipher_o  = %h", c1_tb);
      $display("[BLOC 1]      expected  = %h", C1_EXP);
      if (c1_tb == C1_EXP)
         $display("[BLOC 1]      -> OK");
      else begin
         $display("[BLOC 1]      -> KO  (diff = %h)", c1_tb ^ C1_EXP);
         errors_tb += 1;
      end
      data_valid_tb = 1'b0;
      @(negedge clock_tb);

      @(negedge clock_tb);
      data_tb       = P2_EXP;
      data_valid_tb = 1'b1;
      wait (cipher_valid_tb == 1'b1);
      @(negedge clock_tb);
      c2_tb = cipher_tb;
      $display("[BLOC 2] @%t : plaintext = %h", $time, P2_EXP);
      $display("[BLOC 2]      cipher_o  = %h", c2_tb);
      $display("[BLOC 2]      expected  = %h", C2_EXP);
      if (c2_tb == C2_EXP)
         $display("[BLOC 2]      -> OK");
      else begin
         $display("[BLOC 2]      -> KO  (diff = %h)", c2_tb ^ C2_EXP);
         errors_tb += 1;
      end
      data_valid_tb = 1'b0;
      @(negedge clock_tb);

      @(negedge clock_tb);
      data_tb       = P3_EXP;
      data_valid_tb = 1'b1;
      wait (cipher_valid_tb == 1'b1);
      @(negedge clock_tb);
      c3_tb = cipher_tb;
      $display("[BLOC 3] @%t : plaintext = %h", $time, P3_EXP);
      $display("[BLOC 3]      cipher_o  = %h", c3_tb);
      $display("[BLOC 3]      expected  = %h", C3_EXP);
      if (c3_tb == C3_EXP)
         $display("[BLOC 3]      -> OK");
      else begin
         $display("[BLOC 3]      -> KO  (diff = %h)", c3_tb ^ C3_EXP);
         errors_tb += 1;
      end
      data_valid_tb = 1'b0;
      @(negedge clock_tb);

      full_cipher_tb = {c3_tb[111:0], c2_tb, c1_tb};

      $display("==================================================");
      $display("  Resultat global");
      $display("  Computed : %h", full_cipher_tb);
      $display("  Expected : %h", FULL_C_EXP);
      $display("  XOR      : %h", full_cipher_tb ^ FULL_C_EXP);
      if ((full_cipher_tb == FULL_C_EXP) && (errors_tb == 0))
         $display("  ===>  TEST PASSED");
      else
         $display("  ===>  TEST FAILED  (%0d erreur(s) bloc)", errors_tb);
      $display("==================================================");

      repeat (5) @(negedge clock_tb);
      #20;
      $finish;
   end

endmodule : chacha20_top_tb
