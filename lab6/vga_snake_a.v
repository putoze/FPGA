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

reg [9:0] snake_x [0:4];
reg [8:0] snake_y [0:4];

reg [3:0] rand_num0, rand_num1;
reg [9:0] rand_x;
reg [8:0] rand_y;
reg [9:0] match;

reg [3:0] snake_cs, snake_ns;
reg [1:0] dir_cs, dir_ns;

parameter UP = 0;
parameter DOWN = 1;
parameter LEFT = 2;
parameter RIGHT = 3;

parameter dist = 40;
parameter range = 20;

parameter IDLE = 0;
parameter S2 = 1;
parameter S21 = 2;
parameter S3 = 3;
parameter S31 = 4;
parameter S4 = 5;
parameter S41 = 6;
parameter S5 = 7;
parameter S51 = 8;

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
    if(!rst_n) begin
        vga_hs <= 1;
        X      <= 0;
    end
    else begin
        //Horizontal Sync
        if(H_cnt<=H_SYNC)    //Sync pulse start
            vga_hs <= 1'b0;    //horizontal synchronize pulse
        else
            vga_hs <= 1'b1;
        //Current X
        if( (H_cnt>=H_SYNC+H_BACK) && (H_cnt<=H_TOTAL-H_FRONT) )
            X <= X + 1;
        else
            X <= 0;
    end
end

//Vertical Generator: Refer to the horizontal sync
always@(posedge VGA_HS or negedge rst_n)begin
    if(!rst_n) begin
        vga_vs <= 1;
        Y      <= 0;
    end
    else begin
        //Vertical Sync
        if(V_cnt<=V_SYNC)    //Sync pulse start
            vga_vs <= 0;
        else
            vga_vs <= 1;
        //Current Y
        if( (V_cnt>=V_SYNC+V_BACK) && (V_cnt<=V_TOTAL-V_FRONT) )
            Y <= Y + 1;
        else
            Y <= 0;
    end
end

//snake_cs
always@(posedge d_clk or negedge rst_n) begin
    if(!rst_n) begin
        snake_cs <= 0;
    end
    else begin
        snake_cs <= snake_ns;
    end
end

always@(*) begin
    case(snake_cs)
    IDLE : snake_ns = S2;
    S2 : snake_ns = (snake_x[0]==rand_x && snake_y[0]==rand_y) ? S21 : S2;
    S21 : snake_ns = S3;
    S3 : snake_ns = (snake_x[0]==rand_x && snake_y[0]==rand_y) ? S31 : S3;
    S31 : snake_ns = S4;
    S4 : snake_ns = (snake_x[0]==rand_x && snake_y[0]==rand_y) ? S41 : S4;
    S41 : snake_ns = S5;
    S5 : snake_ns = (snake_x[0]==rand_x && snake_y[0]==rand_y) ? S51 : S5;
    S51 : snake_ns = S5;
    default : snake_ns = IDLE;
    endcase
end

//dir_cs
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dir_cs <= 0;
    end
    else begin
        dir_cs <= dir_ns;
    end
end

always@(*) begin
    case(dir_cs)
    UP : begin
        if(btn_l)
            dir_ns = LEFT;
        else if(btn_r)
            dir_ns = RIGHT;
        else
            dir_ns = UP;
    end
    DOWN : begin
        if(btn_l)
            dir_ns = LEFT;
        else if(btn_r)
            dir_ns = RIGHT;
        else
            dir_ns = DOWN;
    end
    LEFT : begin
        if(btn_t)
            dir_ns = UP;
        else if(btn_d)
            dir_ns = DOWN;
        else
            dir_ns = LEFT;
    end
    RIGHT : begin
        if(btn_t)
            dir_ns = UP;
        else if(btn_d)
            dir_ns = DOWN;
        else
            dir_ns = RIGHT;
    end
    default: begin
        dir_ns = UP;
    end
    endcase
end

