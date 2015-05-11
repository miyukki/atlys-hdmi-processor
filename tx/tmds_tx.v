`timescale 1ns / 1ps

module tmds_tx (
  input  wire       rst,
  input  wire       clk,
  input  wire       hsync,
  input  wire       vsync,
  input  wire [7:0] blue,
  input  wire [7:0] green,
  input  wire [7:0] red,
  input  wire       de,

  output wire tmdsclk_p,
  output wire tmdsclk_n,
  output wire blue_p,
  output wire blue_n,
  output wire green_p,
  output wire green_n,
  output wire red_p,
  output wire red_n,
  output wire [3:0] LED
);

wire clk2, clk10, serdesstrobe;

wire [29:0] f_datain = {
  red_data[9:5], green_data[9:5], blue_data[9:5],
  red_data[4:0], green_data[4:0], blue_data[4:0]
};
wire [14:0] f_dataout;

convert_30to15_fifo converter (
  .rst     (rst),
  .clk     (clk),
  .clkx2   (clk2),
  .datain  (f_datain),
  .dataout (f_dataout)
);

/////////////////////////////////////
// CLOCK GENERATOR (clk*2, clk*10)
/////////////////////////////////////

wire clkfbout, pllclk0, pllclk1, pllclk2, pll_lckd, bufpll_lock;

// BUFG pclkbufg (
//  .I(pllclk1),
//  .O(pclk)
// );

BUFG pclkx2bufg (
  .I (pllclk2),
  .O (clk2)
);

PLL_BASE #(
  .CLKIN_PERIOD   (13),
  .CLKFBOUT_MULT  (10),
  .CLKOUT0_DIVIDE (1),
  .CLKOUT1_DIVIDE (10),
  .CLKOUT2_DIVIDE (5),
  .COMPENSATION   ("INTERNAL")
) pll_base_oserdes (
  .CLKFBOUT       (clkfbout),
  .CLKOUT0        (pllclk0),
  .CLKOUT1        (pllclk1),
  .CLKOUT2        (pllclk2),
  .CLKOUT3        (),
  .CLKOUT4        (),
  .CLKOUT5        (),
  .LOCKED         (pll_lckd),
  .CLKFBIN        (clkfbout),
  .CLKIN          (clk),
  .RST            (rst)
);

BUFPLL #(
  .DIVIDE       (5)
) ioclk_buf (
  .PLLIN        (pllclk0),
  .GCLK         (clk2),
  .LOCKED       (pll_lckd),
  .IOCLK        (clk10),
  .SERDESSTROBE (serdesstrobe),
  .LOCK         (bufpll_lock)
);

/////////////////////////////////////
// CLOCK
/////////////////////////////////////

reg [4:0] tmdsclkint = 5'b00000;
reg       clk_toggle = 1'b0;
wire      clk_serdes;

always @ (posedge clk2 or posedge rst) begin
  if (rst)
    clk_toggle <= 1'b0;
  else
    clk_toggle <= ~clk_toggle;
end

always @ (posedge clk2) begin
  if (clk_toggle)
    tmdsclkint <= 5'b11111;
  else
    tmdsclkint <= 5'b00000;
end

serdes_n_to_1 #(
  .SF (5)
) serdes_clk (
  .reset        (rst),
  .gclk         (clk2),
  .ioclk        (clk10),
  .datain       (tmdsclkint),
  .iob_data_out (clk_serdes),
  .serdesstrobe (serdesstrobe)
);

OBUFDS obufds_clk (
  .I  (clk_serdes),
  .O  (tmdsclk_p),
  .OB (tmdsclk_n)
);

/*wire clk_out;*/
/*serialize serialize_clk (
  .rst          (rst),
  .clk          (clk),
  .clk2         (clk2),
  .clk10        (clk10),
  .serdesstrobe (serdesstrobe),
  .data         (clk_data),
  .p            (tmdsclk_p),
  .n            (tmdsclk_n)
);*/

/////////////////////////////////////
// BLUE
/////////////////////////////////////

wire [9:0] blue_data;
wire       blue_serdes;
/*assign f_datain[9:0] = blue_data;*/

encode encode_b (
  .rstin (rst),
  .clkin (clk),
  .din   (blue),
  .c0    (hsync),
  .c1    (vsync),
  .de    (de),
  .dout  (blue_data)
);

serdes_n_to_1 #(
  .SF (5)
) serdes_b (
  .reset        (rst),
  .gclk         (clk2),
  .ioclk        (clk10),
  .datain       (f_dataout[4:0]),
  .iob_data_out (blue_serdes),
  .serdesstrobe (serdesstrobe)
);

OBUFDS obufds_b (
  .I  (blue_serdes),
  .O  (blue_p),
  .OB (blue_n)
);

/*serialize serialize_b (
  .rst          (rst),
  .clk          (clk),
  .clk2         (clk2),
  .clk10        (clk10),
  .serdesstrobe (serdesstrobe),
  .data         (blue_data),
  .p            (blue_p),
  .n            (blue_n)
);*/

/////////////////////////////////////
// GREEN
/////////////////////////////////////

wire [9:0] green_data;
wire       green_serdes;
/*assign f_datain[19:10] = green_data;*/

encode encode_g (
  .rstin (rst),
  .clkin (clk),
  .din   (green),
  .c0    (FALSE),
  .c1    (FALSE),
  .de    (de),
  .dout  (green_data)
);

serdes_n_to_1 #(
  .SF (5)
) serdes_g (
  .reset        (rst),
  .gclk         (clk2),
  .ioclk        (clk10),
  .datain       (f_dataout[9:5]),
  .iob_data_out (green_serdes),
  .serdesstrobe (serdesstrobe)
);

OBUFDS obufds_g (
  .I  (green_serdes),
  .O  (green_p),
  .OB (green_n)
);

/*serialize serialize_g (
  .rst          (rst),
  .clk          (clk),
  .clk2         (clk2),
  .clk10        (clk10),
  .serdesstrobe (serdesstrobe),
  .data         (green_data),
  .p            (green_p),
  .n            (green_n)
);*/

/////////////////////////////////////
// RED
/////////////////////////////////////

wire [9:0] red_data;
wire       red_serdes;
/*assign f_datain[29:20] = red_data;*/

encode encode_r (
  .rstin (rst),
  .clkin (clk),
  .din   (red),
  .c0    (FALSE),
  .c1    (FALSE),
  .de    (de),
  .dout  (red_data)
);

serdes_n_to_1 #(
  .SF (5)
) serdes_r (
  .reset        (rst),
  .gclk         (clk2),
  .ioclk        (clk10),
  .datain       (f_dataout[14:10]),
  .iob_data_out (red_serdes),
  .serdesstrobe (serdesstrobe)
);

OBUFDS obufds_r (
  .I  (red_serdes),
  .O  (red_p),
  .OB (red_n)
);

/*serialize serialize_r (
  .rst          (rst),
  .clk          (clk),
  .clk2         (clk2),
  .clk10        (clk10),
  .serdesstrobe (serdesstrobe),
  .data         (red_data),
  .p            (red_p),
  .n            (red_n)
);*/

/////////////////////////////////////
// DEBUG
/////////////////////////////////////

assign LED = { bufpll_lock, rst, hsync, vsync };

endmodule
