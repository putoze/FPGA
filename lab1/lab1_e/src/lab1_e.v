`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NCHU EE Lab716
// Engineer:
//
// Module Name: flash_led_top
// Project Name:
// Target Devices:
// Versions: 1.0
// Tool Versions: Vivado 2018.2
//////////////////////////////////////////////////////////////////////////////////

//====== module ======
module flash_led_top(
    input clk,
    input rst_n,
    input btn_c,
    output reg [15:0] led
);

//====== frequency division ======
reg [24:0] count;
wire d_clk;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        count <= 0;
    else
        count <= count + 1;
end

//====== write your own code below ======

assign d_clk = ;

//====== LED light control ======
always@(posedge d_clk or negedge rst_n) begin
    
end

endmodule 



