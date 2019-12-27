//------------------------------------------------------------------------------
//
//Module Name:					NCO.v
//Department:					Xidian University
//Function Description:	   数字控制振荡器
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana		Verdvana		Verdvana		  			2019-11-26
//
//-----------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		16位正余弦波输出；
//				频率可调，理论上大于1小于时钟频率都可以，实际到时钟频率的十分之一以上波形就快不能看了；
//				相位可调：0-100；
//				en使能加载相位控制字
//
//-----------------------------------------------------------------------------------

`timescale 1ns/1ns

module NCO #(
		parameter 	CLK_FREQUENCY=50000000,	//时钟频率（Hz）	
						DATA_WIDTH=16 				//输出数据位宽
)(
		input                   	clk,		//50M时钟
		input                   	rst_n,	//异步复位
		
		input                   	en,		//使能，加载相位控制字
		input  [23:0] 					fre_chtr,//频率控制字（理论上大于1小于时钟频率都可以）
		input  [6:0] 					pha_chtr,//相位控制字（0-100）百分比
		
		output [DATA_WIDTH-1:0] 	sin_out,	//正弦波形输出
		output [DATA_WIDTH-1:0] 	cos_out	//余弦波形输出
);  
	
	parameter MAX_PRE = CLK_FREQUENCY/2000;//连续读ROM地址可达到的最大频率
	
	reg [8:0] 	fre_fast;						//频率控制字大于MAX_PRE时需要使用的寄存器
														//ROM地址每次跳变fre_fast
														
	reg [14:0] 	fre_slow;						//频率控制字大于MAX_PRE时需要使用的寄存器
														//ROM地址每隔fre_slow跳变一次
	
	//========================================================================
	//判断频率
	
	always_ff@(posedge clk or negedge rst_n) begin
	
		if(!rst_n) begin								//复位
		
			fre_fast <=	'0;
			fre_slow <=	'0;
			
		end
		
		else if(en) begin								//如果使能信号为正
		
			if(fre_chtr>=MAX_PRE) begin			//如果频率控制字大于MAX_PRE
		
				fre_fast <= fre_chtr/MAX_PRE;		//对应寄存器为：频率控制字/MAX_PRE
				fre_slow <= '0;						//另一个寄存器用不到
			
			end
		
			else begin									//如果频率控制字小于MAX_PRE
				
				fre_slow <= MAX_PRE/fre_chtr;		//对应寄存器为：MAX_PRE/频率控制字
				fre_fast <= 1;							//另一个寄存器始终为1
						
			end
		
		end
		
		else begin										//使能信号为负
		
			fre_fast <=	'0;
		   fre_slow <=	'0;
			
		end	
	
	end
	
	//========================================================================
	//如果频率控制字小于MAX_PRE，需要用计数器延长ROM地址的跳变周期
	
	reg 			flag;    //计数器计满标志位
	reg [14:0] 	cnt;		//计数器寄存器
	
	always_ff@(posedge clk or negedge rst_n) begin
	
		if(!rst_n) begin						//复位
		
			flag <= 1'b0;
			cnt  <= '0;
			
		end
			
		else if(fre_chtr>=MAX_PRE) begin	//如果控制字大于MAX_PRE
		
			flag <= 1'b1;						//ROM地址一直跳变，即计数器满标志一直为1
			
		end
		
		else begin								//如果控制字小于MAX_PRE
			
			if(cnt>=fre_slow-1) begin		//计数器计到（MAX_PRE/频率控制字）时，计数器复位，标志位置1
			
				cnt <= '0;
				flag <= 1'b1;
			
			end
			
			else begin							//计数器计没到（MAX_PRE/频率控制字）时，计数器加1，标志位置0
			
				cnt <= cnt+1;
				flag <= 1'b0;
			
			end
			
		end
	
	end
				
	
	//========================================================================
	//地址产生
	
	reg [10:0] address;						//ROM地址
	
	always_ff@(posedge clk or negedge rst_n) begin
	
		if(!rst_n)								//复位
		
			address <= '0;
			
		else if(en) begin						//如果使能为正
			
			if(address>=(2000-fre_fast))	//如果地址大于ROM的最大值减去（频率控制字/MAX_PRE），地址复位
				address <= '0;					//减去（频率控制字/MAX_PRE）是为了防止地址大于ROM最大地址导致ROM输出数据为Z
			
			else if(flag)						//如果标志位置1，则地址加（频率控制字/MAX_PRE）
				address <= address + fre_fast;
		
			else
				address <= address;			//否则地址不变
				
		end
		
		else begin
		
			address <= pha_chtr*20-1;		//如果使能为负，加载相位
													//地址为相位控制字代表的百分比乘以ROM深度
		end
	
	end
			
	
	//========================================================================
	//Intel 1-Port ROM IP核
	
	wire [DATA_WIDTH-1:0] q_sin;			//正弦数据
	wire [DATA_WIDTH-1:0] q_cos;			//余弦数据
	
	//------------------------------------------------------------------------
	//存储正弦波形的ROM，16位数据，2000深度
	
	ROM_Sin	ROM_Sin_inst (
	.address ( address ),
	.clock ( clk ),
	.q ( {q_sin,8'b0} )
	);
	
	//------------------------------------------------------------------------
	//存储余弦波形的ROM，16位数据，2000深度	
	ROM_Cos	ROM_Cos_inst (
	.address ( address ),
	.clock ( clk ),
	.q ( q_cos )
	);
	

	//========================================================================
	//数据输出
	
	assign sin_out = q_sin;
	assign cos_out = q_cos;
	
	       
	
endmodule 