//snake move
always @ (posedge d_clk or negedge rst_n) begin
    if(!rst_n) begin
        snake_x[0] <= 340;
        snake_y[0] <= 260;
        snake_x[1] <= 340;
        snake_y[1] <= 300;
        snake_x[2] <= 340;
        snake_y[2] <= 340;
        snake_x[3] <= 340;
        snake_y[3] <= 380;
        snake_x[4] <= 340;
        snake_y[4] <= 420;
    end
    else begin
        case(dir_cs)
        UP : begin
            if(snake_y[0] == range) begin
                snake_x[0] <= snake_x[0];
                snake_y[0] <= V_ACT-range;
                snake_x[1] <= snake_x[0];
                snake_y[1] <= snake_y[0];
                snake_x[2] <= snake_x[1];
                snake_y[2] <= snake_y[1];
                snake_x[3] <= snake_x[2];
                snake_y[3] <= snake_y[2];
                snake_x[4] <= snake_x[3];
                snake_y[4] <= snake_y[3];
            end
            else begin
                snake_x[0] <= snake_x[0];
                snake_y[0] <= snake_y[0]-dist;
                snake_x[1] <= snake_x[0];
                snake_y[1] <= snake_y[0];
                snake_x[2] <= snake_x[1];
                snake_y[2] <= snake_y[1];
                snake_x[3] <= snake_x[2];
                snake_y[3] <= snake_y[2];
                snake_x[4] <= snake_x[3];
                snake_y[4] <= snake_y[3];
            end
        end
        DOWN : begin
            if(snake_y[0] == V_ACT-range) begin
                snake_x[0] <= snake_x[0];
                snake_y[0] <= range;
                snake_x[1] <= snake_x[0];
                snake_y[1] <= snake_y[0];
                snake_x[2] <= snake_x[1];
                snake_y[2] <= snake_y[1];
                snake_x[3] <= snake_x[2];
                snake_y[3] <= snake_y[2];
                snake_x[4] <= snake_x[3];
                snake_y[4] <= snake_y[3];
            end
            else begin
                snake_x[0] <= snake_x[0];
                snake_y[0] <= snake_y[0]+dist;
                snake_x[1] <= snake_x[0];
                snake_y[1] <= snake_y[0];
                snake_x[2] <= snake_x[1];
                snake_y[2] <= snake_y[1];
                snake_x[3] <= snake_x[2];
                snake_y[3] <= snake_y[2];
                snake_x[4] <= snake_x[3];
                snake_y[4] <= snake_y[3];
            end
        end
        LEFT :
            if(snake_x[0] == range) begin
                snake_x[0] <= H_ACT-range;
                snake_y[0] <= snake_y[0];
                snake_x[1] <= snake_x[0];
                snake_y[1] <= snake_y[0];
                snake_x[2] <= snake_x[1];
                snake_y[2] <= snake_y[1];
                snake_x[3] <= snake_x[2];
                snake_y[3] <= snake_y[2];
                snake_x[4] <= snake_x[3];
                snake_y[4] <= snake_y[3];
            end
            else begin
                snake_x[0] <= snake_x[0]-dist;
                snake_y[0] <= snake_y[0];
                snake_x[1] <= snake_x[0];
                snake_y[1] <= snake_y[0];
                snake_x[2] <= snake_x[1];
                snake_y[2] <= snake_y[1];
                snake_x[3] <= snake_x[2];
                snake_y[3] <= snake_y[2];
                snake_x[4] <= snake_x[3];
                snake_y[4] <= snake_y[3];
            end
        RIGHT :
            if(snake_x[0] == H_ACT-range) begin
                snake_x[0] <= range;
                snake_y[0] <= snake_y[0];
                snake_x[1] <= snake_x[0];
                snake_y[1] <= snake_y[0];
                snake_x[2] <= snake_x[1];
                snake_y[2] <= snake_y[1];
                snake_x[3] <= snake_x[2];
                snake_y[3] <= snake_y[2];
                snake_x[4] <= snake_x[3];
                snake_y[4] <= snake_y[3];
            end
            else begin
                snake_x[0] <= snake_x[0]+dist;
                snake_y[0] <= snake_y[0];
                snake_x[1] <= snake_x[0];
                snake_y[1] <= snake_y[0];
                snake_x[2] <= snake_x[1];
                snake_y[2] <= snake_y[1];
                snake_x[3] <= snake_x[2];
                snake_y[3] <= snake_y[2];
                snake_x[4] <= snake_x[3];
                snake_y[4] <= snake_y[3];
            end
        endcase
    end
