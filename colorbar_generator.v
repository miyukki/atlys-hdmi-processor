/*
This video pattern generator will generate color bars for the 18 video standards
currently supported by the SMPTE 292M (HD-SDI) video standard. The color bars
comply with SMPTE RP-219 standard color bars, as shown below. This module can
also generate the SMPTE RP-198 HD-SDI checkfield test pattern and 75% color
bars.

|<-------------------------------------- a ------------------------------------->|
|                                                                                |
|        |<----------------------------(3/4)a-------------------------->|        |
|        |                                                              |        |
|   d    |    c        c        c        c        c        c        c   |   d    |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+ - - - - -
|        |        |        |        |        |        |        |        |        |   ^     ^
|        |        |        |        |        |        |        |        |        |   |     |
|        |        |        |        |        |        |        |        |        |   |     |
|        |        |        |        |        |        |        |        |        |   |     |
|        |        |        |        |        |        |        |        |        | (7/12)b |
|  40%   |  75%   | YELLOW |  CYAN  |  GREEN | MAGENTA|   RED  |  BLUE  |  40%   |   |     |
|  GRAY  | WHITE  |        |        |        |        |        |        |  GRAY  |   |     |
|   *1   |        |        |        |        |        |        |        |   *1   |   |     b
|        |        |        |        |        |        |        |        |        |   |     |
|        |        |        |        |        |        |        |        |        |   |     |
|        |        |        |        |        |        |        |        |        |   v     |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+ - - -   |
|100%CYAN|  *2    |                   75% WHITE                         |100%BLUE| (1/12)b |
+--------+--------+-----------------------------------------------------+--------+ - - -   |
|100%YELO|  *3    |                    Y-RAMP                           |100% RED| (1/12)b |
+--------+--------+---+-----------------+-------+--+--+--+--+--+--------+--------+ - - -   |
|        |            |                 |       |  |  |  |  |  |        |        |         |
|  15%   |     0%     |       100%      |  0%   |BL|BL|BL|BL|BL|    0%  |  15%   | (3/12)b |
|  GRAY  |    BLACK   |      WHITE      | BLACK |K-|K |K+|K |K+|  BLACK |  GRAY  |         |
|   *4   |            |                 |       |2%|0%|2%|0%|4%|        |   *4   |         v
+--------+------------+-----------------+-------+--+--+--+--+--+--------+--------+ - - - - -
    d        (3/2)c            2c        (5/6)c  c  c  c  c  c      c       d
                                                 -  -  -  -  -
                                                 3  3  3  3  3

*1: The block marked *1 is 40% Gray for a default value. This value may
optionally be set to any other value in accordance with the operational
requirements of the user.

*2: In the block marked *2, the user may select 75% White, 100% White, +I, or
-I.

*3: In the block marked *3, the user may select either 0% Black, or +Q. When the
-I value is selected for the block marked *2, then the +Q signal must be
selected for the *3 block.

*4: The block marked *4 is 15% Gray for a default value. This value may
optionally be set to any other value in accordance with the operational
requirements of the user.
*/

