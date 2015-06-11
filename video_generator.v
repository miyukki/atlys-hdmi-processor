/*`timescale 1ns / 1ps

module video_generator #(
  parameter TRUE = 1'b1,
  parameter FALSE = 1'b0,

  // Video timings
  // See: http://www.3dexpress.de/displayconfigx/timings.html

  // 720p @ 60fps
  // parameter H_ACTIVE_PIXEL = 1280,
  // parameter H_FPORCH_PIXEL = 72,
  // parameter H_SYNC_PIXEL   = 80,
  // parameter H_BPORCH_PIXEL = 216,
  // parameter H_LIMIT_PIXEL  = H_ACTIVE_PIXEL + H_FPORCH_PIXEL + H_SYNC_PIXEL + H_BPORCH_PIXEL,

  // parameter V_ACTIVE_LINE  = 720,
  // parameter V_FPORCH_LINE  = 3,
  // parameter V_SYNC_LINE    = 5,
  // parameter V_BPORCH_LINE  = ,
  // parameter V_LIMIT_LINE   = V_ACTIVE_LINE + V_FPORCH_LINE + V_SYNC_LINE + V_BPORCH_LINE

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
  // (1920+67+75+205)*(1080+3+5+16)*60/1000000
) (
  input  wire       rst,
  input  wire       clk,
  output wire       hsync,
  output wire       vsync,
  output wire [7:0] blue,
  output wire [7:0] green,
  output wire [7:0] red,
  output wire       de
);

/////////////////////////////////////
// VIDEO GENERATOR
/////////////////////////////////////

reg [11:0] hpos = 12'b0;
reg [10:0] vpos = 11'b0;
reg [11:0] lpos = 12'b0;

reg       hsync_out = TRUE;
reg       vsync_out = TRUE;
reg [7:0] b_out  = 8'b0;
reg [7:0] g_out  = 8'b0;
reg [7:0] r_out  = 8'b0;
reg       de_out = TRUE;

assign hsync = hsync_out;
assign vsync = vsync_out;
assign blue  = b_out;
assign green = g_out;
assign red   = r_out;
assign de    = de_out;

always @(posedge rst or posedge clk or posedge rst) begin
  if (rst == TRUE) begin
    hpos <= 0;
    vpos <= 0;
    hsync_out <= TRUE;
    hsync_out <= TRUE;
    r_out <= 8'b0;
    g_out <= 8'b0;
    b_out <= 8'b0;
    de_out <= TRUE;
  end
  else begin
    // Active video
    if (hpos == H_ACTIVE_PIXEL || vpos == V_ACTIVE_LINE) begin
      r_out <= 8'b0;
      g_out <= 8'b0;
      b_out <= 8'b0;
      de_out <= FALSE;
    end
    else if (hpos < H_ACTIVE_PIXEL && vpos < V_ACTIVE_LINE) begin
      if (hpos == lpos) begin
        r_out <= 8'b11111111;
        g_out <= 8'b11111111;
        b_out <= 8'b11111111;
      end
      else begin
        r_out <= 8'b11111111;
        g_out <= 8'b0;
        b_out <= 8'b0;
      end
      de_out <= TRUE;
    end

    // Horizontal sync
    if (hpos == H_ACTIVE_PIXEL + H_FPORCH_PIXEL) begin
      hsync_out <= FALSE;
    end
    if (hpos == H_ACTIVE_PIXEL + H_FPORCH_PIXEL + H_SYNC_PIXEL) begin
      hsync_out <= TRUE;
    end

    // Vertical sync
    if (vpos == V_ACTIVE_LINE + V_FPORCH_LINE) begin
      vsync_out <= FALSE;
    end
    if (vpos == V_ACTIVE_LINE + V_FPORCH_LINE + V_SYNC_LINE) begin
      vsync_out <= TRUE;
    end

    // Counter
    hpos <= hpos + 1;
    if (hpos == H_LIMIT_PIXEL + 1) begin
      hpos <= 0;
      vpos <= vpos + 1;
      if (vpos == V_LIMIT_LINE + 1) begin
        vpos <= 0;
        lpos <= lpos + 1;
        if (lpos == H_ACTIVE_PIXEL + 1) begin
          lpos <= 0;
        end
      end
    end
  end
end

endmodule*/

module video_generator #(
  parameter TRUE = 1'b1,
  parameter FALSE = 1'b0,

  // 1080p @ 60fps
  parameter H_ACTIVE_PIXEL = 12'd1920,
  parameter H_FPORCH_PIXEL = 12'd88,
  parameter H_SYNC_PIXEL   = 12'd44,
  parameter H_BPORCH_PIXEL = 12'd148,
  parameter H_LIMIT_PIXEL  = H_ACTIVE_PIXEL + H_FPORCH_PIXEL + H_SYNC_PIXEL + H_BPORCH_PIXEL,

  parameter V_ACTIVE_LINE  = 11'd1080,
  parameter V_FPORCH_LINE  = 11'd4,
  parameter V_SYNC_LINE    = 11'd5,
  parameter V_BPORCH_LINE  = 11'd36,
  parameter V_LIMIT_LINE   = V_ACTIVE_LINE + V_FPORCH_LINE + V_SYNC_LINE + V_BPORCH_LINE
) (
  input  wire       rst,
  input  wire       clk,
  output reg        hsync,
  output reg        vsync,
  output reg        de,
  output reg  [7:0] blue  = 8'b0,
  output reg  [7:0] green = 8'b0,
  output reg  [7:0] red   = 8'b0
);

reg [11:0] lpos = 12'b0;
reg [11:0] hpos = 12'd0;
reg [10:0] vpos = 11'd0;

/////////////////////////////////////
// TIMINGS
/////////////////////////////////////

always @(posedge rst or negedge clk) begin
  if (rst) begin
    hpos  <= 0;
    vpos  <= 0;
  end
  else begin
    // Counter
    hpos <= hpos + 1;
    if (hpos + 1 == H_LIMIT_PIXEL) begin
      hpos <= 0;
      vpos <= vpos + 1;
      if (vpos + 1 == V_LIMIT_LINE) begin
        vpos <= 0;
        lpos <= lpos + 1;
        if (lpos + 1 == H_ACTIVE_PIXEL) begin
          lpos <= 0;
        end
      end
    end
  end
end

/////////////////////////////////////
// SYNC GENERATOR
/////////////////////////////////////

always @(posedge rst or posedge clk) begin
  if (rst) begin
    hsync <= FALSE;
    vsync <= FALSE;
    de    <= FALSE;
  end
  else begin
    hsync <= hpos < H_ACTIVE_PIXEL + H_FPORCH_PIXEL || H_ACTIVE_PIXEL + H_FPORCH_PIXEL + H_SYNC_PIXEL <= hpos;
    vsync <= vpos < V_ACTIVE_LINE  + V_FPORCH_LINE  || V_ACTIVE_LINE  + V_FPORCH_LINE  + V_SYNC_LINE  <= vpos;
    de    <= hpos < H_ACTIVE_PIXEL && vpos < V_ACTIVE_LINE;
  end
end

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
    if (hpos < H_ACTIVE_PIXEL && vpos < V_ACTIVE_LINE) begin
      if (hpos == lpos) begin
        red   <= 8'b11111111;
        green <= 8'b11111111;
        blue  <= 8'b11111111;
      end
      else begin
        red   <= 8'b11111111;
        green <= 8'b0;
        blue  <= 8'b0;
      end
    end
    else begin
      red   <= 8'b0;
      green <= 8'b0;
      blue  <= 8'b0;
    end
  end
end

endmodule
