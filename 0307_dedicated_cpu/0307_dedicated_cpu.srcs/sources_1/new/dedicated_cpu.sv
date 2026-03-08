`timescale 1ns / 1ps

module dedicated_cpu (
    input        clk,
    input        rst,
    output [7:0] out
);

    logic asrcsel, aload;

    control_unit U_CONTROL_UNIT (.*);
    datapath U_DATAPATH (.*);
endmodule

module control_unit (
    input        clk,
    input        rst,
    output logic aload,
    output logic asrcsel
);

    typedef enum logic [2:0] {
        S0 = 0,
        S1 = 1,
        S2 = 2
    } state_t;

    state_t c_state, n_state;

    always_ff @(posedge clk, posedge rst) begin : blockName
        if (rst) begin
            c_state <= S0;
        end else begin
            c_state <= n_state;
        end
    end

    always_comb begin
        n_state = c_state;
        asrcsel = 0;
        aload   = 0;
        case (c_state)
            S0: begin
                asrcsel = 0;
                aload   = 0;
                n_state = S1;
            end
            S1: begin
                asrcsel = 0;
                aload   = 1;
                n_state = S2;
            end
            S2: begin
                asrcsel = 1;
                aload   = 1;
            end

        endcase
    end

endmodule


module datapath (
    input        clk,
    input        rst,
    input        aload,
    input        asrcsel,
    output [7:0] out
);

    logic [7:0] w_aluout, w_reg_in, w_reg_out;
    assign out = w_reg_out;

    areg U_AREG (
        .clk(clk),
        .rst(rst),
        .reg_in(w_reg_in),
        .aload(aload),
        .reg_out(w_reg_out)
    );

    alu U_ALU (
        .a(w_reg_out),
        .b(8'h1),
        .alu_out(w_aluout)
    );

    mux_2x1 U_ASRCMUX (
        .a(0),  // 0
        .b(w_aluout),  // 1
        .asrcsel(asrcsel),
        .mux_out(w_reg_in)
    );

endmodule

module areg (
    input       clk,
    input       rst,
    input [7:0] reg_in,
    input       aload,
    output [7:0] reg_out
);

    logic [7:0] areg;
    assign reg_out = areg;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            areg <= 0;
        end else begin
            if (aload) begin
                areg <= reg_in;
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
    input  [7:0] a,        // 0
    input  [7:0] b,        // 1
    input        asrcsel,
    output [7:0] mux_out
);

    assign mux_out = (asrcsel) ? b : a;

endmodule
