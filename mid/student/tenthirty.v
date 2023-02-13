module tenthirty(
    input clk,
    input rst_n, //negedge reset
    input btn_m, //bottom middle
    input btn_r, //bottom right
    output reg [7:0] seg7_sel,
    output reg [7:0] seg7,   //segment right
    output reg [7:0] seg7_l, //segment left
    output reg [2:0] led // led[0] : player win, led[1] : dealer win, led[2] : done
);

//================================================================
//   PARAMETER
//================================================================

/*
Please write your FSM parameter here.
*/

//================================================================
//   d_clk
//================================================================
//frequency division
reg [24:0] counter; 
wire dis_clk; //seg display clk, frequency faster than d_clk
wire d_clk  ; //division clk

//====== frequency division ======
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter <= 0;
    end
    else begin
        counter <= counter + 1;
    end
end

//================================================================
//   REG/WIRE
//================================================================
//store segment display situation
reg [7:0] seg7_temp[0:7]; 
//display counter
reg [2:0] dis_cnt;
//LUT IO
reg  pip;
wire [3:0] number;

//================================================================
//   FSM
//================================================================

/*
Please write your FSM design here.
*/

//================================================================
//   DESIGN
//================================================================


//seg7_temp
/*
Please write your segment display format here.
*/

/*
For example, seg7_temp[0] is used for the rightmost segment display.
*/

//================================================================
//   LED
//================================================================

/*
Please write your led design here.
*/

//#################### Don't revise the code below ############################## 

//================================================================
//   SEGMENT
//================================================================

//display counter 
always@(posedge dis_clk or negedge rst_n) begin
    if(!rst_n) begin
        dis_cnt <= 0;
    end
    else begin
        dis_cnt <= (dis_cnt >= 7) ? 0 : (dis_cnt + 1);
    end
end

always @(posedge dis_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg7 <= 8'b0000_0001;
    end 
    else begin
        if(!dis_cnt[2]) begin
            seg7 <= seg7_temp[dis_cnt];
        end
    end
end

always @(posedge dis_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg7_l <= 8'b0000_0001;
    end 
    else begin
        if(dis_cnt[2]) begin
            seg7_l <= seg7_temp[dis_cnt];
        end
    end
end

always@(posedge dis_clk or negedge rst_n) begin
    if(!rst_n) begin
        seg7_sel <= 8'b11111111;
    end
    else begin
        case(dis_cnt)
            0 : seg7_sel <= 8'b00000001;
            1 : seg7_sel <= 8'b00000010;
            2 : seg7_sel <= 8'b00000100;
            3 : seg7_sel <= 8'b00001000;
            4 : seg7_sel <= 8'b00010000;
            5 : seg7_sel <= 8'b00100000;
            6 : seg7_sel <= 8'b01000000;
            7 : seg7_sel <= 8'b10000000;
            default : seg7_sel <= 8'b11111111;
        endcase
    end
end

//================================================================
//   LUT
//================================================================
 
LUT inst_LUT (.clk(d_clk), .rst_n(rst_n), .pip(pip), .number(number));


endmodule 