
`define CYCLE 100000 // 單一cycle 長度

//模組名稱
module seg7_switch(
	input clk,
	input rst_n,
	input [7:0] switch,
	output [7:0] seg7,
	output [3:0] seg7_sel
    );
	
	//暫存器宣告
	reg [7:0] seg7;
	reg [3:0] seg7_sel;
	reg [3:0] seg7_temp [0:3];
	reg [1:0] seg7_count;
	
	reg [29:0] count;
	wire d_clk;
	
	//除頻
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			count <= 0;
		else if (count >= `CYCLE)
			count <= 0;
		else
			count <= count + 1;
	end
	assign d_clk = count > (`CYCLE/2) ? 0 : 1;
	
	//switch 二進位轉十進位
	always @(posedge d_clk or negedge rst_n)begin
		if(!rst_n)begin
			seg7_temp[0] <= 0;
			seg7_temp[1] <= 0;
			seg7_temp[2] <= 0;
			seg7_temp[3] <= 0;
		end
		else begin
		  if(switch<=9) begin
		      seg7_temp[3]<=switch%10;
		      seg7_temp[2]<=0;
		      seg7_temp[1]<=0;
		      seg7_temp[0]<=0;
		  end
		  else if(switch <=99) begin
		        seg7_temp[3]<=(switch%100)/10;
                seg7_temp[2]<=(switch%10);
                seg7_temp[1]<=0;
                seg7_temp[0]<=1;
		  end
		  else if(switch <=255) begin
		      seg7_temp[3]<=(switch%1000)/100;
              seg7_temp[2]<=(switch%100)/10;
              seg7_temp[1]<=switch%10;
              seg7_temp[0]<=2;
		  end
		  /*
			if(switch[7]==0) begin
				seg7_temp[3] <= 0;
		    end
			else seg7_temp [3]<=10;
			if(switch[7]==0) begin
				seg7_temp[2]<=switch[6:4];
			end
			else seg7_temp[2] <=~(switch[7:4]-1);
			seg7_temp[1] <= (switch [3:0]% 100) / 10;
			seg7_temp[0] <= switch[3:0] % 10;
			*/
		end
	end
	
	
	//七段顯示器顯示
	always @(posedge d_clk or negedge rst_n)begin
		if(!rst_n)begin
			seg7_count <= 0;
		end
		else begin
			seg7_count <= seg7_count + 1;
		end
	end
	
	always @(posedge d_clk or negedge rst_n)begin
		if(!rst_n)begin
			seg7_sel <= 0;
			seg7 <= 0;
		end
		else begin
			case(seg7_count)
				0:	seg7_sel <= 4'b0001;
				1:	seg7_sel <= 4'b0010;
				2:	seg7_sel <= 4'b0100;
				3:	seg7_sel <= 4'b1000;
			endcase
			case(seg7_temp[seg7_count])
				0:seg7 <= (seg7_count==3)?8'b1011_1111:8'b0011_1111;
                1:seg7 <= (seg7_count==3)?8'b1000_0110:8'b0000_0110;
                2:seg7 <= (seg7_count==3)?8'b1101_1011:8'b0101_1011;
                3:seg7 <= (seg7_count==3)?8'b1100_1111:8'b0100_1111;
                4:seg7 <= (seg7_count==3)?8'b1110_0110:8'b0110_0110;
                5:seg7 <= (seg7_count==3)?8'b1110_1101:8'b0110_1101;
                6:seg7 <= (seg7_count==3)?8'b1111_1101:8'b0111_1101;
                7:seg7 <= (seg7_count==3)?8'b1000_0111:8'b0000_0111;
                8:seg7 <= (seg7_count==3)?8'b1111_1111:8'b0111_1111;
                9:seg7 <= (seg7_count==3)?8'b1110_1111:8'b0110_1111;
				
			endcase
		end
	end
	
endmodule
