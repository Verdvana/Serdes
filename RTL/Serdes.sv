//------------------------------------------------------------------------------
//
//Module Name:					Serdes_TX.v
//Department:					Xidian University
//Function Description:	        8B/10B编码SerDes模块测试
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana	Verdvana	Verdvana		  			2019-12-24
//
//-----------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		包含NCO，用来产生数据
//          1Gbps传输
//
//-----------------------------------------------------------------------------------


`timescale 1ns/1ns
module Serdes(
    input           clk,        //时钟50M
    input           rst_n,      //异步复位

    input           enable,     //使能

    output          serdes_tx,  //serdes发送
    input           serdes_rx,  //serdes接收


    output          bit_align_done, 
	 

    output [7:0]    data_out    //数据输出

	 
);


wire clk_100m;
wire clk_hs;
wire pll_locked;

PLL	PLL_inst (
	.areset ( ~rst_n ),
	.inclk0 ( clk ),
	.c0 ( clk_100m ),
	.c1 ( clk_hs ),
	.locked ( pll_locked )
	);

    reg [3:0]  cnt;

    always_ff @(posedge clk_100m, negedge pll_locked) begin
        if(!pll_locked) begin
            cnt <= '0;
        end
        else if(enable) begin
				cnt <= cnt + 1;
        end
        else begin
            cnt <= '0;
        end
    end

    reg flag;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            flag <= '0;
        end
        else if(&cnt) begin
            flag <= '1;
        end
        else begin
            flag <= flag;
        end
    end
    
    

    reg [7:0] data;

    always_ff @(posedge clk_100m, negedge pll_locked) begin
        if(!pll_locked) begin
            data <= '0;
        end
        else if(~flag) begin
            data <= 8'b10100110 ;
        end
        else begin
            data <= sin;
        end
    end


    wire [7:0] sin;

    NCO #(
	    .CLK_FREQUENCY(100000000),	//时钟频率（Hz）	
		.DATA_WIDTH(8)  				//输出数据位宽
    ) u_NCO(
		.clk(clk_100m),		//50M时钟
		.rst_n(pll_locked),	//异步复位
		
		.en(enable),		//使能，加载相位控制字
		.fre_chtr(24'd100000),//频率控制字（理论上大于1小于时钟频率都可以）
		.pha_chtr(7'd0),//相位控制字（0-100）百分比
		
		.sin_out(sin),	//正弦波形输出
		.cos_out()	//余弦波形输出
);  

	 

	Serdes_TX u_Serdes_TX(
		//********时钟与复位*********//
		.clk(clk_100m),        //时钟100MHz
		.clk_hs(clk_hs),        //时钟
		.rst_n(pll_locked),      //异步复位
		//*******控制/数据信号*******//
		.enable(enable),     //使能
		.k_char(1'b0),     //控制为1，数据为0
		//********数据输入输出*******//
		.data_in(data),    //8bit并行数据输入
		.data_out(serdes_tx),   //1bit串行数据输出
		//**********指示信号*********//
		.valid()       //转换完成
	);    

	 
    Serdes_RX u_Serdes_RX(
        //********时钟与复位*********//
        .clk(clk_100m),            //时钟
        .clk_hs(clk_hs),        //时钟
        .rst_n(pll_locked),          //异步复位
        //*******控制/数据信号*******//
        .enable(enable),         //使能
        .k_char(1'b0),         //是否为控制信号输出
        //********数据输入输出*******//
        .data_in(serdes_rx),        //串行数据输入
        .data_out(data_out),       //并行数据输出
        //**********指示信号*********//
        .bit_align_done(bit_align_done), //对齐完成信号
        //********错误指示信号*******//
        .error(),          //解码或RD错误
        .rd_err(),         //RD错误
        .code_err()        //解码错误    
    );



endmodule