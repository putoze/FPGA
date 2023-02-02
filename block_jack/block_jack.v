module block_jack(
    input clk,
    input rst_n,
    input sw,
    input btn_m, //bottom middle
    input btn_r, //bottom right
    output reg [7:0] seg7_sel, // sw:0 [3:0], sw:1 [7:4]
    output reg [7:0] seg7
);

localparam IDLE             = 4'd0;
localparam PREPARE          = 4'd1;
localparam CHECK_BLACK_JACK = 4'd2;
localparam WAIT_CARD        = 4'd3;
localparam CHECK_1          = 4'd4;
localparam CHECK_2          = 4'd5;
localparam CHECK_3          = 4'd6;
localparam COMPARE          = 4'd7;
localparam DONE             = 4'd8;

reg [3:0]  curr_state,next_state;
reg [24:0] counter; //frequency division
reg [3:0]  global_counter;

//seg7_temp
reg [7:0] seg7_temp[0:3];
reg [1:0] dis_cnt;

//mem
reg [5:0] player_poker[0:4];
reg [5:0] dealer_poker[0:4];
reg [4:0] seg_acc,dealer_acc;
reg [2:0] player_pointer,dealer_pointer;

//wire
wire [3:0] player_poker_num [0:4];
wire [3:0] dealer_poker_num [0:4];

//integer
integer i;

genvar idx;
generate
    for(idx=0;idx<5;idx=idx+1) begin
        assign player_poker_num[idx] = player_poker[idx][5:2] > 10 ? 10 : player_poker[idx][5:2];
        assign dealer_poker_num[idx] = dealer_poker[idx][5:2] > 10 ? 10 : dealer_poker[idx][5:2];
    end
endgenerate

//================================================================
//   I/O
//================================================================
reg  pip;
wire [3:0] number;
wire [1:0] suits;
wire empty;

//================================================================
//   Flag
//================================================================
wire done_pre = global_counter == 'd3;
reg  block_jack;
reg  check_black_done;
wire over_21;
wire over_five_card;
wire less_16;
wire card_empty;
wire if_last_person;
wire show_result_done;

//================================================================
//   d_clk
//================================================================
wire dis_clk = counter[17];
wire d_clk   = counter[24];

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
//   FSM
//================================================================

always @(posedge d_clk or negedge rst_n) begin
    if (!rst_n) begin
        curr_state <= IDLE;
    end
    else begin
        curr_state <= next_state;
    end
end

always @(*) begin
    case (curr_state)
        IDLE             : next_state = btn_m ? PREPARE : IDLE;
        PREPARE          : next_state = done_pre ? CHECK_BLACK_JACK : PREPARE;
        CHECK_BLACK_JACK : next_state = block_jack ? COMPARE : check_black_done ? WAIT_CARD : CHECK_BLACK_JACK;
        WAIT_CARD        : next_state = btn_m ? CHECK_1 : btn_r ? CHECK_2 : WAIT_CARD;
        CHECK_1          : next_state = over_21 ? CHECK_3 : over_five_card ? CHECK_3 : WAIT_CARD;
        CHECK_2          : next_state = less_16 ? WAIT_CARD : CHECK_3;
        CHECK_3          : next_state = card_empty ? DONE : if_last_person ? COMPARE : WAIT_CARD;
        COMPARE          : next_state = show_result_done ? IDLE : COMPARE;
        default          : next_state = IDLE;
    endcase
end

//================================================================
//   DESIGN
//================================================================
//global_counter
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        global_counter <= 'd0;
    end 
    else if(curr_state == PREPARE) begin
        global_counter <= global_counter + 'd1;
    end
    else begin
        global_counter <= 'd0;
    end
end
//pip
always @(posedge d_clk or negedge rst_n) begin
    if(!rst_n) begin
        pip <= 0;
    end 
    else if(next_state == PREPARE) begin
        pip <= 1;
    end
    else begin
        pip <= 0;
    end
end

//pip_r
always @(posedge d_clk or negedge rst_n) begin
    if(!rst_n) begin
        pip_r <= 0;
    end 
    else if(pip) begin
        pip_r <= 1;
    end
    else begin
        pip_r <= 0;
    end
end

//dealer_pointer
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        dealer_pointer <= 'd0;
    end 
    else if(pip_r && global_counter[0]) begin
        dealer_pointer <= dealer_pointer + 'd1;
    end
end

//player_pointer
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        player_pointer <= 'd0;
    end 
    else if(pip_r && global_counter[0]) begin
        player_pointer <= player_pointer + 'd1;
    end
end

//dealer_poker
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        for (i = 0; i < 5; i=i+1) begin
            dealer_poker[i] <= 'd0;
        end
    end 
    else if(pip_r && global_counter[0]) begin
        dealer_poker[dealer_pointer] <= {number,suits};
    end
end

//player_poker
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        for (i = 0; i < 5; i=i+1) begin
            player_poker[i] <= 'd0;
        end
    else if(pip_r && !global_counter[0]) begin
        player_poker[player_pointer] <= {number,suits};
    end
end

//seg_acc
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg_acc <= 'd0;
    end 
    else if(curr_state == CHECK_BLACK_JACK)begin
        seg_acc <= player_poker_num[0] + player_poker_num[1];
    end
    else if(curr_state == IDLE) begin
        seg_acc <= 'd0;
    end
end

//dealer_acc
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        dealer_acc <= 'd0;
    end 
    else if(curr_state == CHECK_BLACK_JACK) begin
        dealer_acc <= dealer_poker_num[0] + dealer_poker_num[1];
    end
    else if(curr_state == IDLE) begin
        dealer_acc <= 'd0;
    end
end

//block_jack
always @(*) begin 
    if (seg_acc == 11 && (player_poker_num[0] == 1 || player_poker_num[1] == 1)) begin
        block_jack = 1;
    end
    else if(dealer_acc == 11 && (dealer_poker_num[0] == 1 || dealer_poker_num[1] == 1)) begin
        block_jack = 1;
    end
    else begin
        block_jack = 0;
    end
end 

//check_black_done
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        check_black_done <= 'd0;
    end 
    else begin
        check_black_done <= curr_state == CHECK_BLACK_JACK;
    end
end

//================================================================
//   SEG
//================================================================

//===== display counter =====
always@(posedge dis_clk or negedge rst_n) begin
    if(!rst_n) begin
        dis_cnt <= 0;
    end
    else begin
        dis_cnt <= (dis_cnt>=3) ? 0 : (dis_cnt + 1);
    end
end

always@(posedge dis_clk or negedge rst_n) begin
    if(!rst_n) begin
        seg7_sel <= 4'b1111;
        seg7 <= 8'b0000_0001;
    end
    else begin
        case(dis_cnt)
            0 : seg7_sel <= 4'b0001;
            1 : seg7_sel <= 4'b0010;
            2 : seg7_sel <= 4'b0100;
            3 : seg7_sel <= 4'b1000;
        endcase
        
        seg7 <= seg7_temp[dis_cnt];
    end
end

//================================================================
//   LUT
//================================================================

LUT inst_LUT
    (
        .clk    (d_clk),
        .rst_n  (rst_n),
        .pip    (pip),
        .number (number),
        .suits  (suits),
        .empty  (empty)
    );


endmodule 