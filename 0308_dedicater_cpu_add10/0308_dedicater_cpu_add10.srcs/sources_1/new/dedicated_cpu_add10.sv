`timescale 1ns / 1ps

module dedicated_cpu_add10 (
    input        clk,
    input        rst,
    output [7:0] out
);

    logic ile10, isrcsel, sumsrcsel, iload, sumload, alusrcsel, outload;

    control_unit U_CONTROL_UNIT (.*);

    datapath U_DATAPATH (.*);

endmodule

module control_unit (
    input        clk,
    input        rst,
    input        ile10,
    output logic isrcsel,
    output logic sumsrcsel,
    output logic iload,
    output logic sumload,
    output logic alusrcsel,
    output logic outload
);

    typedef enum logic [2:0] {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5
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
        n_state   = c_state;
        isrcsel   = 0;
        sumsrcsel = 0;
        iload     = 0;
        sumload   = 0;
        alusrcsel = 0;
        outload   = 0;

        case (c_state)
            S0: begin
                isrcsel   = 0;
                sumsrcsel = 0;
                iload     = 1;
                sumload   = 1;
                alusrcsel = 0;
                outload   = 0;
                n_state   = S1;
            end
            S1: begin
                isrcsel   = 0;
                sumsrcsel = 0;
                iload     = 0;
                sumload   = 0;
                alusrcsel = 0;
                outload   = 0;
                if (ile10 == 1) begin
                    n_state = S2;
                end else begin
                    n_state = S5;
                end
            end
            S2: begin
                isrcsel   = 0;
                sumsrcsel = 1;
                iload     = 0;
                sumload   = 1;
                alusrcsel = 0;
                outload   = 0;
                n_state   = S3;
            end
            S3: begin
                isrcsel   = 1;
                sumsrcsel = 0;
                iload     = 1;
                sumload   = 0;
                alusrcsel = 1;
                outload   = 0;
                n_state   = S4;
            end
            S4: begin
                isrcsel   = 0;
                sumsrcsel = 0;
                iload     = 0;
                sumload   = 0;
                alusrcsel = 0;
                outload   = 1;
                n_state   = S1;
            end
            S5: begin
                isrcsel   = 0;
                sumsrcsel = 0;
                iload     = 0;
                sumload   = 0;
                alusrcsel = 0;
                outload   = 0;
            end
        endcase
    end

endmodule

module datapath (
    input        clk,
    input        rst,
    input        isrcsel,
    input        sumsrcsel,
    input        iload,
    input        sumload,
    input        alusrcsel,
    input        outload,
    output       ile10,
    output [7:0] out
);

    logic [7:0]
        w_alu_out,
        w_imux_out,
        w_summux_out,
        w_ireg_out,
        w_sumreg_out,
        w_alumux_out;

    register_isum U_IREG (
        .clk         (clk),
        .rst         (rst),
        .load        (iload),
        .reg_in_data (w_imux_out),
        .reg_out_data(w_ireg_out)
    );


    mux_2x1 U_IMUX (
        .a      (0),          // 0
        .b      (w_alu_out),  // 1
        .mux_sel(isrcsel),
        .mux_out(w_imux_out)
    );

    register_isum U_SUMREG (
        .clk         (clk),
        .rst         (rst),
        .load        (sumload),
        .reg_in_data (w_summux_out),
        .reg_out_data(w_sumreg_out)
    );

    mux_2x1 U_SUMMUX (
        .a      (0),            // 0
        .b      (w_alu_out),    // 1
        .mux_sel(sumsrcsel),
        .mux_out(w_summux_out)
    );

    ilt10 U_ILT10 (
        .in_data(w_ireg_out),
        .ile10  (ile10)
    );

    alu U_ALU (
        .a      (w_ireg_out),
        .b      (w_alumux_out),
        .alu_out(w_alu_out)
    );

    mux_2x1 U_ALUMUX (
        .a      (w_sumreg_out),  // 0
        .b      (8'h1),          // 1
        .mux_sel(alusrcsel),
        .mux_out(w_alumux_out)
    );

    register_isum U_OUTREG (
        .clk         (clk),
        .rst         (rst),
        .load        (outload),
        .reg_in_data (w_sumreg_out),
        .reg_out_data(out)
    );

endmodule

module register_isum (
    input              clk,
    input              rst,
    input              load,
    input        [7:0] reg_in_data,
    output logic [7:0] reg_out_data
);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            reg_out_data <= 0;
        end else begin
            if (load) begin
                reg_out_data <= reg_in_data;
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
    input        mux_sel,
    output [7:0] mux_out
);

    assign mux_out = (mux_sel) ? b : a;

endmodule

module ilt10 (
    input  [7:0] in_data,
    output       ile10
);

    assign ile10 = (in_data <= 10);

endmodule
