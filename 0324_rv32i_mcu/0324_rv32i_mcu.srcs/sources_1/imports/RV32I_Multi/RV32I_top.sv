`timescale 1ns / 1ps

module RV32I_mcu_top (
    input clk,
    input rst
);
    logic       dwe;
    logic [2:0] o_funct3;
    logic [31:0] instr_addr, instr_data, daddr, dwdata, drdata;

    instruction_mem U_INSTRUCTION_MEM (.*);

    RV32I_cpu U_RV32I (
        .*,
        .o_funct3(o_funct3)
    );

    APB_Master U_APB_MASTER (
        .PCLK(),
        .PRESETn(),
        .Addr(),
        .Wdata(),
        .WREQ(),
        .RREQ(),
        .Rdata(),
        .Ready(),
        .PAddr(),
        .PWdata(),
        .PEnable(),
        .PWrite(),
        .PSEL0(),    //RAM
        .PSEL1(),    //GPO
        .PSEL2(),    //GPI
        .PSEL3(),    //GPIO
        .PSEL4(),    //FND
        .PSEL5(),    //UART
        .PRdata0(),  //from RAM
        .PRdata1(),  //from GPO
        .PRdata2(),  //from GPI
        .PRdata3(),  //from GPIO
        .PRdata4(),  //from FND
        .PRdata5(),  //from UART
        .PReady0(),  //from RAM
        .PReady1(),  //from GPO
        .PReady2(),  //from GPI
        .PReady3(),  //from GPIO
        .PReady4(),  //from FND
        .PReady5()   //from UART
    );

    data_mem U_DATA_MEM (
        .*,
        .i_funct3(o_funct3) 
    );


endmodule 
