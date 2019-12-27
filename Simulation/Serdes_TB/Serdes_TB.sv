`timescale 1ns/1ns

module Serdes_TB;

    reg clk;
    reg rst_n;

    reg enable;

    wire [9:0] data_out;

    wire serdes;

    Serdes u_Serdes(
        .clk,
        .rst_n,

        .enable,

        .serdes_tx(serdes),
        .serdes_rx(serdes),

        .data_out
    );


    initial begin
        clk = 1'b1;
        forever #10 clk = ~clk;
    end

    initial begin
        rst_n = '0;
        enable = '0;

        #10;
        rst_n = 1'b1;

        #10;
    

        #100;

        enable = 1'b1;

        #10000;

        $stop;

    end

endmodule