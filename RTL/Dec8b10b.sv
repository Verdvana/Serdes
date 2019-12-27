//------------------------------------------------------------------------------
//
//Module Name:					Dec8b10b.v
//Department:					Xidian University
//Function Description:	        8B/10B解码器
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana	Verdvana	Verdvana		  			2019-12-15
//
//-----------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		基于LUT的8B/10B解码器；
//          一个时钟周期出结果；
//          判断是否为控制信号；
//          判断RD错误；
//          判断解码错误。
//
//-----------------------------------------------------------------------------------

`timescale 1ns/1ns

module Dec8b10b(
    //********时钟与复位*********//
    input           clk,        //时钟
    input           rst_n,      //异步复位
    //***运行不一致性（RD）信号***//
    input           init_rd_n,  //RD初始化，通常为0
    input           init_rd_val,//RD输入，连接上次转码的RD输出
    output          rd,         //RD输出，连接下次转码的RD输入
    //*******控制/数据信号*******//
    input           enable,     //使能
    output          k_char,     //是否为控制信号输出
    //********数据输入输出*******//
    input  [9:0]    data_in,    //10bit待解码数据输入
    output [7:0]    data_out,   //解码后8bit数据输出
    //********错误指示信号*******//
    output          error,      //解码或RD错误
    output          rd_err,     //RD错误
    output          code_err    //解码错误
);


    //===================================================================
    //判断是否为控制信号

    reg kd;

    always_comb begin
        if(enable) begin
            if((data_in == 10'b0011110100) | (
                data_in == 10'b1100001011) | (
                data_in == 10'b0011111001) | (
                data_in == 10'b1100000110) | (
                data_in == 10'b0011110101) | (
                data_in == 10'b1100001010) | (
                data_in == 10'b0011110011) | (
                data_in == 10'b1100001100) | (
                data_in == 10'b0011110010) | (
                data_in == 10'b1100001101) | (
                data_in == 10'b0011111010) | (
                data_in == 10'b1100000101) | (
                data_in == 10'b0011110110) | (
                data_in == 10'b1100001001) | (
                data_in == 10'b0011111000) | (
                data_in == 10'b1100000111) | (
                data_in == 10'b1110101000) | (
                data_in == 10'b0001010111) | (
                data_in == 10'b1101101000) | (
                data_in == 10'b0010010111) | (
                data_in == 10'b1011101000) | (
                data_in == 10'b0100010111) | (
                data_in == 10'b0111101000) | (
                data_in == 10'b1000010111))
                kd = '1;
            else    
                kd = '0;
        end
        else begin
            kd = '0;
        end
    end


    //===================================================================
    //RD临时信号1生产

    wire rd_temp1;  //RD临时信号

    assign rd_temp1 = init_rd_n ? (init_rd_val & init_rd_n) : (init_rd_val | init_rd_n);


    //===================================================================
    //解码

    //-------------------------------------------------------------------
    //高6bit数据解码

    reg         code_err_x;     //高6bit解码数据错误指示
    reg [1:0]   rd_x;           //当前6bit码对应RD
    reg         rd_temp_x;      //解码之后下一次RD
    reg [4:0]   x;              //高6bit数据解码后4bit数据

    always_comb begin
        if(enable)begin
            case(data_in[9:4])
                6'b100111:  begin
                                x = 5'b00000;
                                rd_x = '0;          //当前6bit数据对应RD为-1
                                rd_temp_x = '1;     //下次解码RD应为1
                                code_err_x = '0;    //数据无误
                            end
                6'b011000:  begin
                                x = 5'b00000;
                                rd_x = 2'b01;       //当前6bit数据对应RD为1
                                rd_temp_x = '0;     //下次解码应为-1
                                code_err_x = '0;
                            end
                6'b011101:  begin
                                x = 5'b00001;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b100010:  begin
                                x = 5'b00001;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b101101:  begin
                                x = 5'b00010;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b010010:  begin
                                x = 5'b00010;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b110001:  begin
                                x = 5'b00011;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b110101:  begin
                                x = 5'b00100;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b001010:  begin
                                x = 5'b00100;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b101001:  begin
                                x = 5'b00101;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b011001:  begin
                                x = 5'b00110;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b111000:  begin
                                x = 5'b00111;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b000111:  begin
                                x = 5'b00110;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b111001:  begin
                                x = 5'b01000;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b000110:  begin
                                x = 5'b00110;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b100101:  begin
                                x = 5'b01001;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b010101:  begin
                                x = 5'b01010;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b110100:  begin
                                x = 5'b01011;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b001101:  begin
                                x = 5'b01100;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b101100:  begin
                                x = 5'b01101;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b011100:  begin
                                x = 5'b01110;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b010111:  begin
                                x = 5'b01111;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b101000:  begin
                                x = 5'b01111;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b011011:  begin
                                x = 5'b10000;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b100100:  begin
                                x = 5'b10000;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b100011:  begin
                                x = 5'b10001;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b010011:  begin
                                x = 5'b10010;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b110010:  begin
                                x = 5'b10011;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b001011:  begin
                                x = 5'b10100;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b101010:  begin
                                x = 5'b10101;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b011010:  begin
                                x = 5'b10110;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b111010:  begin
                                x = 5'b10111;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b000101:  begin
                                x = 5'b10111;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b110011:  begin
                                x = 5'b11000;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b001100:  begin
                                x = 5'b11000;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b100110:  begin
                                x = 5'b11001;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b010110:  begin
                                x = 5'b11010;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b110110:  begin
                                x = 5'b11011;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b001001:  begin
                                x = 5'b11011;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b001110:  begin
                                x = 5'b11100;
                                rd_x = 2'b10;
                                rd_temp_x = rd_temp1;
                                code_err_x = '0;
                            end
                6'b101110:  begin
                                x = 5'b11101;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b010001:  begin
                                x = 5'b11101;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b011110:  begin
                                x = 5'b11110;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b100001:  begin
                                x = 5'b11110;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b101011:  begin
                                x = 5'b11111;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b010100:  begin
                                x = 5'b11111;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                6'b001111:  begin
                                x = 5'b11100;
                                rd_x = '0;
                                rd_temp_x = '1;
                                code_err_x = '0;
                            end
                6'b110000:  begin
                                x = 5'b11100;
                                rd_x = 2'b01;
                                rd_temp_x = '0;
                                code_err_x = '0;
                            end
                default:    begin
                                x = '0;
                                rd_x = 'x;
                                rd_temp_x = rd_temp1;
                                code_err_x = 1'b1;
                            end
            endcase
        end
        else begin
            x = '0;
            rd_x = '0;
            rd_temp_x = '0; 
            code_err_x = '1;
        end
    end


    //-------------------------------------------------------------------
    //高6bit数据RD错误判断
    reg rd_err_x;                   //高6bit数据RD错误指示

    always_comb begin
        if(rd_x[1]==1'b1)                //当前6bit数据对应RD为不定态则不判断
            rd_err_x = '0;
        else if (rd_x[0]== rd_temp1)  //当前6bit数据对应RD与上次转换后的RD值是否相等
            rd_err_x = '0;
        else
            rd_err_x = '1;
    end


    //-------------------------------------------------------------------
    //低4bit数据解码

    reg         code_err_y;     //低4bit解码错误指示
    reg [1:0]   rd_y;           //当前4bit码对应RD
    reg         rd_temp_y;      //解码之后下一次RD
    reg [2:0]   y;              //低4bit数据解码后3bit数据

    always_comb begin
        if(enable) begin
            if(k_char) begin
                case(data_in[3:0])
                    4'b1011:    begin
                                    y = '0;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b0100:    begin
                                    y = '0;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    4'b0110:    begin
                                    y = 3'b001;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b1001:    begin
                                    y = 3'b001;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    4'b1010:    begin
                                    y = 3'b010;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b0101:    begin
                                    y = 3'b010;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end          
                    4'b1100:    begin
                                    y = 3'b011;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b0011:    begin
                                    y = 3'b011;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    4'b1101:    begin
                                    y = 3'b100;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b0010:    begin
                                    y = 3'b100;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    4'b0101:    begin
                                    y = 3'b101;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b1010:    begin
                                    y = 3'b101;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    4'b1001:    begin
                                    y = 3'b110;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b0110:    begin
                                    y = 3'b110;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    4'b0111:    begin
                                    y = 3'b111;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b1000:    begin
                                    y = 3'b111;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    default:    begin
                                    y = '0;
                                    rd_y = 'x;
                                    rd_temp_y = rd_temp_x;
                                    code_err_y = '1;
                                end
                endcase    
            end
            else begin
                case(data_in[3:0])
                    4'b1011:    begin
                                    y = '0;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b0100:    begin
                                    y = '0;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    4'b1001:    begin
                                    y = 3'b001;
                                    rd_y = 2'b10;
                                    rd_temp_y = rd_temp_x;
                                    code_err_y = '0;
                                end
                    4'b0101:    begin
                                    y = 3'b010;
                                    rd_y = 2'b10;
                                    rd_temp_y = rd_temp_x;
                                    code_err_y = '0;
                                end
                    4'b1100:    begin
                                    y = 3'b011;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b0011:    begin
                                    y = 3'b011;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    4'b1101:    begin
                                    y = 3'b100;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b0010:    begin
                                    y = 3'b100;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    4'b1010:    begin
                                    y = 3'b101;
                                    rd_y = 2'b10;
                                    rd_temp_y = rd_temp_x;
                                    code_err_y = '0;
                                end
                    4'b0110:    begin
                                    y = 3'b110;
                                    rd_y = 2'b10;
                                    rd_temp_y = rd_temp_x;
                                    code_err_y = '0;
                                end
                    4'b1110:    begin
                                    y = 3'b111;
                                    rd_y = '0;
                                    rd_temp_y = '1;
                                    code_err_y = '0;
                                end
                    4'b0001:    begin
                                    y = 3'b111;
                                    rd_y = 2'b01;
                                    rd_temp_y = '0;
                                    code_err_y = '0;
                                end
                    default:    begin
                                    y = '0;
                                    rd_y = 'x;
                                    rd_temp_y = rd_temp_x;
                                    code_err_y = '1;
                                end
                endcase            
            end
        end
        else begin
            y = '0;
            code_err_y = '1;
            rd_temp_y = '0;
            rd_y = '0;
        end
    end


    //-------------------------------------------------------------------
    //低4bit数据RD错误判断

    reg rd_err_y;                       //低4bit数据RD错误指示

    always_comb begin
        if(rd_y[1]==1'b1)                    //当前4bit数据对应RD为不定态则不判断
            rd_err_y = '0;
        else if (rd_y[0]== rd_temp_x)     //当前4bit数据对应RD与上次转换后的RD值是否相等
            rd_err_y = '0;
        else
            rd_err_y = '1;
    end


    //===================================================================
    //寄存

    reg [7:0]   data_out_r;
    reg rd_r;
    reg code_err_r;
    reg rd_err_r;
    reg k_char_r;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_out_r <= '0;
            rd_r <= '0;
            code_err_r <= '1;
            rd_err_r <= '1;
            k_char_r <= '0;
        end
        else if(enable)begin
            data_out_r <= {y,x};
            rd_r <= rd_temp_y;
            code_err_r <= code_err_x | code_err_y;
            rd_err_r <= rd_err_x | rd_err_y;
            k_char_r <= kd;
        end
		  else begin
			data_out_r <= '0;
            code_err_r <= '1;
            rd_err_r <= '1;
			rd_r <= '0;
            k_char_r <= '0;
		  end
    end

    
    //===================================================================
    //输出

    assign code_err = code_err_r;
    assign rd_err = rd_err_r;
    assign error = code_err | rd_err;
    assign data_out = data_out_r;
    assign rd = rd_r;
    assign k_char = k_char_r;

endmodule
