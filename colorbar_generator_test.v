`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:37:48 05/14/2015
// Design Name:   colorbar_generator
// Module Name:   /media/psf/Home/Develop/atlys-hdmi-processor/colorbar_generator_test.v
// Project Name:  atlys-hdmi-processor
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: colorbar_generator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module colorbar_generator_test;

	// Inputs
	reg rst;
	reg clk;

	// Outputs
	wire hsync;
	wire vsync;
	wire de;
	wire [7:0] blue;
	wire [7:0] green;
	wire [7:0] red;

	// Instantiate the Unit Under Test (UUT)
	colorbar_generator uut (
		.rst(rst), 
		.clk(clk), 
		.hsync(hsync), 
		.vsync(vsync), 
		.de(de), 
		.blue(blue), 
		.green(green), 
		.red(red)
	);

	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

