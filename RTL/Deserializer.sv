//------------------------------------------------------------------------------
//
//Module Name:					Deserializer.v
//Department:					Xidian University
//Function Description:	        解串器
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana	Verdvana	Verdvana		  			2019-12-24
//
//-----------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		1位串行数据转10位并行
//          1Gbps
//
//-----------------------------------------------------------------------------------


`timescale 1ns/1ns

module Deserializer(
    //********时钟与复位*********//
    input           clk,            //时钟
    input           rst_n,          //异步复位
    //**********使能信号*********//
    input           enable,         //使能
    //*******数据输出入/输出******//
    input           data_in,        //串行数据输入
    output [9:0]    data_out,       //并行数据输出
    //**********指示信号*********//
    output reg      bit_align_done  //对齐完成信号
);


    //==================================================================
    //输入寄存4个10bit串行数据

    reg  data [40];     //40位寄存
    
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data[0] <= '0;
        end
        else if(enable) begin
            data[0] <= data_in;
        end
        else begin
            data[0] <= data[0];
        end
    end
    
    genvar i;
    generate for(i=1;i<40;i++)
        begin:DataInput
            always_ff @(posedge clk, negedge rst_n) begin
                if(!rst_n) begin
                    data[i] <= '0;
                end
                else if(enable)begin
                    data[i] <= data[i-1];
                end
                else begin
                     data[i] <= data[i];
                end 
            end
        end
    endgenerate


    //==================================================================
    //将40bit串行数据和帧头：四个连续的0110011010做比较

    reg [19:0] data_comp;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_comp <= '0;
        end
        else begin
            data_comp[19] <= !data[39]&data[38];
            data_comp[18] <= data[37]&!data[36];
            data_comp[17] <= !data[35]&data[34];
            data_comp[16] <= data[33]&!data[32];
            data_comp[15] <= data[31]&!data[30];
            data_comp[14] <= !data[29]&data[28];
            data_comp[13] <= data[27]&!data[26];
            data_comp[12] <= !data[25]&data[24];
            data_comp[11] <= data[23]&!data[22];
            data_comp[10] <= data[21]&!data[20];
            data_comp[9] <= !data[19]&data[18];
            data_comp[8] <= data[17]&!data[16];
            data_comp[7] <= !data[15]&data[14];
            data_comp[6] <= data[13]&!data[12];
            data_comp[5] <= data[11]&!data[10];
            data_comp[4] <= !data[9] &data[8];
            data_comp[3] <= data[7] &!data[6];
            data_comp[2] <= !data[5] &data[4];
            data_comp[1] <= data[3] &!data[2];
            data_comp[0] <= data[1] &!data[0];
        end
    end 

    reg [9:0] data_comp_r;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_comp_r <= '0;
        end
        else begin
            data_comp_r[9] <= data_comp[19]&data_comp[18];
            data_comp_r[8] <= data_comp[17]&data_comp[16];
            data_comp_r[7] <= data_comp[15]&data_comp[14];
            data_comp_r[6] <= data_comp[13]&data_comp[12];
            data_comp_r[5] <= data_comp[11]&data_comp[10];
            data_comp_r[4] <= data_comp[9] &data_comp[8];
            data_comp_r[3] <= data_comp[7] &data_comp[6];
            data_comp_r[2] <= data_comp[5] &data_comp[4];
            data_comp_r[1] <= data_comp[3] &data_comp[2];
            data_comp_r[0] <= data_comp[1] &data_comp[0];
        end
    end

    reg [4:0] data_comp_r_r;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_comp_r_r <= '0;
        end
        else begin
            data_comp_r_r[4] <= data_comp_r[9] &data_comp_r[8];
            data_comp_r_r[3] <= data_comp_r[7] &data_comp_r[6];
            data_comp_r_r[2] <= data_comp_r[5] &data_comp_r[4];
            data_comp_r_r[1] <= data_comp_r[3] &data_comp_r[2];
            data_comp_r_r[0] <= data_comp_r[1] &data_comp_r[0];
        end
    end    


    reg data_comp_r_r_r;        //连续四个十位都对齐则为1

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_comp_r_r_r <= '0;
        end
        else begin
            data_comp_r_r_r <= &data_comp_r_r;
        end
    end 


    //==================================================================
    //产生对齐完成信号并保持
    
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            bit_align_done <= '0;
        end
        else if(data_comp_r_r_r) begin
            bit_align_done <= '1;
        end
        else begin
            bit_align_done <= bit_align_done;
        end
    end 

    //==================================================================
    //产生计数器使能信号

    reg en;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            en <= '0;
        end
        else begin
            en <= bit_align_done;
        end
    end 
    
    //==================================================================
    //计数器，每过10个时钟周期输出一组10bit并行数据

    reg [4:0] cnt;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            cnt <= '0;
        end
        else if(en) begin
            if (cnt == 4'd9)
                cnt <= '0;
            else 
                cnt <= cnt + 1;
        end
        else begin
            cnt <= cnt;
        end
    end


    //==================================================================
    //输出寄存器加载信号

    reg  fresh;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            fresh <= '0;
        end
        else if(cnt == 4'd4)begin
            fresh <= '1;
        end
        else begin
            fresh <= '0;
        end
    end 


    //==================================================================
    //输出数据合并

    reg [9:0] data_temp;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_temp <= '0;
        end
        else begin
            data_temp <= {data[9],data[8],data[7],data[6],data[5],data[4],data[3],data[2],data[1],data[0]};
        end
    end


    //==================================================================
    //输出寄存器

    reg [9:0] data_out_r;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_out_r <= '0;
        end
        else if(fresh) begin
            data_out_r <= data_temp;
        end
        else begin
            data_out_r <= data_out_r;
        end
    end
    
    //==================================================================
    //输出

    assign data_out = data_out_r;

endmodule