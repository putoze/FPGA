module tenthirty(
    input clk,
    input rst_n,
    //input sw,
    input btn_m, //bottom middle
    input btn_r, //bottom right
    output reg [7:0] seg7_sel, // sw:0 [3:0], sw:1 [7:4]
    output reg [7:0] seg7,
    output reg [7:0] seg7_l, //segment left
    output reg [2:0] led // led[0] : dealer win, led[1] : player win, led[2] : done
);

//================================================================
//   PARAMETER
//================================================================

localparam IDLE      = 3'd0;
localparam DEAL      = 3'd1;
localparam WAIT_CARD = 3'd2;
localparam CHECK     = 3'd3;
localparam CHECK_2   = 3'd4;
localparam COMPARE   = 3'd5;
localparam DONE      = 3'd6;

integer i;

//================================================================
//   d_clk
//================================================================
//frequency division
reg [24:0] counter; 
wire dis_clk = counter[17];
wire d_clk   = counter[24];
//wire dis_clk = counter[1];
//wire d_clk = counter[5];

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
//seg7_temp
reg [7:0] seg7_temp[0:7];
reg [2:0] dis_cnt;
//FSM
reg [2:0] curr_state,next_state;
//acc
reg [5:0] seg_acc; //[5] record half point
reg [5:0] player_acc; //[5] record half point
reg [2:0] seg_card_acc;
//poker
reg [3:0] dealer_poker[0:4],player_poker[0:4];
//player_pointer
reg player_pointer; // 0: player, 1: dealer
//poker_pt
reg [2:0] dealer_poker_pt,player_poker_pt;
//global_counter
reg [7:0] global_counter;
//game_counter
reg [1:0] game_counter;

//================================================================
//   FLAG
//================================================================
wire deal_done = global_counter[0];
wire overTenHalf = seg_acc[4:0] > 10;
wire overFiveCard = seg_card_acc > 4;
wire if_dealer_done = player_pointer;
reg  game_result;//0:player win, 1:dealer win, if tie, dealer win
wire done_four_game = game_counter == 'd0;

//================================================================
//   FSM
//================================================================

always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        curr_state <= IDLE;
    end 
    else begin
        curr_state <= next_state;
    end
end

always @(*) begin 
    case (curr_state)
        IDLE      : next_state = btn_m ? DEAL : IDLE;
        DEAL      : next_state = deal_done ? WAIT_CARD : DEAL;
        WAIT_CARD : next_state = btn_m ? CHECK : btn_r ? CHECK_2 : WAIT_CARD;
        CHECK     : next_state = deal_done ? overTenHalf || overFiveCard ? CHECK_2 : WAIT_CARD : CHECK;
        CHECK_2   : next_state = if_dealer_done ? COMPARE : WAIT_CARD;
        COMPARE   : next_state = btn_r ? done_four_game ? DONE : IDLE : COMPARE;
        DONE      : next_state = DONE;
        default : next_state = IDLE;
    endcase
end

//================================================================
//   I/O
//================================================================
reg  pip;
wire empty;
wire [3:0] number;

//================================================================
//   DESIGN
//================================================================

//global_counter
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        global_counter <= 'd0;
    end 
    else if(curr_state == DEAL) begin
        global_counter <= global_counter + 'd1;
    end
    else if(curr_state == CHECK) begin
        global_counter <= global_counter + 'd1;
    end
    else begin
        global_counter <= 'd0;
    end
end

//pip
always @(*) begin 
    if(next_state == DEAL) begin
        pip = 1;
    end
    else if(next_state == CHECK) begin
        pip = 1;
    end
    else begin
        pip = 0;
    end
end

//dealer_poker_pt
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        dealer_poker_pt <= 'd0;
    end 
    else if(curr_state == DEAL && global_counter[0]) begin
        dealer_poker_pt <= dealer_poker_pt + 'd1;
    end
    else if(curr_state == CHECK && player_pointer && !global_counter[0]) begin
        dealer_poker_pt <= dealer_poker_pt + 'd1;
    end
    else if(curr_state == IDLE) begin
        dealer_poker_pt <= 'd0;
    end
end

//player_poker_pt
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        player_poker_pt <= 'd0;
    end 
    else if(curr_state == DEAL && !global_counter[0]) begin
        player_poker_pt <= player_poker_pt + 'd1;
    end
    else if(curr_state == CHECK && !player_pointer && !global_counter[0]) begin
        player_poker_pt <= player_poker_pt + 'd1;
    end
    else if(curr_state == IDLE) begin
        player_poker_pt <= 'd0;
    end
end

//dealer_poker
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        for (i = 0; i < 5; i=i+1) begin
            dealer_poker[i] <= 'd0;
        end
    end 
    else if(curr_state == DEAL && global_counter[0]) begin
        dealer_poker[dealer_poker_pt] <= number;
    end
    else if(curr_state == CHECK && player_pointer && !global_counter[0]) begin
        dealer_poker[dealer_poker_pt] <= number;
    end
    else if(curr_state == IDLE) begin
        for (i = 0; i < 5; i=i+1) begin
            dealer_poker[i] <= 'd0;
        end
    end
