/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : V-2023.12-SP5-1
// Date      : Sat Sep 26 08:25:42 2026
/////////////////////////////////////////////////////////////


module bin2gray_WIDTH4_1 ( bin, gray );
  input [3:0] bin;
  output [3:0] gray;
  wire   \bin[3] ;
  assign gray[3] = \bin[3] ;
  assign \bin[3]  = bin[3];

  XOR2X1 U1 ( .A(\bin[3] ), .B(bin[2]), .Y(gray[2]) );
  XOR2X1 U2 ( .A(bin[2]), .B(bin[1]), .Y(gray[1]) );
  XOR2X1 U3 ( .A(bin[1]), .B(bin[0]), .Y(gray[0]) );
endmodule


module gray2bin_WIDTH4_1 ( gray, bin );
  input [3:0] gray;
  output [3:0] bin;
  wire   n1, n2, n5;

  INVX1 U1 ( .A(n5), .Y(bin[1]) );
  XOR2X1 U2 ( .A(gray[2]), .B(gray[3]), .Y(n1) );
  XOR2X1 U3 ( .A(gray[1]), .B(gray[0]), .Y(n2) );
  XOR2X1 U4 ( .A(n1), .B(n2), .Y(bin[0]) );
  BUFX2 U5 ( .A(gray[3]), .Y(bin[3]) );
  BUFX2 U6 ( .A(n1), .Y(bin[2]) );
  XNOR2X1 U7 ( .A(gray[1]), .B(n1), .Y(n5) );
endmodule


