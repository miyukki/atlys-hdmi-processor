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
  input  wire       SW,

  // input  wire [3:0] RX0_TMDS,
  // input  wire [3:0] RX0_TMDSB,
  // input  wire [3:0] RX1_TMDS,
  // input  wire [3:0] RX1_TMDSB,

  output wire [3:0] TX0_TMDS,
  output wire [3:0] TX0_TMDSB,
  output wire [3:0] LED
);

/////////////////////////////////////
// PIXEL CLOCK GENERATOR (150M)
/////////////////////////////////////

wire px_clk, px_clk_l;

dcm px_clk_dcm (
  .CLK_IN1  (CLOCK_100M),
  .CLK_OUT1 (px_clk_l),
  .RESET    (RESET)
);

BUFG px_clk_bufg (
  .I (px_clk_l),
  .O (px_clk)
);

/////////////////////////////////////
// COLOR BAR GENERATOR
/////////////////////////////////////

wire       clr_hsync;
wire       clr_vsync;
wire [7:0] clr_blue;
wire [7:0] clr_green;
wire [7:0] clr_red;
wire       clr_de;

colorbar_generator clr_gen (
  .rst   (RESET),
  .clk   (px_clk),
  .hsync (clr_hsync),
  .vsync (clr_vsync),
  .blue  (clr_blue),
  .green (clr_green),
  .red   (clr_red),
  .de    (clr_de)
);

/////////////////////////////////////
// VIDEO GENERATOR
/////////////////////////////////////

wire       vg_hsync;
wire       vg_vsync;
wire [7:0] vg_blue;
wire [7:0] vg_green;
wire [7:0] vg_red;
wire       vg_de;

video_generator vg_gen (
  .rst   (RESET),
  .clk   (px_clk),
  .hsync (vg_hsync),
  .vsync (vg_vsync),
  .blue  (vg_blue),
  .green (vg_green),
  .red   (vg_red),
  .de    (vg_de)
);

/////////////////////////////////////
// TMDS TRANSMITTER
/////////////////////////////////////

wire       v_hsync = (SW) ? vg_hsync : clr_hsync;
wire       v_vsync = (SW) ? vg_vsync : clr_vsync;
wire [7:0] v_blue  = (SW) ? vg_blue  : clr_blue;
wire [7:0] v_green = (SW) ? vg_green : clr_green;
wire [7:0] v_red   = (SW) ? vg_red   : clr_red;
wire       v_de    = (SW) ? vg_de    : clr_de;

tmds_tx tmds_tx_0 (
  .rst   (RESET),
  .clk   (px_clk),
  .hsync (v_hsync),
  .vsync (v_vsync),
  .blue  (v_blue),
  .green (v_green),
  .red   (v_red),
  .de    (v_de),

  .tmdsclk_p   (TX0_TMDS[3]),
  .tmdsclk_n   (TX0_TMDSB[3]),
  .blue_p      (TX0_TMDS[0]),
  .blue_n      (TX0_TMDSB[0]),
  .green_p     (TX0_TMDS[1]),
  .green_n     (TX0_TMDSB[1]),
  .red_p       (TX0_TMDS[2]),
  .red_n       (TX0_TMDSB[2]),
  .LED         (LED)
);

endmodule
