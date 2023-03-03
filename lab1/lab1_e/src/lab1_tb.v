`timescale 1ps / 1ps
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

module flash_led_top_tb;

reg clk = 0;
reg rst_n, btn_c;
wire [15:0] led;

flash_led_top flash_led_top(
.clk(clk),
.rst_n(rst_n),
.btn_c(btn_c),
.led(led)
);

//====== Signal ======
//division counter
reg [24:0] count = 'd0;
wire d_clk;

//====== frequency division ======
always@(posedge clk) begin
    count <= count + 1;
end

assign d_clk = count[23];

initial begin
    rst_n = 1'b1;
    btn_c = 1'b0;
    @(negedge d_clk); rst_n = 1'b0;
    @(negedge d_clk); rst_n = 1'b1;
    @(negedge d_clk); btn_c = 1'b1;
    repeat(2)@(negedge d_clk); btn_c = 1'b0;
    repeat(20)@(negedge d_clk);
    $finish;
end

always #5 clk <= ~clk;

endmodule 