end

//random0
always@(posedge VGA_HS or negedge rst_n) begin
    if(!rst_n) begin
        rand_num0 <= 2;
    end
    else begin
        rand_num0[0] <= rand_num0[3];
        rand_num0[1] <= rand_num0[2]^rand_num1[2];
        rand_num0[2] <= rand_num0[1];
        rand_num0[3] <= rand_num0[0]^rand_num1[3];
    end
end

//random1
always@(posedge VGA_HS or negedge rst_n) begin
    if(!rst_n) begin
        rand_num1 <= 6;
    end
    else begin
        rand_num1[0] <= rand_num1[3]^rand_num1[1];
        rand_num1[1] <= rand_num1[2];
        rand_num1[2] <= rand_num1[1]^rand_num0[2];
        rand_num1[3] <= rand_num1[0];
    end
end

//random x y
always@(posedge d_clk or negedge rst_n) begin
    if(!rst_n) begin
        rand_x <= (rand_num1>16) ? ( (rand_num1-16)*dist + range ) : ( rand_num1*dist + range );
        rand_y <= (rand_num0>12) ? ( (rand_num0-12)*dist + range ) : ( rand_num0*dist + range );
    end
    else begin
        if(snake_cs==S2 || snake_cs==S3 || snake_cs==S4 || snake_cs==S5) begin
            rand_x <= rand_x;
            rand_y <= rand_y;
        end
        else if(snake_cs==S21 || snake_cs==S31 || snake_cs==S41 || snake_cs==S51) begin
            rand_x <= (rand_num0>16) ? ( (rand_num0-16)*dist + range ) : ( rand_num0*dist + range );
            rand_y <= (rand_num1>12) ? ( (rand_num1-12)*dist + range ) : ( rand_num1*dist + range );
        end
    end
end

//Pattern
always@(*) begin
    if( (X > snake_x[0]-range) && (X < snake_x[0]+range) && (Y > snake_y[0]-range) && (Y < snake_y[0]+range) )
        VGA_RGB = 12'hfff;
    else if( (X > snake_x[1]-range) && (X < snake_x[1]+range) && (Y > snake_y[1]-range) && (Y < snake_y[1]+range) )
        VGA_RGB = 12'hfff;
    else if( (X > snake_x[2]-range) && (X < snake_x[2]+range) && (Y > snake_y[2]-range) && (Y < snake_y[2]+range) )
        VGA_RGB = (snake_cs<S5) ? 12'hfff : 12'h000;
    else if( (X > snake_x[3]-range) && (X < snake_x[3]+range) && (Y > snake_y[3]-range) && (Y < snake_y[3]+range) )
        VGA_RGB = (snake_cs<S4) ? 12'hfff : 12'h000;
    else if( (X > snake_x[4]-range) && (X < snake_x[4]+range) && (Y > snake_y[4]-range) && (Y < snake_y[4]+range) )
        VGA_RGB = (snake_cs<S3) ? 12'hfff : 12'h000;
    else if( (X > rand_x-10) && (X < rand_x+10) && (Y > rand_y-10) && (Y < rand_y+10) )
        VGA_RGB = 12'hf00;
    else
        VGA_RGB = 12'h000;
end

endmodule 