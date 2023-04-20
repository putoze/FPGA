`define CYCLE 80000

module lab3(
	input clk,
	input rst_n,
	input btn_t,
	input btn_d,
	input btn_l,
	input btn_r,
	output reg [7:0] seg7,
	output reg [3:0] seg7_sel
);
	
	reg [20:0] count;
	wire d_clk;
	
	reg press_flag_t; //按壓旗號
	reg press_flag_d; //按壓旗號
	reg press_flag_l; //按壓旗號
	reg press_flag_r; //按壓旗號
	wire btn_t_pulse; // 單一脈衝
	wire btn_d_pulse; // 單一脈衝
	wire btn_l_pulse; // 單一脈衝
	wire btn_r_pulse; // 單一脈衝
	
	reg [7:0] counter; //計數器
	wire [7:0] counter_pos;
	
	reg [7:0] seg7_temp[0:3];
	reg [1:0] seg7_count;
	
	// 除頻
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			count <= 0;
		end
		else begin
			if(count >= `CYCLE)
				count <= 0;
			else
				count <= count + 1;
		end
	end
	assign d_clk = count >= (`CYCLE/2)  ? 1 : 0;  // 掃描七段顯示器的時脈
	
	// 轉為 「單一脈衝」
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			press_flag_t <= 0;
		end
		else begin
			press_flag_t <= btn_t;
		end
	end
	assign btn_t_pulse = {btn_t,press_flag_t} == 2'b10 ? 1 : 0;

		///************************************///
		///									   ///
		///									   ///
		///									   ///
		///       Write your code here         ///
		///									   ///
		///									   ///
		///									   ///
		///************************************///
	
	
	
	// 記錄按壓的次數
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			counter <= 0;
		end
		///************************************///
		///									   ///
		///									   ///
		///									   ///
		///       Write your code here         ///
		///									   ///
		///									   ///
		///									   ///
		///************************************///
	end
	
	
	// 將按壓次數計數器轉為十進位
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			seg7_temp[0] <= 0;
			seg7_temp[1] <= 0;
			seg7_temp[2] <= 0;
			seg7_temp[3] <= 0;
		end
		///************************************///
		///									   ///
		///									   ///
		///									   ///
		///       Write your code here         ///
		///									   ///
		///									   ///
		///									   ///
		///************************************///
	end
	
	//顯示於七段顯示器
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
			seg7_sel <= 4'b1111;
			seg7 <= 8'b0011_1111;
		end
		else begin
			case(seg7_count)
				0:	seg7_sel <= 4'b0001;
				1:	seg7_sel <= 4'b0010;
				2:	seg7_sel <= 4'b0100;
				3:	seg7_sel <= 4'b1000;
			endcase
			case(seg7_temp[seg7_count])
				0:seg7 <= 8'b0011_1111;
                1:seg7 <= 8'b0000_0110;
                2:seg7 <= 8'b0101_1011;
                3:seg7 <= 8'b0100_1111;
                4:seg7 <= 8'b0110_0110;
                5:seg7 <= 8'b0110_1101;
                6:seg7 <= 8'b0111_1101;
                7:seg7 <= 8'b0000_0111;
                8:seg7 <= 8'b0111_1111;
                9:seg7 <= 8'b0110_1111;
				10:seg7 <= 8'b0100_0000;
			endcase
		end
	end
	
endmodule