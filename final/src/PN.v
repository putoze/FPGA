// 2023 FPGA
// FIANL : Polish Notation(PN)
//
// -----------------------------------------------------------------------------
// ©Communication IC & Signal Processing Lab 716
// -----------------------------------------------------------------------------
// Author : HSUAN-YU LIN
// File   : PN.v
// Create : 2023-02-27 13:19:54
// Revise : 2023-02-27 13:19:54
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
module PN(
	input clk,
	input rst_n,
	input [1:0] mode,
	input operator,
	input [2:0] in,
	input in_valid,
	output out_valid,
	output signed [31:0] out
    );
	
//================================================================
//   PARAMETER/INTEGER
//================================================================

//integer
integer i;

//================================================================
//   REG/WIRE
//================================================================

//================================================================
//   Design
//================================================================



endmodule