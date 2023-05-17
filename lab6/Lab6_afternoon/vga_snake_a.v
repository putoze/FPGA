module VGA( 
    input rst_n,
    input clk,    //100MHz
    input btn_t,
    input btn_d,
    input btn_l,
    input btn_r,
    output VGA_HS,    //Horizontal synchronize signal
    output VGA_VS,    //Vertical synchronize signal
    output [3:0] VGA_R,    //Signal RED
    output [3:0] VGA_G,    //Signal Green
    output [3:0] VGA_B     //Signal Blue
);

//Horizontal Parameter
parameter H_FRONT = 16;
parameter H_SYNC  = 96;
parameter H_BACK  = 48;
parameter H_ACT   = 640;
parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

//Vertical Parameter
parameter V_FRONT = 10;
parameter V_SYNC  = 2;
parameter V_BACK  = 33;
parameter V_ACT   = 480;
parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;

wire d_clk;
wire clk_25;    //25MHz clk
reg [24:0] count;

reg [9:0] H_cnt;
reg [9:0] V_cnt;
reg vga_hs;    //register for horizontal synchronize signal
reg vga_vs;    //register for vertical synchronize signal
reg [9:0] X;    //from 1~640
reg [8:0] Y;    //from 1~480

assign VGA_HS = vga_hs;
assign VGA_VS = vga_vs;

reg [11:0] VGA_RGB;

assign VGA_R = VGA_RGB[11:8];
assign VGA_G = VGA_RGB[7:4];
assign VGA_B = VGA_RGB[3:0];

//100MHz -> 25MHz
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        count <= 0;
    else
        count <= count + 1;
end
assign clk_25 = count[1];
assign d_clk = count[24];

//Horizontal counter
always@(posedge clk_25 or negedge rst_n) begin    //count 0~800
    H_cnt <= (!rst_n) ? H_TOTAL : ( (H_cnt < H_TOTAL) ? (H_cnt+1'b1) : 10'd0 );
end

//Vertical counter
always@(posedge VGA_HS or negedge rst_n) begin    //count 0~525
    V_cnt <= (!rst_n) ? V_TOTAL : ( (V_cnt < V_TOTAL) ? (V_cnt+1'b1) : 10'd0 );
end

//Horizontal Generator: Refer to the pixel clock
always@(posedge clk_25 or negedge rst_n) begin
    if() begin
        vga_hs <= 1;
        X      <= 0;
    end
    else begin
        //Horizontal Sync
        if()    //Sync pulse start
            vga_hs <= 1'b0;    //horizontal synchronize pulse
        else
            vga_hs <= 1'b1;
        //Current X
        if()
            X <= X + 1;
        else
            X <= 0;
    end
end

//Vertical Generator: Refer to the horizontal sync
always@(posedge VGA_HS or negedge rst_n)begin
    if() begin
        vga_vs <= 1;
        Y      <= 0;
    end
    else begin
        //Vertical Sync
        if()    //Sync pulse start
            vga_vs <= 0;
        else
            vga_vs <= 1;
        //Current Y
        if()
            Y <= Y + 1;
        else
            Y <= 0;
    end
end

///************************************///
///                                    ///
///                                    ///
///                                    ///
///       Write your code here         ///
///                                    ///
///                                    ///
///                                    ///
///************************************///

endmodule 