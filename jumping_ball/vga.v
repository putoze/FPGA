module VGA( 
    input rst_n,
    input clk,    //100MHz
    input btn_l, //left  bottom
    input btn_r, //right bottom
    output reg VGA_HS,    //Horizontal synchronize signal
    output reg VGA_VS,    //Vertical synchronize signal
    output [3:0] VGA_R,    //Signal RED
    output [3:0] VGA_G,    //Signal Green
    output [3:0] VGA_B     //Signal Blue
);

//================================================================
//   PARAMETER
//================================================================

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

//================================================================
//   REG/WIRE
//================================================================

reg [9:0]  pos_X;     //from 1~640
reg [8:0]  pos_Y;     //from 1~480
reg [11:0] VGA_RGB_w; //VGA_RGB[11:8] red, VGA_RGB[7:4] green, VGA_RGB[3:0] blue
reg [9:0]  H_cnt,V_cnt; //Horizontal counter, Vertical counter

//================================================================
//   d_clk
//================================================================
wire d_clk = counter[24];
wire clk_25 = counter[1];    //25MHz clk
reg [24:0] counter;

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
        counter <= 'd0;
    end 
    else begin
        counter <= counter + 'd1;
    end
end

//================================================================
//   OUTPUT
//================================================================
assign VGA_R = VGA_RGB_w[11:8];
assign VGA_G = VGA_RGB_w[7:4];
assign VGA_B = VGA_RGB_w[3:0];

//VGA_HS
always @(posedge clk_25 or negedge rst_n) begin 
    if(!rst_n) begin
        VGA_HS <= 1;
    end 
    else if(H_cnt < H_SYNC)begin //Sync pulse start
        VGA_HS <= 0;  //horizontal synchronize pulse
    end
    else begin
        VGA_HS <= 1;
    end
end

//VGA_VS
always@(posedge VGA_HS or negedge rst_n)begin
    if(!rst_n) begin
        VGA_VS <= 1;
    end
    else if(V_cnt <= V_SYNC) begin //Sync pulse start
        VGA_VS <= 0;
    end
    else begin
        VGA_VS <= 1;
    end
end

//================================================================
//   VGA
//================================================================

//Horizontal counter
always@(posedge clk_25 or negedge rst_n) begin    //count 0~800
    if (!rst_n) begin
        H_cnt <= H_TOTAL;
    end
    else if(H_cnt >= H_TOTAL) begin
        H_cnt <= 'd0;
    end
    else begin
        H_cnt <= H_cnt + 'd1;
    end
end

//Vertical counter
always@(posedge VGA_HS or negedge rst_n) begin    //count 0~525
    if (!rst_n) begin
        V_cnt <= V_TOTAL;
    end
    else if(V_cnt >= V_TOTAL) begin
        V_cnt <= 'd0;
    end
    else begin
        V_cnt <= V_cnt + 'd1;
    end
end

//pos_X
always @(posedge clk_25 or negedge rst_n) begin 
    if(!rst_n) begin
        pos_X <= 'd0;
    end 
    else if((H_cnt >= H_SYNC + H_BACK) && (H_cnt <= H_TOTAL - H_FRONT))begin
        pos_X <= pos_X + 'd1;
    end
    else begin
        pos_X <= 'd0;
    end
end

//pos_Y
always@(posedge VGA_HS or negedge rst_n)begin
    if(!rst_n) begin
        pos_Y <= 'd0;
    end
    else if((V_cnt >= V_SYNC + V_BACK) && (V_cnt <= V_TOTAL - V_FRONT)) begin
        pos_Y <= pos_Y + 'd1;
    end
    else begin
        pos_Y <= 'd0;
    end
end


//VGA_RGB_w
always@(*) begin

end

//================================================================
//   Design
//================================================================


endmodule 