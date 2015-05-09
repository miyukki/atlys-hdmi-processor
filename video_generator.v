`timescale 1ns / 1ps

module video_generator #(
  parameter TRUE = 1'b1,
  parameter FALSE = 1'b0,

  parameter H_ACTIVE_PIXEL = 720,
  parameter H_FPORCH_PIXEL = 16,
  parameter H_SYNC_PIXEL   = 96,
  parameter H_BPORCH_PIXEL = 48,
  parameter H_LIMIT_PIXEL  = H_ACTIVE_PIXEL + H_FPORCH_PIXEL + H_SYNC_PIXEL + H_BPORCH_PIXEL,

  parameter V_ACTIVE_LINE  = 480,
  parameter V_FPORCH_LINE  = 10,
  parameter V_SYNC_LINE    = 2,
  parameter V_BPORCH_LINE  = 33,
  parameter V_LIMIT_LINE   = V_ACTIVE_LINE + V_FPORCH_LINE + V_SYNC_LINE + V_BPORCH_LINE
) (
  input wire clk,
  output wire hsync,
  output wire vsync,
  output wire red,
  output wire green,
  output wire blue
);


/***********************************
 * START
 */

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

dvi_encoder dvi_tx0 (
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
