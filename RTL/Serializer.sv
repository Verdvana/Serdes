//------------------------------------------------------------------------------
//
//Module Name:					Serializer.v
//Department:					Xidian University
//Function Description:	        串行器
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana	Verdvana	Verdvana		  			2019-12-24
//
//-----------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		10位并行数据转1位串行
//          1Gbps
//
//-----------------------------------------------------------------------------------

`timescale 1ns/1ns

module Serializer(
    //********时钟与复位*********//
    input               clk,        //串行时钟
    input               rst_n,      //异步复位
    //**********使能信号*********//
    input               enable,     //使能
    //*******数据输出入/输出******//
    input  [9:0]        data_in,    //10位并行数据输入
    output              data_out,   //1位串行数据输出
    //**********指示信号*********//
    output              valid       //转换完成
);

    //===================================================================
    //模10计数器

    reg [3:0] cnt;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            cnt <= '0;
        end
        else if(enable)begin
            if(cnt == 4'd9)begin
                cnt <= '0;
            end
            else begin  
                cnt <= cnt + 1;
            end
        end
        else begin
            cnt <= cnt;
        end
    end


    //===================================================================
    //移位寄存器更新标志，计数器计到9更新

    reg fresh;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            fresh <= '0;
        end
        else if(cnt == 4'd9)begin
            fresh <= '1;
        end
        else begin  
            fresh <= '0;
        end
    end

    //===================================================================
    //输入数据加载

    reg [9:0] data;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data <= 'x;
        end
        else if(fresh) begin
            data <= data_in;
        end
        else begin
            data <= data;
        end
    end
    

    //===================================================================
    //移位寄存器加载
    
    reg [9:0]   data_out_r;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_out_r <= '0;
        end
        else if(fresh) begin    //更新
            data_out_r <= data;
        end
        else begin              //移位
            data_out_r <= {data_out_r[8:0],data_out_r[9]};
        end
    end

    //===================================================================
    //串行数据输出

    assign data_out = data_out_r[9];
    
    
    //===================================================================
    //数据有效

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            valid <= '0;
        end
        else if(fresh) begin
            valid <= '1;
        end
        else begin
            valid <= valid;
        end
    end


endmodule