module write_ptr_DEPTH8_ADDR_WIDTH3_PTR_WIDTH4_ALMOST_FULL_LEVEL6 ( w_clk, 
        w_rst_b, write_en, rptr_gray_sync, w_addr, wptr_bin, wptr_gray, full, 
        almost_full );
  input [3:0] rptr_gray_sync;
  output [2:0] w_addr;
  output [3:0] wptr_bin;
  output [3:0] wptr_gray;
  input w_clk, w_rst_b, write_en;
  output full, almost_full;
  wire   n96, n88, n89, n90, n91, n92, n93, n94, n95, \wptr_bin_next[3] ,
         full_next, almost_full_next, n30, n31, n32, n33, n34, n35, n37, n38,
         n39, n40, n41, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n21, n22, n23,
         n24, n25, n27, n28, n29, n36, n42, n47, n48, n49, n50, n51, n52, n53,
         n54, n55, n56, n57, n58, n63, n64, n65, n66, n67, n68, n69, n70, n71,
         n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85,
         n86, n87;
  wire   [3:0] wptr_gray_next;
  wire   [3:0] rptr_bin_sync;
  assign wptr_bin[2] = w_addr[2];
  assign wptr_bin[1] = w_addr[1];
  assign wptr_bin[0] = w_addr[0];

  DFFSR full_reg ( .D(full_next), .CLK(w_clk), .R(w_rst_b), .S(1'b1), .Q(n95)
         );
  DFFSR \wptr_bin_reg[0]  ( .D(n85), .CLK(w_clk), .R(w_rst_b), .S(1'b1), .Q(
        n89) );
  DFFSR \wptr_bin_reg[1]  ( .D(n24), .CLK(w_clk), .R(w_rst_b), .S(1'b1), .Q(
        n88) );
  DFFSR \wptr_bin_reg[2]  ( .D(n83), .CLK(w_clk), .R(w_rst_b), .S(1'b1), .Q(
        n96) );
  DFFSR \wptr_bin_reg[3]  ( .D(n53), .CLK(w_clk), .R(w_rst_b), .S(1'b1), .Q(
        n90) );
  DFFSR almost_full_reg ( .D(almost_full_next), .CLK(w_clk), .R(w_rst_b), .S(
        1'b1), .Q(almost_full) );
  DFFSR \wptr_gray_reg[0]  ( .D(wptr_gray_next[0]), .CLK(w_clk), .R(w_rst_b), 
        .S(1'b1), .Q(n94) );
  DFFSR \wptr_gray_reg[1]  ( .D(n1), .CLK(w_clk), .R(w_rst_b), .S(1'b1), .Q(
        n93) );
  DFFSR \wptr_gray_reg[2]  ( .D(wptr_gray_next[2]), .CLK(w_clk), .R(w_rst_b), 
        .S(1'b1), .Q(n92) );
  DFFSR \wptr_gray_reg[3]  ( .D(wptr_gray_next[3]), .CLK(w_clk), .R(w_rst_b), 
        .S(1'b1), .Q(n91) );
  NOR3X1 U27 ( .A(n86), .B(n56), .C(n49), .Y(n31) );
  NAND3X1 U29 ( .A(w_addr[2]), .B(n6), .C(n34), .Y(n35) );
  NOR3X1 U30 ( .A(n29), .B(n39), .C(n38), .Y(full_next) );
  XNOR2X1 U31 ( .A(wptr_gray_next[3]), .B(n9), .Y(n39) );
  XNOR2X1 U32 ( .A(wptr_gray_next[2]), .B(rptr_gray_sync[2]), .Y(n38) );
  XNOR2X1 U34 ( .A(wptr_gray_next[0]), .B(rptr_gray_sync[0]), .Y(n41) );
  XNOR2X1 U35 ( .A(wptr_gray_next[1]), .B(rptr_gray_sync[1]), .Y(n40) );
  BUFX2 U13 ( .A(wptr_gray_next[1]), .Y(n1) );
  AND2X1 U14 ( .A(w_addr[1]), .B(w_addr[0]), .Y(n34) );
  OR2X1 U15 ( .A(n8), .B(n31), .Y(n30) );
  AND2X1 U16 ( .A(rptr_bin_sync[2]), .B(n74), .Y(n76) );
  AND2X1 U17 ( .A(n34), .B(n87), .Y(n32) );
  AND2X1 U18 ( .A(w_addr[2]), .B(n72), .Y(n73) );
  AND2X1 U19 ( .A(rptr_bin_sync[0]), .B(n67), .Y(n66) );
  AND2X1 U20 ( .A(n40), .B(n41), .Y(n37) );
  AND2X1 U21 ( .A(n2), .B(n42), .Y(\wptr_bin_next[3] ) );
  INVX2 U22 ( .A(n74), .Y(n83) );
  INVX1 U23 ( .A(n25), .Y(n23) );
  AND2X1 U24 ( .A(n65), .B(w_addr[0]), .Y(n21) );
  INVX1 U25 ( .A(n30), .Y(n2) );
  AND2X2 U26 ( .A(write_en), .B(w_addr[1]), .Y(n22) );
  INVX1 U28 ( .A(write_en), .Y(n3) );
  INVX1 U33 ( .A(n3), .Y(n4) );
  INVX1 U36 ( .A(n4), .Y(n5) );
  INVX1 U37 ( .A(n5), .Y(n6) );
  INVX1 U38 ( .A(n72), .Y(n7) );
  AND2X1 U39 ( .A(wptr_bin[3]), .B(n52), .Y(n8) );
  AND2X1 U40 ( .A(n67), .B(rptr_bin_sync[0]), .Y(n68) );
  BUFX2 U41 ( .A(rptr_gray_sync[3]), .Y(n9) );
  BUFX2 U42 ( .A(full), .Y(n10) );
  BUFX2 U43 ( .A(n23), .Y(n24) );
  INVX1 U44 ( .A(n84), .Y(n25) );
  INVX2 U45 ( .A(n71), .Y(n84) );
  BUFX2 U46 ( .A(n95), .Y(full) );
  BUFX2 U47 ( .A(n77), .Y(n27) );
  AND2X2 U48 ( .A(n21), .B(n22), .Y(n72) );
  BUFX2 U49 ( .A(n70), .Y(n28) );
  INVX1 U50 ( .A(n37), .Y(n29) );
  AND2X2 U51 ( .A(n21), .B(n4), .Y(n36) );
  AND2X1 U52 ( .A(n47), .B(wptr_bin[3]), .Y(n64) );
  INVX1 U53 ( .A(n64), .Y(n42) );
  BUFX2 U54 ( .A(n91), .Y(wptr_gray[3]) );
  BUFX2 U55 ( .A(n92), .Y(wptr_gray[2]) );
  BUFX2 U56 ( .A(n93), .Y(wptr_gray[1]) );
  BUFX2 U57 ( .A(n94), .Y(wptr_gray[0]) );
  BUFX2 U58 ( .A(n35), .Y(n47) );
  INVX1 U59 ( .A(n68), .Y(n48) );
  INVX1 U60 ( .A(n32), .Y(n49) );
  BUFX2 U61 ( .A(n78), .Y(n54) );
  INVX1 U62 ( .A(n36), .Y(n50) );
  INVX1 U63 ( .A(n10), .Y(n51) );
  INVX1 U64 ( .A(n51), .Y(n52) );
  INVX1 U65 ( .A(\wptr_bin_next[3] ), .Y(n53) );
  INVX1 U66 ( .A(n76), .Y(n55) );
  AND2X2 U67 ( .A(write_en), .B(n51), .Y(n33) );
  INVX1 U68 ( .A(n33), .Y(n56) );
  INVX1 U69 ( .A(n73), .Y(n57) );
  INVX1 U70 ( .A(n66), .Y(n58) );
  BUFX2 U71 ( .A(n90), .Y(wptr_bin[3]) );
  BUFX2 U72 ( .A(n89), .Y(w_addr[0]) );
  BUFX2 U73 ( .A(n96), .Y(w_addr[2]) );
  BUFX2 U74 ( .A(n88), .Y(w_addr[1]) );
  INVX1 U75 ( .A(n72), .Y(n63) );
  INVX1 U76 ( .A(rptr_bin_sync[1]), .Y(n69) );
  INVX1 U77 ( .A(rptr_bin_sync[2]), .Y(n75) );
  INVX1 U78 ( .A(n67), .Y(n85) );
  INVX1 U79 ( .A(n10), .Y(n65) );
  INVX1 U80 ( .A(w_addr[2]), .Y(n86) );
  INVX1 U81 ( .A(wptr_bin[3]), .Y(n87) );
  XOR2X1 U82 ( .A(n63), .B(w_addr[2]), .Y(n74) );
  OAI21X1 U83 ( .A(w_addr[0]), .B(n33), .C(n50), .Y(n67) );
  OAI21X1 U84 ( .A(w_addr[1]), .B(n36), .C(n7), .Y(n71) );
  FAX1 U85 ( .A(n58), .B(n24), .C(rptr_bin_sync[1]), .YC(), .YS(n82) );
  AOI21X1 U86 ( .A(n84), .B(n69), .C(n48), .Y(n70) );
  AOI21X1 U87 ( .A(rptr_bin_sync[1]), .B(n25), .C(n28), .Y(n77) );
  FAX1 U88 ( .A(rptr_bin_sync[2]), .B(n83), .C(n27), .YC(), .YS(n81) );
  FAX1 U89 ( .A(rptr_bin_sync[3]), .B(wptr_bin[3]), .C(n57), .YC(), .YS(n79)
         );
  AOI22X1 U90 ( .A(n55), .B(n27), .C(n83), .D(n75), .Y(n78) );
  XOR2X1 U91 ( .A(n54), .B(n79), .Y(n80) );
  OAI21X1 U92 ( .A(n82), .B(n81), .C(n80), .Y(almost_full_next) );
  bin2gray_WIDTH4_1 wptr_bin_to_gray ( .bin({n53, n83, n23, n85}), .gray(
        wptr_gray_next) );
  gray2bin_WIDTH4_1 rptr_gray_to_bin ( .gray(rptr_gray_sync), .bin(
        rptr_bin_sync) );
endmodule


module bin2gray_WIDTH4_0 ( bin, gray );
  input [3:0] bin;
  output [3:0] gray;
  wire   \bin[3] ;
  assign gray[3] = \bin[3] ;
  assign \bin[3]  = bin[3];

  XOR2X1 U1 ( .A(\bin[3] ), .B(bin[2]), .Y(gray[2]) );
  XOR2X1 U2 ( .A(bin[2]), .B(bin[1]), .Y(gray[1]) );
  XOR2X1 U3 ( .A(bin[1]), .B(bin[0]), .Y(gray[0]) );
endmodule


module gray2bin_WIDTH4_0 ( gray, bin );
  input [3:0] gray;
  output [3:0] bin;
  wire   \gray[3] , n3, n4;
  assign bin[3] = \gray[3] ;
  assign \gray[3]  = gray[3];

  XOR2X1 U1 ( .A(gray[0]), .B(bin[1]), .Y(bin[0]) );
  XOR2X1 U2 ( .A(bin[2]), .B(gray[1]), .Y(n4) );
  XOR2X1 U3 ( .A(gray[2]), .B(\gray[3] ), .Y(n3) );
  BUFX4 U4 ( .A(n4), .Y(bin[1]) );
  BUFX4 U5 ( .A(n3), .Y(bin[2]) );
endmodule


module read_ptr_DEPTH8_ADDR_WIDTH3_PTR_WIDTH4_ALMOST_EMPTY_LEVEL2 ( r_clk, 
        r_rst_b, read_en, wptr_gray_sync, r_addr, rptr_bin, rptr_gray, empty, 
        almost_empty );
  input [3:0] wptr_gray_sync;
  output [2:0] r_addr;
  output [3:0] rptr_bin;
  output [3:0] rptr_gray;
  input r_clk, r_rst_b, read_en;
  output empty, almost_empty;
  wire   n73, n74, n66, n67, n68, n69, n70, n71, n72, empty_next,
         almost_empty_next, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35,
         n36, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n1, n2,
         n7, n8, n19, n20, n21, n22, n23, n25, n48, n49, n50, n51, n52, n53,
         n58, n59, n60, n61, n62, n63, n64, n65;
  wire   [3:0] rptr_bin_next;
  wire   [3:0] rptr_gray_next;
  wire   [3:0] wptr_bin_sync;
  assign rptr_bin[2] = r_addr[2];
  assign rptr_bin[1] = r_addr[1];
  assign rptr_bin[0] = r_addr[0];

  DFFSR empty_reg ( .D(empty_next), .CLK(r_clk), .R(1'b1), .S(r_rst_b), .Q(n72) );
  DFFSR \rptr_bin_reg[0]  ( .D(rptr_bin_next[0]), .CLK(r_clk), .R(r_rst_b), 
        .S(1'b1), .Q(n66) );
  DFFSR \rptr_bin_reg[1]  ( .D(rptr_bin_next[1]), .CLK(r_clk), .R(r_rst_b), 
        .S(1'b1), .Q(n74) );
  DFFSR \rptr_bin_reg[2]  ( .D(n61), .CLK(r_clk), .R(r_rst_b), .S(1'b1), .Q(
        n73) );
  DFFSR \rptr_bin_reg[3]  ( .D(n49), .CLK(r_clk), .R(r_rst_b), .S(1'b1), .Q(
        n67) );
  DFFSR almost_empty_reg ( .D(almost_empty_next), .CLK(r_clk), .R(1'b1), .S(
        r_rst_b), .Q(almost_empty) );
  DFFSR \rptr_gray_reg[0]  ( .D(rptr_gray_next[0]), .CLK(r_clk), .R(r_rst_b), 
        .S(1'b1), .Q(n71) );
  DFFSR \rptr_gray_reg[1]  ( .D(rptr_gray_next[1]), .CLK(r_clk), .R(r_rst_b), 
        .S(1'b1), .Q(n70) );
  DFFSR \rptr_gray_reg[2]  ( .D(rptr_gray_next[2]), .CLK(r_clk), .R(r_rst_b), 
        .S(1'b1), .Q(n69) );
  DFFSR \rptr_gray_reg[3]  ( .D(rptr_gray_next[3]), .CLK(r_clk), .R(r_rst_b), 
        .S(1'b1), .Q(n68) );
  AND2X2 U13 ( .A(n47), .B(r_addr[1]), .Y(n41) );
  AND2X2 U14 ( .A(n59), .B(read_en), .Y(n47) );
  OAI21X1 U23 ( .A(n8), .B(n22), .C(rptr_bin[3]), .Y(n28) );
  NAND3X1 U24 ( .A(n30), .B(n29), .C(n7), .Y(n27) );
  NOR3X1 U29 ( .A(n20), .B(n33), .C(n34), .Y(empty_next) );
  XOR2X1 U30 ( .A(wptr_gray_sync[3]), .B(rptr_gray_next[3]), .Y(n34) );
  XNOR2X1 U33 ( .A(wptr_gray_sync[0]), .B(rptr_gray_next[0]), .Y(n36) );
  XNOR2X1 U34 ( .A(rptr_gray_next[1]), .B(wptr_gray_sync[1]), .Y(n35) );
  NOR3X1 U35 ( .A(n37), .B(n21), .C(n39), .Y(almost_empty_next) );
  FAX1 U36 ( .A(n64), .B(n23), .C(rptr_bin[3]), .YC(), .YS(n39) );
  AOI22X1 U37 ( .A(n41), .B(r_addr[2]), .C(n25), .D(n61), .Y(n40) );
  AOI22X1 U38 ( .A(n53), .B(n44), .C(n19), .D(n43), .Y(n38) );
  NAND3X1 U39 ( .A(n65), .B(n44), .C(wptr_bin_sync[0]), .Y(n45) );
  XOR2X1 U42 ( .A(n46), .B(r_addr[0]), .Y(rptr_bin_next[0]) );
  FAX1 U43 ( .A(wptr_bin_sync[2]), .B(n48), .C(n61), .YC(), .YS(n37) );
  OR2X1 U15 ( .A(n63), .B(wptr_bin_sync[1]), .Y(n42) );
  INVX1 U16 ( .A(wptr_gray_sync[2]), .Y(n1) );
  AND2X1 U17 ( .A(read_en), .B(n58), .Y(n46) );
  AND2X1 U18 ( .A(read_en), .B(r_addr[0]), .Y(n30) );
  AND2X1 U19 ( .A(r_addr[2]), .B(r_addr[1]), .Y(n29) );
  XNOR2X1 U20 ( .A(n1), .B(rptr_gray_next[2]), .Y(n33) );
  BUFX2 U21 ( .A(n27), .Y(n2) );
  BUFX2 U22 ( .A(n68), .Y(rptr_gray[3]) );
  BUFX2 U25 ( .A(n69), .Y(rptr_gray[2]) );
  BUFX2 U26 ( .A(n70), .Y(rptr_gray[1]) );
  BUFX2 U27 ( .A(n71), .Y(rptr_gray[0]) );
  OR2X1 U28 ( .A(rptr_bin[3]), .B(n62), .Y(n31) );
  INVX1 U31 ( .A(n31), .Y(n7) );
  INVX1 U32 ( .A(n30), .Y(n8) );
  OR2X1 U40 ( .A(n50), .B(n51), .Y(n52) );
  INVX4 U41 ( .A(n60), .Y(n61) );
  OR2X2 U44 ( .A(n26), .B(n52), .Y(n49) );
  BUFX2 U45 ( .A(n45), .Y(n19) );
  AND2X2 U46 ( .A(n35), .B(n36), .Y(n32) );
  INVX1 U47 ( .A(n32), .Y(n20) );
  BUFX2 U48 ( .A(n38), .Y(n21) );
  INVX1 U49 ( .A(n29), .Y(n22) );
  BUFX2 U50 ( .A(n40), .Y(n23) );
  BUFX2 U51 ( .A(n72), .Y(empty) );
  INVX1 U52 ( .A(n42), .Y(n25) );
  INVX1 U53 ( .A(n42), .Y(n48) );
  INVX1 U54 ( .A(n28), .Y(n50) );
  INVX1 U55 ( .A(n2), .Y(n51) );
  AND2X1 U56 ( .A(rptr_bin[3]), .B(n62), .Y(n26) );
  OR2X1 U57 ( .A(n65), .B(wptr_bin_sync[0]), .Y(n43) );
  INVX1 U58 ( .A(n43), .Y(n53) );
  BUFX2 U59 ( .A(n74), .Y(r_addr[1]) );
  BUFX2 U60 ( .A(n66), .Y(r_addr[0]) );
  BUFX2 U61 ( .A(n67), .Y(rptr_bin[3]) );
  BUFX2 U62 ( .A(n73), .Y(r_addr[2]) );
  AND2X2 U63 ( .A(r_addr[0]), .B(n58), .Y(n59) );
  INVX1 U64 ( .A(n62), .Y(n58) );
  XNOR2X1 U65 ( .A(n41), .B(r_addr[2]), .Y(n60) );
  INVX1 U66 ( .A(n63), .Y(rptr_bin_next[1]) );
  XOR2X1 U67 ( .A(wptr_bin_sync[1]), .B(rptr_bin_next[1]), .Y(n44) );
  INVX1 U68 ( .A(rptr_bin_next[0]), .Y(n65) );
  INVX1 U69 ( .A(wptr_bin_sync[3]), .Y(n64) );
  BUFX2 U70 ( .A(empty), .Y(n62) );
  XNOR2X1 U71 ( .A(n47), .B(r_addr[1]), .Y(n63) );
  bin2gray_WIDTH4_0 rptr_bin_to_gray ( .bin({n49, n61, rptr_bin_next[1:0]}), 
        .gray(rptr_gray_next) );
  gray2bin_WIDTH4_0 wptr_gray_to_bin ( .gray(wptr_gray_sync), .bin(
        wptr_bin_sync) );
endmodule


module synchronizer_WIDTH4_1 ( clk, rst_b, async_ptr, sync_ptr );
  input [3:0] async_ptr;
  output [3:0] sync_ptr;
  input clk, rst_b;
  wire   n17, n18, n19, n20, n9, n10, n11, n12;
  wire   [3:0] sync_ff1;

  DFFSR \sync_ff1_reg[3]  ( .D(async_ptr[3]), .CLK(clk), .R(rst_b), .S(1'b1), 
        .Q(sync_ff1[3]) );
  DFFSR \sync_ptr_reg[3]  ( .D(n12), .CLK(clk), .R(rst_b), .S(1'b1), .Q(n17)
         );
  DFFSR \sync_ff1_reg[2]  ( .D(async_ptr[2]), .CLK(clk), .R(rst_b), .S(1'b1), 
        .Q(sync_ff1[2]) );
  DFFSR \sync_ptr_reg[2]  ( .D(n11), .CLK(clk), .R(rst_b), .S(1'b1), .Q(n18)
         );
  DFFSR \sync_ff1_reg[1]  ( .D(async_ptr[1]), .CLK(clk), .R(rst_b), .S(1'b1), 
        .Q(sync_ff1[1]) );
  DFFSR \sync_ptr_reg[1]  ( .D(n10), .CLK(clk), .R(rst_b), .S(1'b1), .Q(n19)
         );
  DFFSR \sync_ff1_reg[0]  ( .D(async_ptr[0]), .CLK(clk), .R(rst_b), .S(1'b1), 
        .Q(sync_ff1[0]) );
  DFFSR \sync_ptr_reg[0]  ( .D(n9), .CLK(clk), .R(rst_b), .S(1'b1), .Q(n20) );
  BUFX2 U11 ( .A(sync_ff1[0]), .Y(n9) );
  BUFX2 U12 ( .A(sync_ff1[1]), .Y(n10) );
  BUFX2 U13 ( .A(sync_ff1[2]), .Y(n11) );
  BUFX2 U14 ( .A(sync_ff1[3]), .Y(n12) );
  BUFX2 U15 ( .A(n18), .Y(sync_ptr[2]) );
  BUFX2 U16 ( .A(n20), .Y(sync_ptr[0]) );
  BUFX2 U17 ( .A(n19), .Y(sync_ptr[1]) );
  BUFX2 U18 ( .A(n17), .Y(sync_ptr[3]) );
endmodule


module synchronizer_WIDTH4_0 ( clk, rst_b, async_ptr, sync_ptr );
  input [3:0] async_ptr;
  output [3:0] sync_ptr;
  input clk, rst_b;
  wire   n24, n25, n26, n9, n10, n11, n12;
  wire   [3:0] sync_ff1;

  DFFSR \sync_ff1_reg[3]  ( .D(async_ptr[3]), .CLK(clk), .R(rst_b), .S(1'b1), 
        .Q(sync_ff1[3]) );
  DFFSR \sync_ptr_reg[3]  ( .D(n12), .CLK(clk), .R(rst_b), .S(1'b1), .Q(
        sync_ptr[3]) );
  DFFSR \sync_ff1_reg[2]  ( .D(async_ptr[2]), .CLK(clk), .R(rst_b), .S(1'b1), 
        .Q(sync_ff1[2]) );
  DFFSR \sync_ptr_reg[2]  ( .D(n11), .CLK(clk), .R(rst_b), .S(1'b1), .Q(n24)
         );
  DFFSR \sync_ff1_reg[1]  ( .D(async_ptr[1]), .CLK(clk), .R(rst_b), .S(1'b1), 
        .Q(sync_ff1[1]) );
  DFFSR \sync_ptr_reg[1]  ( .D(n10), .CLK(clk), .R(rst_b), .S(1'b1), .Q(n25)
         );
  DFFSR \sync_ff1_reg[0]  ( .D(async_ptr[0]), .CLK(clk), .R(rst_b), .S(1'b1), 
        .Q(sync_ff1[0]) );
  DFFSR \sync_ptr_reg[0]  ( .D(n9), .CLK(clk), .R(rst_b), .S(1'b1), .Q(n26) );
  BUFX2 U11 ( .A(sync_ff1[0]), .Y(n9) );
  BUFX2 U12 ( .A(sync_ff1[1]), .Y(n10) );
  BUFX2 U13 ( .A(sync_ff1[2]), .Y(n11) );
  BUFX2 U14 ( .A(sync_ff1[3]), .Y(n12) );
  BUFX2 U15 ( .A(n26), .Y(sync_ptr[0]) );
  BUFX2 U16 ( .A(n24), .Y(sync_ptr[2]) );
  BUFX2 U17 ( .A(n25), .Y(sync_ptr[1]) );
endmodule


module fifo_mem_DATA_WIDTH8_ADDR_WIDTH3_DEPTH8 ( w_clk, r_clk, write_en, 
        read_en, w_addr, r_addr, w_data, r_data );
  input [2:0] w_addr;
  input [2:0] r_addr;
  input [7:0] w_data;
  output [7:0] r_data;
  input w_clk, r_clk, write_en, read_en;
  wire   N10, N11, N12, \mem[0][7] , \mem[0][6] , \mem[0][5] , \mem[0][4] ,
         \mem[0][3] , \mem[0][2] , \mem[0][1] , \mem[0][0] , \mem[1][7] ,
         \mem[1][6] , \mem[1][5] , \mem[1][4] , \mem[1][3] , \mem[1][2] ,
         \mem[1][1] , \mem[1][0] , \mem[2][7] , \mem[2][6] , \mem[2][5] ,
         \mem[2][4] , \mem[2][3] , \mem[2][2] , \mem[2][1] , \mem[2][0] ,
         \mem[3][7] , \mem[3][6] , \mem[3][5] , \mem[3][4] , \mem[3][3] ,
         \mem[3][2] , \mem[3][1] , \mem[3][0] , \mem[4][7] , \mem[4][6] ,
         \mem[4][5] , \mem[4][4] , \mem[4][3] , \mem[4][2] , \mem[4][1] ,
         \mem[4][0] , \mem[5][7] , \mem[5][6] , \mem[5][5] , \mem[5][4] ,
         \mem[5][3] , \mem[5][2] , \mem[5][1] , \mem[5][0] , \mem[6][7] ,
         \mem[6][6] , \mem[6][5] , \mem[6][4] , \mem[6][3] , \mem[6][2] ,
         \mem[6][1] , \mem[6][0] , \mem[7][7] , \mem[7][6] , \mem[7][5] ,
         \mem[7][4] , \mem[7][3] , \mem[7][2] , \mem[7][1] , \mem[7][0] , N30,
         N31, N32, N33, N34, N35, N36, N37, n1, n3, n4, n5, n6, n7, n8, n9,
         n10, n12, n14, n16, n18, n20, n22, n24, n26, n27, n28, n29, n30, n31,
         n32, n33, n34, n35, n36, n38, n39, n40, n41, n42, n43, n44, n45, n46,
         n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61,
         n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75,
         n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89,
         n90, n91, n92, n93, n103, n104, n105, n106, n107, n108, n109, n110,
         n111, n112, n113, n114, n115, n116, n117, n118, n119, n120, n121,
         n122, n123, n124, n125, n126, n127, n128, n129, n130, n131, n132,
         n133, n134, n135, n136, n137, n138, n139, n140, n141, n142, n143,
         n144, n145, n146, n147, n148, n149, n150, n151, n152, n153, n154,
         n155, n156, n157, n158, n159, n160, n161, n162, n163, n164, n165,
         n166, n2, n11, n13, n15, n17, n19, n21, n23, n25, n37, n47, n94, n95,
         n96, n97, n98, n99, n100, n101, n102, n167, n168, n169, n170, n171,
         n172, n173, n174, n175, n176, n177, n178, n179, n180, n181, n182,
         n183, n184, n185, n186, n187, n188, n189, n190, n191, n192, n193,
         n194, n195, n196, n197, n198, n199, n200, n201, n202, n203, n204,
         n205, n206, n207, n208, n209, n210, n211, n212, n213, n214, n215,
         n216, n217, n218, n219, n220, n221, n222, n223, n224, n225, n226,
         n227, n228, n229, n230, n231, n232, n233, n234, n235, n236, n237,
         n238, n239, n240, n241, n242, n243, n244, n245, n246, n247, n248,
         n249, n250, n251, n252, n253, n254, n255, n256, n257, n258, n259,
         n260, n261, n262, n263, n264, n265, n266, n267, n268, n269, n270,
         n271, n272, n273, n274, n275, n276, n277, n278, n279, n280, n281,
         n282, n283, n284, n285, n286, n287, n288, n289, n290, n291, n292,
         n293, n294, n295, n296, n297, n298, n299, n300, n301, n302, n303,
         n304, n305, n306, n307, n308, n309, n310, n311, n312, n313, n314,
         n315, n316, n317, n318, n319, n320, n321, n322, n323, n324, n325,
         n326, n327, n328, n329, n330, n331, n332, n333, n334, n335, n336,
         n337, n338, n339, n340, n341, n342, n343, n344, n345, n346, n347,
         n348, n349, n350, n351, n352, n353, n354, n355, n356;
  assign N10 = r_addr[0];
  assign N11 = r_addr[1];
  assign N12 = r_addr[2];

  DFFPOSX1 \mem_reg[0][7]  ( .D(n166), .CLK(w_clk), .Q(\mem[0][7] ) );
  DFFPOSX1 \mem_reg[0][6]  ( .D(n165), .CLK(w_clk), .Q(\mem[0][6] ) );
  DFFPOSX1 \mem_reg[0][5]  ( .D(n164), .CLK(w_clk), .Q(\mem[0][5] ) );
  DFFPOSX1 \mem_reg[0][4]  ( .D(n163), .CLK(w_clk), .Q(\mem[0][4] ) );
  DFFPOSX1 \mem_reg[0][3]  ( .D(n162), .CLK(w_clk), .Q(\mem[0][3] ) );
  DFFPOSX1 \mem_reg[0][2]  ( .D(n161), .CLK(w_clk), .Q(\mem[0][2] ) );
  DFFPOSX1 \mem_reg[0][1]  ( .D(n160), .CLK(w_clk), .Q(\mem[0][1] ) );
  DFFPOSX1 \mem_reg[0][0]  ( .D(n159), .CLK(w_clk), .Q(\mem[0][0] ) );
  DFFPOSX1 \mem_reg[1][7]  ( .D(n158), .CLK(w_clk), .Q(\mem[1][7] ) );
  DFFPOSX1 \mem_reg[1][6]  ( .D(n157), .CLK(w_clk), .Q(\mem[1][6] ) );
  DFFPOSX1 \mem_reg[1][5]  ( .D(n156), .CLK(w_clk), .Q(\mem[1][5] ) );
  DFFPOSX1 \mem_reg[1][4]  ( .D(n155), .CLK(w_clk), .Q(\mem[1][4] ) );
  DFFPOSX1 \mem_reg[1][3]  ( .D(n154), .CLK(w_clk), .Q(\mem[1][3] ) );
  DFFPOSX1 \mem_reg[1][2]  ( .D(n153), .CLK(w_clk), .Q(\mem[1][2] ) );
  DFFPOSX1 \mem_reg[1][1]  ( .D(n152), .CLK(w_clk), .Q(\mem[1][1] ) );
  DFFPOSX1 \mem_reg[1][0]  ( .D(n151), .CLK(w_clk), .Q(\mem[1][0] ) );
  DFFPOSX1 \mem_reg[2][7]  ( .D(n150), .CLK(w_clk), .Q(\mem[2][7] ) );
  DFFPOSX1 \mem_reg[2][6]  ( .D(n149), .CLK(w_clk), .Q(\mem[2][6] ) );
  DFFPOSX1 \mem_reg[2][5]  ( .D(n148), .CLK(w_clk), .Q(\mem[2][5] ) );
  DFFPOSX1 \mem_reg[2][4]  ( .D(n147), .CLK(w_clk), .Q(\mem[2][4] ) );
  DFFPOSX1 \mem_reg[2][3]  ( .D(n146), .CLK(w_clk), .Q(\mem[2][3] ) );
  DFFPOSX1 \mem_reg[2][2]  ( .D(n145), .CLK(w_clk), .Q(\mem[2][2] ) );
  DFFPOSX1 \mem_reg[2][1]  ( .D(n144), .CLK(w_clk), .Q(\mem[2][1] ) );
  DFFPOSX1 \mem_reg[2][0]  ( .D(n143), .CLK(w_clk), .Q(\mem[2][0] ) );
  DFFPOSX1 \mem_reg[3][7]  ( .D(n142), .CLK(w_clk), .Q(\mem[3][7] ) );
  DFFPOSX1 \mem_reg[3][6]  ( .D(n141), .CLK(w_clk), .Q(\mem[3][6] ) );
  DFFPOSX1 \mem_reg[3][5]  ( .D(n140), .CLK(w_clk), .Q(\mem[3][5] ) );
  DFFPOSX1 \mem_reg[3][4]  ( .D(n139), .CLK(w_clk), .Q(\mem[3][4] ) );
  DFFPOSX1 \mem_reg[3][3]  ( .D(n138), .CLK(w_clk), .Q(\mem[3][3] ) );
  DFFPOSX1 \mem_reg[3][2]  ( .D(n137), .CLK(w_clk), .Q(\mem[3][2] ) );
  DFFPOSX1 \mem_reg[3][1]  ( .D(n136), .CLK(w_clk), .Q(\mem[3][1] ) );
  DFFPOSX1 \mem_reg[3][0]  ( .D(n135), .CLK(w_clk), .Q(\mem[3][0] ) );
  DFFPOSX1 \mem_reg[4][7]  ( .D(n134), .CLK(w_clk), .Q(\mem[4][7] ) );
  DFFPOSX1 \mem_reg[4][6]  ( .D(n133), .CLK(w_clk), .Q(\mem[4][6] ) );
  DFFPOSX1 \mem_reg[4][5]  ( .D(n132), .CLK(w_clk), .Q(\mem[4][5] ) );
  DFFPOSX1 \mem_reg[4][4]  ( .D(n131), .CLK(w_clk), .Q(\mem[4][4] ) );
  DFFPOSX1 \mem_reg[4][3]  ( .D(n130), .CLK(w_clk), .Q(\mem[4][3] ) );
  DFFPOSX1 \mem_reg[4][2]  ( .D(n129), .CLK(w_clk), .Q(\mem[4][2] ) );
  DFFPOSX1 \mem_reg[4][1]  ( .D(n128), .CLK(w_clk), .Q(\mem[4][1] ) );
  DFFPOSX1 \mem_reg[4][0]  ( .D(n127), .CLK(w_clk), .Q(\mem[4][0] ) );
  DFFPOSX1 \mem_reg[5][7]  ( .D(n126), .CLK(w_clk), .Q(\mem[5][7] ) );
  DFFPOSX1 \mem_reg[5][6]  ( .D(n125), .CLK(w_clk), .Q(\mem[5][6] ) );
  DFFPOSX1 \mem_reg[5][5]  ( .D(n124), .CLK(w_clk), .Q(\mem[5][5] ) );
  DFFPOSX1 \mem_reg[5][4]  ( .D(n123), .CLK(w_clk), .Q(\mem[5][4] ) );
  DFFPOSX1 \mem_reg[5][3]  ( .D(n122), .CLK(w_clk), .Q(\mem[5][3] ) );
  DFFPOSX1 \mem_reg[5][2]  ( .D(n121), .CLK(w_clk), .Q(\mem[5][2] ) );
  DFFPOSX1 \mem_reg[5][1]  ( .D(n120), .CLK(w_clk), .Q(\mem[5][1] ) );
  DFFPOSX1 \mem_reg[5][0]  ( .D(n119), .CLK(w_clk), .Q(\mem[5][0] ) );
  DFFPOSX1 \mem_reg[6][7]  ( .D(n118), .CLK(w_clk), .Q(\mem[6][7] ) );
  DFFPOSX1 \mem_reg[6][6]  ( .D(n117), .CLK(w_clk), .Q(\mem[6][6] ) );
  DFFPOSX1 \mem_reg[6][5]  ( .D(n116), .CLK(w_clk), .Q(\mem[6][5] ) );
  DFFPOSX1 \mem_reg[6][4]  ( .D(n115), .CLK(w_clk), .Q(\mem[6][4] ) );
  DFFPOSX1 \mem_reg[6][3]  ( .D(n114), .CLK(w_clk), .Q(\mem[6][3] ) );
  DFFPOSX1 \mem_reg[6][2]  ( .D(n113), .CLK(w_clk), .Q(\mem[6][2] ) );
  DFFPOSX1 \mem_reg[6][1]  ( .D(n112), .CLK(w_clk), .Q(\mem[6][1] ) );
  DFFPOSX1 \mem_reg[6][0]  ( .D(n111), .CLK(w_clk), .Q(\mem[6][0] ) );
  DFFPOSX1 \mem_reg[7][7]  ( .D(n110), .CLK(w_clk), .Q(\mem[7][7] ) );
  DFFPOSX1 \mem_reg[7][6]  ( .D(n109), .CLK(w_clk), .Q(\mem[7][6] ) );
  DFFPOSX1 \mem_reg[7][5]  ( .D(n108), .CLK(w_clk), .Q(\mem[7][5] ) );
  DFFPOSX1 \mem_reg[7][4]  ( .D(n107), .CLK(w_clk), .Q(\mem[7][4] ) );
  DFFPOSX1 \mem_reg[7][3]  ( .D(n106), .CLK(w_clk), .Q(\mem[7][3] ) );
  DFFPOSX1 \mem_reg[7][2]  ( .D(n105), .CLK(w_clk), .Q(\mem[7][2] ) );
  DFFPOSX1 \mem_reg[7][1]  ( .D(n104), .CLK(w_clk), .Q(\mem[7][1] ) );
  DFFPOSX1 \mem_reg[7][0]  ( .D(n103), .CLK(w_clk), .Q(\mem[7][0] ) );
  DFFPOSX1 \r_data_reg[7]  ( .D(n337), .CLK(r_clk), .Q(r_data[7]) );
  DFFPOSX1 \r_data_reg[6]  ( .D(n338), .CLK(r_clk), .Q(r_data[6]) );
  DFFPOSX1 \r_data_reg[5]  ( .D(n339), .CLK(r_clk), .Q(r_data[5]) );
  DFFPOSX1 \r_data_reg[4]  ( .D(n340), .CLK(r_clk), .Q(r_data[4]) );
  DFFPOSX1 \r_data_reg[3]  ( .D(n341), .CLK(r_clk), .Q(r_data[3]) );
  DFFPOSX1 \r_data_reg[2]  ( .D(n342), .CLK(r_clk), .Q(r_data[2]) );
  DFFPOSX1 \r_data_reg[1]  ( .D(n343), .CLK(r_clk), .Q(r_data[1]) );
  DFFPOSX1 \r_data_reg[0]  ( .D(n344), .CLK(r_clk), .Q(r_data[0]) );
  AOI22X1 U3 ( .A(n328), .B(N37), .C(r_data[0]), .D(n345), .Y(n1) );
  AOI22X1 U5 ( .A(N36), .B(n328), .C(r_data[1]), .D(n345), .Y(n3) );
  AOI22X1 U7 ( .A(N35), .B(n328), .C(r_data[2]), .D(n345), .Y(n4) );
  AOI22X1 U9 ( .A(N34), .B(n328), .C(r_data[3]), .D(n345), .Y(n5) );
  AOI22X1 U11 ( .A(N33), .B(n328), .C(r_data[4]), .D(n345), .Y(n6) );
  AOI22X1 U13 ( .A(N32), .B(n328), .C(r_data[5]), .D(n345), .Y(n7) );
  AOI22X1 U15 ( .A(N31), .B(n328), .C(r_data[6]), .D(n345), .Y(n8) );
  AOI22X1 U17 ( .A(N30), .B(n328), .C(r_data[7]), .D(n345), .Y(n9) );
  OAI21X1 U19 ( .A(n336), .B(n356), .C(n252), .Y(n103) );
  OAI21X1 U21 ( .A(n336), .B(n355), .C(n242), .Y(n104) );
  OAI21X1 U23 ( .A(n336), .B(n354), .C(n232), .Y(n105) );
  OAI21X1 U25 ( .A(n336), .B(n353), .C(n222), .Y(n106) );
  OAI21X1 U27 ( .A(n336), .B(n352), .C(n212), .Y(n107) );
  OAI21X1 U29 ( .A(n336), .B(n351), .C(n201), .Y(n108) );
  OAI21X1 U31 ( .A(n336), .B(n350), .C(n191), .Y(n109) );
  OAI21X1 U33 ( .A(n336), .B(n349), .C(n98), .Y(n110) );
  NAND3X1 U35 ( .A(w_addr[0]), .B(n27), .C(w_addr[1]), .Y(n10) );
  OAI21X1 U36 ( .A(n356), .B(n335), .C(n259), .Y(n111) );
  OAI21X1 U38 ( .A(n355), .B(n335), .C(n251), .Y(n112) );
  OAI21X1 U40 ( .A(n354), .B(n335), .C(n241), .Y(n113) );
  OAI21X1 U42 ( .A(n353), .B(n335), .C(n231), .Y(n114) );
  OAI21X1 U44 ( .A(n352), .B(n335), .C(n221), .Y(n115) );
  OAI21X1 U46 ( .A(n351), .B(n335), .C(n211), .Y(n116) );
  OAI21X1 U48 ( .A(n350), .B(n335), .C(n200), .Y(n117) );
  OAI21X1 U50 ( .A(n349), .B(n335), .C(n190), .Y(n118) );
  NAND3X1 U52 ( .A(n27), .B(n346), .C(w_addr[1]), .Y(n28) );
  OAI21X1 U53 ( .A(n356), .B(n334), .C(n240), .Y(n119) );
  OAI21X1 U55 ( .A(n355), .B(n334), .C(n263), .Y(n120) );
  OAI21X1 U57 ( .A(n354), .B(n334), .C(n250), .Y(n121) );
  OAI21X1 U59 ( .A(n353), .B(n334), .C(n210), .Y(n122) );
  OAI21X1 U61 ( .A(n352), .B(n334), .C(n230), .Y(n123) );
  OAI21X1 U63 ( .A(n351), .B(n334), .C(n220), .Y(n124) );
  OAI21X1 U65 ( .A(n350), .B(n334), .C(n97), .Y(n125) );
  OAI21X1 U67 ( .A(n349), .B(n334), .C(n199), .Y(n126) );
  NAND3X1 U69 ( .A(n27), .B(n347), .C(w_addr[0]), .Y(n38) );
  OAI21X1 U70 ( .A(n356), .B(n333), .C(n262), .Y(n127) );
  OAI21X1 U72 ( .A(n355), .B(n333), .C(n258), .Y(n128) );
  OAI21X1 U74 ( .A(n354), .B(n333), .C(n219), .Y(n129) );
  OAI21X1 U76 ( .A(n353), .B(n333), .C(n239), .Y(n130) );
  OAI21X1 U78 ( .A(n352), .B(n333), .C(n198), .Y(n131) );
  OAI21X1 U80 ( .A(n351), .B(n333), .C(n229), .Y(n132) );
  OAI21X1 U82 ( .A(n350), .B(n333), .C(n209), .Y(n133) );
  OAI21X1 U84 ( .A(n349), .B(n333), .C(n96), .Y(n134) );
  NAND3X1 U86 ( .A(n346), .B(n347), .C(n27), .Y(n48) );
  OAI21X1 U88 ( .A(n356), .B(n332), .C(n228), .Y(n135) );
  OAI21X1 U90 ( .A(n355), .B(n332), .C(n218), .Y(n136) );
  OAI21X1 U92 ( .A(n354), .B(n332), .C(n208), .Y(n137) );
  OAI21X1 U94 ( .A(n353), .B(n332), .C(n249), .Y(n138) );
  OAI21X1 U96 ( .A(n352), .B(n332), .C(n238), .Y(n139) );
  OAI21X1 U98 ( .A(n351), .B(n332), .C(n189), .Y(n140) );
  OAI21X1 U100 ( .A(n350), .B(n332), .C(n95), .Y(n141) );
  OAI21X1 U102 ( .A(n349), .B(n332), .C(n94), .Y(n142) );
  NAND3X1 U104 ( .A(w_addr[1]), .B(w_addr[0]), .C(n66), .Y(n57) );
  OAI21X1 U105 ( .A(n356), .B(n331), .C(n217), .Y(n143) );
  OAI21X1 U107 ( .A(n355), .B(n331), .C(n227), .Y(n144) );
  OAI21X1 U109 ( .A(n354), .B(n331), .C(n257), .Y(n145) );
  OAI21X1 U111 ( .A(n353), .B(n331), .C(n197), .Y(n146) );
  OAI21X1 U113 ( .A(n352), .B(n331), .C(n248), .Y(n147) );
  OAI21X1 U115 ( .A(n351), .B(n331), .C(n237), .Y(n148) );
  OAI21X1 U117 ( .A(n350), .B(n331), .C(n47), .Y(n149) );
  OAI21X1 U119 ( .A(n349), .B(n331), .C(n207), .Y(n150) );
  NAND3X1 U121 ( .A(w_addr[1]), .B(n346), .C(n66), .Y(n67) );
  OAI21X1 U122 ( .A(n356), .B(n330), .C(n206), .Y(n151) );
  OAI21X1 U124 ( .A(n355), .B(n330), .C(n196), .Y(n152) );
  OAI21X1 U126 ( .A(n354), .B(n330), .C(n261), .Y(n153) );
  OAI21X1 U128 ( .A(n353), .B(n330), .C(n188), .Y(n154) );
  OAI21X1 U130 ( .A(n352), .B(n330), .C(n37), .Y(n155) );
  OAI21X1 U132 ( .A(n351), .B(n330), .C(n247), .Y(n156) );
  OAI21X1 U134 ( .A(n350), .B(n330), .C(n236), .Y(n157) );
  OAI21X1 U136 ( .A(n349), .B(n330), .C(n226), .Y(n158) );
  NAND3X1 U138 ( .A(w_addr[0]), .B(n347), .C(n66), .Y(n76) );
  OAI21X1 U139 ( .A(n356), .B(n329), .C(n195), .Y(n159) );
  OAI21X1 U142 ( .A(n355), .B(n329), .C(n205), .Y(n160) );
  OAI21X1 U145 ( .A(n354), .B(n329), .C(n187), .Y(n161) );
  OAI21X1 U148 ( .A(n353), .B(n329), .C(n260), .Y(n162) );
  OAI21X1 U151 ( .A(n352), .B(n329), .C(n256), .Y(n163) );
  OAI21X1 U154 ( .A(n351), .B(n329), .C(n25), .Y(n164) );
  OAI21X1 U157 ( .A(n350), .B(n329), .C(n246), .Y(n165) );
  OAI21X1 U160 ( .A(n349), .B(n329), .C(n216), .Y(n166) );
  NAND3X1 U162 ( .A(n346), .B(n347), .C(n66), .Y(n85) );
  INVX2 U2 ( .A(n268), .Y(n315) );
  INVX2 U4 ( .A(n267), .Y(n316) );
  OR2X2 U6 ( .A(N11), .B(N12), .Y(n267) );
  AND2X1 U8 ( .A(N12), .B(n321), .Y(n314) );
  AND2X1 U10 ( .A(N12), .B(N11), .Y(n313) );
  OR2X1 U12 ( .A(n321), .B(N12), .Y(n268) );
  OR2X1 U14 ( .A(n100), .B(n253), .Y(N36) );
  OR2X1 U16 ( .A(n101), .B(n243), .Y(N35) );
  OR2X1 U18 ( .A(n102), .B(n233), .Y(N34) );
  OR2X1 U20 ( .A(n167), .B(n223), .Y(N33) );
  OR2X1 U22 ( .A(n168), .B(n213), .Y(N32) );
  OR2X1 U24 ( .A(n169), .B(n202), .Y(N31) );
  OR2X1 U26 ( .A(n170), .B(n192), .Y(N30) );
  AND2X1 U28 ( .A(write_en), .B(n348), .Y(n66) );
  AND2X1 U30 ( .A(write_en), .B(w_addr[2]), .Y(n27) );
  BUFX2 U32 ( .A(n9), .Y(n2) );
  BUFX2 U34 ( .A(n8), .Y(n11) );
  BUFX2 U37 ( .A(n7), .Y(n13) );
  BUFX2 U39 ( .A(n6), .Y(n15) );
  BUFX2 U41 ( .A(n5), .Y(n17) );
  BUFX2 U43 ( .A(n4), .Y(n19) );
  BUFX2 U45 ( .A(n3), .Y(n21) );
  BUFX2 U47 ( .A(n1), .Y(n23) );
  OR2X1 U49 ( .A(n99), .B(n264), .Y(N37) );
  AND2X1 U51 ( .A(\mem[0][5] ), .B(n329), .Y(n91) );
  INVX1 U54 ( .A(n91), .Y(n25) );
  AND2X1 U56 ( .A(\mem[1][4] ), .B(n330), .Y(n81) );
  INVX1 U58 ( .A(n81), .Y(n37) );
  AND2X1 U60 ( .A(\mem[2][6] ), .B(n331), .Y(n74) );
  INVX1 U62 ( .A(n74), .Y(n47) );
  AND2X1 U64 ( .A(\mem[3][7] ), .B(n332), .Y(n65) );
  INVX1 U66 ( .A(n65), .Y(n94) );
  AND2X1 U68 ( .A(\mem[3][6] ), .B(n332), .Y(n64) );
  INVX1 U71 ( .A(n64), .Y(n95) );
  AND2X1 U73 ( .A(\mem[4][7] ), .B(n333), .Y(n56) );
  INVX1 U75 ( .A(n56), .Y(n96) );
  AND2X1 U77 ( .A(\mem[5][6] ), .B(n334), .Y(n45) );
  INVX1 U79 ( .A(n45), .Y(n97) );
  AND2X1 U81 ( .A(\mem[7][7] ), .B(n336), .Y(n26) );
  INVX1 U83 ( .A(n26), .Y(n98) );
  BUFX2 U85 ( .A(n274), .Y(n99) );
  BUFX2 U87 ( .A(n280), .Y(n100) );
  BUFX2 U89 ( .A(n286), .Y(n101) );
  BUFX2 U91 ( .A(n292), .Y(n102) );
  BUFX2 U93 ( .A(n298), .Y(n167) );
  BUFX2 U95 ( .A(n304), .Y(n168) );
  BUFX2 U97 ( .A(n310), .Y(n169) );
  BUFX2 U99 ( .A(n320), .Y(n170) );
  BUFX2 U101 ( .A(n269), .Y(n171) );
  BUFX2 U103 ( .A(n275), .Y(n172) );
  BUFX2 U106 ( .A(n281), .Y(n173) );
  BUFX2 U108 ( .A(n287), .Y(n174) );
  BUFX2 U110 ( .A(n293), .Y(n175) );
  BUFX2 U112 ( .A(n299), .Y(n176) );
  BUFX2 U114 ( .A(n305), .Y(n177) );
  BUFX2 U116 ( .A(n311), .Y(n178) );
  BUFX2 U118 ( .A(n270), .Y(n179) );
  BUFX2 U120 ( .A(n276), .Y(n180) );
  BUFX2 U123 ( .A(n282), .Y(n181) );
  BUFX2 U125 ( .A(n288), .Y(n182) );
  BUFX2 U127 ( .A(n294), .Y(n183) );
  BUFX2 U129 ( .A(n300), .Y(n184) );
  BUFX2 U131 ( .A(n306), .Y(n185) );
  BUFX2 U133 ( .A(n312), .Y(n186) );
  AND2X1 U135 ( .A(\mem[0][2] ), .B(n329), .Y(n88) );
  INVX1 U137 ( .A(n88), .Y(n187) );
  AND2X1 U140 ( .A(\mem[1][3] ), .B(n330), .Y(n80) );
  INVX1 U141 ( .A(n80), .Y(n188) );
  AND2X1 U143 ( .A(\mem[3][5] ), .B(n332), .Y(n63) );
  INVX1 U144 ( .A(n63), .Y(n189) );
  AND2X1 U146 ( .A(\mem[6][7] ), .B(n335), .Y(n36) );
  INVX1 U147 ( .A(n36), .Y(n190) );
  AND2X1 U149 ( .A(\mem[7][6] ), .B(n336), .Y(n24) );
  INVX1 U150 ( .A(n24), .Y(n191) );
  BUFX2 U152 ( .A(n319), .Y(n192) );
  BUFX2 U153 ( .A(n318), .Y(n193) );
  BUFX2 U155 ( .A(n317), .Y(n194) );
  AND2X1 U156 ( .A(\mem[0][0] ), .B(n329), .Y(n86) );
  INVX1 U158 ( .A(n86), .Y(n195) );
  AND2X1 U159 ( .A(\mem[1][1] ), .B(n330), .Y(n78) );
  INVX1 U161 ( .A(n78), .Y(n196) );
  AND2X1 U163 ( .A(\mem[2][3] ), .B(n331), .Y(n71) );
  INVX1 U164 ( .A(n71), .Y(n197) );
  AND2X1 U165 ( .A(\mem[4][4] ), .B(n333), .Y(n53) );
  INVX1 U166 ( .A(n53), .Y(n198) );
  AND2X1 U167 ( .A(\mem[5][7] ), .B(n334), .Y(n46) );
  INVX1 U168 ( .A(n46), .Y(n199) );
  AND2X1 U169 ( .A(\mem[6][6] ), .B(n335), .Y(n35) );
  INVX1 U170 ( .A(n35), .Y(n200) );
  AND2X1 U171 ( .A(\mem[7][5] ), .B(n336), .Y(n22) );
  INVX1 U172 ( .A(n22), .Y(n201) );
  BUFX2 U173 ( .A(n309), .Y(n202) );
  BUFX2 U174 ( .A(n308), .Y(n203) );
  BUFX2 U175 ( .A(n307), .Y(n204) );
  AND2X1 U176 ( .A(\mem[0][1] ), .B(n329), .Y(n87) );
  INVX1 U177 ( .A(n87), .Y(n205) );
  AND2X1 U178 ( .A(\mem[1][0] ), .B(n330), .Y(n77) );
  INVX1 U179 ( .A(n77), .Y(n206) );
  AND2X1 U180 ( .A(\mem[2][7] ), .B(n331), .Y(n75) );
  INVX1 U181 ( .A(n75), .Y(n207) );
  AND2X1 U182 ( .A(\mem[3][2] ), .B(n332), .Y(n60) );
  INVX1 U183 ( .A(n60), .Y(n208) );
  AND2X1 U184 ( .A(\mem[4][6] ), .B(n333), .Y(n55) );
  INVX1 U185 ( .A(n55), .Y(n209) );
  AND2X1 U186 ( .A(\mem[5][3] ), .B(n334), .Y(n42) );
  INVX1 U187 ( .A(n42), .Y(n210) );
  AND2X1 U188 ( .A(\mem[6][5] ), .B(n335), .Y(n34) );
  INVX1 U189 ( .A(n34), .Y(n211) );
  AND2X1 U190 ( .A(\mem[7][4] ), .B(n336), .Y(n20) );
  INVX1 U191 ( .A(n20), .Y(n212) );
  BUFX2 U192 ( .A(n303), .Y(n213) );
  BUFX2 U193 ( .A(n302), .Y(n214) );
  BUFX2 U194 ( .A(n301), .Y(n215) );
  AND2X1 U195 ( .A(\mem[0][7] ), .B(n329), .Y(n93) );
  INVX1 U196 ( .A(n93), .Y(n216) );
  AND2X1 U197 ( .A(\mem[2][0] ), .B(n331), .Y(n68) );
  INVX1 U198 ( .A(n68), .Y(n217) );
  AND2X1 U199 ( .A(\mem[3][1] ), .B(n332), .Y(n59) );
  INVX1 U200 ( .A(n59), .Y(n218) );
  AND2X1 U201 ( .A(\mem[4][2] ), .B(n333), .Y(n51) );
  INVX1 U202 ( .A(n51), .Y(n219) );
  AND2X1 U203 ( .A(\mem[5][5] ), .B(n334), .Y(n44) );
  INVX1 U204 ( .A(n44), .Y(n220) );
  AND2X1 U205 ( .A(\mem[6][4] ), .B(n335), .Y(n33) );
  INVX1 U206 ( .A(n33), .Y(n221) );
  AND2X1 U207 ( .A(\mem[7][3] ), .B(n336), .Y(n18) );
  INVX1 U208 ( .A(n18), .Y(n222) );
  BUFX2 U209 ( .A(n297), .Y(n223) );
  BUFX2 U210 ( .A(n296), .Y(n224) );
  BUFX2 U211 ( .A(n295), .Y(n225) );
  AND2X1 U212 ( .A(\mem[1][7] ), .B(n330), .Y(n84) );
  INVX1 U213 ( .A(n84), .Y(n226) );
  AND2X1 U214 ( .A(\mem[2][1] ), .B(n331), .Y(n69) );
  INVX1 U215 ( .A(n69), .Y(n227) );
  AND2X1 U216 ( .A(\mem[3][0] ), .B(n332), .Y(n58) );
  INVX1 U217 ( .A(n58), .Y(n228) );
  AND2X1 U218 ( .A(\mem[4][5] ), .B(n333), .Y(n54) );
  INVX1 U219 ( .A(n54), .Y(n229) );
  AND2X1 U220 ( .A(\mem[5][4] ), .B(n334), .Y(n43) );
  INVX1 U221 ( .A(n43), .Y(n230) );
  AND2X1 U222 ( .A(\mem[6][3] ), .B(n335), .Y(n32) );
  INVX1 U223 ( .A(n32), .Y(n231) );
  AND2X1 U224 ( .A(\mem[7][2] ), .B(n336), .Y(n16) );
  INVX1 U225 ( .A(n16), .Y(n232) );
  BUFX2 U226 ( .A(n291), .Y(n233) );
  BUFX2 U227 ( .A(n290), .Y(n234) );
  BUFX2 U228 ( .A(n289), .Y(n235) );
  AND2X1 U229 ( .A(\mem[1][6] ), .B(n330), .Y(n83) );
  INVX1 U230 ( .A(n83), .Y(n236) );
  AND2X1 U231 ( .A(\mem[2][5] ), .B(n331), .Y(n73) );
  INVX1 U232 ( .A(n73), .Y(n237) );
  AND2X1 U233 ( .A(\mem[3][4] ), .B(n332), .Y(n62) );
  INVX1 U234 ( .A(n62), .Y(n238) );
  AND2X1 U235 ( .A(\mem[4][3] ), .B(n333), .Y(n52) );
  INVX1 U236 ( .A(n52), .Y(n239) );
  AND2X1 U237 ( .A(\mem[5][0] ), .B(n334), .Y(n39) );
  INVX1 U238 ( .A(n39), .Y(n240) );
  AND2X1 U239 ( .A(\mem[6][2] ), .B(n335), .Y(n31) );
  INVX1 U240 ( .A(n31), .Y(n241) );
  AND2X1 U241 ( .A(\mem[7][1] ), .B(n336), .Y(n14) );
  INVX1 U242 ( .A(n14), .Y(n242) );
  BUFX2 U243 ( .A(n285), .Y(n243) );
  BUFX2 U244 ( .A(n284), .Y(n244) );
  BUFX2 U245 ( .A(n283), .Y(n245) );
  AND2X1 U246 ( .A(\mem[0][6] ), .B(n329), .Y(n92) );
  INVX1 U247 ( .A(n92), .Y(n246) );
  AND2X1 U248 ( .A(\mem[1][5] ), .B(n330), .Y(n82) );
  INVX1 U249 ( .A(n82), .Y(n247) );
  AND2X1 U250 ( .A(\mem[2][4] ), .B(n331), .Y(n72) );
  INVX1 U251 ( .A(n72), .Y(n248) );
  AND2X1 U252 ( .A(\mem[3][3] ), .B(n332), .Y(n61) );
  INVX1 U253 ( .A(n61), .Y(n249) );
  AND2X1 U254 ( .A(\mem[5][2] ), .B(n334), .Y(n41) );
  INVX1 U255 ( .A(n41), .Y(n250) );
  AND2X1 U256 ( .A(\mem[6][1] ), .B(n335), .Y(n30) );
  INVX1 U257 ( .A(n30), .Y(n251) );
  AND2X1 U258 ( .A(\mem[7][0] ), .B(n336), .Y(n12) );
  INVX1 U259 ( .A(n12), .Y(n252) );
  BUFX2 U260 ( .A(n279), .Y(n253) );
  BUFX2 U261 ( .A(n278), .Y(n254) );
  BUFX2 U262 ( .A(n277), .Y(n255) );
  AND2X1 U263 ( .A(\mem[0][4] ), .B(n329), .Y(n90) );
  INVX1 U264 ( .A(n90), .Y(n256) );
  AND2X1 U265 ( .A(\mem[2][2] ), .B(n331), .Y(n70) );
  INVX1 U266 ( .A(n70), .Y(n257) );
  AND2X1 U267 ( .A(\mem[4][1] ), .B(n333), .Y(n50) );
  INVX1 U268 ( .A(n50), .Y(n258) );
  AND2X1 U269 ( .A(\mem[6][0] ), .B(n335), .Y(n29) );
  INVX1 U270 ( .A(n29), .Y(n259) );
  AND2X1 U271 ( .A(\mem[0][3] ), .B(n329), .Y(n89) );
  INVX1 U272 ( .A(n89), .Y(n260) );
  AND2X1 U273 ( .A(\mem[1][2] ), .B(n330), .Y(n79) );
  INVX1 U274 ( .A(n79), .Y(n261) );
  AND2X1 U275 ( .A(\mem[4][0] ), .B(n333), .Y(n49) );
  INVX1 U276 ( .A(n49), .Y(n262) );
  AND2X1 U277 ( .A(\mem[5][1] ), .B(n334), .Y(n40) );
  INVX1 U278 ( .A(n40), .Y(n263) );
  BUFX2 U279 ( .A(n273), .Y(n264) );
  BUFX2 U280 ( .A(n272), .Y(n265) );
  BUFX2 U281 ( .A(n271), .Y(n266) );
  INVX1 U282 ( .A(n328), .Y(n345) );
  BUFX2 U283 ( .A(n85), .Y(n329) );
  BUFX2 U284 ( .A(n48), .Y(n333) );
  BUFX2 U285 ( .A(n314), .Y(n325) );
  BUFX2 U286 ( .A(n314), .Y(n324) );
  BUFX2 U287 ( .A(n313), .Y(n327) );
  BUFX2 U288 ( .A(n313), .Y(n326) );
  INVX1 U289 ( .A(n323), .Y(n322) );
  INVX1 U290 ( .A(n21), .Y(n343) );
  INVX1 U291 ( .A(n19), .Y(n342) );
  INVX1 U292 ( .A(n17), .Y(n341) );
  INVX1 U293 ( .A(n15), .Y(n340) );
  INVX1 U294 ( .A(n13), .Y(n339) );
  INVX1 U295 ( .A(n11), .Y(n338) );
  INVX1 U296 ( .A(n2), .Y(n337) );
  INVX1 U297 ( .A(n23), .Y(n344) );
  INVX1 U298 ( .A(N11), .Y(n321) );
  BUFX2 U299 ( .A(N10), .Y(n323) );
  BUFX2 U300 ( .A(n28), .Y(n335) );
  BUFX2 U301 ( .A(n38), .Y(n334) );
  BUFX2 U302 ( .A(n10), .Y(n336) );
  BUFX2 U303 ( .A(n67), .Y(n331) );
  INVX1 U304 ( .A(w_addr[2]), .Y(n348) );
  BUFX2 U305 ( .A(n76), .Y(n330) );
  BUFX2 U306 ( .A(n57), .Y(n332) );
  INVX1 U307 ( .A(w_addr[1]), .Y(n347) );
  INVX1 U308 ( .A(w_addr[0]), .Y(n346) );
  INVX1 U309 ( .A(w_data[0]), .Y(n356) );
  INVX1 U310 ( .A(w_data[1]), .Y(n355) );
  INVX1 U311 ( .A(w_data[2]), .Y(n354) );
  INVX1 U312 ( .A(w_data[3]), .Y(n353) );
  INVX1 U313 ( .A(w_data[4]), .Y(n352) );
  INVX1 U314 ( .A(w_data[5]), .Y(n351) );
  INVX1 U315 ( .A(w_data[6]), .Y(n350) );
  INVX1 U316 ( .A(w_data[7]), .Y(n349) );
  AOI22X1 U317 ( .A(\mem[4][0] ), .B(n325), .C(\mem[6][0] ), .D(n327), .Y(n270) );
  AOI22X1 U318 ( .A(\mem[0][0] ), .B(n316), .C(\mem[2][0] ), .D(n315), .Y(n269) );
  AOI21X1 U319 ( .A(n179), .B(n171), .C(n323), .Y(n274) );
  AOI22X1 U320 ( .A(\mem[5][0] ), .B(n325), .C(\mem[7][0] ), .D(n327), .Y(n272) );
  AOI22X1 U321 ( .A(\mem[1][0] ), .B(n316), .C(\mem[3][0] ), .D(n315), .Y(n271) );
  AOI21X1 U322 ( .A(n265), .B(n266), .C(n322), .Y(n273) );
  AOI22X1 U323 ( .A(\mem[4][1] ), .B(n325), .C(\mem[6][1] ), .D(n327), .Y(n276) );
  AOI22X1 U324 ( .A(\mem[0][1] ), .B(n316), .C(\mem[2][1] ), .D(n315), .Y(n275) );
  AOI21X1 U325 ( .A(n180), .B(n172), .C(n323), .Y(n280) );
  AOI22X1 U326 ( .A(\mem[5][1] ), .B(n325), .C(\mem[7][1] ), .D(n327), .Y(n278) );
  AOI22X1 U327 ( .A(\mem[1][1] ), .B(n316), .C(\mem[3][1] ), .D(n315), .Y(n277) );
  AOI21X1 U328 ( .A(n254), .B(n255), .C(n322), .Y(n279) );
  AOI22X1 U329 ( .A(\mem[4][2] ), .B(n325), .C(\mem[6][2] ), .D(n327), .Y(n282) );
  AOI22X1 U330 ( .A(\mem[0][2] ), .B(n316), .C(\mem[2][2] ), .D(n315), .Y(n281) );
  AOI21X1 U331 ( .A(n181), .B(n173), .C(n323), .Y(n286) );
  AOI22X1 U332 ( .A(\mem[5][2] ), .B(n325), .C(\mem[7][2] ), .D(n327), .Y(n284) );
  AOI22X1 U333 ( .A(\mem[1][2] ), .B(n316), .C(\mem[3][2] ), .D(n315), .Y(n283) );
  AOI21X1 U334 ( .A(n244), .B(n245), .C(n322), .Y(n285) );
  AOI22X1 U335 ( .A(\mem[4][3] ), .B(n325), .C(\mem[6][3] ), .D(n327), .Y(n288) );
  AOI22X1 U336 ( .A(\mem[0][3] ), .B(n316), .C(\mem[2][3] ), .D(n315), .Y(n287) );
  AOI21X1 U337 ( .A(n182), .B(n174), .C(n323), .Y(n292) );
  AOI22X1 U338 ( .A(\mem[5][3] ), .B(n325), .C(\mem[7][3] ), .D(n327), .Y(n290) );
  AOI22X1 U339 ( .A(\mem[1][3] ), .B(n316), .C(\mem[3][3] ), .D(n315), .Y(n289) );
  AOI21X1 U340 ( .A(n234), .B(n235), .C(n322), .Y(n291) );
  AOI22X1 U341 ( .A(\mem[4][4] ), .B(n324), .C(\mem[6][4] ), .D(n326), .Y(n294) );
  AOI22X1 U342 ( .A(\mem[0][4] ), .B(n316), .C(\mem[2][4] ), .D(n315), .Y(n293) );
  AOI21X1 U343 ( .A(n183), .B(n175), .C(n323), .Y(n298) );
  AOI22X1 U344 ( .A(\mem[5][4] ), .B(n324), .C(\mem[7][4] ), .D(n326), .Y(n296) );
  AOI22X1 U345 ( .A(\mem[1][4] ), .B(n316), .C(\mem[3][4] ), .D(n315), .Y(n295) );
  AOI21X1 U346 ( .A(n224), .B(n225), .C(n322), .Y(n297) );
  AOI22X1 U347 ( .A(\mem[4][5] ), .B(n324), .C(\mem[6][5] ), .D(n326), .Y(n300) );
  AOI22X1 U348 ( .A(\mem[0][5] ), .B(n316), .C(\mem[2][5] ), .D(n315), .Y(n299) );
  AOI21X1 U349 ( .A(n184), .B(n176), .C(n323), .Y(n304) );
  AOI22X1 U350 ( .A(\mem[5][5] ), .B(n324), .C(\mem[7][5] ), .D(n326), .Y(n302) );
  AOI22X1 U351 ( .A(\mem[1][5] ), .B(n316), .C(\mem[3][5] ), .D(n315), .Y(n301) );
  AOI21X1 U352 ( .A(n214), .B(n215), .C(n322), .Y(n303) );
  AOI22X1 U353 ( .A(\mem[4][6] ), .B(n324), .C(\mem[6][6] ), .D(n326), .Y(n306) );
  AOI22X1 U354 ( .A(\mem[0][6] ), .B(n316), .C(\mem[2][6] ), .D(n315), .Y(n305) );
  AOI21X1 U355 ( .A(n185), .B(n177), .C(n323), .Y(n310) );
  AOI22X1 U356 ( .A(\mem[5][6] ), .B(n324), .C(\mem[7][6] ), .D(n326), .Y(n308) );
  AOI22X1 U357 ( .A(\mem[1][6] ), .B(n316), .C(\mem[3][6] ), .D(n315), .Y(n307) );
  AOI21X1 U358 ( .A(n203), .B(n204), .C(n322), .Y(n309) );
  AOI22X1 U359 ( .A(\mem[4][7] ), .B(n324), .C(\mem[6][7] ), .D(n326), .Y(n312) );
  AOI22X1 U360 ( .A(\mem[0][7] ), .B(n316), .C(\mem[2][7] ), .D(n315), .Y(n311) );
  AOI21X1 U361 ( .A(n186), .B(n178), .C(n323), .Y(n320) );
  AOI22X1 U362 ( .A(\mem[5][7] ), .B(n324), .C(\mem[7][7] ), .D(n326), .Y(n318) );
  AOI22X1 U363 ( .A(\mem[1][7] ), .B(n316), .C(\mem[3][7] ), .D(n315), .Y(n317) );
  AOI21X1 U364 ( .A(n193), .B(n194), .C(n322), .Y(n319) );
  BUFX2 U365 ( .A(read_en), .Y(n328) );
endmodule



    module async_fifo_DATA_WIDTH8_DEPTH8_ADDR_WIDTH3_PTR_WIDTH4_ALMOST_FULL_LEVEL6_ALMOST_EMPTY_LEVEL2_I_fifo_fifo_if__DATA_WIDTH_8 ( 
        \fifo.w_clk , \fifo.r_clk , \fifo.w_rst_b , \fifo.r_rst_b , 
        \fifo.write_en , \fifo.read_en , \fifo.w_data , \fifo.r_data , 
        \fifo.full , \fifo.empty , \fifo.almost_full , \fifo.almost_empty  );
  input [7:0] \fifo.w_data ;
  output [7:0] \fifo.r_data ;
  input \fifo.w_clk , \fifo.r_clk , \fifo.w_rst_b , \fifo.r_rst_b ,
         \fifo.write_en , \fifo.read_en ;
  output \fifo.full , \fifo.empty , \fifo.almost_full , \fifo.almost_empty ;
  wire   write_en, read_en, n1, n2, n3, n4, n5, n6;
  wire   [3:0] wptr_gray;
  wire   [2:0] w_addr;
  wire   [3:0] rptr_gray_sync;
  wire   [3:0] rptr_gray;
  wire   [2:0] r_addr;
  wire   [3:0] wptr_gray_sync;

  OR2X1 U1 ( .A(\fifo.empty ), .B(n6), .Y(read_en) );
  OR2X1 U2 ( .A(\fifo.full ), .B(n5), .Y(write_en) );
  INVX1 U3 ( .A(write_en), .Y(n1) );
  INVX1 U4 ( .A(write_en), .Y(n3) );
  INVX1 U5 ( .A(read_en), .Y(n4) );
  BUFX2 U6 ( .A(rptr_gray_sync[3]), .Y(n2) );
  INVX1 U7 ( .A(\fifo.write_en ), .Y(n5) );
  INVX1 U8 ( .A(\fifo.read_en ), .Y(n6) );
  write_ptr_DEPTH8_ADDR_WIDTH3_PTR_WIDTH4_ALMOST_FULL_LEVEL6 write_ptr_inst ( 
        .w_clk(\fifo.w_clk ), .w_rst_b(\fifo.w_rst_b ), .write_en(n1), 
        .rptr_gray_sync({n2, rptr_gray_sync[2:0]}), .w_addr(w_addr), 
        .wptr_bin(), .wptr_gray(wptr_gray), .full(\fifo.full ), .almost_full(
        \fifo.almost_full ) );
  read_ptr_DEPTH8_ADDR_WIDTH3_PTR_WIDTH4_ALMOST_EMPTY_LEVEL2 read_ptr_inst ( 
        .r_clk(\fifo.r_clk ), .r_rst_b(\fifo.r_rst_b ), .read_en(n4), 
        .wptr_gray_sync(wptr_gray_sync), .r_addr(r_addr), .rptr_bin(), 
        .rptr_gray(rptr_gray), .empty(\fifo.empty ), .almost_empty(
        \fifo.almost_empty ) );
  synchronizer_WIDTH4_1 wptr_sync_inst ( .clk(\fifo.r_clk ), .rst_b(
        \fifo.r_rst_b ), .async_ptr(wptr_gray), .sync_ptr(wptr_gray_sync) );
  synchronizer_WIDTH4_0 rptr_sync_inst ( .clk(\fifo.w_clk ), .rst_b(
        \fifo.w_rst_b ), .async_ptr(rptr_gray), .sync_ptr(rptr_gray_sync) );
  fifo_mem_DATA_WIDTH8_ADDR_WIDTH3_DEPTH8 fifo_mem_inst ( .w_clk(\fifo.w_clk ), 
        .r_clk(\fifo.r_clk ), .write_en(n3), .read_en(n4), .w_addr(w_addr), 
        .r_addr(r_addr), .w_data(\fifo.w_data ), .r_data(\fifo.r_data ) );
endmodule


module fifo_wrapper ( w_clk, r_clk, w_rst_b, r_rst_b, write_en, read_en, 
        w_data, r_data, full, empty, almost_full, almost_empty );
  input [7:0] w_data;
  output [7:0] r_data;
  input w_clk, r_clk, w_rst_b, r_rst_b, write_en, read_en;
  output full, empty, almost_full, almost_empty;


  async_fifo_DATA_WIDTH8_DEPTH8_ADDR_WIDTH3_PTR_WIDTH4_ALMOST_FULL_LEVEL6_ALMOST_EMPTY_LEVEL2_I_fifo_fifo_if__DATA_WIDTH_8 async_fifo_inst ( 
        .\fifo.w_clk (w_clk), .\fifo.r_clk (r_clk), .\fifo.w_rst_b (w_rst_b), 
        .\fifo.r_rst_b (r_rst_b), .\fifo.write_en (write_en), .\fifo.read_en (
        read_en), .\fifo.w_data (w_data), .\fifo.r_data (r_data), 
        .\fifo.full (full), .\fifo.empty (empty), .\fifo.almost_full (
        almost_full), .\fifo.almost_empty (almost_empty) );
endmodule

