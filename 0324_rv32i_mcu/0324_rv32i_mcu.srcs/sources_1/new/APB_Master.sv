`timescale 1ns / 1ps

module APB_Master (
    input               PCLK,
    input               PRESETn,
    //from cpu
    input        [31:0] Addr,
    input        [31:0] Wdata,
    input               WREQ,
    input               RREQ,
    //from master to cpu
    output       [31:0] Rdata,
    output              Ready,
    //from master to slave
    output logic [31:0] PAddr,
    output logic [31:0] PWdata,
    output logic        PEnable,
    output logic        PWrite,
    output              PSEL0,    //RAM
    output              PSEL1,    //GPO
    output              PSEL2,    //GPI
    output              PSEL3,    //GPIO
    output              PSEL4,    //FND
    output              PSEL5,    //UART

    input [31:0] PRdata0,  //from RAM
    input [31:0] PRdata1,  //from GPO
    input [31:0] PRdata2,  //from GPI
    input [31:0] PRdata3,  //from GPIO
    input [31:0] PRdata4,  //from FND
    input [31:0] PRdata5,  //from UART
    input        PReady0,  //from RAM
    input        PReady1,  //from GPO
    input        PReady2,  //from GPI
    input        PReady3,  //from GPIO
    input        PReady4,  //from FND
    input        PReady5   //from UART
);

    typedef enum {
        IDLE,
        SETUP,
        ACCESS
    } apb_state_e;

    apb_state_e c_state, n_state;
    logic [31:0] PAddr_next, PWdata_next;
    logic decode_en, PWrite_next;

    //FSM 의 SL로, 다음 상태를 현재 상태로 업데이트 
    //FF 구성으로 Register 역할도 함 
    always_ff @(posedge PCLK, negedge PRESETn) begin
        if (!PRESETn) begin
            c_state     <= IDLE;
            PAddr_next  <= 32'd0;
            PWdata_next <= 32'd0;
            PWrite_next <= 1'b0;
        end else begin
            c_state <= n_state;
            PAddr   <= PAddr_next;
            PWdata  <= PWdata_next;
            PWrite  <= PWrite_next;
        end
    end

    //next & output CL
    always_comb begin
        n_state     = c_state;
        decode_en   = 1'b0;
        PEnable     = 1'b0;
        PAddr_next  = PAddr;
        PWdata_next = PWdata;
        PWrite_next = PWrite;
        case (c_state)
            IDLE: begin
                if (WREQ | RREQ) begin
                    PAddr_next  = Addr;
                    PWdata_next = Wdata;
                    if (WREQ) begin
                        PWrite_next = 1'b1;
                    end else begin
                        PWrite_next = 1'b0;
                    end
                    n_state = SETUP;
                end
            end
            SETUP: begin
                decode_en = 1'b1;
                PEnable   = 1'b0;
                n_state = ACCESS;
            end
            ACCESS: begin
                decode_en = 1'b1;
                PEnable = 1'b1;
                if (Ready) begin
                    n_state = IDLE;
                end
            end
        endcase
    end

    apb_decoder U_APB_DECODER (
        .en(decode_en),
        .addr(Addr),
        .PSEL0(PSEL0),
        .PSEL1(PSEL1),
        .PSEL2(PSEL2),
        .PSEL3(PSEL3),
        .PSEL4(PSEL4),
        .PSEL5(PSEL5)
    );

    apb__mux U_APB_MUX (
        .addr(Addr),
        .PRdata0(PRdata0),
        .PRdata1(PRdata1),
        .PRdata2(PRdata2),
        .PRdata3(PRdata3),
        .PRdata4(PRdata4),
        .PRdata5(PRdata5),
        .PReady0(PReady0),
        .PReady1(PReady1),
        .PReady2(PReady2),
        .PReady3(PReady3),
        .PReady4(PReady4),
        .PReady5(PReady5),
        .Rdata(Rdata),
        .Ready(Ready)
    );

endmodule



//en은 왜 추가했더라?
module apb_decoder (
    input               en,
    input        [31:0] addr,
    output logic        PSEL0,
    output logic        PSEL1,
    output logic        PSEL2,
    output logic        PSEL3,
    output logic        PSEL4,
    output logic        PSEL5
);

    always_comb begin
        PSEL0 = 1'b0;
        PSEL1 = 1'b0;
        PSEL2 = 1'b0;
        PSEL3 = 1'b0;
        PSEL4 = 1'b0;
        PSEL5 = 1'b0;
        if (en) begin
            case (addr[31:28])
                4'h1: PSEL0 = 1'b1;
                4'h2: begin
                    case (addr[15:12])
                        4'h0: PSEL1 = 1'b1;
                        4'h1: PSEL2 = 1'b1;
                        4'h2: PSEL3 = 1'b1;
                        4'h3: PSEL4 = 1'b1;
                        4'h4: PSEL5 = 1'b1;
                    endcase
                end
            endcase
        end
    end

endmodule

module apb__mux (
    input        [31:0] addr,
    input               PRdata0,
    input               PRdata1,
    input               PRdata2,
    input               PRdata3,
    input               PRdata4,
    input               PRdata5,
    input               PReady0,
    input               PReady1,
    input               PReady2,
    input               PReady3,
    input               PReady4,
    input               PReady5,
    output logic [31:0] Rdata,
    output logic        Ready
);

    always_comb begin
        case (addr[31:28])
            4'h1: begin
                Rdata = PRdata0;
                Ready = PReady0;
            end
            4'h2: begin
                case (addr[15:12])
                    4'h0: begin
                        Rdata = PRdata1;
                        Ready = PRdata1;
                    end
                    4'h1: begin
                        Rdata = PRdata2;
                        Ready = PRdata2;
                    end
                    4'h2: begin
                        Rdata = PRdata3;
                        Ready = PRdata3;
                    end
                    4'h3: begin
                        Rdata = PRdata4;
                        Ready = PRdata4;
                    end
                    4'h4: begin
                        Rdata = PRdata5;
                        Ready = PRdata5;
                    end
                endcase
            end
        endcase
    end

endmodule
