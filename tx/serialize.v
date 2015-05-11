`timescale 1ns / 1ps

module serialize #(
  parameter TRUE = 1'b1,
  parameter FALSE = 1'b0
) (
  input  wire       rst,
  input  wire       clk,
  input  wire       clk2,
  input  wire       clk10,
  input  wire       serdesstrobe,
  input  wire [9:0] data,
  output wire       p,
  output wire       n
);

/////////////////////////////////////
// Fabric
/////////////////////////////////////

/*reg       switch    = FALSE;
reg [4:0] half_data = 5'b0;

always @ (posedge rst or posedge clk or negedge clk) begin
  if (rst == TRUE) begin
    switch <= FALSE;
  end
  else begin
    if (switch == FALSE) begin
      half_data <= data[9:5];
    end
    else begin
      half_data <= data[4:0];
    end
    switch <= ~switch;
  end
end*/

/////////////////////////////////////
// Logical / Electrical
/////////////////////////////////////

wire serdes_out;

serdes_n_to_1 #(
  .SF (5)
) serdes (
  .reset        (rst),
  .gclk         (clk2),
  .ioclk        (clk10),
  .datain       (),
  .iob_data_out (serdes_out),
  .serdesstrobe (serdesstrobe)
);

OBUFDS obufds (
  .I  (serdes_out),
  .O  (p),
  .OB (n)
);

endmodule
