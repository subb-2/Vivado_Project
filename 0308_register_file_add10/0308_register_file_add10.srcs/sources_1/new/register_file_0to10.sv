`timescale 1ns / 1ps

module register_file_0to10 (
    input        clk,
    input        rst,
    output [7:0] out
);

    logic let10, rfsrcsel, we;
    logic [1:0] raddr0, raddr1, waddr;

    control_unit U_CONTROL_UNIT (.*);

    datapath U_DATAPATH (.*);

endmodule

module control_unit (
    input              clk,
    input              rst,
    input              let10,
    output logic       rfsrcsel,
    output logic [1:0] raddr0,
    output logic [1:0] raddr1,
    output logic [1:0] waddr,
    output logic       we
);

    typedef enum logic [2:0] {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5,
        S6
    } state_t;

    state_t c_state, n_state;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= S0;
        end else begin
            c_state <= n_state;
        end
    end

    always_comb begin
        n_state = c_state;
        rfsrcsel = 0;
        raddr0 = 0;
        raddr1 = 0;
        waddr = 0;
        we = 0;

        case (c_state)
            S0: begin
                rfsrcsel = 0;
                raddr0   = 0;
                raddr1   = 0;
                waddr    = 3;
                we       = 1;
                n_state  = S1;
            end
            S1: begin
                rfsrcsel = 1;
                raddr0   = 0;
                raddr1   = 0;
                waddr    = 1;
                we       = 1;
                n_state  = S2;
            end
            S2: begin
                rfsrcsel = 1;
                raddr0   = 0;
                raddr1   = 0;
                waddr    = 2;
                we       = 1;
                n_state = S3;
            end
            S3: begin
                rfsrcsel = 0;
                raddr0   = 1;
                raddr1   = 0;
                waddr    = 0;
                we       = 0;
                if (let10 == 1) begin
                    n_state = S4;
                end else begin
                    n_state = S6;
                end
            end
            S4: begin
                rfsrcsel = 1;
                raddr0   = 1;
                raddr1   = 2;
                waddr    = 2;
                we       = 1;
                n_state  = S5;
            end
            S5: begin
                rfsrcsel = 1;
                raddr0   = 1;
                raddr1   = 3;
                waddr    = 1;
                we       = 1;
                n_state  = S3;
            end
            S6: begin
                rfsrcsel = 0;
                raddr0   = 0;
                raddr1   = 2;
                waddr    = 0;
                we       = 0;
            end
        endcase
    end

endmodule

module datapath (
    input        clk,
    input        rst,
    input        rfsrcsel,
    input  [1:0] raddr0,
    input  [1:0] raddr1,
    input  [1:0] waddr,
    input        we,
    output       let10,
    output [7:0] out
);

    logic [7:0] w_wdata, w_rdata0, w_rdata1, w_alu_out;

    assign out = w_rdata1;

    register_file U_REG_FILE (
        .clk   (clk),
        .rst   (rst),
        .raddr0(raddr0),
        .raddr1(raddr1),
        .waddr (waddr),
        .we    (we),
        .wdata (w_wdata),
        .rdata0(w_rdata0),
        .rdata1(w_rdata1)
    );

    alu U_ALU (
        .a      (w_rdata0),
        .b      (w_rdata1),
        .alu_out(w_alu_out)
    );

    mux_2x1 U_RF_MUX (
        .a       (8'h1),       //0
        .b       (w_alu_out),  //1
        .rfsrcsel(rfsrcsel),
        .mux_out (w_wdata)
    );

    let10 U_LET10 (
        .in_data(w_rdata0),
        .let10  (let10)
    );

endmodule

module register_file (
    input              clk,
    input              rst,
    input        [1:0] raddr0,
    input        [1:0] raddr1,
    input        [1:0] waddr,
    input              we,
    input        [7:0] wdata,
    output logic [7:0] rdata0,
    output logic [7:0] rdata1
);

    logic [7:0] wdata_arry[0:3];

    assign rdata0 = wdata_arry[raddr0];
    assign rdata1 = wdata_arry[raddr1];

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            wdata_arry[0] <= 0;
            wdata_arry[1] <= 0;
            wdata_arry[2] <= 0;
            wdata_arry[3] <= 0;
        end else begin
            if (we) begin
                wdata_arry[waddr] <= wdata;
            end
        end
    end

endmodule

module alu (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] alu_out
);

    assign alu_out = a + b;

endmodule

module mux_2x1 (
    input  [7:0] a,         //0
    input  [7:0] b,         //1
    input        rfsrcsel,
    output [7:0] mux_out
);

    assign mux_out = (rfsrcsel) ? b : a;

endmodule

module let10 (
    input  [7:0] in_data,
    output       let10
);

    assign let10 = (in_data <= 10);

endmodule
