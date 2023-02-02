module LUT (
    input  clk,    // Clock
    input  rst_n,  // Asynchronous reset active low
    input  pip,
    output number,
    output suits,
    output empty
);
reg [3:0] number;
reg [1:0] suits;
reg empty;

//Poker_mem
reg [5:0] poker_mem [0:51];
//pointer
reg [5:0] pointer;

//integer
integer i;

//================================================================
//   OUTPUT
//================================================================

always @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin
        {number,suits} <= 'd0;
    end 
    else if (empty) begin
        {number,suits} <= 'd0;
    end
    else if (pip) begin
        {number,suits} <= poker_mem[pointer];
    end
    else begin
        {number,suits} <= 'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        empty <= 0;
    end
    else if(pointer > 51)begin
        empty <= 1;
    end
end

//================================================================
//   LUT
//================================================================

//pointer
always @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin
        pointer <= 'd0;
    end 
    else begin
        if(pip) begin
            pointer <= pointer + 'd1;
        end
    end
end

//poker_mem
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(i=0;i<52;i=i+1) begin
            poker_mem[i] <= 'd0;
        end
    end 
    else begin
        //poker_mem[{:2d}] <= 6'd{cb}; 
        poker_mem[ 0] <= 6'd48; 
        poker_mem[ 1] <= 6'd27; 
        poker_mem[ 2] <= 6'd4; 
        poker_mem[ 3] <= 6'd34; 
        poker_mem[ 4] <= 6'd38; 
        poker_mem[ 5] <= 6'd51; 
        poker_mem[ 6] <= 6'd26; 
        poker_mem[ 7] <= 6'd5; 
        poker_mem[ 8] <= 6'd37; 
        poker_mem[ 9] <= 6'd24; 
        poker_mem[10] <= 6'd36; 
        poker_mem[11] <= 6'd16; 
        poker_mem[12] <= 6'd47; 
        poker_mem[13] <= 6'd39; 
        poker_mem[14] <= 6'd21; 
        poker_mem[15] <= 6'd15; 
        poker_mem[16] <= 6'd35; 
        poker_mem[17] <= 6'd40; 
        poker_mem[18] <= 6'd44; 
        poker_mem[19] <= 6'd30; 
        poker_mem[20] <= 6'd45; 
        poker_mem[21] <= 6'd52; 
        poker_mem[22] <= 6'd29; 
        poker_mem[23] <= 6'd17; 
        poker_mem[24] <= 6'd11; 
        poker_mem[25] <= 6'd6; 
        poker_mem[26] <= 6'd28; 
        poker_mem[27] <= 6'd31; 
        poker_mem[28] <= 6'd22; 
        poker_mem[29] <= 6'd53; 
        poker_mem[30] <= 6'd50; 
        poker_mem[31] <= 6'd8; 
        poker_mem[32] <= 6'd43; 
        poker_mem[33] <= 6'd46; 
        poker_mem[34] <= 6'd10; 
        poker_mem[35] <= 6'd54; 
        poker_mem[36] <= 6'd42; 
        poker_mem[37] <= 6'd18; 
        poker_mem[38] <= 6'd32; 
        poker_mem[39] <= 6'd20; 
        poker_mem[40] <= 6'd14; 
        poker_mem[41] <= 6'd23; 
        poker_mem[42] <= 6'd33; 
        poker_mem[43] <= 6'd25; 
        poker_mem[44] <= 6'd41; 
        poker_mem[45] <= 6'd49; 
        poker_mem[46] <= 6'd12; 
        poker_mem[47] <= 6'd9; 
        poker_mem[48] <= 6'd7; 
        poker_mem[49] <= 6'd13; 
        poker_mem[50] <= 6'd55; 
        poker_mem[51] <= 6'd19; 
    end
end

endmodule

