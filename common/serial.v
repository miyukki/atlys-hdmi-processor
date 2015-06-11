module serial #(
  parameter TRUE  = 1'b1,
  parameter FALSE = 1'b0,
  parameter RATE  = 14'd9600
) (
  input  wire rst,
  input  wire clk,
  input  wire rx,
  output reg  tx
);

endmodule
