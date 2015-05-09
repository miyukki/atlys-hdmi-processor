//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    01:08:53 02/06/2015
// Design Name:
// Module Name:    main
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module main #(
  parameter TRUE = 1'b1,
  parameter FALSE = 1'b0
) (
  input  wire       RESET,
  input  wire       CLOCK_100M,

  input  wire [3:0] RX0_TMDS,
  input  wire [3:0] RX0_TMDSB,
  input  wire [3:0] RX1_TMDS,
  input  wire [3:0] RX1_TMDSB,

  output wire [3:0] TX0_TMDS,
  output wire [3:0] TX0_TMDSB,
  output wire [3:0] LED
);

/////////////////////////////////////
// PIXEL CLOCK GENERATOR (150M)
/////////////////////////////////////



/*wire clk25m;
wire px_clk;

BUFIO2 #(
  .DIVIDE_BYPASS("FALSE"),
  .DIVIDE(5)
) sysclk_div (
  .DIVCLK(clk25m),
  .IOCLK(),
  .SERDESSTROBE(),
  .I(CLOCK_100M)
);
BUFG clk25_buf (
  .I(clk25m),
  .O(px_clk)
);*/

/////////////////////////////////////
// VIDEO GENERATOR
/////////////////////////////////////

wire v_hsync;
wire v_vsync;
wire v_red;
wire v_green;
wire v_blue;

video_generator gen_0 (
  .hsync (v_hsync),
  .vsync (v_vsync),
  .red   (v_red),
  .green (v_green),
  .blue  (v_blue),
);

/////////////////////////////////////
// TMDS TRANSMITTER
/////////////////////////////////////

tmds_tx tmds_tx_0 (
  .hsync (v_hsync),
  .vsync (v_vsync),
  .red   (v_red),
  .green (v_green),
  .blue  (v_blue),

  .tmdsclk_p   (RX0_TMDS[3]),
  .tmdsclk_n   (RX0_TMDSB[3]),
  .blue_p      (RX0_TMDS[0]),
  .green_p     (RX0_TMDS[1]),
  .red_p       (RX0_TMDS[2]),
  .blue_n      (RX0_TMDSB[0]),
  .green_n     (RX0_TMDSB[1]),
  .red_n       (RX0_TMDSB[2])
);

endmodule
