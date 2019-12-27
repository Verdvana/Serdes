//------------------------------------------------------------------------------
//
//Module Name:					Enc8b10b.v
//Department:					Xidian University
//Function Description:	        8B/10B编码器
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana	Verdvana	Verdvana		  			2019-12-13
//V1.1		Verdvana	Verdvana	Verdvana		  			2019-12-13
//
//-----------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		基于LUT的8B/10B编码器；
//          一个时钟周期出结果；
//          先进行5B/6B编码，并更新RD信号，
//			再根据更新后的RD信号进行3B/4B编码，且产生下次编码的RD信号。
//
//V1.1		根据Synopsys的IP手册规范引脚名称，且添加使能信号。
//
//-----------------------------------------------------------------------------------

`timescale 1ns/1ns

module Enc8b10b(
    //********时钟与复位*********//
	input           clk,        //时钟
    input           rst_n,      //复位
    //*******控制/数据信号*******//
    input           enable,     //使能
    input           k_char,     //控制为1，数据为0
    //***运行不一致性（RD）信号***//
    input           init_rd_n,  //RD初始化，通常为0
    input           init_rd_val,//RD输入，连接上次转码的RD输出
    output          rd,         //RD输出，连接下次转码的RD输入
    //********数据输入输出*******//
    input  [7:0]    data_in,    //8bit数据输入
    output [9:0]    data_out    //10bit数据输出
);


    wire    rd_temp1;           //RD临时信号1
    reg     rd_temp2;           //RD临时信号2
    reg     rd_temp3;           //RD临时信号3
    reg     rd_temp4;           //RD临时信号4

    //===================================================================
    //RD临时信号1生产
    assign rd_temp1 = init_rd_n ? (init_rd_n&init_rd_val) : (init_rd_n|init_rd_val);

    //===================================================================
    //编码

    //-------------------------------------------------------------------
    //先进行5b/6b编码，rd为RD临时信号1，rd结果为RD临时信号2

    reg [5:0] x;    //低5位的编码后的6位数据

    always_comb begin
        if(!rst_n) begin
            x <= '0;
            rd_temp2 <= '0;
        end
        else if(enable)begin 
            case(data_in[4:0])
                5'b00000:   if(rd_temp1) begin  //如果rd为1，下次编码rd为0，下同
                                x <= 6'b011000;
                                rd_temp2 <= '0;
                            end
                            else begin          //如果rd为0，下次编码rd为1，下同
                                x <= 6'b100111;
                                rd_temp2 <= '1;
                            end
                5'b00001:   if(rd_temp1) begin
                                x <= 6'b100010;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b011101;
                                rd_temp2 <= '1;
                            end
                5'b00010:   if(rd_temp1) begin
                                x <= 6'b010010;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b101101;
                                rd_temp2 <= '1;
                            end
                5'b00011:   begin
                                x <= 6'b110001;
                                rd_temp2 <= rd_temp1;
                            end
                5'b00100:   if(rd_temp1) begin
                                x <= 6'b001010;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b110101;
                                rd_temp2 <= '1;
                            end
                5'b00101:   begin
                                x <= 6'b101001;
                                rd_temp2 <= rd_temp1;
                            end
                5'b00110:   begin   
                                x <= 6'b011001;
                                rd_temp2 <= rd_temp1;
                            end
                5'b00111:   if(rd_temp1) begin
                                x <= 6'b000111;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b111000;
                                rd_temp2 <= '1;
                            end
                5'b01000:   if(rd_temp1) begin
                                x <= 6'b000110;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b111001;
                                rd_temp2 <= '1;
                            end
                5'b01001:   begin   
                                x <= 6'b100101;
                                rd_temp2 <= rd_temp1;
                            end
                5'b01010:   begin   
                                x <= 6'b010101;
                                rd_temp2 <= rd_temp1;
                            end
                5'b01011:   begin   
                                x <= 6'b110100;
                                rd_temp2 <= rd_temp1;
                            end
                5'b01100:   begin   
                                x <= 6'b001101;
                                rd_temp2 <= rd_temp1;
                            end
                5'b01101:   begin   
                                x <= 6'b101100;
                                rd_temp2 <= rd_temp1;
                            end
                5'b01110:   begin   
                                x <= 6'b011100;
                                rd_temp2 <= rd_temp1;
                            end
                5'b01111:   if(rd_temp1) begin
                                x <= 6'b101000;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b010111;
                                rd_temp2 <= '1;
                            end
                5'b10000:   if(rd_temp1) begin
                                x <= 6'b100100;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b011011;
                                rd_temp2 <= '1;
                            end
                5'b10001:   begin   
                                x <= 6'b100011;
                                rd_temp2 <= rd_temp1;
                            end
                5'b10010:   begin   
                                x <= 6'b010011;
                                rd_temp2 <= rd_temp1;
                            end
                5'b10011:   begin   
                                x <= 6'b110010;
                                rd_temp2 <= rd_temp1;
                            end
                5'b10100:   begin   
                                x <= 6'b001011;
                                rd_temp2 <= rd_temp1;
                            end
                5'b10101:   begin   
                                x <= 6'b101010;
                                rd_temp2 <= rd_temp1;
                            end
                5'b10110:   begin   
                                x <= 6'b011010;
                                rd_temp2 <= rd_temp1;
                            end
                5'b10111:   if(rd_temp1) begin
                                x <= 6'b000101;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b111010;
                                rd_temp2 <= '1;
                            end   
                5'b11000:   if(rd_temp1) begin
                                x <= 6'b001100;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b110011;
                                rd_temp2 <= '1;
                            end
                5'b11001:   begin   
                                x <= 6'b100110;
                                rd_temp2 <= rd_temp1;
                            end
                5'b11010:   begin   
                                x <= 6'b010110;
                                rd_temp2 <= rd_temp1;
                            end
                5'b11011:   if(rd_temp1) begin
                                x <= 6'b001001;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b110110;
                                rd_temp2 <= '1;
                            end
                5'b11100:   case(k_char)
                                1'b0: begin
                                    x <= 6'b001110;
                                    rd_temp2 <= rd_temp1;
                                end
                                1'b1: begin
                                    if(rd_temp1) begin
                                        x <= 6'b110000;
                                        rd_temp2 <= '0;
                                    end
                                    else begin
                                        x <= 6'b001111;
                                        rd_temp2 <= '1;
                                    end 
                                end
                            endcase
                5'b11101:   if(rd_temp1) begin
                                x <= 6'b010001;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b101110;
                                rd_temp2 <= '1;
                            end 
                5'b11110:   if(rd_temp1) begin
                                x <= 6'b100001;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b011110;
                                rd_temp2 <= '1;
                            end  
                5'b11111:   if(rd_temp1) begin
                                x <= 6'b010100;
                                rd_temp2 <= '0;
                            end
                            else begin
                                x <= 6'b101011;
                                rd_temp2 <= '1;
                            end
                default:    begin
                                x <= '0;
                                rd_temp2 <= rd_temp1;
                            end
            endcase
        end
        else begin
            x <= '0;
            rd_temp2 <= '0;
        end
    end
    
    //-------------------------------------------------------------------
    //再进行3b/4b编码，rd为RD临时信号2，rd结果为RD临时信号3

    reg [3:0]   y;      //高2位的编码后的4位数据
    
    always_comb begin
        if(!rst_n) begin
            y <= '0;
            rd_temp3 <= '0;
        end
        else if(enable)begin
            case(k_char)                                //判断是否为控制信号，1为是
                1'b0:   begin
                    case(data_in[7:5])
                        3'b000: if(rd_temp2) begin
                                    y <= 4'b0100;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b1011;
                                    rd_temp3 <= '1;
                                end
                        3'b001: begin
                                    y <= 4'b1001;
                                    rd_temp3 <= rd_temp2;
                                end
                        3'b010: begin
                                    y <= 4'b0101;
                                    rd_temp3 <= rd_temp2;
                                end
                        3'b011: if(rd_temp2) begin
                                    y <= 4'b0011;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b1100;
                                    rd_temp3 <= '1;
                                end
                        3'b100: if(rd_temp2) begin
                                    y <= 4'b0010;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b1101;
                                    rd_temp3 <= '1;
                                end
                        3'b101: begin
                                    y <= 4'b1010;
                                    rd_temp3 <= rd_temp2;
                                end
                        3'b110: begin
                                    y <= 4'b0110;
                                    rd_temp3 <= rd_temp2;
                                end
                        3'b111: if(x[1]==1&&x[0]==1)begin   
                                    if(rd_temp2) begin
                                        y <= 4'b1000;
                                        rd_temp3 <= '0;
                                    end
                                    else begin
                                        y <= 4'b0111;
                                        rd_temp3 <= '1;
                                    end
                                end
                                else begin
                                    if(rd_temp2) begin
                                        y <= 4'b0001;
                                        rd_temp3 <= '0;
                                    end
                                    else begin
                                        y <= 4'b1110;
                                        rd_temp3 <= '1;
                                    end
                                end
                        default:begin
                                y <= '0;
                                rd_temp3 <= rd_temp2;
                                end
                    endcase         
                end
                1'b1:   begin
                    case(data_in[7:5])
                        3'b000: if(rd_temp2) begin
                                    y <= 4'b0100;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b1011;
                                    rd_temp3 <= '1;
                                end
                        3'b001: if(rd_temp2) begin
                                    y <= 4'b1001;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b0110;
                                    rd_temp3 <= '1;
                                end
                        3'b010: if(rd_temp2) begin
                                    y <= 4'b0101;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b1010;
                                    rd_temp3 <= '1;
                                end
                        3'b011: if(rd_temp2) begin
                                    y <= 4'b0011;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b1100;
                                    rd_temp3 <= '1;
                                end
                        3'b100: if(rd_temp2) begin
                                    y <= 4'b0010;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b1101;
                                    rd_temp3 <= '1;
                                end
                        3'b101: if(rd_temp2) begin
                                    y <= 4'b1010;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b0101;
                                    rd_temp3 <= '1;
                                end
                        3'b110: if(rd_temp2) begin
                                    y <= 4'b0110;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b1001;
                                    rd_temp3 <= '1;
                                end
                        3'b111: if(rd_temp2) begin
                                    y <= 4'b1000;
                                    rd_temp3 <= '0;
                                end
                                else begin
                                    y <= 4'b0111;
                                    rd_temp3 <= '1;
                                end
                        default:begin
                                y <= '0;
                                rd_temp3 <= rd_temp2;
                        end
                    endcase                 
                end
                default:begin
                        y <= '0;
                        rd_temp3 <= rd_temp2;
                end        
            endcase
        end
        else begin
            y <= '0;
            rd_temp3 <= '0;
        end
    end

    //===================================================================
    //寄存
    
    reg [9:0] data_out_r;
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_out_r <= '0;
            rd_temp4 <= '0;
        end
        else if(enable)begin
            data_out_r <= {x,y};
            rd_temp4 <= rd_temp3;
        end
        else begin
            data_out_r <= '0;
            rd_temp4 <= '0;
        end
    end
    
    //===================================================================
    //输出

    assign rd = rd_temp4;
    assign data_out =  data_out_r;

endmodule

