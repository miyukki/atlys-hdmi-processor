`timescale 1ns / 1ps

module test(
	input wire CLK
);

parameter AA = 5/3;

reg a = 1'b0;
reg b = 1'b0;
reg c = 1'b0;

always @ (posedge CLK) begin
	if (a) begin
		c <= 1'b1;
	end
end

always @ (posedge CLK) begin
	a = 1'b1;
	/*if (!a) begin*/
		/*a <= 1'b0;*/
	/*end*/
end

endmodule
