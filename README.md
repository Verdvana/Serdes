# 8B/10B编码的SerDes模块

#### 代码介绍
    基于8B/10B编码的SerDes模块，由SerDes_TX发送模块和SerDes_RX接收模块组成，本设计还包含了NCO用以产生发送得到正弦波数据。

* V1.0   2019.12.27
    * 1Gbps传输；
    * 通过LVDS物理接口实现传输；
    * 接收到的波形有毛刺。

仿真波形：

![wave](https://raw.githubusercontent.com/Verdvana/Dec8b10b/master/Simulation/enc8b10b_TB/wave.jpg)


| Flow Summary | Content |
| --- | --- |
| Flow Status | Successful - Fri Dec 27 14:15:13 2019 |
| Quartus Prime Version | 18.1.0 Build 625 09/12/2018 SJ Standard Edition |
| Revision Name | Serdes |
| Top-level Entity Name | Serdes |
| Family | Stratix IV |
| Device | EP4SGX230KF40C2 |
| Timing Models | Final |
| Logic utilization | < 1 % |
| Combinational ALUTs | 126 / 182,400 ( < 1 % ) |
| Memory ALUTs | 0 / 91,200 ( 0 % ) |
| Dedicated logic registers | 187 / 182,400 ( < 1 % ) |
| Total registers | 187 |
| Total pins | 16 / 888 ( 2 % ) |
| Total virtual pins | 0 |
| Total block memory bits | 16,000 / 14,625,792 ( < 1 % ) |
| DSP block 18-bit elements | 0 / 1,288 ( 0 % ) |
| Total GXB Receiver Channel PCS | 0 / 24 ( 0 % ) |
| Total GXB Receiver Channel PMA | 0 / 36 ( 0 % ) |
| Total GXB Transmitter Channel PCS | 0 / 24 ( 0 % ) |
| Total PLLs | 1 / 8 ( 13 % ) |
| Total DLLs | 0 / 4 ( 0 % ) |