end

//player_poker
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        for (i = 0; i < 5; i=i+1) begin
            player_poker[i] <= 'd0;
        end
    end 
    else if(curr_state == DEAL && !global_counter[0]) begin
        player_poker[player_poker_pt] <= number;
    end
    else if(curr_state == CHECK && !player_pointer && !global_counter[0]) begin
        player_poker[player_poker_pt] <= number;
    end
    else if(curr_state == COMPARE) begin
        player_poker[0] <= player_acc[4:0] % 10 == 0 ? 10 : player_acc[4:0] % 10;
        player_poker[1] <= player_acc[4:0] / 10;
        player_poker[2] <= player_acc[5] ? 'd11 : 'd0;
        player_poker[3] <= 'd0;
        player_poker[4] <= 'd0;
    end 
    else if(curr_state == IDLE) begin
        player_poker[0] <= 'd0;
        player_poker[1] <= 'd0;
        player_poker[2] <= 'd0;
    end
end

//seg_acc
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg_acc <= 'd0;
    end 
    else if(curr_state == DEAL && global_counter[0]) begin
        if(player_poker[0] > 10) begin
            seg_acc <= 6'b100000;
        end
        else begin
            seg_acc <= player_poker[0];
        end
    end
    else if(curr_state == CHECK && !global_counter[0]) begin
        if(number > 10) begin
            if (seg_acc[5]) begin
                seg_acc[5]   <= 0;
                seg_acc[4:0] <= seg_acc[4:0] + 'd1;
            end
            else begin
                seg_acc[5] <= 1;
            end
        end
        else begin
            seg_acc <= seg_acc + number;
        end
    end
    else if(curr_state == CHECK_2 && !player_pointer) begin
        if(dealer_poker[0] > 10) begin
            seg_acc <= 6'b100000;
        end
        else begin
            seg_acc <= dealer_poker[0];
        end
    end
    else if(curr_state == IDLE) begin
        seg_acc <= 'd0;
    end
end

//seg_card_acc
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg_card_acc <= 'd1;
    end 
    else if(curr_state == CHECK && !global_counter[0]) begin
        seg_card_acc <= seg_card_acc + 'd1;
    end
    else if(curr_state == CHECK_2) begin
        seg_card_acc <= 'd1;
    end
    else if(curr_state == IDLE) begin
        seg_card_acc <= 'd1;
    end
end

//player_acc
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        player_acc <= 'd0;
    end 
    else if(curr_state == CHECK_2 && !player_pointer)begin
        player_acc <= seg_acc;
    end
    else if(curr_state == IDLE) begin
        player_acc <= 'd0;
    end
end

//player_pointer
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        player_pointer <= 'd0;
    end 
    else if(curr_state == CHECK_2)begin
        player_pointer <= player_pointer + 'd1;
    end
    else if(curr_state == IDLE) begin
        player_pointer <= 'd0;
    end
end

//game_result
always @(*) begin
    if(curr_state == COMPARE) begin
        if(player_acc[3:0] > 10) begin 
            game_result = 1;
        end
        else if(seg_acc[3:0] > player_acc[3:0]) begin
            game_result = 1;
        end
        else if(seg_acc[3:0] == player_acc[3:0]) begin
            if (player_acc[5] & seg_acc[5]) begin
                game_result = 0;
            end
            else begin
                game_result = 1;
            end
        end
        else begin
            game_result = 0;
        end
    end
    else begin
        game_result = 0;
    end
end

//game_counter
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        game_counter <= 'd0;
    end 
    else if(curr_state == CHECK_2 && player_pointer)begin
        game_counter <= game_counter + 'd1;
    end
end

//================================================================
//   SEG
//================================================================
//seg7_temp
always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        for (i = 0; i < 5; i=i+1) begin
            seg7_temp[i] <= 'd1;
        end
    end 
    else begin
        //seg7_temp[0]~seg7_temp[5]
        if(player_pointer) begin
            for (i = 0; i < 5; i=i+1) begin
                case (dealer_poker[i])
                    1 :seg7_temp[i] <= 8'b0000_0110;
                    2 :seg7_temp[i] <= 8'b0101_1011;
                    3 :seg7_temp[i] <= 8'b0100_1111;
                    4 :seg7_temp[i] <= 8'b0110_0110;
                    5 :seg7_temp[i] <= 8'b0110_1101;
                    6 :seg7_temp[i] <= 8'b0111_1101;
                    7 :seg7_temp[i] <= 8'b0000_0111;
                    8 :seg7_temp[i] <= 8'b0111_1111;
                    9 :seg7_temp[i] <= 8'b0110_0111;
                    10:seg7_temp[i] <= 8'b0011_1111;
                    11:seg7_temp[i] <= 8'b1000_0000;
                    12:seg7_temp[i] <= 8'b1000_0000;
                    13:seg7_temp[i] <= 8'b1000_0000;
                    default : seg7_temp[i] <= 8'b0000_0001;
                endcase
            end
        end
        else begin
            for (i = 0; i < 5; i=i+1) begin
                case (player_poker[i])
                    1 :seg7_temp[i] <= 8'b0000_0110;
                    2 :seg7_temp[i] <= 8'b0101_1011;
                    3 :seg7_temp[i] <= 8'b0100_1111;
                    4 :seg7_temp[i] <= 8'b0110_0110;
                    5 :seg7_temp[i] <= 8'b0110_1101;
                    6 :seg7_temp[i] <= 8'b0111_1101;
                    7 :seg7_temp[i] <= 8'b0000_0111;
                    8 :seg7_temp[i] <= 8'b0111_1111;
                    9 :seg7_temp[i] <= 8'b0110_0111;
                    10:seg7_temp[i] <= 8'b0011_1111;
                    11:seg7_temp[i] <= 8'b1000_0000;
                    12:seg7_temp[i] <= 8'b1000_0000;
                    13:seg7_temp[i] <= 8'b1000_0000;
                    default : seg7_temp[i] <= 8'b0000_0001;
                endcase
            end
        end
    end
