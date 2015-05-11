`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:38:39 05/11/2015 
// Design Name: 
// Module Name:    test 
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
module test(
	input wire CLK
);

reg a = 1'b0;
reg b = 1'b0;

always @ (posedge CLK) begin
	a = 1'b1;
	if (a == 1'b1) begin
		a = 1'b0;
		b = 1'b1;
	end
end

endmodule
