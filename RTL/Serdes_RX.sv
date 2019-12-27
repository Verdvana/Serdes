//------------------------------------------------------------------------------
//
//Module Name:					Serdes_RX.v
//Department:					Xidian University
//Function Description:	        8B/10B编码SerDes模块接收端
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana	Verdvana	Verdvana		  			2019-12-24
//
//-----------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		1位串行数据转8位并行
//          进行8B/10B解码
//          1Gbps
//
//-----------------------------------------------------------------------------------

`timescale 1ns/1ns

module Serdes_RX(
    //********时钟与复位*********//
    input           clk,            //时钟
    input           clk_hs,        //时钟
    input           rst_n,          //异步复位
    //*******控制/数据信号*******//
    input           enable,         //使能
    output          k_char,         //是否为控制信号输出
    //********数据输入输出*******//
    input           data_in,        //串行数据输入
    output [7:0]    data_out,       //并行数据输出
    //**********指示信号*********//
    output          bit_align_done, //对齐完成信号
    //********错误指示信号*******//
    output          error,          //解码或RD错误
    output          rd_err,         //RD错误
    output          code_err        //解码错误    
);




    //==================================================================
    //输入寄存4个10bit串行数据

    wire [9:0]  data;

    Deserializer u_Deserializer(
        //********时钟与复位*********//
        .clk            (clk_hs),      //时钟
        .rst_n          (rst_n),   //异步复位
        //**********使能信号*********//
        .enable,                        //使能
        //*******数据输出入/输出******//
        .data_in,                       //串行数据输入
        .data_out       (data),         //并行数据输出
        //**********指示信号*********//
        .bit_align_done                 //对齐完成信号
    );

    reg [9:0] data_r;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_r <= '0;
        end
        else begin
            data_r <= data;
        end
    end
    

    
    wire rd;

    Dec8b10b u_Dec8b10b(
        //********时钟与复位*********//
        .clk            (clk),  //时钟
        .rst_n          (rst_n),//异步复位
        //***运行不一致性（RD）信号***//
        .init_rd_n      (1'b0),      //RD初始化，通常为0
        .init_rd_val    (rd),        //RD输入，连接上次转码的RD输出
        .rd,                         //RD输出，连接下次转码的RD输入
        //*******控制/数据信号*******//
        .enable,                     //使能
        .k_char,                     //是否为控制信号输出
        //********数据输入输出*******//
        .data_in        (data_r),      //10bit待解码数据输入
        .data_out,                   //解码后8bit数据输出
        //********错误指示信号*******//
        .error,                      //解码或RD错误
        .rd_err,                     //RD错误
        .code_err                    //解码错误
    );    

endmodule