end

always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg7_temp[7] <= 'd1;
        seg7_temp[6] <= 'd1;
        seg7_temp[5] <= 'd1;
    end 
    else begin
        //seg7_temp[6]
        case (seg_acc[4:0])
            //1~9
            1 : begin seg7_temp[5] <= 8'b0000_0110; seg7_temp[6] <= 8'b0011_1111 ;end
            2 : begin seg7_temp[5] <= 8'b0101_1011; seg7_temp[6] <= 8'b0011_1111 ;end
            3 : begin seg7_temp[5] <= 8'b0100_1111; seg7_temp[6] <= 8'b0011_1111 ;end
            4 : begin seg7_temp[5] <= 8'b0110_0110; seg7_temp[6] <= 8'b0011_1111 ;end
            5 : begin seg7_temp[5] <= 8'b0110_1101; seg7_temp[6] <= 8'b0011_1111 ;end
            6 : begin seg7_temp[5] <= 8'b0111_1101; seg7_temp[6] <= 8'b0011_1111 ;end
            7 : begin seg7_temp[5] <= 8'b0000_1111; seg7_temp[6] <= 8'b0011_1111 ;end
            8 : begin seg7_temp[5] <= 8'b0111_1111; seg7_temp[6] <= 8'b0011_1111 ;end
            9 : begin seg7_temp[5] <= 8'b0110_1111; seg7_temp[6] <= 8'b0011_1111 ;end
            //10~19
            10: begin seg7_temp[5] <= 8'b0011_1111; seg7_temp[6] <= 8'b0000_0110 ;end
            11: begin seg7_temp[5] <= 8'b0000_0110; seg7_temp[6] <= 8'b0000_0110 ;end
            12: begin seg7_temp[5] <= 8'b0101_1011; seg7_temp[6] <= 8'b0000_0110 ;end
            13: begin seg7_temp[5] <= 8'b0100_1111; seg7_temp[6] <= 8'b0000_0110 ;end
            14: begin seg7_temp[5] <= 8'b0110_0110; seg7_temp[6] <= 8'b0000_0110 ;end
            15: begin seg7_temp[5] <= 8'b0110_1101; seg7_temp[6] <= 8'b0000_0110 ;end
            16: begin seg7_temp[5] <= 8'b0111_1101; seg7_temp[6] <= 8'b0000_0110 ;end
            17: begin seg7_temp[5] <= 8'b0000_1111; seg7_temp[6] <= 8'b0000_0110 ;end
            18: begin seg7_temp[5] <= 8'b0111_1111; seg7_temp[6] <= 8'b0000_0110 ;end
            19: begin seg7_temp[5] <= 8'b0110_0111; seg7_temp[6] <= 8'b0000_0110 ;end
            //20
            20: begin seg7_temp[5] <= 8'b0011_1111; seg7_temp[6] <= 8'b0101_1011 ;end
            //default
            default : begin seg7_temp[5] <= 8'b0000_0001; seg7_temp[6] <= 8'b0000_0001 ;end
        endcase
        if(seg_acc == 0) begin
            seg7_temp[7] <= 8'b0000_0001;
        end
        else if(seg_acc[5]) begin
            seg7_temp[7] <= 8'b1000_0000;
        end
        else begin
            seg7_temp[7] <= 8'b0011_1111;
        end
    end
end


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
//   LED
//================================================================

always @(posedge d_clk or negedge rst_n) begin 
    if(!rst_n) begin
        led <= 'd0;
    end 
    else if(curr_state == COMPARE) begin
        if (game_result) begin
            led <= 3'b001;
        end 
        else begin
            led <= 3'b010;
        end
    end
    else if(curr_state == DONE) begin
        led <= 3'b100;
    end
    else begin
        led <= 'd0;
    end
end

//================================================================
//   LUT
//================================================================
LUT inst_LUT (.clk(d_clk), .rst_n(rst_n), .pip(pip), .number(number), .empty(empty));


endmodule 