`timescale 1ns / 1ps

module colorbar_generator #(
  parameter TRUE = 1'b1,
  parameter FALSE = 1'b0,

  // 1080p @ 60fps
  parameter H_ACTIVE_PIXEL = 1920,
  parameter H_FPORCH_PIXEL = 67,
  parameter H_SYNC_PIXEL   = 75,
  parameter H_BPORCH_PIXEL = 205,
  parameter H_LIMIT_PIXEL  = H_ACTIVE_PIXEL + H_FPORCH_PIXEL + H_SYNC_PIXEL + H_BPORCH_PIXEL,

  parameter V_ACTIVE_LINE  = 1080,
  parameter V_FPORCH_LINE  = 3,
  parameter V_SYNC_LINE    = 5,
  parameter V_BPORCH_LINE  = 16,
  parameter V_LIMIT_LINE   = V_ACTIVE_LINE + V_FPORCH_LINE + V_SYNC_LINE + V_BPORCH_LINE
) (
  input  wire       rst,
  input  wire       clk,
  output reg        hsync = TRUE,
  output reg        vsync = TRUE,
  output reg        de    = TRUE,
  output reg  [7:0] blue  = 8'b0,
  output reg  [7:0] green = 8'b0,
  output reg  [7:0] red   = 8'b0
);

reg [11:0] hpos = 12'b0;
reg [10:0] vpos = 11'b0;

/*reg       hsync = TRUE;
reg       vsync = TRUE;
reg [7:0] blue  = 8'b0;
reg [7:0] green = 8'b0;
reg [7:0] red   = 8'b0;
reg       de    = TRUE;*/

/*assign hsync = hpos < H_ACTIVE_PIXEL + H_FPORCH_PIXEL || H_ACTIVE_PIXEL + H_FPORCH_PIXEL + H_SYNC_PIXEL <= hpos;*/
/*assign hsync = hsync;
assign vsync = vsync;
assign blue  = blue;
assign green = green;
assign red   = red;
assign de    = hpos < H_ACTIVE_PIXEL && vpos < V_ACTIVE_LINE;*/

/////////////////////////////////////
// COLORS
/////////////////////////////////////

parameter LVL_100   = 8'd255;
parameter LVL_75    = 8'd191;
parameter LVL_40    = 8'd102;
parameter LVL_15    = 8'd38;
parameter LVL_4     = 8'd10;
parameter LVL_2     = 8'd5;
parameter LVL_0     = 8'd0;

/*parameter H_PART_LINE_1 = H_ACTIVE_PIXEL / 8;*/
/*parameter H_PART_LINE_2 = H_PART_LINE_1 + ;*/

parameter V_PART_LINE_1 = (V_ACTIVE_LINE / 12) * 7;
parameter V_PART_LINE_2 = V_PART_LINE_1 + V_ACTIVE_LINE / 12;
parameter V_PART_LINE_3 = V_PART_LINE_2 + V_ACTIVE_LINE / 12;

/*parameter  I_R       = 8'd0; // -I signal
parameter  Q_R       = 8'd65;// +Q signal
parameter  I_G       = 8'd63;
parameter  Q_G       = 8'd0;
parameter  I_B       = 8'd105;
parameter  Q_B       = 8'd120;*/

/*
wire vbar1bgn = 12'd0;
wire vbar2bgn = (hdtype) ? ((interlace) ? 12'd315 : 12'd630) : 12'd420;
wire vbar3bgn = (hdtype) ? ((interlace) ? 12'd360 : 12'd720) : 12'd480;
wire vbar4bgn = (hdtype) ? ((interlace) ? 12'd405 : 12'd810) : 12'd540;

wire vbar1bgn2 = 12'd563;
wire vbar2bgn2 = 12'd878;
wire vbar3bgn2 = 12'd923;
wire vbar4bgn2 = 12'd968;

wire hbar1bgn  = 12'd0;
wire hbar2bgn  = (hdtype) ? 12'd 240  : 12'd160;
wire hbar3bgn  = (hdtype) ? 12'd 445  : 12'd297;
wire hbar4bgn  = (hdtype) ? 12'd 651  : 12'd434;
wire hbar5bgn  = (hdtype) ? 12'd 857  : 12'd571;
wire hbar6bgn  = (hdtype) ? 12'd 1063 : 12'd709;
wire hbar7bgn  = (hdtype) ? 12'd 1269 : 12'd846;
wire hbar8bgn  = (hdtype) ? 12'd 1475 : 12'd983;
wire hbar9bgn  = (hdtype) ? 12'd 1680 : 12'd1120;
wire hbar10bgn = (hdtype) ? 12'd 240  : 12'd160;
wire hbar11bgn = (hdtype) ? 12'd 549  : 12'd366;
wire hbar12bgn = (hdtype) ? 12'd 960  : 12'd640;
wire hbar13bgn = (hdtype) ? 12'd 1131 : 12'd754;
wire hbar14bgn = (hdtype) ? 12'd 1200 : 12'd800;
wire hbar15bgn = (hdtype) ? 12'd 1268 : 12'd845;
wire hbar16bgn = (hdtype) ? 12'd 1337 : 12'd891;
wire hbar17bgn = (hdtype) ? 12'd 1405 : 12'd937;*/

/*initial begin
  red   <= 8'b0;
  green <= 8'b0;
  blue  <= 8'b0;
  hpos  <= 0;
  vpos  <= 0;
  hsync <= TRUE;
  vsync <= TRUE;
  de    <= TRUE;
end*/

/////////////////////////////////////
// VIDEO GENERATOR
/////////////////////////////////////

always @(posedge rst or posedge clk) begin
  if (rst) begin
    red   <= 8'b0;
    green <= 8'b0;
    blue  <= 8'b0;
  end
  else begin
    // Active video
    if (hpos <= H_ACTIVE_PIXEL || vpos <= V_ACTIVE_LINE) begin
      red   <= 8'b0;
      green <= 8'b0;
      blue  <= 8'b0;
    end
    else begin
      if (vpos <= V_PART_LINE_1) begin
        red   <= 8'b11111111;
        green <= 8'b11111111;
        blue  <= 8'b0;
      end
      else if (vpos <= V_PART_LINE_2) begin
        red   <= 8'b11111111;
        green <= 8'b11111111;
        blue  <= 8'b11111111;
      end
      else if (vpos <= V_PART_LINE_3) begin
        red   <= 8'b0;
        green <= 8'b11111111;
        blue  <= 8'b11111111;
      end
      else begin
        red   <= 8'b0;
        green <= 8'b0;
        blue  <= 8'b0;
      end
    end
  end
end

/////////////////////////////////////
// TIMINGS
/////////////////////////////////////

always @(posedge rst or posedge clk) begin
  if (rst) begin
    hpos  <= 0;
    vpos  <= 0;
    hsync <= TRUE;
    vsync <= TRUE;
    de    <= TRUE;
  end
  else begin
    // Data enable 
    if (H_ACTIVE_PIXEL < hpos || V_ACTIVE_LINE < vpos) begin
      de    <= FALSE;
    end
    else begin
      de    <= TRUE;
    end
    /*if (hpos == H_ACTIVE_PIXEL || vpos == V_ACTIVE_LINE) begin
      de <= FALSE;
    end
    else if (hpos < H_ACTIVE_PIXEL && vpos < V_ACTIVE_LINE) begin
      de <= TRUE;
    end*/

    // Horizontal sync
    /*if (hpos == H_ACTIVE_PIXEL + H_FPORCH_PIXEL) begin
      hsync <= FALSE;
    end
    if (hpos == H_ACTIVE_PIXEL + H_FPORCH_PIXEL + H_SYNC_PIXEL) begin
      hsync <= TRUE;
    end*/
    if (H_ACTIVE_PIXEL + H_FPORCH_PIXEL < hpos && hpos <= H_ACTIVE_PIXEL + H_FPORCH_PIXEL + H_SYNC_PIXEL) begin
      hsync <= FALSE;
    end
    else begin
      hsync <= TRUE;
    end

    // Vertical sync
    /*if (vpos == V_ACTIVE_LINE + V_FPORCH_LINE) begin
      vsync <= FALSE;
    end
    if (vpos == V_ACTIVE_LINE + V_FPORCH_LINE + V_SYNC_LINE) begin
      vsync <= TRUE;
    end*/

    if (V_ACTIVE_LINE + V_FPORCH_LINE < vpos && vpos <= V_ACTIVE_LINE + V_FPORCH_LINE + V_SYNC_LINE) begin
      vsync <= FALSE;
    end
    else begin
      vsync <= TRUE;
    end


    // Counter
    hpos <= hpos + 1;
    if (hpos + 1 == H_LIMIT_PIXEL) begin
      hpos <= 0;
      vpos <= vpos + 1;
      if (vpos + 1 == V_LIMIT_LINE) begin
        vpos <= 0;
      end
    end
  end
end

endmodule
